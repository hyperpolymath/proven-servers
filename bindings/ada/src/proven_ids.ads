-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-intrusion detection protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Ids is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Alert severity levels (tags 0-3).
   type Alert_Severity is
     (Sev_Low, Sev_Medium, Sev_High, Sev_Critical);
   for Alert_Severity use
     (Sev_Low => 0, Sev_Medium => 1, Sev_High => 2, Sev_Critical => 3);
   pragma Convention (C, Alert_Severity);

   -- Intrusion detection methods (tags 0-3).
   type Detection_Method is
     (Meth_Signature, Meth_Anomaly, Meth_Stateful, Meth_Heuristic);
   for Detection_Method use
     (Meth_Signature => 0, Meth_Anomaly => 1,
      Meth_Stateful  => 2, Meth_Heuristic => 3);
   pragma Convention (C, Detection_Method);

   -- Monitored network protocols (tags 0-6).
   type Ids_Protocol is
     (Proto_Tcp, Proto_Udp, Proto_Icmp, Proto_Dns,
      Proto_Http, Proto_Tls, Proto_Ssh);
   for Ids_Protocol use
     (Proto_Tcp  => 0, Proto_Udp  => 1, Proto_Icmp => 2,
      Proto_Dns  => 3, Proto_Http => 4, Proto_Tls  => 5,
      Proto_Ssh  => 6);
   pragma Convention (C, Ids_Protocol);

   -- IDS response actions (tags 0-4).
   type Ids_Action is
     (Act_Alert, Act_Drop, Act_Log, Act_Block, Act_Pass);
   for Ids_Action use
     (Act_Alert => 0, Act_Drop => 1, Act_Log => 2,
      Act_Block => 3, Act_Pass => 4);
   pragma Convention (C, Ids_Action);

   -- Traffic direction (tags 0-2).
   type Direction is (Dir_Inbound, Dir_Outbound, Dir_Both);
   for Direction use
     (Dir_Inbound => 0, Dir_Outbound => 1, Dir_Both => 2);
   pragma Convention (C, Direction);

   -- Threat assessment levels (tags 0-4).
   type Threat_Level is
     (Threat_Info, Threat_Low, Threat_Medium, Threat_High, Threat_Critical);
   for Threat_Level use
     (Threat_Info     => 0, Threat_Low  => 1, Threat_Medium => 2,
      Threat_High     => 3, Threat_Critical => 4);
   pragma Convention (C, Threat_Level);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ids_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "ids_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "ids_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ids_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ids_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Ids;
