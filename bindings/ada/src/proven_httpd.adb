-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Implementation of safe wrappers for the proven-httpd Ada bindings.

package body Proven_Httpd is

   function Safe_Create_Context return Proven_Error.Slot_Id is
      Raw : constant int := Create_Context;
   begin
      return Proven_Error.Check_Slot (Raw);
   end Safe_Create_Context;

   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id) is
   begin
      Destroy_Context (int (Slot));
   end Safe_Destroy_Context;

   procedure Safe_Send_Response (Slot : Proven_Error.Slot_Id) is
      Raw : constant unsigned_char := Send_Response (int (Slot));
   begin
      Proven_Error.Check_Status (Raw);
   end Safe_Send_Response;

   procedure Safe_Reset_Context (Slot : Proven_Error.Slot_Id) is
      Raw : constant unsigned_char := Reset_Context (int (Slot));
   begin
      Proven_Error.Check_Status (Raw);
   end Safe_Reset_Context;

   function Is_Keep_Alive (Slot : Proven_Error.Slot_Id) return Boolean is
   begin
      return Keep_Alive_Check (int (Slot)) = 1;
   end Is_Keep_Alive;

end Proven_Httpd;
