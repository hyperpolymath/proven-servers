-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Implementation of shared error conversion routines for proven-servers
-- Ada bindings. Translates raw FFI return codes into typed Ada values.

package body Proven_Error is

   -----------------------------------------------------------------------
   -- From_Status
   -----------------------------------------------------------------------

   function From_Status (Raw : unsigned_char) return Error_Code is
   begin
      case Raw is
         when 0 => return Success;
         when 1 => return Invalid_State;
         when 2 => return Validation_Failed;
         when others => return Unknown_Error;
      end case;
   end From_Status;

   -----------------------------------------------------------------------
   -- From_Slot
   -----------------------------------------------------------------------

   function From_Slot (Raw : int) return Result_Type is
   begin
      if Raw >= 0 then
         return (Ok => True, Code => Success);
      else
         return (Ok => False, Code => Pool_Exhausted);
      end if;
   end From_Slot;

   -----------------------------------------------------------------------
   -- Check_Status
   -----------------------------------------------------------------------

   procedure Check_Status (Raw : unsigned_char) is
      Code : constant Error_Code := From_Status (Raw);
   begin
      if Code /= Success then
         raise Proven_Error_Exception with Error_Code'Image (Code);
      end if;
   end Check_Status;

   -----------------------------------------------------------------------
   -- Check_Slot
   -----------------------------------------------------------------------

   function Check_Slot (Raw : int) return Slot_Id is
   begin
      if Raw < 0 then
         raise Proven_Error_Exception with "Pool_Exhausted";
      end if;
      return Slot_Id (Raw);
   end Check_Slot;

end Proven_Error;
