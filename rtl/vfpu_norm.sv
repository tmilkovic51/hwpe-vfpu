`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;
import hwpe_ctrl_vfpu_package::*;

module vfpu_norm
(
  input  logic                              clk_i,
  input  logic                              rst_ni,
  
  input ctrl_vfpu_t                         ctrl_vfpu_i,

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
//                      LOGIC                           //
//======================================================//

assign signPostNorm_o = signPreNorm_i;
assign exponentPostNorm_o = exponentPreNorm_i[FP_EXP_WIDTH-1:0];
assign mantissaPostNorm_o = mantissaPreNorm_i[FP_MANT_PRENORM_WIDTH-1-1:FP_MANT_PRENORM_WIDTH-1-FP_MANT_WIDTH];
assign done_o = operandReady_i;

endmodule