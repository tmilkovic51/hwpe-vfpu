`timescale 1ns / 1ps

import hwpe_stream_package::*;

module hwpe_test
#(
  parameter int unsigned DATA_WIDTH     = 32,
  parameter int unsigned NB_TCDM_PORTS  = DATA_WIDTH/32
)
(
  input  logic                  clk_i,
  input  logic                  rst_ni,
  input  logic                  clear_i,
  
  hwpe_stream_intf_tcdm.master  tcdm_master_load,
  hwpe_stream_intf_tcdm.master  tcdm_master_store,
  
  output flags_fifo_t           load_fifo_flags_o,
  
  input ctrl_sourcesink_t       source_stream_ctrl_i,
  output flags_sourcesink_t     source_stream_flags_o,
  
  input ctrl_sourcesink_t       sink_stream_ctrl_i,
  output flags_sourcesink_t     sink_stream_flags_o,
  
  output flags_fifo_t           store_fifo_flags_o
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//
  
  logic                 stream_source_fifo_ready;
  
  hwpe_stream_intf_tcdm tcdm_internal_source [NB_TCDM_PORTS-1:0] (
    .clk ( clk_i )
  );
  
    hwpe_stream_intf_tcdm tcdm_internal_sink [NB_TCDM_PORTS-1:0] (
    .clk ( clk_i )
  );
  
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(DATA_WIDTH)
  ) operand_stream (
    .clk ( clk_i )
  );

//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

// TCDM LOAD
  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH (8),
    .LATCH_FIFO (0)
  ) tcdm_load (
    .clk_i (clk_i),
    .rst_ni (rst_ni),
    .clear_i (clear_i),
    .flags_o (load_fifo_flags_o),
    .ready_i (stream_source_fifo_ready),

    .tcdm_slave (tcdm_internal_source[0]),
    .tcdm_master (tcdm_master_load)
  );

// STREAM SOURCE
  hwpe_stream_source #(
    .DATA_WIDTH(DATA_WIDTH),
    .NB_TCDM_PORTS (DATA_WIDTH/32),
    .DECOUPLED (1),
    .LATCH_FIFO (0),
    .TRANS_CNT (16)
  ) stream_source (
    .clk_i (clk_i),
    .rst_ni (rst_ni),
    .test_mode_i (1'b0),
    .clear_i (clear_i),
	
    .tcdm (tcdm_internal_source),
    .stream (operand_stream),
	
    .tcdm_fifo_ready_o (stream_source_fifo_ready),
    .ctrl_i (source_stream_ctrl_i),
    .flags_o (source_stream_flags_o)
  );
  
// STREAM SINK
  hwpe_stream_sink
 #(
    .DATA_WIDTH (DATA_WIDTH),
    .NB_TCDM_PORTS (DATA_WIDTH/32),
    .USE_TCDM_FIFOS (1)
  ) stream_sink (
    .clk_i (clk_i),
    .rst_ni (rst_ni),
    .test_mode_i (1'b0),
    .clear_i (clear_i),

    .tcdm (tcdm_internal_sink),
    .stream (operand_stream),

    .ctrl_i (sink_stream_ctrl_i),
    .flags_o (sink_stream_flags_o)
);
  
  
  hwpe_stream_tcdm_fifo_store #(
    .FIFO_DEPTH (8),
    .LATCH_FIFO (0)
  ) tcdm_store (
    .clk_i (clk_i),
    .rst_ni (rst_ni),
    .clear_i (clear_i),
    .flags_o (store_fifo_flags_o),
	
    .tcdm_slave (tcdm_internal_sink[0]),
    .tcdm_master (tcdm_master_store)
);

endmodule
