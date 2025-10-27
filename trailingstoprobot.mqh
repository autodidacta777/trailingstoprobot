//+------------------------------------------------------------------+
//|                                           TrailingStopRobot.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//--- Variables globales
double DistanciaSL;
int Ticket;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("=== Robot Trailing Stop iniciado ===");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment(""); // Limpia la pantalla
   ObjectsDeleteAll(0, 0, -1); // Elimina líneas creadas
   Print("=== Robot Trailing Stop detenido ===");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Si no hay operaciones abiertas, abrimos una compra
   if( OperacionesAbiertas() == 0 )
     {
      DistanciaSL = (50 * 10) * MarketInfo(NULL, MODE_POINT); // 50 pips
      Ticket = OrderSend(Symbol(), OP_BUY, 1.0, Ask, 1, Ask - DistanciaSL, 0, "Compra TS", 0, 0, clrLime);

      if(Ticket > 0)
        {
         Print("Orden BUY abierta. Ticket: ", Ticket);

         // Dibujar línea de entrada
         string entrada = "Entry_" + IntegerToString(Ticket);
         ObjectCreate(0, entrada, OBJ_HLINE, 0, 0, Ask);
         ObjectSetInteger(0, entrada, OBJPROP_COLOR, clrLime);
         ObjectSetInteger(0, entrada, OBJPROP_WIDTH, 1);
        }
      else
        {
         Print("Error al abrir la orden: ", GetLastError());
        }
     }
   else
     {
      // Gestionar trailing stop
      if(OrderSelect(Ticket, SELECT_BY_TICKET))
        {
         double NuevoSL = Ask - DistanciaSL;

         if(NuevoSL > OrderStopLoss())
           {
            bool modificado = OrderModify(OrderTicket(), OrderOpenPrice(), NuevoSL, OrderTakeProfit(), 0, clrRed);
            if(modificado)
              {
               Print("Stop Loss actualizado a ", DoubleToString(NuevoSL, _Digits));

               // Dibujar línea del Trailing Stop
               string lineaSL = "SL_" + IntegerToString(OrderTicket());
               if(ObjectFind(0, lineaSL) < 0)
                  ObjectCreate(0, lineaSL, OBJ_HLINE, 0, 0, OrderStopLoss());
               else
                  ObjectMove(0, lineaSL, 0, 0, OrderStopLoss());
               ObjectSetInteger(0, lineaSL, OBJPROP_COLOR, clrRed);
               ObjectSetInteger(0, lineaSL, OBJPROP_STYLE, STYLE_DOT);
              }
           }
        }
     }

   // --- Mostrar información en pantalla ---
   Comment(
      "=== Robot Trailing Stop ===\n",
      "Balance: ", DoubleToString(AccountBalance(), 2), "\n",
      "Equidad: ", DoubleToString(AccountEquity(), 2), "\n",
      "Órdenes abiertas: ", OrdersTotal(), "\n",
      "Distancia SL (pips): ", DoubleToString(DistanciaSL / MarketInfo(NULL, MODE_POINT) / 10, 1), "\n",
      "Precio actual (Ask): ", DoubleToString(Ask, _Digits), "\n",
      "Hora: ", TimeToString(TimeCurrent(), TIME_SECONDS)
   );
  }

//+------------------------------------------------------------------+
//| Función: contar operaciones abiertas del símbolo actual          |
//+------------------------------------------------------------------+
int OperacionesAbiertas()
  {
   int CantidadOrdenes = 0;

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        if(OrderSymbol() == Symbol())
          {
           CantidadOrdenes++;
           Ticket = OrderTicket(); // guarda el ticket actual
           break;
          }
     }

   return CantidadOrdenes;
  }
//+------------------------------------------------------------------+
