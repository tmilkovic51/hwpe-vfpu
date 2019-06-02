package hwpe_ctrl_registers_package;

  // OPERAND A CONTROL REGISTERS INDICES
  parameter int unsigned BASE_ADDR_A_REG_INDEX              = 0;
  parameter int unsigned LINE_STRIDE_A_REG_INDEX            = 1;
  parameter int unsigned LINE_LENGTH_A_REG_INDEX            = 1;
  parameter int unsigned FEAT_STRIDE_A_REG_INDEX            = 2;
  parameter int unsigned FEAT_LENGTH_A_REG_INDEX            = 2;
  parameter int unsigned LOOP_OUTER_A_REG_INDEX             = 3;
  parameter int unsigned FEAT_ROLL_A_REG_INDEX              = 3;

  // OPERAND B CONTROL REGISTERS INDICES
  parameter int unsigned BASE_ADDR_B_REG_INDEX              = 4;
  parameter int unsigned LINE_STRIDE_B_REG_INDEX            = 5;
  parameter int unsigned LINE_LENGTH_B_REG_INDEX            = 5;
  parameter int unsigned FEAT_STRIDE_B_REG_INDEX            = 6;
  parameter int unsigned FEAT_LENGTH_B_REG_INDEX            = 6;
  parameter int unsigned LOOP_OUTER_B_REG_INDEX             = 7;
  parameter int unsigned FEAT_ROLL_B_REG_INDEX              = 7;

  // RESULT CONTROL REGISTERS INDICES
  parameter int unsigned BASE_ADDR_RESULT_REG_INDEX         = 8;
  parameter int unsigned LINE_STRIDE_RESULT_REG_INDEX       = 9;
  parameter int unsigned LINE_LENGTH_RESULT_REG_INDEX       = 9;
  parameter int unsigned FEAT_STRIDE_RESULT_REG_INDEX       = 10;
  parameter int unsigned FEAT_LENGTH_RESULT_REG_INDEX       = 10;
  parameter int unsigned LOOP_OUTER_RESULT_REG_INDEX        = 11;
  parameter int unsigned FEAT_ROLL_RESULT_REG_INDEX         = 11;

  // COMMON CONTROL REGISTER INDICES
  parameter int unsigned TRANSACTION_SIZE_REG_INDEX         = 12;
  parameter int unsigned OPERATION_SELECT_REG_INDEX         = 13;

endpackage // hwpe_ctrl_registers_package
