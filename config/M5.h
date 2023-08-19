/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_DPO_Params_M5 : IndiDPOParams {
  Indi_DPO_Params_M5() : IndiDPOParams(indi_dpo_defaults, PERIOD_M5) { shift = 0; }
} indi_dpo_m5;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_DPO_Params_M5 : StgParams {
  // Struct constructor.
  Stg_DPO_Params_M5() : StgParams(stg_dpo_defaults) {}
} stg_dpo_m5;
