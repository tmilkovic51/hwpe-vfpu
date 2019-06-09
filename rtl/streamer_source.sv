`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;

module streamer_source
#(
  parameter int unsigned DATA_WIDTH  = 32,
  parameter int unsigned NB_OPERANDS = 2
  //parameter int unsigned NB_TCDM_PORTS  = DATA_WIDTH/32
)
(
  input  logic                      clk_i,
  input  logic                      rst_ni,
  input  logic                      clear_i,
  
  // TCDM master interface for loading
  hwpe_stream_intf_tcdm.master      tcdm_load_master[NB_OPERANDS],
  
  // HWPE-stream source interface
  hwpe_stream_intf_stream.source    source_stream[NB_OPERANDS],
  
  // HWPE-stream source control and flags
  input ctrl_sourcesink_t           source_stream_ctrl_i[NB_OPERANDS],
  output flags_sourcesink_t         source_stream_flags_o[NB_OPERANDS]
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//
  
  logic stream_source_fifo_ready[NB_OPERANDS];
  
  hwpe_stream_intf_tcdm tcdm_internal_source[NB_OPERANDS][1] (
    .clk ( clk_i )
  );
  
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(DATA_WIDTH)
  ) operands[NB_OPERANDS] (
    .clk ( clk_i )
  );

//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

  for(genvar i = 0; i < NB_OPERANDS; i++) begin
  
    // load operands from TCDM
    hwpe_stream_tcdm_fifo_load #(
      .FIFO_DEPTH (8),
      .LATCH_FIFO (0)
    ) tcdm_load (
      .clk_i (clk_i),
      .rst_ni (rst_ni),
      .clear_i (clear_i),
      .flags_o (), // FIFO flags not used
      .ready_i (stream_source_fifo_ready[i]),
      
      .tcdm_slave (tcdm_internal_source[i][0]),
      .tcdm_master (tcdm_load_master[i])
    );

    // convert operands from HWPE-mem to HWPE-stream
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

  // fence operands
  hwpe_stream_fence #(
      .NB_STREAMS(NB_OPERANDS),
      .DATA_WIDTH(DATA_WIDTH)
  ) stream_fence (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .clear_i(clear_i),
    .test_mode_i(1'b0),

    .push_i(operands),
    .pop_o(source_stream)
  );

endmodule
