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
  input logic [FP_MANT_WIDTH-1+1:0]                 mantissaA_i, // +1 because of implied bit
  input logic [FP_MANT_WIDTH-1+1:0]                 mantissaB_i, // +1 because of implied bit

  // resiult
  output logic                                      signPreNorm_o,
  output logic signed [FP_EXP_PRENORM_WIDTH-1:0]    exponentPreNorm_o,
  output logic [FP_MANT_PRENORM_WIDTH-1:0]          mantissaPreNorm_o,
  
  input logic                                       operandsReady_i,
  output logic                                      done_o
);

//======================================================//
//           EXPONENT COMPARISON AND DIFFERENCE         //
//======================================================//
   logic                        signNorm;
   logic                        exponentA_gt_exponentB;
   logic                        exponents_equal;
   logic [FP_EXP_WIDTH-1:0]     exponent_diff;
   logic [FP_EXP_WIDTH-1:0]     greaterExponent;

   assign exponentA_gt_exponentB  = exponentA_i > exponentB_i;
   assign exponents_equal = exponent_diff == 0;

   always_comb
     begin
        if (exponentA_gt_exponentB)
          begin
             exponent_diff   = exponentA_i - exponentB_i;
             greaterExponent = exponentA_i;
          end
        else
          begin
             exponent_diff   = exponentB_i - exponentA_i;
             greaterExponent = exponentB_i;
          end
     end // always_comb

//======================================================//
//     MANTISSA SHIFTING AND ADDITION/SUBTRACTION       //
//======================================================//

   // shifter related signals
   logic                           mantissaA_gt_mantissaB;
   logic [MANT_SHIFTIN_WIDTH-1:0]  smallerMantissa;
   logic [MANT_SHIFTED_WIDTH-1:0]  shiftedMantissa;
   logic                           mantissaStickyBit;
   logic [MANT_SHIFTED_WIDTH-1:0]  biggerMantissa;

   // adder related signals
   logic [MANT_ADDIN_WIDTH-1:0]    adderInputA;
   logic [MANT_ADDIN_WIDTH-1:0]    adderInputB;
   logic [MANT_ADDOUT_WIDTH-1:0]   adderOutput;

   logic [FP_MANT_PRENORM_WIDTH-1:0] addedMantissa;

   // 2's complement for subtraction
   logic        adderCarryIn;
   logic        invertMantissaA;
   logic        invertMantissaB;

   logic        areSignsDifferent;

   // shift the number with the smaller exponent to the right
   assign mantissaA_gt_mantissaB    = mantissaA_i > mantissaB_i;
   assign biggerMantissa            = {(exponentA_gt_exponentB ? mantissaA_i : mantissaB_i), 3'b0};
   assign smallerMantissa           = {(exponentA_gt_exponentB ? mantissaB_i : mantissaA_i), 2'b0};


   always_comb // sticky bit calculation
     begin
        mantissaStickyBit = 1'b0;
        if (exponent_diff >= (FP_MANT_WIDTH+3)) // 23 bits, + guard, round, sticky
          mantissaStickyBit = | smallerMantissa;
        else
          mantissaStickyBit = | (smallerMantissa << ((FP_MANT_WIDTH+3) - exponent_diff));
     end
     
   // right shift mantissa of smaller operand
   assign shiftedMantissa = {(smallerMantissa >> exponent_diff), mantissaStickyBit};

//======================================================//
//           INVERTING MANTISSA FOR SUBTRACTION         //
//======================================================//

   always_comb
     begin
        invertMantissaA = '0;
        invertMantissaB = '0;
        if (areSignsDifferent)
          begin
             if (exponentA_gt_exponentB)
               invertMantissaA = 1'b1;
             else if (exponents_equal)
               begin
                 if (mantissaA_gt_mantissaB)
                   invertMantissaB = 1'b1;
                 else
                   invertMantissaA = 1'b1;
               end
             else
               invertMantissaA = 1'b1;
          end // if (areSignsDifferent)
     end // always_comb begin

   assign adderCarryIn = areSignsDifferent;
   assign adderInputA      = (invertMantissaA) ? ~shiftedMantissa   : shiftedMantissa;
   assign adderInputB      = (invertMantissaB) ? ~biggerMantissa : biggerMantissa;

   assign adderOutput      = adderInputA + adderInputB + adderCarryIn;

   assign addedMantissa    = {(adderOutput[MANT_ADDOUT_WIDTH-1] & ~areSignsDifferent), adderOutput[MANT_ADDOUT_WIDTH-2:0], 20'b0};

//======================================================//
//                    CALCULATE SIGN                    //
//======================================================//

   assign areSignsDifferent = signA_i ^ signB_i;

   always_comb
     begin
        signNorm = 1'b0;
        if (exponentA_gt_exponentB)
          signNorm = signA_i;
        else if (exponents_equal)
          begin
             if (mantissaA_gt_mantissaB)
               signNorm = signA_i;
             else
               signNorm = signB_i;
          end
        else
          signNorm = signB_i;
     end

//======================================================//
//                     OUTPUT ASSIGNMENTS               //
//======================================================//

   assign signPreNorm_o         = signNorm;
   assign exponentPreNorm_o     = signed'({2'b0, greaterExponent});
   assign mantissaPreNorm_o     = addedMantissa;
   
   assign done_o                = operandsReady_i;

endmodule
