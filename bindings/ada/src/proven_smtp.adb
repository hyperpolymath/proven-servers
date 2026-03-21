-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Implementation of safe wrappers for the proven-smtp Ada bindings.

package body Proven_Smtp is

   function Safe_Create_Context return Proven_Error.Slot_Id is
   begin
      return Proven_Error.Check_Slot (Create_Context);
   end Safe_Create_Context;

   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id) is
   begin
      Destroy_Context (int (Slot));
   end Safe_Destroy_Context;

   procedure Safe_Greet (Slot : Proven_Error.Slot_Id; Is_Ehlo : Boolean) is
      Flag : constant unsigned_char := (if Is_Ehlo then 1 else 0);
   begin
      Proven_Error.Check_Status (Greet (int (Slot), Flag));
   end Safe_Greet;

   procedure Safe_Quit (Slot : Proven_Error.Slot_Id) is
   begin
      Proven_Error.Check_Status (Quit (int (Slot)));
   end Safe_Quit;

end Proven_Smtp;
