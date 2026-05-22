-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Implementation of safe wrappers for the Proven_Syslog Ada bindings.

package body Proven_Syslog is

   function Safe_Create_Context return Proven_Error.Slot_Id is
   begin
      return Proven_Error.Check_Slot (Create_Context);
   end Safe_Create_Context;

   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id) is
   begin
      Destroy_Context (int (Slot));
   end Safe_Destroy_Context;


end Proven_Syslog;
