-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Shared error types for all proven-servers Ada bindings.
--
-- Maps the unified error model from the Zig FFI slot-based context
-- pool pattern. Every protocol uses the same error codes:
--   0 = success, 1 = invalid state, 2 = validation failed,
--   -1 = pool exhausted (for slot-returning calls).

with Interfaces.C; use Interfaces.C;

package Proven_Error is

   -- Unified error codes matching the Idris2 ABI Result type.
   type Error_Code is
     (Success,
      Invalid_State,
      Validation_Failed,
      Pool_Exhausted,
      Invalid_Slot,
      Invalid_Parameter,
      Capacity_Exceeded,
      Unknown_Error);
   pragma Convention (C, Error_Code);

   -- Context slot handle. Valid slots are in range [0, 63].
   subtype Slot_Id is int range 0 .. 63;

   -- Sentinel value returned by create functions when pool is full.
   Pool_Exhausted_Sentinel : constant int := -1;

   -- Result type pairing a boolean success flag with an error code.
   type Result_Type is record
      Ok   : Boolean;
      Code : Error_Code;
   end record;

   -- Convert a raw FFI status byte (u8) to an Error_Code.
   function From_Status (Raw : unsigned_char) return Error_Code;

   -- Convert a raw FFI slot-returning call (c_int) to a Result_Type.
   -- Returns Success with the slot, or Pool_Exhausted on -1.
   function From_Slot (Raw : int) return Result_Type;

   -- Proven_Error_Exception is raised when an FFI call fails and the
   -- caller uses the raising wrapper variant.
   Proven_Error_Exception : exception;

   -- Raise Proven_Error_Exception if the status byte is non-zero.
   procedure Check_Status (Raw : unsigned_char);

   -- Raise Proven_Error_Exception if the slot is -1.
   function Check_Slot (Raw : int) return Slot_Id;

end Proven_Error;
