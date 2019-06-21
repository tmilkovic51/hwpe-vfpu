`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;
import hwpe_ctrl_vfpu_package::*;

module vfpu_add
(
  input  logic                                      clk_i,
  input  logic                                      rst_ni,

  // operands
  input logic                                       signA_i,
  input logic                                       signB_i,
  input logic [FP_EXP_WIDTH-1:0]                    exponentA_i,
  input logic [FP_EXP_WIDTH-1:0]                    exponentB_i,
  input logic [FP_MANT_WIDTH-1+1:0]                 mantissaA_i, // +1 because of hidden one
  input logic [FP_MANT_WIDTH-1+1:0]                 mantissaB_i, // +1 because of hidden one

  // resiult
  output logic                                      signPreNorm_o,
  output logic signed [FP_EXP_PRENORM_WIDTH-1:0]    exponentPreNorm_o,
  output logic [FP_MANT_PRENORM_WIDTH-1:0]          mantissaPreNorm_o,
  
  input logic                                       operandsReady_i,
  output logic                                      done_o
);

//======================================================//
//                         SIGNALS                      //
//======================================================//
   logic                        signNorm;
   logic                        exponentA_gt_exponentB;
   logic                        exponents_equal;
   logic [FP_EXP_WIDTH-1:0]     exponent_diff;
   logic [FP_EXP_WIDTH-1:0]     exponentPreNorm;

   assign exponentA_gt_exponentB  = exponentA_i > exponentB_i;
   assign exponents_equal = exponent_diff == 0;

   always_comb
     begin
        if (exponentA_gt_exponentB)
          begin
             exponent_diff   = exponentA_i - exponentB_i;
             exponentPreNorm = exponentA_i;
          end
        else
          begin
             exponent_diff   = exponentB_i - exponentA_i;
             exponentPreNorm = exponentB_i;
          end
     end // always_comb

   /////////////////////////////////////////////////////////////////////////////
   // Mantissa operations
   /////////////////////////////////////////////////////////////////////////////

   logic                            Mant_agtb_S;
   logic [MANT_SHIFTIN_WIDTH-1:0]  Mant_shiftIn_D;
   logic [MANT_SHIFTED_WIDTH-1:0]  Mant_shifted_D;
   logic                            Mant_sticky_D;
   logic [MANT_SHIFTED_WIDTH-1:0]  Mant_unshifted_D;

   //Main Adder
   logic [MANT_ADDIN_WIDTH-1:0]   Mant_addInA_D;
   logic [MANT_ADDIN_WIDTH-1:0]   Mant_addInB_D;
   logic [MANT_ADDOUT_WIDTH-1:0]  Mant_addOut_D;

   logic [FP_MANT_PRENORM_WIDTH-1:0] Mant_prenorm_D;

   //Inversion and carry for Subtraction
   logic        Mant_addCarryIn_D;
   logic        Mant_invA_S;
   logic        Mant_invB_S;

   logic        Subtract_S;

   //Shift the number with the smaller exponent to the right
   assign Mant_agtb_S      = mantissaA_i > mantissaB_i;
   assign Mant_unshifted_D = {(exponentA_gt_exponentB ? mantissaA_i : mantissaB_i), 3'b0};
   assign Mant_shiftIn_D   = {(exponentA_gt_exponentB ? mantissaB_i : mantissaA_i), 2'b0};


   always_comb //sticky bit
     begin
        Mant_sticky_D = 1'b0;
        if (exponent_diff >= (FP_MANT_WIDTH+3)) // 23 + guard, round, sticky
          Mant_sticky_D = | Mant_shiftIn_D;
        else
          Mant_sticky_D = | (Mant_shiftIn_D << ((FP_MANT_WIDTH+3) - exponent_diff));
     end
   assign Mant_shifted_D = {(Mant_shiftIn_D >> exponent_diff), Mant_sticky_D};

   always_comb
     begin
        Mant_invA_S = '0;
        Mant_invB_S = '0;
        if (Subtract_S)
          begin
             if (exponentA_gt_exponentB)
               Mant_invA_S = 1'b1;
             else if (exponents_equal)
               begin
                 if (Mant_agtb_S)
                   Mant_invB_S = 1'b1;
                 else
                   Mant_invA_S = 1'b1;
               end
             else
               Mant_invA_S = 1'b1;
          end // if (Subtract_S)
     end // always_comb begin

   assign Mant_addCarryIn_D = Subtract_S;
   assign Mant_addInA_D     = (Mant_invA_S) ? ~Mant_shifted_D   : Mant_shifted_D;
   assign Mant_addInB_D     = (Mant_invB_S) ? ~Mant_unshifted_D : Mant_unshifted_D;

   assign Mant_addOut_D     = Mant_addInA_D + Mant_addInB_D + Mant_addCarryIn_D;

   assign Mant_prenorm_D    = {(Mant_addOut_D[MANT_ADDOUT_WIDTH-1] & ~Subtract_S), Mant_addOut_D[MANT_ADDOUT_WIDTH-2:0], 20'b0};

   /////////////////////////////////////////////////////////////////////////////
   // Sign operations
   /////////////////////////////////////////////////////////////////////////////

   assign Subtract_S = signA_i ^ signB_i;

   always_comb
     begin
        signNorm = 1'b0;
        if (exponentA_gt_exponentB)
          signNorm = signA_i;
        else if (exponents_equal)
          begin
             if (Mant_agtb_S)
               signNorm = signA_i;
             else
               signNorm = signB_i;
          end
        else //Exp_a < Exp_b
          signNorm = signB_i;
     end

   /////////////////////////////////////////////////////////////////////////////
   // Output Assignments
   /////////////////////////////////////////////////////////////////////////////

   assign signPreNorm_o = signNorm;
   assign exponentPreNorm_o  = signed'({2'b0, exponentPreNorm});
   assign mantissaPreNorm_o = Mant_prenorm_D;
   
   assign done_o = operandsReady_i;

endmodule
