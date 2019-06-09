`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;
import hwpe_ctrl_vfpu_package::*;

module vfpu_add
(
  input  logic                      clk_i,
  input  logic                      rst_ni,

  input  fp_t                       operandA_i,
  input  fp_t                       operandB_i,
  output fp_t                       result_o,
  
  input ctrl_vfpu_t                 ctrl_vfpu_i,
  
  output logic                      ready_o,
  output logic                      done_o
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//

//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

//======================================================//
//                ADDER LOGIC                           //
//======================================================//

endmodule