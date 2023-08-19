/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_DPO_Params_M15 : IndiDPOParams {
  Indi_DPO_Params_M15() : IndiDPOParams(indi_dpo_defaults, PERIOD_M15) { shift = 0; }
} indi_dpo_m15;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_DPO_Params_M15 : StgParams {
  // Struct constructor.
  Stg_DPO_Params_M15() : StgParams(stg_dpo_defaults) {}
} stg_dpo_m15;
