`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;
import hwpe_ctrl_vfpu_package::*;

module vfpu
(
  input  logic                      clk_i,
  input  logic                      rst_ni,

  input  fp_t                       operandA_i,
  input  fp_t                       operandB_i,
  output fp_t                       result_o,
  
  input ctrl_vfpu_t                 ctrl_vfpu_i,
  output flags_vfpu_t               flags_vfpu_o,
  input logic                       operands_valid_i,
  
  output logic                      ready_o,
  output logic                      done_o
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//
fp_t operandA_reg;
fp_t operandB_reg;
logic valid_reg;

// operand components
logic                       signA;
logic                       signB;
logic [FP_EXP_WIDTH-1:0]    exponentA;
logic [FP_EXP_WIDTH-1:0]    exponentB;
logic                       impliedBitA;
logic                       impliedBitB;
logic [FP_MANT_WIDTH-1+1:0] mantissaA; // +1 because of concatenation with implied bit
logic [FP_MANT_WIDTH-1+1:0] mantissaB; // +1 because of concatenation with implied bit

// output result
fp_t result;

//======================================================//
//          ASSIGNMENTS AND INPUT FLIP-FLOP             //
//======================================================//
// VFPU is always ready (pipeline can take new operands every cycle)
assign ready_o = 1'b1;

// latch operands and valid signal
always_ff @(posedge clk_i, negedge rst_ni)
  begin
    if (rst_ni == 1'b0) begin
      operandA_reg   <= '0;
      operandB_reg   <= '0;
      valid_reg      <= '0;
    end
    else begin
      operandA_reg   <= operandA_i;
      operandB_reg   <= operandB_i;
      valid_reg      <= operands_valid_i;
   end
end

// break operands into components
assign signA = operandA_reg.sign;
assign signB = (ctrl_vfpu_i.operation == FP_OP_SUB) ? ~operandB_reg.sign : operandB_reg.sign; // invert sign of B operand if operation is subtraction
assign exponentA  = operandA_reg.exponent;
assign exponentB  = operandB_reg.exponent;
assign impliedBitA = | operandA_reg.exponent; // calculate implied bit
assign impliedBitB = | operandB_reg.exponent;
assign mantissaA = {impliedBitA, operandA_reg.mantissa}; // concatenate implied bit with mantissa
assign mantissaB = {impliedBitB, operandB_reg.mantissa};

//======================================================//
//                        FP ADDER                      //
//======================================================//
logic                                   signAdderPreNorm;
logic signed [FP_EXP_PRENORM_WIDTH-1:0] exponentAdderPreNorm;
logic [FP_MANT_PRENORM_WIDTH-1:0]       mantissaAdderPreNorm;
logic                                   adderDone;

vfpu_add adder (
  .clk_i(clk_i),
  .rst_ni(rst_ni),
  
  // operands
  .signA_i(signA),
  .signB_i(signB),
  .exponentA_i(exponentA),
  .exponentB_i(exponentB),
  .mantissaA_i(mantissaA),
  .mantissaB_i(mantissaB),
  
  // result
  .signPreNorm_o(signAdderPreNorm),
  .exponentPreNorm_o(exponentAdderPreNorm),
  .mantissaPreNorm_o(mantissaAdderPreNorm),
  
  .operandsReady_i(valid_reg),
  .done_o(adderDone)
);

//======================================================//
//                    FP_MULTIPLIER                     //
//======================================================//
logic                                   signMultPreNorm;
logic signed [FP_EXP_PRENORM_WIDTH-1:0] exponentMultPreNorm;
logic [FP_MANT_PRENORM_WIDTH-1:0]       mantissaMultPreNorm;
logic                                   multDone;

vfpu_mult multiplier (
  .clk_i(clk_i),
  .rst_ni(rst_ni),
  
  // operands
  .signA_i(signA),
  .signB_i(signB),
  .exponentA_i(exponentA),
  .exponentB_i(exponentB),
  .mantissaA_i(mantissaA),
  .mantissaB_i(mantissaB),
  
  // result
  .signPreNorm_o(signMultPreNorm),
  .exponentPreNorm_o(exponentMultPreNorm),
  .mantissaPreNorm_o(mantissaMultPreNorm),
  
  .operandsReady_i(valid_reg),
  .done_o(multDone)
);

//======================================================//
//                    FP NORMALIZER                     //
//======================================================//
// result components before normalization
logic                                       signPreNorm;
logic signed [FP_EXP_PRENORM_WIDTH-1:0]     exponentPreNorm;
logic [FP_MANT_PRENORM_WIDTH-1:0]           mantissaPreNorm;

// result components after normalization
logic                                       signPostNorm;
logic [FP_EXP_WIDTH-1:0]                    exponentPostNorm;
logic [FP_MANT_WIDTH-1+1:0]                 mantissaPostNorm; // +1 because of hidden one

// result components after normalization (registered)
logic                                       signPostNorm_reg;
logic [FP_EXP_WIDTH-1:0]                    exponentPostNorm_reg;
logic [FP_MANT_WIDTH-1+1:0]                 mantissaPostNorm_reg; // +1 because of hidden one
logic                                       normOperandReady_reg;

// flags
logic                                       normOperandReady;
logic                                       normDone;

// normalizer input MUX
always_comb
  begin
    signPreNorm = '0;
    exponentPreNorm = '0;
    mantissaPreNorm = '0;
    normOperandReady = '0;
    case (ctrl_vfpu_i.operation)
      FP_OP_ADD, FP_OP_SUB:
      begin
        signPreNorm = signAdderPreNorm;
        exponentPreNorm = exponentAdderPreNorm;
        mantissaPreNorm = mantissaAdderPreNorm;
        normOperandReady = adderDone;
      end
      FP_OP_MUL:
      begin
        signPreNorm = signMultPreNorm;
        exponentPreNorm = exponentMultPreNorm;
        mantissaPreNorm = mantissaMultPreNorm;
        normOperandReady = multDone;
      end
    endcase // case (ctrl_vfpu_i.operation)
end // always_comb begin

// latch normalizer operand and valid signal
always_ff @(posedge clk_i, negedge rst_ni)
  begin
    if (rst_ni == 1'b0) begin
      signPreNorm_reg       <= '0;
      exponentPreNorm_reg   <= '0;
      mantissaPreNorm_reg   <= '0;
      normOperandReady_reg  <= '0;
    end
    else begin
      signPreNorm_reg       <= signPreNorm;
      exponentPreNorm_reg   <= exponentPreNorm;
      mantissaPreNorm_reg   <= mantissaPreNorm;
      normOperandReady_reg  <= normOperandReady;
   end
end

// normalizer instantiation
vfpu_norm normalizer (
  .clk_i(clk_i),
  .rst_ni(rst_ni),
  
  .ctrl_vfpu_i(ctrl_vfpu_i),
  
  // operand
  .signPreNorm_i(signPreNorm_reg),
  .exponentPreNorm_i(exponentPreNorm_reg),
  .mantissaPreNorm_i(mantissaPreNorm_reg),
  
  // result
  .signPostNorm_o(signPostNorm),
  .exponentPostNorm_o(exponentPostNorm),
  .mantissaPostNorm_o(mantissaPostNorm),
  
  .operandReady_i(normOperandReady_reg),
  .done_o(normDone)
);

//======================================================//
//                    RESULT ASSIGNMENTS                //
//======================================================//
assign result_o.sign = signPostNorm;
assign result_o.exponent = exponentPostNorm;
assign result_o.mantissa = mantissaPostNorm[FP_MANT_WIDTH-1:0]; // remove leading implied one bit
assign done_o = normDone;

/*
assign result_o.sign = (Zero_S && (OP_SP != C_FPU_MUL_CMD)) ? 1'b0 : signPostNorm;
always_comb
  begin
    Exp_res_D = Exp_norm_D;
    if (Exp_toZero_S)
      Exp_res_D = C_EXP_ZERO;
    else if (Exp_toInf_S)
      Exp_res_D = C_EXP_INF;
    end
   assign Mant_res_D = Mant_toZero_S ? C_MANT_ZERO : Mant_norm_D;

   assign Result_D = IV_S ? F_QNAN : ((OP_SP == C_FPU_F2I_CMD) ? Result_ftoi_D : {Sign_res_D, Exp_res_D, Mant_res_D[C_MANT-1:0]});
*/

endmodule
