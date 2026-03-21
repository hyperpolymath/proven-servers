-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Implementation of safe wrappers for the proven-firewall Ada bindings.

package body Proven_Firewall is

   function Safe_Create_Context return Proven_Error.Slot_Id is
   begin
      return Proven_Error.Check_Slot (Create_Context);
   end Safe_Create_Context;

   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id) is
   begin
      Destroy_Context (int (Slot));
   end Safe_Destroy_Context;

   procedure Safe_Commit (Slot : Proven_Error.Slot_Id) is
   begin
      Proven_Error.Check_Status (Commit (int (Slot)));
   end Safe_Commit;

end Proven_Firewall;
