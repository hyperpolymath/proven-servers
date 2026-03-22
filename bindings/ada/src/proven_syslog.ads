-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-syslog protocol (Syslog logging).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Syslog is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Severity levels (RFC 5424, tags 0-7).
   type Severity is
     (Sev_Emergency, Sev_Alert, Sev_Critical, Sev_Error,
      Sev_Warning, Sev_Notice, Sev_Informational, Sev_Debug);
   for Severity use
     (Sev_Emergency     => 0, Sev_Alert         => 1,
      Sev_Critical      => 2, Sev_Error         => 3,
      Sev_Warning       => 4, Sev_Notice        => 5,
      Sev_Informational => 6, Sev_Debug         => 7);
   pragma Convention (C, Severity);

   -- Facility codes (RFC 5424, tags 0-23).
   type Facility is
     (Fac_Kern, Fac_User, Fac_Mail, Fac_Daemon, Fac_Auth,
      Fac_Syslog, Fac_Lpr, Fac_News, Fac_Uucp, Fac_Cron,
      Fac_Auth_Priv, Fac_Ftp, Fac_Ntp, Fac_Audit, Fac_Alert,
      Fac_Clock, Fac_Local0, Fac_Local1, Fac_Local2, Fac_Local3,
      Fac_Local4, Fac_Local5, Fac_Local6, Fac_Local7);
   for Facility use
     (Fac_Kern      => 0,  Fac_User      => 1,  Fac_Mail      => 2,
      Fac_Daemon    => 3,  Fac_Auth      => 4,  Fac_Syslog    => 5,
      Fac_Lpr       => 6,  Fac_News      => 7,  Fac_Uucp      => 8,
      Fac_Cron      => 9,  Fac_Auth_Priv => 10, Fac_Ftp       => 11,
      Fac_Ntp       => 12, Fac_Audit     => 13, Fac_Alert     => 14,
      Fac_Clock     => 15, Fac_Local0    => 16, Fac_Local1    => 17,
      Fac_Local2    => 18, Fac_Local3    => 19, Fac_Local4    => 20,
      Fac_Local5    => 21, Fac_Local6    => 22, Fac_Local7    => 23);
   pragma Convention (C, Facility);

   -- Transport mechanisms (tags 0-2).
   type Transport is (Tp_Udp_514, Tp_Tcp_514, Tp_Tls_6514);
   for Transport use (Tp_Udp_514 => 0, Tp_Tcp_514 => 1, Tp_Tls_6514 => 2);
   pragma Convention (C, Transport);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "syslog_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "syslog_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "syslog_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "syslog_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "syslog_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Syslog;
