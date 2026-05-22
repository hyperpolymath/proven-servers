-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Implementation of safe wrappers for the proven-mqtt Ada bindings.

package body Proven_Mqtt is

   function Safe_Create
     (Version       : Mqtt_Version;
      Clean_Session : Boolean;
      Keep_Alive    : unsigned_short) return Proven_Error.Slot_Id
   is
      Clean_Flag : constant unsigned_char :=
        (if Clean_Session then 1 else 0);
   begin
      return Proven_Error.Check_Slot
        (Create (unsigned_char (Mqtt_Version'Pos (Version)),
                 Clean_Flag,
                 Keep_Alive));
   end Safe_Create;

   procedure Safe_Destroy (Slot : Proven_Error.Slot_Id) is
   begin
      Destroy (int (Slot));
   end Safe_Destroy;

   procedure Safe_Disconnect (Slot : Proven_Error.Slot_Id) is
   begin
      Proven_Error.Check_Status (Mqtt_Disconnect (int (Slot)));
   end Safe_Disconnect;

end Proven_Mqtt;
