//+------------------------------------------------------------------+
//|                                                      EnhancedEA.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
#include <Math/Stat/Math.mqh>

CTrade trade;
CPositionInfo pos;

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Trading Parameters ==="
input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;  // Chart timeframe
input double risk = 1.0;                          // Risk percentage per trade
input int MagicNum = 1234;                        // Magic Number

input group "=== Strategy Parameters ==="
input int RSIPeriod = 14;                         // RSI period
input double OverboughtLevel = 70;                // RSI overbought level
input double OversoldLevel = 30;                  // RSI oversold level
input int BBPeriod = 20;                          // Bollinger Bands period
input double BBDeviation = 2.0;                   // Bollinger Bands deviation
input int FastEMA = 12;                           // MACD fast EMA
input int SlowEMA = 26;                           // MACD slow EMA
input int SignalSMA = 9;                          // MACD signal SMA
input int ATRPeriod = 14;                         // ATR period for volatility

input group "=== Trend Filter ==="
input bool EnableTrendFilter = true;              // Enable trend filtering
input int TrendMAPeriod = 200;                    // Trend MA period

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
int atrHandle, maHandle, bbHandle, macdHandle, rsiHandle;
double atrBuffer[], maBuffer[];
datetime lastCandleTime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize indicators
   atrHandle = iATR(_Symbol, TimeFrame, ATRPeriod);
   bbHandle = iBands(_Symbol, TimeFrame, BBPeriod, BBDeviation, 0, PRICE_CLOSE);
   macdHandle = iMACD(_Symbol, TimeFrame, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE);
   rsiHandle = iRSI(_Symbol, TimeFrame, RSIPeriod, PRICE_CLOSE);
   
   if(EnableTrendFilter) maHandle = iMA(_Symbol, TimeFrame, TrendMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   
   ArraySetAsSeries(atrBuffer, true);
   ArraySetAsSeries(maBuffer, true);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release indicator handles
   IndicatorRelease(atrHandle);
   IndicatorRelease(bbHandle);
   IndicatorRelease(macdHandle);
   IndicatorRelease(rsiHandle);
   if(EnableTrendFilter) IndicatorRelease(maHandle);
}

//+------------------------------------------------------------------+
//| Calculate position size with volatility adjustment               |
//+------------------------------------------------------------------+
double calcLots(double slDistance)
{
   if(slDistance == 0) return 0;
   
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * risk / 100;
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ticksize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   if(tickValue == 0 || ticksize == 0) return 0;
   
   double moneyRiskPerLot = slDistance / ticksize * tickValue;
   if(moneyRiskPerLot == 0) return 0;
   
   double lots = NormalizeDouble(riskAmount / moneyRiskPerLot, 2);
   lots = MathMin(lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));
   lots = MathMax(lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
   
   return lots;
}

//+------------------------------------------------------------------+
//| Improved trailing stop with ATR                                  |
//+------------------------------------------------------------------+
void TrailStop()
{
   CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
   double atrValue = atrBuffer[0];
   
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      if(pos.SelectByIndex(i) && pos.Magic() == MagicNum && pos.Symbol() == _Symbol)
      {
         ulong ticket = pos.Ticket();
         double currentSL = pos.StopLoss();
         double newSL = currentSL;
         
         if(pos.PositionType() == POSITION_TYPE_BUY)
         {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            newSL = bid - 2 * atrValue;
            if(newSL > currentSL || currentSL == 0)
               trade.PositionModify(ticket, newSL, pos.TakeProfit());
         }
         else if(pos.PositionType() == POSITION_TYPE_SELL)
         {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            newSL = ask + 2 * atrValue;
            if(newSL < currentSL || currentSL == 0)
               trade.PositionModify(ticket, newSL, pos.TakeProfit());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check trend direction using EMA                                  |
//+------------------------------------------------------------------+
bool CheckTrend()
{
   if(!EnableTrendFilter) return true;
   
   if(CopyBuffer(maHandle, 0, 0, 1, maBuffer) < 1) return false;
   
   MqlRates currentRate;

   CopyRates(_Symbol, TimeFrame, 0, 1, &currentRate);
   
   return currentRate.close > maBuffer[0];
}

//+------------------------------------------------------------------+
//| Get Bollinger Bands values                                       |
//+------------------------------------------------------------------+
bool GetBollingerBands(double &upper, double &lower)
{
   double upperBand[], middleBand[], lowerBand[];
   if(CopyBuffer(bbHandle, 1, 0, 1, upperBand) < 1) return false;
   if(CopyBuffer(bbHandle, 2, 0, 1, lowerBand) < 1) return false;
   
   upper = upperBand[0];
   lower = lowerBand[0];
   return true;
}

//+------------------------------------------------------------------+
//| Get MACD values                                                  |
//+------------------------------------------------------------------+
bool GetMACD(double &macdMain, double &macdSignal)
{
   double mainBuffer[], signalBuffer[];
   if(CopyBuffer(macdHandle, 0, 0, 1, mainBuffer) < 1) return false;
   if(CopyBuffer(macdHandle, 1, 0, 1, signalBuffer) < 1) return false;
   
   macdMain = mainBuffer[0];
   macdSignal = signalBuffer[0];
   return true;
}

//+------------------------------------------------------------------+
//| Get RSI value                                                    |
//+------------------------------------------------------------------+
double GetRSI()
{
   double rsiBuffer[];
   if(CopyBuffer(rsiHandle, 0, 0, 1, rsiBuffer) < 1) return -1;
   return rsiBuffer[0];
}

//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!IsNewBar()) return;
   
   TrailStop();
   
   // Get price data
   MqlRates rates[];
   if(CopyRates(_Symbol, TimeFrame, 0, 3, rates) < 3) return;
   
   // Get indicator values
   double rsiValue = GetRSI();
   double upperBand, lowerBand;
   if(!GetBollingerBands(upperBand, lowerBand)) return;
   double macdMain, macdSignal;
   if(!GetMACD(macdMain, macdSignal)) return;
   CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
   double atrValue = atrBuffer[0];
   
   bool trendUp = CheckTrend();

   // Trading logic
   if(PositionsTotal() == 0)
   {
      double entry, sl, tp, lots;
      
      // Buy condition
      if(rates[0].close < lowerBand && 
         rsiValue < OversoldLevel && 
         macdMain > macdSignal && 
         macdMain < 0 && 
         trendUp)
      {
         entry = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         sl = entry - 1.5 * atrValue;
         tp = entry + 3 * atrValue;
         lots = calcLots(MathAbs(entry - sl));
         if(lots > 0)
            trade.Buy(lots, _Symbol, entry, sl, tp, "Buy Entry");
      }
      
      // Sell condition
      else if(rates[0].close > upperBand && 
              rsiValue > OverboughtLevel && 
              macdMain < macdSignal && 
              macdMain > 0 && 
              !trendUp)
      {
         entry = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         sl = entry + 1.5 * atrValue;
         tp = entry - 3 * atrValue;
         lots = calcLots(MathAbs(entry - sl));
         if(lots > 0)
            trade.Sell(lots, _Symbol, entry, sl, tp, "Sell Entry");
      }
   }
}

//+------------------------------------------------------------------+
//| Check for new bar                                                |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime currentTime[1];
   if(CopyTime(_Symbol, TimeFrame, 0, 1, currentTime) != 1) return false;
   if(currentTime[0] == lastCandleTime) return false;
   lastCandleTime = currentTime[0];
   return true;
}
//+------------------------------------------------------------------+