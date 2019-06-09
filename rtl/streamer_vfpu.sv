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

//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

//======================================================//
//                ADDER LOGIC                           //
//======================================================//

assign operand_streams_sink[0].ready = result_stream_source.ready;
assign operand_streams_sink[1].ready = result_stream_source.ready;
assign result_stream_source.valid = operand_streams_sink[0].valid & operand_streams_sink[1].valid;
assign result_stream_source.data = (ctrl_vfpu_i.operation == 0) ? operand_streams_sink[0].data + operand_streams_sink[1].data : operand_streams_sink[0].data - operand_streams_sink[1].data;
assign result_stream_source.strb = operand_streams_sink[0].strb & operand_streams_sink[1].strb;

endmodule
