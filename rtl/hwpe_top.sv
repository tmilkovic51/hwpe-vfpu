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
import hwpe_ctrl_vfpu_package::*;

module hwpe_top
#(
  parameter int unsigned N_CORES = 2,
  parameter int unsigned ID_WIDTH = 16,
  parameter int unsigned DATA_WIDTH = 32
)
(
  input  logic                                  clk_i,
  input  logic                                  rst_ni,

  output logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt_o,
  
  hwpe_stream_intf_tcdm.master                  tcdm[`HWPE_NB_TCDM_PORTS],

  hwpe_ctrl_intf_periph.slave                   slave_config_interface
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//

  // SIGNALS
  // control module clear signal
  logic clear;
  
  // control module flags
  flags_slave_t control_flags;
  
  // source stream flags and control signals
  flags_sourcesink_t source_stream_flags[`HWPE_NB_OPERANDS];
  ctrl_sourcesink_t source_stream_ctrl[`HWPE_NB_OPERANDS];
  
  // VFPU module flags and control signals
  flags_vfpu_t flags_vfpu;
  ctrl_vfpu_t  ctrl_vfpu;
  
  // sink stream flags and control signals
  flags_sourcesink_t sink_stream_flags;
  ctrl_sourcesink_t sink_stream_ctrl;
  
  
  // INTERFACES
  // operands stream
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(DATA_WIDTH)
  ) operands[`HWPE_NB_OPERANDS] (
    .clk(clk_i)
  );
  
  // result stream
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(DATA_WIDTH)
  ) result (
    .clk(clk_i)
  );
  
//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

  streamer_source #(
    .DATA_WIDTH(DATA_WIDTH),
    .NB_OPERANDS(`HWPE_NB_OPERANDS)
  ) streamer_source_inst (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .clear_i(clear),
    
    // interfaces
    .tcdm_load_master(tcdm[0:1]),
    .source_stream(operands),
    
    // control and flags
    .source_stream_ctrl_i(source_stream_ctrl),
    .source_stream_flags_o(source_stream_flags)
  );
  
  streamer_vfpu #(
    .DATA_WIDTH(DATA_WIDTH),
    .NB_OPERANDS(`HWPE_NB_OPERANDS)
  ) streamer_inst (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .clear_i(clear),
    
    // interfaces
    .operand_streams_sink(operands),
    .result_stream_source(result),
    
    // control and flags
    .ctrl_vfpu_i(ctrl_vfpu),
    .flags_vfpu_o(flags_vfpu)
  );

  streamer_sink #(
    .DATA_WIDTH(DATA_WIDTH)
  ) streamer_sink_inst (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .clear_i(clear),
    
    // interfaces
    .tcdm_store_master(tcdm[2]),
    .sink_stream(result),
    
    // control and flags
    .sink_stream_ctrl_i(sink_stream_ctrl),
    .sink_stream_flags_o(sink_stream_flags)
  );

  control #(
    .DATA_WIDTH(DATA_WIDTH),
    .NB_OPERANDS(`HWPE_NB_OPERANDS),
    .ID_WIDTH(ID_WIDTH),
    .N_CORES(N_CORES),
    .N_CONTEXT(2)
  ) control_inst (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .clear_o(clear),
    
    .source_stream_ctrl_o(source_stream_ctrl),
    .source_stream_flags_i(source_stream_flags),
    
    .sink_stream_ctrl_o(sink_stream_ctrl),
    .sink_stream_flags_i(sink_stream_flags),
    
    .ctrl_flags_o(control_flags),
    .ctrl_vfpu_o(ctrl_vfpu),
    
    .slave_config_interface(slave_config_interface)
  );
  
  assign evt_o = control_flags.evt[N_CORES-1:0];

endmodule
