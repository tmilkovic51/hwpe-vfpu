`timescale 1ns / 1ps

`ifndef HWPE_NB_OPERANDS
`define HWPE_NB_OPERANDS 2
`endif

`ifndef HWPE_NB_RESULTS
`define HWPE_NB_RESULTS 1
`endif

`ifndef HWPE_NB_TCDM_PORTS
`define HWPE_NB_TCDM_PORTS (`HWPE_NB_OPERANDS + `HWPE_NB_RESULTS)
`endif

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;

module hwpe_top
#(
  parameter int unsigned N_CORES = 2,
  parameter int unsigned ID_WIDTH = 16,
  parameter int unsigned DATA_WIDTH = 32
)
(
  input  logic                  clk,
  input  logic                  rst_n,

  output logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt,
  
  hwpe_stream_intf_tcdm.master  tcdm[`HWPE_NB_TCDM_PORTS],

  hwpe_ctrl_intf_periph.slave   slave_config_interface
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//
  logic clear;
  logic operation;
  flags_sourcesink_t source_stream_flags[`HWPE_NB_OPERANDS];
  ctrl_sourcesink_t source_stream_ctrl[`HWPE_NB_OPERANDS];
  flags_sourcesink_t sink_stream_flags;
  ctrl_sourcesink_t sink_stream_ctrl;
  flags_slave_t control_flags;
  
//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

  streamer #(
    .DATA_WIDTH(DATA_WIDTH),
    .NB_OPERANDS(`HWPE_NB_OPERANDS)
  ) streamer_inst (
    .clk_i(clk),
    .rst_ni(rst_n),
    .clear_i(clear),
    .operation_i(operation),
    
    .tcdm_master_load(tcdm[0:1]),
    .tcdm_master_store(tcdm[2]),
    
    .load_fifo_flags_o(),
    .source_stream_ctrl_i(source_stream_ctrl),
    .source_stream_flags_o(source_stream_flags),
    .sink_stream_ctrl_i(sink_stream_ctrl),
    .sink_stream_flags_o(sink_stream_flags),
    .store_fifo_flags_o()
  );

  control #(
    .DATA_WIDTH(DATA_WIDTH),
    .NB_OPERANDS(`HWPE_NB_OPERANDS),
    .ID_WIDTH(ID_WIDTH),
    .N_CORES(N_CORES),
    .N_CONTEXT(2)
  ) control_inst (
    .clk_i(clk),
    .rst_ni(rst_n),
    .clear_o(clear),
    .operation_o(operation),
    
    .source_stream_ctrl_o(source_stream_ctrl),
    .source_stream_flags_i(source_stream_flags),
    
    .sink_stream_ctrl_o(sink_stream_ctrl),
    .sink_stream_flags_i(sink_stream_flags),
    
    .ctrl_flags_o(control_flags),
    
    .slave_config_interface(slave_config_interface)
  );
  
  assign evt = control_flags.evt[N_CORES-1:0];

endmodule
