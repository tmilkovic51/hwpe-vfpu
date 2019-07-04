`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;
import hwpe_ctrl_vfpu_package::*;

module vfpu_norm
(
  input  logic                              clk_i,
  input  logic                              rst_ni,
  
  input ctrl_vfpu_t                         ctrl_vfpu_i,
  output flags_vfpu_t                       flags_vfpu_o,

  // operand
  input logic                               signPreNorm_i,
  input logic [FP_EXP_PRENORM_WIDTH-1:0]    exponentPreNorm_i,
  input logic [FP_MANT_PRENORM_WIDTH-1:0]   mantissaPreNorm_i,

  // resiult
  output logic                              signPostNorm_o,
  output logic signed [FP_EXP_WIDTH-1:0]    exponentPostNorm_o,
  output logic [FP_MANT_WIDTH-1+1:0]        mantissaPostNorm_o,
  
  input logic                               operandReady_i,
  output logic                              done_o
);

//======================================================//
//               NORMALIZATION                          //
//======================================================//

   logic [C_MANT_PRENORM_IND-1:0]                leadingOneIndex;
   logic                                         isMantissaZero;
   logic [FP_MANT_WIDTH+4:0]                     Mant_norm_D;
   logic signed [FP_EXP_PRENORM_WIDTH-1:0]       Exp_norm_D;

   // trying out stuff for denormals
   logic signed [FP_EXP_PRENORM_WIDTH-1:0]       shiftAmount;
   logic signed [FP_EXP_PRENORM_WIDTH:0]         Mant_shAmt2_D;

   logic [FP_EXP_WIDTH-1:0]                      Exp_final_D;
   logic signed [FP_EXP_PRENORM_WIDTH-1:0]       Exp_rounded_D;

   // sticky bit
   logic                                  Mant_sticky_D;

   logic                                  Denormal_S;
   logic                                  Mant_renorm_S;

   // detect leading one
   vfpu_lod
   #(
     .WIDTH(FP_MANT_PRENORM_WIDTH))
   LOD
   (
     .in_i        ( mantissaPreNorm_i ),
     .first_one_o ( leadingOneIndex   ),
     .no_ones_o   ( isMantissaZero    )
   );


   logic                                 Denormals_shift_add_D;
   logic                                 Denormals_exp_add_D;
   assign Denormals_shift_add_D = ~isMantissaZero & (exponentPreNorm_i == C_EXP_ZERO) & ((ctrl_vfpu_i.operation != FP_OP_MUL) | (~mantissaPreNorm_i[FP_MANT_PRENORM_WIDTH-1] & ~mantissaPreNorm_i[FP_MANT_PRENORM_WIDTH-2]));
   assign Denormals_exp_add_D   =  mantissaPreNorm_i[FP_MANT_PRENORM_WIDTH-2] & (exponentPreNorm_i == C_EXP_ZERO) & ((ctrl_vfpu_i.operation == FP_OP_ADD) | (ctrl_vfpu_i.operation == FP_OP_SUB ));

   assign shiftAmount  = leadingOneIndex;

   // shift mantissa
   always_comb
     begin
        logic [FP_MANT_PRENORM_WIDTH+FP_MANT_WIDTH+4:0] temp;
        temp = ((FP_MANT_PRENORM_WIDTH+FP_MANT_WIDTH+4+1)'(mantissaPreNorm_i) << (shiftAmount) );
        Mant_norm_D = temp[FP_MANT_PRENORM_WIDTH+FP_MANT_WIDTH+4:FP_MANT_PRENORM_WIDTH];
     end

   always_comb
     begin
        Mant_sticky_D = 1'b0;
        if (shiftAmount <= 0)
          Mant_sticky_D = | mantissaPreNorm_i;
        else if (shiftAmount <= FP_MANT_PRENORM_WIDTH)
          Mant_sticky_D = | (mantissaPreNorm_i << (shiftAmount));
     end

   //adjust exponent
   assign Exp_norm_D = exponentPreNorm_i - (FP_EXP_PRENORM_WIDTH)'(signed'(leadingOneIndex)) + 1 + Denormals_exp_add_D;
   //Explanation of the +1 since I'll probably forget:
   //we get numbers in the format xx.x...
   //but to make things easier we interpret them as
   //x.xx... and adjust the exponent accordingly

   assign Exp_rounded_D = Exp_norm_D + Mant_renorm_S;
   assign Exp_final_D   = Exp_rounded_D[FP_EXP_WIDTH-1:0];

//======================================================//
//               OVERFLOW/UNDERFLOW                     //
//======================================================//

   always_comb //detect exponent over/underflow
     begin
        flags_vfpu_o.overflow = 1'b0;
        flags_vfpu_o.underflow = 1'b0;
        if (Exp_rounded_D >= signed'({2'b0,C_EXP_INF})) //overflow
          begin
             flags_vfpu_o.overflow = 1'b1;
          end
        else if (Exp_rounded_D <= signed'({2'b0,C_EXP_ZERO})) //underflow
          begin
             flags_vfpu_o.underflow = 1'b1;
          end
     end

//======================================================//
//                    ROUNDING                          //
//======================================================//

   logic [FP_MANT_WIDTH:0]   Mant_upper_D;
   logic [3:0]        Mant_lower_D;
   logic [FP_MANT_WIDTH+1:0] Mant_upperRounded_D;

   logic              Mant_roundUp_S;
   logic              Mant_rounded_S;

   assign Mant_lower_D = Mant_norm_D[3:0];
   assign Mant_upper_D = Mant_norm_D[FP_MANT_WIDTH+4:4];


   assign Mant_rounded_S = (|(Mant_lower_D)) | Mant_sticky_D;

   always_comb //determine whether to round up or not
     begin
        Mant_roundUp_S = 1'b0;
        case (ctrl_vfpu_i.rounding_mode)
          FP_RM_NEAREST :
            Mant_roundUp_S = Mant_lower_D[3] && (((| Mant_lower_D[2:0]) | Mant_sticky_D) || Mant_upper_D[0]);
          FP_RM_TRUNCATE :
            Mant_roundUp_S = 0;
          FP_RM_PLUS_INF :
            Mant_roundUp_S = Mant_rounded_S & ~signPreNorm_i;
          FP_RM_MINUS_INF:
            Mant_roundUp_S = Mant_rounded_S & signPreNorm_i;
          default     :
            Mant_roundUp_S = 0;
        endcase // case (RM_DI)
     end // always_comb begin

   assign Mant_upperRounded_D = Mant_upper_D + Mant_roundUp_S;
   assign Mant_renorm_S       = Mant_upperRounded_D[FP_MANT_WIDTH+1];

//======================================================//
//               OUTPUT ASSIGNMENTS                    //
//======================================================//
   assign signPostNorm_o = signPreNorm_i;
   assign exponentPostNorm_o  = Exp_final_D;
   assign mantissaPostNorm_o = Mant_upperRounded_D >> (Mant_renorm_S & ~Denormal_S);
   assign flags_vfpu_o.inexact  = Mant_rounded_S;
   
   assign done_o = operandReady_i;

endmodule