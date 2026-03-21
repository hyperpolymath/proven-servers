-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Implementation of safe wrappers for the proven-grpc Ada bindings.

package body Proven_Grpc is

   function Safe_Create
     (Compress : Compression) return Proven_Error.Slot_Id
   is
   begin
      return Proven_Error.Check_Slot
        (Create (unsigned_char (Compression'Pos (Compress))));
   end Safe_Create;

   procedure Safe_Destroy (Slot : Proven_Error.Slot_Id) is
   begin
      Destroy (int (Slot));
   end Safe_Destroy;

   procedure Safe_Send_Headers (Slot : Proven_Error.Slot_Id) is
   begin
      Proven_Error.Check_Status (Send_Headers (int (Slot)));
   end Safe_Send_Headers;

end Proven_Grpc;
