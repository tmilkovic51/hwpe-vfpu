`timescale 1ns / 1ps

`define NB_OPERANDS 2
`define NB_RESULTS 1
`define NB_TCDM_PORTS (`NB_OPERANDS + `NB_RESULTS)

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;

module top
#(
  parameter int unsigned N_CORES = 2,
  parameter int unsigned ID_WIDTH = 16,
  parameter int unsigned DATA_WIDTH = 32
)
(
  input  logic                  clk,
  input  logic                  rst_n,

  output logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt,
  
  hwpe_stream_intf_tcdm.master  tcdm[`NB_TCDM_PORTS-1:0],

  hwpe_ctrl_intf_periph.slave   slave_config_interface
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//
  logic clear;
  flags_sourcesink_t source_stream_flags[`NB_OPERANDS];
  ctrl_sourcesink_t source_stream_ctrl[`NB_OPERANDS];
  flags_sourcesink_t sink_stream_flags;
  ctrl_sourcesink_t sink_stream_ctrl;
  flags_slave_t control_flags;
  
//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

  streamer #(
    .DATA_WIDTH(32),
    .NB_OPERANDS(`NB_OPERANDS)
  ) streamer_inst (
    .clk_i(clk),
    .rst_ni(rst_n),
    .clear_i(clear),
    
    .tcdm_master_load(tcdm[1:0]),
    .tcdm_master_store(tcdm[2]),
    
    .load_fifo_flags_o(),
    .source_stream_ctrl_i(source_stream_ctrl),
    .source_stream_flags_o(source_stream_flags),
    .sink_stream_ctrl_i(sink_stream_ctrl),
    .sink_stream_flags_o(sink_stream_flags),
    .store_fifo_flags_o()
  );

  control #(
    .DATA_WIDTH(32),
    .NB_OPERANDS(`NB_OPERANDS),
    .ID_WIDTH(ID_WIDTH),
    .N_CORES(N_CORES),
    .N_CONTEXT(2)
  ) control_inst (
    .clk_i(clk),
    .rst_ni(rst_n),
    .clear_o(clear),
    
    .source_stream_ctrl_o(source_stream_ctrl),
    .source_stream_flags_i(source_stream_flags),
    
    .sink_stream_ctrl_o(sink_stream_ctrl),
    .sink_stream_flags_i(sink_stream_flags),
    
    .ctrl_flags_o(control_flags),
    
    .slave_config_interface(slave_config_interface)
  );
  
  assign evt = control_flags.evt[N_CORES-1:0];

endmodule
