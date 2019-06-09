`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;
import hwpe_ctrl_vfpu_package::*;

module streamer_vfpu
#(
  parameter int unsigned DATA_WIDTH  = 32,
  parameter int unsigned NB_OPERANDS = 2
)
(
  input  logic                      clk_i,
  input  logic                      rst_ni,
  input  logic                      clear_i,
  
  // HWPE-stream sink interface for loading operands
  hwpe_stream_intf_stream.sink      operand_streams_sink[NB_OPERANDS],
  
  // HWPE-stream source interface for storing result
  hwpe_stream_intf_stream.source    result_stream_source,
  
  // VFPU control and flags
  input  ctrl_vfpu_t                ctrl_vfpu_i,
  input  flags_vfpu_t               flags_vfpu_o
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//

  fp_t operandA;
  fp_t operandB;
  fp_t result;
  
  logic vfpu_ready;
  logic result_valid;
  logic operands_valid;

//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

  vfpu (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    
    .operandA_i(operandA),
    .operandB_i(operandB),
    .result_o(result),
    
    .ctrl_vfpu_i(ctrl_vfpu_i),
    .flags_vfpu_o(flags_vfpu_o),
    
    .operands_valid_i(operands_valid),
    .ready_o(vfpu_ready),
    .done_o(result_valid)
);

//======================================================//
//                ADDER LOGIC                           //
//======================================================//

  assign operands_valid = operand_streams_sink[0].valid & operand_streams_sink[1].valid;

  assign operand_streams_sink[0].ready = vfpu_ready;
  assign operand_streams_sink[1].ready = vfpu_ready;

  assign operandA.sign     = operand_streams_sink[0].data[FP_WIDTH-1];
  assign operandA.exponent = operand_streams_sink[0].data[FP_WIDTH-FP_SIGN_WIDTH-1:FP_WIDTH-FP_SIGN_WIDTH-FP_EXP_WIDTH];
  assign operandA.mantissa = operand_streams_sink[0].data[FP_WIDTH-FP_SIGN_WIDTH-FP_EXP_WIDTH-1:0];
  
  assign operandB.sign     = operand_streams_sink[1].data[FP_WIDTH-1];
  assign operandB.exponent = operand_streams_sink[1].data[FP_WIDTH-FP_SIGN_WIDTH-1:FP_WIDTH-FP_SIGN_WIDTH-FP_EXP_WIDTH];
  assign operandB.mantissa = operand_streams_sink[1].data[FP_WIDTH-FP_SIGN_WIDTH-FP_EXP_WIDTH-1:0];
  
  assign result_stream_source.data[FP_WIDTH-1] = result.sign;
  assign result_stream_source.data[FP_WIDTH-FP_SIGN_WIDTH-1:FP_WIDTH-FP_SIGN_WIDTH-FP_EXP_WIDTH] = result.exponent;
  assign result_stream_source.data[FP_WIDTH-FP_SIGN_WIDTH-FP_EXP_WIDTH-1:0] = result.mantissa;
  assign result_stream_source.valid = result_valid;
  assign result_stream_source.strb = 4'b1111;

endmodule
