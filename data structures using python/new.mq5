#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.01"

#include <Trade/Trade.mqh>
CTrade                  trade;
CPositionInfo           pos;
COrderInfo              ord;

input group "=== Scalping Trading Inputs ==="
   input double RiskPercent = 3;                      // Risk in %
   input int Tppoints = 200;                          // Take Profit (10 points = 1 pip)
   input int slpoints = 200;                          // Stop Loss Points (10 points = 1 pip)
   input int TslTrigerPoints = 15;                    // Points in profit before Trailing SL triggered (10 points = 1 pip)
   input int TslPoints = 10;                          // Trailing SL (10 points = 1 pip)
   input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;  // Timeframe
   input int inpMagic = 1594;                         // Expert Algorithm ID
   input string TradeComment = "Comment...";          // Comment  
   input int RangeBars = 100;                         // Dynamic range for high/low search

//--- list of hours to pick from using indexing starting from 0 to 23
enum StartHour { Inactive=0, _0100=1, _0200=2, _0300=3, _0400=4, _0500=5, _0600=6, _0700=7, _0800=8, _0900=9, _1000=10, _1100=11, _1200=12, _1300=13, _1400=14, _1500=15, _1600=16, _1700=17, _1800=18, _1900=19, _2000=20, _2100=21, _2200=22, _2300=23 };   
input StartHour SHInput = 0;                          // Start Hour
enum EndHour { Inactive=0, _0100=1, _0200=2, _0300=3, _0400=4, _0500=5, _0600=6, _0700=7, _0800=8, _0900=9, _1000=10, _1100=11, _1200=12, _1300=13, _1400=14, _1500=15, _1600=16, _1700=17, _1800=18, _1900=19, _2000=20, _2100=21, _2200=22, _2300=23 };   
input EndHour EHInput = 0;                            // End Hour

//--- variables for identifying higher highs, lower lows, and orders
int OrderDistancePoints = 100; 

//--- Function to find the highest high
double findHigh(int range) {
   double highestHigh = 0;
   int totalBars = MathMin(range, Bars(_Symbol, TimeFrame));
   for (int i = 0; i < totalBars; i++) {
      double high = iHigh(_Symbol, TimeFrame, i);
      highestHigh = MathMax(high, highestHigh);
   }
   return highestHigh;
}

//--- Function to find the lowest low
double findLow(int range) {
   double lowestLow = DBL_MAX;
   int totalBars = MathMin(range, Bars(_Symbol, TimeFrame));
   for (int i = 0; i < totalBars; i++) {
      double low = iLow(_Symbol, TimeFrame, i);
      lowestLow = MathMin(low, lowestLow);
   }
   return lowestLow;
}

//--- Checking for new candles
bool IsNewBar() {
   static datetime previousTime = 0;
   datetime currentTime = iTime(_Symbol, TimeFrame, 0);
   if (previousTime != currentTime) {
      previousTime = currentTime;
      return true;
   }
   return false;
}

//--- Sending a buy order
void sendBuyOrder(double entry) {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if (ask > entry - OrderDistancePoints * _Point) return;

   double tp = entry + Tppoints * _Point;
   double sl = entry - slpoints * _Point;
   double lots = RiskPercent > 0 ? calcLots(entry - sl) : 0.01;

   datetime expiration = iTime(_Symbol, TimeFrame, 0) + PeriodSeconds(TimeFrame); // order will expire at the end of the current bar.
   trade.BuyStop(lots, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration);
}

//--- Sending a sell order
void sendSellOrder(double entry) {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if (bid < entry + OrderDistancePoints * _Point) return;

   double tp = entry - Tppoints * _Point;
   double sl = entry + slpoints * _Point;
   double lots = RiskPercent > 0 ? calcLots(sl - entry) : 0.01;

   datetime expiration = iTime(_Symbol, TimeFrame, 0) + PeriodSeconds(TimeFrame);
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

   lots = MathMax(lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
   lots = MathMin(lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));
   return NormalizeDouble(lots, 2);
}

//--- Closing all orders
void CloseAllOrders() {
   for (int index = OrdersTotal() - 1; index >= 0; index--) {
      if (ord.SelectByIndex(index)) { // Check if the order is selected
         if (ord.Symbol() == _Symbol && ord.Magic() == inpMagic) {
            trade.OrderDelete(ord.Ticket());
         }
      }
   }
}

//--- Main event functions
int OnInit() {
   trade.SetExpertMagicNumber(inpMagic);
   return INIT_SUCCEEDED;
}

void OnTick() {
   if (!IsNewBar()) return;



//    checking server time
   MqlDateTime time;
   TimeToStruct(TimeCurrent(), time);
   int Hournow = time.hour;
    Print("Time to trade" + )
   if (Hournow < SHInput || (Hournow >= EHInput && EHInput != 0)) {
      CloseAllOrders();
      return;
   }

   int BuyTotal = 0, SellTotal = 0;
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (pos.SelectByIndex(i) && pos.Symbol() == _Symbol && pos.Magic() == inpMagic) {
         if (pos.PositionType() == POSITION_TYPE_BUY) BuyTotal++;
         if (pos.PositionType() == POSITION_TYPE_SELL) SellTotal++;
      }
   }

   if (BuyTotal == 0) {
      double high = findHigh(RangeBars);
      if (high > 0) sendBuyOrder(high);
   }

   if (SellTotal == 0) {
      double low = findLow(RangeBars);
      if (low > 0) sendSellOrder(low);
   }
}
