-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-honeypot protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Honeypot is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Emulated service types (tags 0-6).
   type Service_Emulation is
     (Svc_Ssh,
      Svc_Http,
      Svc_Ftp,
      Svc_Smtp,
      Svc_Telnet,
      Svc_Mysql,
      Svc_Rdp);
   for Service_Emulation use
     (Svc_Ssh    => 0,
      Svc_Http   => 1,
      Svc_Ftp    => 2,
      Svc_Smtp   => 3,
      Svc_Telnet => 4,
      Svc_Mysql  => 5,
      Svc_Rdp    => 6);
   pragma Convention (C, Service_Emulation);

   -- Honeypot interaction levels (tags 0-2).
   type Interaction_Level is
     (Interact_Low,
      Interact_Medium,
      Interact_High);
   for Interaction_Level use
     (Interact_Low    => 0,
      Interact_Medium => 1,
      Interact_High   => 2);
   pragma Convention (C, Interaction_Level);

   -- Honeypot alert severity levels (tags 0-4).
   type Alert_Severity is
     (Sev_Info,
      Sev_Low,
      Sev_Medium,
      Sev_High,
      Sev_Critical);
   for Alert_Severity use
     (Sev_Info     => 0,
      Sev_Low      => 1,
      Sev_Medium   => 2,
      Sev_High     => 3,
      Sev_Critical => 4);
   pragma Convention (C, Alert_Severity);

   -- Observed attacker actions (tags 0-5).
   type Attacker_Action is
     (Act_Scan,
      Act_Brute_Force,
      Act_Exploit,
      Act_Payload,
      Act_Lateral,
      Act_Exfiltration);
   for Attacker_Action use
     (Act_Scan         => 0,
      Act_Brute_Force  => 1,
      Act_Exploit      => 2,
      Act_Payload      => 3,
      Act_Lateral      => 4,
      Act_Exfiltration => 5);
   pragma Convention (C, Attacker_Action);

   -- Honeypot server states (tags 0-3).
   type Server_State is
     (State_Idle,
      State_Deployed,
      State_Engaged,
      State_Shutdown);
   for Server_State use
     (State_Idle     => 0,
      State_Deployed => 1,
      State_Engaged  => 2,
      State_Shutdown => 3);
   pragma Convention (C, Server_State);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "honeypot_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "honeypot_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "honeypot_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "honeypot_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "honeypot_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Honeypot;
