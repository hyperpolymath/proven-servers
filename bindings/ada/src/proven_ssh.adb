-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Implementation of safe wrappers for the proven-ssh Ada bindings.

package body Proven_Ssh is

   function Safe_Create
     (Kex  : Kex_Method;
      Auth : Auth_Method) return Proven_Error.Slot_Id
   is
   begin
      return Proven_Error.Check_Slot
        (Create (unsigned_char (Kex_Method'Pos (Kex)),
                 unsigned_char (Auth_Method'Pos (Auth))));
   end Safe_Create;

   procedure Safe_Destroy (Slot : Proven_Error.Slot_Id) is
   begin
      Destroy (int (Slot));
   end Safe_Destroy;

   procedure Safe_Complete_Kex (Slot : Proven_Error.Slot_Id) is
   begin
      Proven_Error.Check_Status (Complete_Kex (int (Slot)));
   end Safe_Complete_Kex;

   procedure Safe_Disconnect
     (Slot   : Proven_Error.Slot_Id;
      Reason : Disconnect_Reason)
   is
   begin
      Proven_Error.Check_Status
        (Disconnect (int (Slot),
                     unsigned_char (Disconnect_Reason'Pos (Reason))));
   end Safe_Disconnect;

end Proven_Ssh;
