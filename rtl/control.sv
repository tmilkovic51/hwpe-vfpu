`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;
import hwpe_ctrl_vfpu_package::*;

module control
#(
  parameter int unsigned DATA_WIDTH  = 32,
  parameter int unsigned NB_OPERANDS = 2,
  parameter int unsigned ID_WIDTH = 16,
  parameter int unsigned N_CORES = 2,
  parameter int unsigned N_CONTEXT = 2
)
(
  input  logic                  clk_i,
  input  logic                  rst_ni,
  output logic                  clear_o,
  
  // source stream control and flags
  output ctrl_sourcesink_t     source_stream_ctrl_o[NB_OPERANDS],
  input  flags_sourcesink_t    source_stream_flags_i[NB_OPERANDS],
  
  // sink stream control and flags
  output ctrl_sourcesink_t      sink_stream_ctrl_o,
  input  flags_sourcesink_t     sink_stream_flags_i,
  
  // control module flags
  output flags_slave_t          ctrl_flags_o,
  
  // VPFU control signals
  output ctrl_vfpu_t            ctrl_vfpu_o,
  
  // HWPE configuration interface on peripheral bus
  hwpe_ctrl_intf_periph.slave   slave_config_interface
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//
  ctrl_slave_t      slave_control;  // done and event flags must be set here
  ctrl_regfile_t    registers;      // IO and generic registers values are contained here

//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

// HWPE CONTROL
  hwpe_ctrl_slave #(
    .N_CORES (N_CORES),
    .N_CONTEXT (N_CONTEXT),
    .N_EVT (REGFILE_N_EVT),
    .N_IO_REGS (16),
    .N_GENERIC_REGS (0),
    .N_SW_EVT (0), // not used
    .ID_WIDTH (ID_WIDTH)
  ) hwpe_control (
    .clk_i (clk_i),
    .rst_ni (rst_ni),
    .clear_o (clear_o),
    .cfg (slave_config_interface),
    .ctrl_i (slave_control),
    .flags_o (ctrl_flags_o),
    .reg_file (registers)
  );

//======================================================//
//                CONTROL LOGIC                         //
//======================================================//

  // CONTROL FOR HWPE_CTRL MODULE
  assign slave_control.done = sink_stream_flags_i.done; // everything is done when sink stream is done
  assign slave_control.evt = 0; // events currently not used
  
  // START TRIGGER ON STREAM INTERFACES
  assign source_stream_ctrl_o[0].req_start = ctrl_flags_o.start;
  assign source_stream_ctrl_o[1].req_start = ctrl_flags_o.start;
  assign sink_stream_ctrl_o.req_start = ctrl_flags_o.start;
  
  // OPERAND A ADDRESGEN CONTROL
  assign source_stream_ctrl_o[0].addressgen_ctrl.base_addr = registers.hwpe_params[BASE_ADDR_A_REG_INDEX];
  assign source_stream_ctrl_o[0].addressgen_ctrl.trans_size = registers.hwpe_params[TRANSACTION_SIZE_REG_INDEX];
  assign source_stream_ctrl_o[0].addressgen_ctrl.line_stride = registers.hwpe_params[LINE_STRIDE_A_REG_INDEX][31:16];
  assign source_stream_ctrl_o[0].addressgen_ctrl.line_length = registers.hwpe_params[LINE_LENGTH_A_REG_INDEX][15:0];
  assign source_stream_ctrl_o[0].addressgen_ctrl.feat_stride = registers.hwpe_params[FEAT_STRIDE_A_REG_INDEX][31:16];
  assign source_stream_ctrl_o[0].addressgen_ctrl.feat_length = registers.hwpe_params[FEAT_LENGTH_A_REG_INDEX][15:0];
  assign source_stream_ctrl_o[0].addressgen_ctrl.loop_outer = registers.hwpe_params[LOOP_OUTER_A_REG_INDEX][16];
  assign source_stream_ctrl_o[0].addressgen_ctrl.feat_roll = registers.hwpe_params[FEAT_ROLL_A_REG_INDEX][15:0];
  assign source_stream_ctrl_o[0].addressgen_ctrl.realign_type = 0;
  assign source_stream_ctrl_o[0].addressgen_ctrl.line_length_remainder = 0;
  
  // OPERAND B ADDRESGEN CONTROL
  assign source_stream_ctrl_o[1].addressgen_ctrl.base_addr = registers.hwpe_params[BASE_ADDR_B_REG_INDEX];
  assign source_stream_ctrl_o[1].addressgen_ctrl.trans_size = registers.hwpe_params[TRANSACTION_SIZE_REG_INDEX];
  assign source_stream_ctrl_o[1].addressgen_ctrl.line_stride = registers.hwpe_params[LINE_STRIDE_B_REG_INDEX][31:16];
  assign source_stream_ctrl_o[1].addressgen_ctrl.line_length = registers.hwpe_params[LINE_LENGTH_B_REG_INDEX][15:0];
  assign source_stream_ctrl_o[1].addressgen_ctrl.feat_stride = registers.hwpe_params[FEAT_STRIDE_B_REG_INDEX][31:16];
  assign source_stream_ctrl_o[1].addressgen_ctrl.feat_length = registers.hwpe_params[FEAT_LENGTH_B_REG_INDEX][15:0];
  assign source_stream_ctrl_o[1].addressgen_ctrl.loop_outer = registers.hwpe_params[LOOP_OUTER_B_REG_INDEX][16];
  assign source_stream_ctrl_o[1].addressgen_ctrl.feat_roll = registers.hwpe_params[FEAT_ROLL_B_REG_INDEX][15:0];
  assign source_stream_ctrl_o[1].addressgen_ctrl.realign_type = 0;
  assign source_stream_ctrl_o[1].addressgen_ctrl.line_length_remainder = 0;
  
  // RESULT ADDRESGEN CONTROL
  assign sink_stream_ctrl_o.addressgen_ctrl.base_addr = registers.hwpe_params[BASE_ADDR_RESULT_REG_INDEX];
  assign sink_stream_ctrl_o.addressgen_ctrl.trans_size = registers.hwpe_params[TRANSACTION_SIZE_REG_INDEX];
  assign sink_stream_ctrl_o.addressgen_ctrl.line_stride = registers.hwpe_params[LINE_STRIDE_RESULT_REG_INDEX][31:16];
  assign sink_stream_ctrl_o.addressgen_ctrl.line_length = registers.hwpe_params[LINE_LENGTH_RESULT_REG_INDEX][15:0];
  assign sink_stream_ctrl_o.addressgen_ctrl.feat_stride = registers.hwpe_params[FEAT_STRIDE_RESULT_REG_INDEX][31:16];
  assign sink_stream_ctrl_o.addressgen_ctrl.feat_length = registers.hwpe_params[FEAT_LENGTH_RESULT_REG_INDEX][15:0];
  assign sink_stream_ctrl_o.addressgen_ctrl.loop_outer = registers.hwpe_params[LOOP_OUTER_RESULT_REG_INDEX][16];
  assign sink_stream_ctrl_o.addressgen_ctrl.feat_roll = registers.hwpe_params[FEAT_ROLL_RESULT_REG_INDEX][15:0];
  assign sink_stream_ctrl_o.addressgen_ctrl.realign_type = 0;
  assign sink_stream_ctrl_o.addressgen_ctrl.line_length_remainder = 0;

  // VFPU control signals
  assign ctrl_vfpu_o.operation = registers.hwpe_params[OPERATION_SELECT_REG_INDEX][OPERATION_SELECT_WIDTH-1:0];
  assign ctrl_vfpu_o.rounding_mode = registers.hwpe_params[ROUNDING_MODE_SELECT_REG_INDEX][16+ROUNDING_MODE_SELECT_WIDTH-1:16];

endmodule
