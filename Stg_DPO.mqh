/**
 * @file
 * Implements DPO strategy based on the DPO indicator.
 */

// User input params.
INPUT_GROUP("DPO strategy: strategy params");
INPUT float DPO_LotSize = 0;                // Lot size
INPUT int DPO_SignalOpenMethod = 0;         // Signal open method
INPUT float DPO_SignalOpenLevel = 0;        // Signal open level
INPUT int DPO_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int DPO_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT int DPO_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int DPO_SignalCloseMethod = 0;        // Signal close method
INPUT int DPO_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT float DPO_SignalCloseLevel = 0;       // Signal close level
INPUT int DPO_PriceStopMethod = 0;          // Price limit method
INPUT float DPO_PriceStopLevel = 2;         // Price limit level
INPUT int DPO_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT float DPO_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT short DPO_Shift = 0;                  // Shift
INPUT float DPO_OrderCloseLoss = 80;        // Order close loss
INPUT float DPO_OrderCloseProfit = 80;      // Order close profit
INPUT int DPO_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("DPO strategy: DPO indicator params");
INPUT int DPO_Indi_DPO_Shift = 0;                                        // Shift
INPUT ENUM_IDATA_SOURCE_TYPE DPO_Indi_DPO_SourceType = IDATA_INDICATOR;  // Source type

// Structs.

// Defines struct with default user strategy values.
struct Stg_DPO_Params_Defaults : StgParams {
  Stg_DPO_Params_Defaults()
      : StgParams(::DPO_SignalOpenMethod, ::DPO_SignalOpenFilterMethod, ::DPO_SignalOpenLevel,
                  ::DPO_SignalOpenBoostMethod, ::DPO_SignalCloseMethod, ::DPO_SignalCloseFilter, ::DPO_SignalCloseLevel,
                  ::DPO_PriceStopMethod, ::DPO_PriceStopLevel, ::DPO_TickFilterMethod, ::DPO_MaxSpread, ::DPO_Shift) {
    Set(STRAT_PARAM_LS, DPO_LotSize);
    Set(STRAT_PARAM_OCL, DPO_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, DPO_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, DPO_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, DPO_SignalOpenFilterTime);
  }
};

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_DPO : public Strategy {
 public:
  Stg_DPO(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_DPO *Init(ENUM_TIMEFRAMES _tf = NULL) {
    // Initialize strategy initial values.
    Stg_DPO_Params_Defaults stg_dpo_defaults;
    StgParams _stg_params(stg_dpo_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_dpo_m1, stg_dpo_m5, stg_dpo_m15, stg_dpo_m30, stg_dpo_h1, stg_dpo_h4,
                             stg_dpo_h8);
#endif
    // Initialize indicator.
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_DPO(_stg_params, _tparams, _cparams, "DPO");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    IndiDPOParams _indi_params(::DPO_Indi_DPO_Shift);
    _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_DPO(_indi_params));
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    Indi_DPO *_indi = GetIndicator();
    bool _result =
        _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 1);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    IndicatorSignal _signals = _indi.GetSignals(4, _shift);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buy signal.
        _result &= _indi.IsIncreasing(1, 0, _shift);
        _result &= _indi.IsIncByPct(_level / 10, 0, _shift, 2);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
      case ORDER_TYPE_SELL:
        // Sell signal.
        _result &= _indi.IsDecreasing(1, 0, _shift);
        _result &= _indi.IsDecByPct(_level / 10, 0, _shift, 2);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
    }
    return _result;
  }
};
