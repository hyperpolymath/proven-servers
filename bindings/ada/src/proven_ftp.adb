-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Implementation of safe wrappers for the proven-ftp Ada bindings.

package body Proven_Ftp is

   function Safe_Create return Proven_Error.Slot_Id is
   begin
      return Proven_Error.Check_Slot (Create);
   end Safe_Create;

   procedure Safe_Destroy (Slot : Proven_Error.Slot_Id) is
   begin
      Destroy (int (Slot));
   end Safe_Destroy;

   procedure Safe_Quit (Slot : Proven_Error.Slot_Id) is
   begin
      Proven_Error.Check_Status (Quit_Cmd (int (Slot)));
   end Safe_Quit;

end Proven_Ftp;
