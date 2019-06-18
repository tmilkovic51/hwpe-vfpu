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
//                         LOGIC                        //
//======================================================//

assign signPreNorm_o = '0;
assign exponentPreNorm_o = '0;
assign mantissaPreNorm_o = '0;
assign done_o = '0;

endmodule
