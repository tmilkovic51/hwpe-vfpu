`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;

module streamer_sink
#(
  parameter int unsigned DATA_WIDTH  = 32
  //parameter int unsigned NB_TCDM_PORTS  = DATA_WIDTH/32
)
(
  input  logic                      clk_i,
  input  logic                      rst_ni,
  input  logic                      clear_i,
  
  // TCDM master interface for storing
  hwpe_stream_intf_tcdm.master      tcdm_store_master,
  
  // HWPE-stream sink interface
  hwpe_stream_intf_stream.sink      sink_stream,
  
  // HWPE-stream sink control and flags
  input ctrl_sourcesink_t           sink_stream_ctrl_i,
  output flags_sourcesink_t         sink_stream_flags_o
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//
  
  hwpe_stream_intf_tcdm tcdm_internal_sink[1] (
    .clk ( clk_i )
  );

//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//
  
  // convert result from HWPE-stream to HWPE-mem
  hwpe_stream_sink #(
    .DATA_WIDTH (DATA_WIDTH),
    .NB_TCDM_PORTS (DATA_WIDTH/32),
    .USE_TCDM_FIFOS (1)
  ) stream_sink (
    .clk_i (clk_i),
    .rst_ni (rst_ni),
    .test_mode_i (1'b0),
    .clear_i (clear_i),

    .tcdm (tcdm_internal_sink),
    .stream (sink_stream),

    .ctrl_i (sink_stream_ctrl_i),
    .flags_o (sink_stream_flags_o)
);
  
  // store result to TCDM
  hwpe_stream_tcdm_fifo_store #(
    .FIFO_DEPTH (8),
    .LATCH_FIFO (0)
  ) tcdm_store (
    .clk_i (clk_i),
    .rst_ni (rst_ni),
    .clear_i (clear_i),
    .flags_o (), // FIFO flags not used
	
    .tcdm_slave (tcdm_internal_sink[0]),
    .tcdm_master (tcdm_store_master)
);

endmodule
