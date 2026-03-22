-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-modbus protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Modbus is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Modbus function codes (tags 0-9).
   type Function_Code is
     (Fc_Read_Coils, Fc_Read_Discrete_Inputs,
      Fc_Read_Holding_Registers, Fc_Read_Input_Registers,
      Fc_Write_Single_Coil, Fc_Write_Single_Register,
      Fc_Write_Multiple_Coils, Fc_Write_Multiple_Registers,
      Fc_Read_Write_Multiple_Registers, Fc_Mask_Write_Register);
   for Function_Code use
     (Fc_Read_Coils => 0, Fc_Read_Discrete_Inputs => 1,
      Fc_Read_Holding_Registers => 2, Fc_Read_Input_Registers => 3,
      Fc_Write_Single_Coil => 4, Fc_Write_Single_Register => 5,
      Fc_Write_Multiple_Coils => 6, Fc_Write_Multiple_Registers => 7,
      Fc_Read_Write_Multiple_Registers => 8, Fc_Mask_Write_Register => 9);
   pragma Convention (C, Function_Code);

   -- Modbus exception codes (tags 0-8).
   type Exception_Code is
     (Exc_Illegal_Function, Exc_Illegal_Data_Address,
      Exc_Illegal_Data_Value, Exc_Slave_Device_Failure,
      Exc_Acknowledge, Exc_Slave_Device_Busy,
      Exc_Memory_Parity_Error, Exc_Gateway_Path_Unavailable,
      Exc_Gateway_Target_Device_Failed);
   for Exception_Code use
     (Exc_Illegal_Function => 0, Exc_Illegal_Data_Address => 1,
      Exc_Illegal_Data_Value => 2, Exc_Slave_Device_Failure => 3,
      Exc_Acknowledge => 4, Exc_Slave_Device_Busy => 5,
      Exc_Memory_Parity_Error => 6, Exc_Gateway_Path_Unavailable => 7,
      Exc_Gateway_Target_Device_Failed => 8);
   pragma Convention (C, Exception_Code);

   -- Modbus device roles (tags 0-1).
   type Device_Role is (Role_Master, Role_Slave);
   for Device_Role use (Role_Master => 0, Role_Slave => 1);
   pragma Convention (C, Device_Role);

   -- Modbus TCP gateway states (tags 0-4).
   type Gateway_State is
     (Gw_Idle, Gw_Listening, Gw_Processing, Gw_Error, Gw_Stopping);
   for Gateway_State use
     (Gw_Idle => 0, Gw_Listening => 1, Gw_Processing => 2,
      Gw_Error => 3, Gw_Stopping => 4);
   pragma Convention (C, Gateway_State);

   -- Standard Modbus TCP port.
   Modbus_Tcp_Port : constant := 502;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "modbus_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "modbus_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "modbus_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "modbus_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "modbus_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Modbus;
