`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;

module streamer
#(
  parameter int unsigned DATA_WIDTH  = 32,
  parameter int unsigned NB_OPERANDS = 2
  //parameter int unsigned NB_TCDM_PORTS  = DATA_WIDTH/32
)
(
  input  logic                  clk_i,
  input  logic                  rst_ni,
  input  logic                  clear_i,
  
  hwpe_stream_intf_tcdm.master  tcdm_master_load[NB_OPERANDS],
  hwpe_stream_intf_tcdm.master  tcdm_master_store,
  
  output flags_fifo_t           load_fifo_flags_o[NB_OPERANDS],
  
  input ctrl_sourcesink_t       source_stream_ctrl_i[NB_OPERANDS],
  output flags_sourcesink_t     source_stream_flags_o[NB_OPERANDS],
  
  input ctrl_sourcesink_t       sink_stream_ctrl_i,
  output flags_sourcesink_t     sink_stream_flags_o,
  
  output flags_fifo_t           store_fifo_flags_o
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//
  
  logic stream_source_fifo_ready[NB_OPERANDS];
  
  hwpe_stream_intf_tcdm tcdm_internal_source[NB_OPERANDS][0:0] (
    .clk ( clk_i )
  );
  
  hwpe_stream_intf_tcdm tcdm_internal_sink[0:0] (
    .clk ( clk_i )
  );
  
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(DATA_WIDTH)
  ) operands[NB_OPERANDS] (
    .clk ( clk_i )
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH(DATA_WIDTH)
  ) operands_fenced[NB_OPERANDS] (
    .clk ( clk_i )
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH(DATA_WIDTH)
  ) result (
    .clk ( clk_i )
  );

//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

// HWPE STREAM
  genvar i;
  for(i = 0; i < NB_OPERANDS; i++) begin
    hwpe_stream_tcdm_fifo_load #(
      .FIFO_DEPTH (8),
      .LATCH_FIFO (0)
    ) tcdm_load (
      .clk_i (clk_i),
      .rst_ni (rst_ni),
      .clear_i (clear_i),
      .flags_o (load_fifo_flags_o[i]),
      .ready_i (stream_source_fifo_ready[i]),
      
      .tcdm_slave (tcdm_internal_source[i][0]),
      .tcdm_master (tcdm_master_load[i])
    );

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
      
      .tcdm (tcdm_internal_source[i]),
      .stream (operands[i]),
      
      .tcdm_fifo_ready_o (stream_source_fifo_ready[i]),
      .ctrl_i (source_stream_ctrl_i[i]),
      .flags_o (source_stream_flags_o[i])
    );
  end

  hwpe_stream_fence #(
      .NB_STREAMS(NB_OPERANDS),
      .DATA_WIDTH(DATA_WIDTH)
  ) stream_fence (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .clear_i(clear_i),
    .test_mode_i(1'b0),

    .push_i(operands),
    .pop_o(operands_fenced)
  );
  
  
// STREAM SINK
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
    .stream (result),

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

//======================================================//
//                ADDER LOGIC                           //
//======================================================//

assign result.valid = operands_fenced[0].valid;
assign result.ready = operands_fenced[0].ready;
assign result.data = operands_fenced[0].data + operands_fenced[1].data;
assign result.strb = operands_fenced[0].strb;

endmodule
