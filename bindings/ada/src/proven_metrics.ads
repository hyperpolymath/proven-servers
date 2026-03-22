-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-metrics server protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Metrics is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Metric data types (tags 0-5).
   type Metric_Type is
     (Mt_Counter, Mt_Gauge, Mt_Histogram,
      Mt_Summary, Mt_Info, Mt_State_Set);
   for Metric_Type use
     (Mt_Counter => 0, Mt_Gauge => 1, Mt_Histogram => 2,
      Mt_Summary => 3, Mt_Info => 4, Mt_State_Set => 5);
   pragma Convention (C, Metric_Type);

   -- Metrics scrape results (tags 0-3).
   type Scrape_Result is
     (Sr_Success, Sr_Timeout, Sr_Connection_Refused, Sr_Invalid_Response);
   for Scrape_Result use
     (Sr_Success => 0, Sr_Timeout => 1, Sr_Connection_Refused => 2,
      Sr_Invalid_Response => 3);
   pragma Convention (C, Scrape_Result);

   -- Alert rule states (tags 0-3).
   type Alert_State is
     (As_Inactive, As_Pending, As_Firing, As_Resolved);
   for Alert_State use
     (As_Inactive => 0, As_Pending => 1, As_Firing => 2, As_Resolved => 3);
   pragma Convention (C, Alert_State);

   -- Metrics aggregation operations (tags 0-10).
   type Aggregation_Op is
     (Agg_Sum, Agg_Avg, Agg_Min, Agg_Max, Agg_Count,
      Agg_Rate, Agg_Increase, Agg_P50, Agg_P90, Agg_P95, Agg_P99);
   for Aggregation_Op use
     (Agg_Sum => 0, Agg_Avg => 1, Agg_Min => 2, Agg_Max => 3,
      Agg_Count => 4, Agg_Rate => 5, Agg_Increase => 6,
      Agg_P50 => 7, Agg_P90 => 8, Agg_P95 => 9, Agg_P99 => 10);
   pragma Convention (C, Aggregation_Op);

   -- Metrics query error codes (tags 0-3).
   type Query_Error is
     (Qe_Parse_Error, Qe_Execution_Error, Qe_Timeout, Qe_Too_Many_Series);
   for Query_Error use
     (Qe_Parse_Error => 0, Qe_Execution_Error => 1,
      Qe_Timeout => 2, Qe_Too_Many_Series => 3);
   pragma Convention (C, Query_Error);

   -- Metrics collector states (tags 0-4).
   type Collector_State is
     (Cs_Idle, Cs_Configured, Cs_Scraping, Cs_Alerting, Cs_Stopping);
   for Collector_State use
     (Cs_Idle => 0, Cs_Configured => 1, Cs_Scraping => 2,
      Cs_Alerting => 3, Cs_Stopping => 4);
   pragma Convention (C, Collector_State);

   -- Standard Prometheus port.
   Metrics_Port : constant := 9090;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "metrics_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "metrics_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "metrics_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "metrics_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "metrics_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Metrics;
