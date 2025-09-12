#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.01"

#include <Trade/Trade.mqh>
CTrade                  trade;
CPositionInfo           pos;
COrderInfo              ord;

input group "=== Scalping trading Inputs v001 ==="

   input double RiskPercent = 3;                      // Risk in %
   input int Tppoints = 200;                          // Take Profit (10 points = 1pip)
   input int slpoints = 200;                          // Stop Loss Points (10 points = 1pip)
   input int TslTrigerPoints = 15;                    // Points in profit before Trailing SL triggered (10 points = 1pip)
   input int TslPoints = 10;                          // Trailing SL (10 points = 1pip)
   input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;  // TF
   input int inpMagic = 1594;                         // Expert Algorithm ID
   input string TradeComment = "Comment...";          // Comment
   input int DynamicRange = 100;                      // Range for highs and lows
   input int ATRMultiplier = 2;                       // Multiplier for ATR-based buffers
   input int ExpirationTimeInSeconds = 3600;          // Order expiration in seconds

//--- list of hours to pick from using indexing starting from 0 to 23
enum StartHour { Inactive=0, _0100=1, _0200=2, _0300=3, _0400=4, _0500=5, _0600=6, _0700=7, _0800=8, _0900=9, _1000=10, _1100=11, _1200=12, _1300=13, _1400=14, _1500=15, _1600=16, _1700=17, _1800=18, _1900=19, _2000=20, _2100=21, _2200=22, _2300=23 };   
input StartHour SHInput = 0;                       // Start Hour

//--- list of hours to pick from using indexing starting from 0 to 23
enum EndHour { Inactive=0, _0100=1, _0200=2, _0300=3, _0400=4, _0500=5, _0600=6, _0700=7, _0800=8, _0900=9, _1000=10, _1100=11, _1200=12, _1300=13, _1400=14, _1500=15, _1600=16, _1700=17, _1800=18, _1900=19, _2000=20, _2100=21, _2200=22, _2300=23 };   
input EndHour EHInput = 0;                       // End Hour

//--- choices from start hour and end hour
int SHChoice;
int EHChoice;

//--- Function to find the highest high with volatility buffer
double findHigh(int range) {
   double highestHigh = 0;
   double atr = iATR(_Symbol, TimeFrame, 14, 0) * ATRMultiplier;
   int totalBars = MathMin(range, Bars(_Symbol, TimeFrame));
   for (int i = 0; i < totalBars; i++) {
      double high = iHigh(_Symbol, TimeFrame, i);
      highestHigh = MathMax(high + atr, highestHigh);
   }
   return highestHigh;
}

//--- Function to find the lowest low with volatility buffer
double findLow(int range) {
   double lowestLow = DBL_MAX;
   double atr = iATR(_Symbol, TimeFrame, 14, 0) * ATRMultiplier;
   int totalBars = MathMin(range, Bars(_Symbol, TimeFrame));
   for (int i = 0; i < totalBars; i++) {
      double low = iLow(_Symbol, TimeFrame, i);
      lowestLow = MathMin(low - atr, lowestLow);
   }
   return lowestLow;
}

//--- finding the new candle 
bool IsNewBar () {
   static datetime previousTime = 0;
   datetime currentTime = iTime(_Symbol, TimeFrame, 0);
   if (previousTime != currentTime){
      previousTime = currentTime;
      return true;
   }
   return false;
}

//--- sending the buy order 
void sendBuyOrder(double entry) {
   double tp = entry + Tppoints * _Point;
   double sl = entry - slpoints * _Point;

   double lots = calcLots(entry - sl);
   datetime expiration = TimeCurrent() + ExpirationTimeInSeconds;

   trade.BuyStop(lots, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration);
}

//--- Sending sell orders
void sendSellOrder(double entry) {
   double tp = entry - Tppoints * _Point;
   double sl = entry + slpoints * _Point;

   double lots = calcLots(sl - entry);
   datetime expiration = TimeCurrent() + ExpirationTimeInSeconds;

   trade.SellStop(lots, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration);
}

//--- Lot size calculations 
double calcLots(double slPoints) {
   double risk = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100;

   double ticksize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickvalue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double lotstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   double moneyPerLotstep = slPoints / ticksize * tickvalue * lotstep;
   double lots = MathFloor(risk / moneyPerLotstep) * lotstep;

   return NormalizeDouble(lots, 2);
}

//--- Trailing Stop Implementation
void TrailStop() {
   double sl = 0, tp = 0;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (pos.SelectByIndex(i) && pos.Symbol() == _Symbol && pos.Magic() == inpMagic) {
         if (pos.PositionType() == POSITION_TYPE_BUY) {
            if (bid - pos.PriceOpen() > TslTrigerPoints * _Point) {
               sl = bid - TslPoints * _Point;
               tp = pos.TakeProfit();
               if (sl > pos.StopLoss()) {
                  trade.PositionModify(pos.Ticket(), sl, tp);
               }
            }
         } else if (pos.PositionType() == POSITION_TYPE_SELL) {
            if (pos.PriceOpen() - ask > TslTrigerPoints * _Point) {
               sl = ask + TslPoints * _Point;
               tp = pos.TakeProfit();
               if (sl < pos.StopLoss()) {
                  trade.PositionModify(pos.Ticket(), sl, tp);
               }
            }
         }
      }
   }
}

//--- Main OnInit Function
int OnInit(){
   trade.SetExpertMagicNumber(inpMagic);
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   Print("EA Initialized Successfully");
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
   TrailStop();

   if (!IsNewBar()) return;

   MqlDateTime time;
   TimeToStruct(TimeCurrent(), time);
   int Hournow = time.hour;

   SHChoice = SHInput;
   EHChoice = EHInput;

   if (Hournow < SHChoice || (Hournow >= EHChoice && EHChoice != 0)) {
      return;
   }

   int BuyTotal = 0;
   int SellTotal = 0;

   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      pos.SelectByIndex(i);
      if (pos.PositionType() == POSITION_TYPE_BUY && pos.Symbol() == _Symbol && pos.Magic() == inpMagic) BuyTotal++;
      if (pos.PositionType() == POSITION_TYPE_SELL && pos.Symbol() == _Symbol && pos.Magic() == inpMagic) SellTotal++;
   }

   if (BuyTotal <= 0) {
      double high = findHigh(DynamicRange);
      if (high > 0) sendBuyOrder(high);
   }

   if (SellTotal <= 0) {
      double low = findLow(DynamicRange);
      if (low > 0) sendSellOrder(low);
   }
}
