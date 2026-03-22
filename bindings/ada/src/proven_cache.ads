-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-cache protocol (Cache server (Redis/Memcached compatible)).
--
-- Wraps the C-ABI functions from protocols/proven-cache/ffi/zig/src/cache.zig:
--   cache_abi_version, cache_create_context, cache_destroy_context,
--   cache_state, cache_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Cache is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `Command` in `CacheABI.Types`.
   type Command is
     (Get,
      Set,
      Delete,
      Exists,
      Expire,
      Ttl,
      Keys,
      Flush,
      Incr,
      Decr,
      Append,
      Prepend,
      Cas);
   pragma Convention (C, Command);

   -- Matches `EvictionPolicy` in `CacheABI.Types`.
   type Eviction_Policy is
     (Lru,
      Lfu,
      Random,
      Evict_Ttl,
      No_Eviction);
   pragma Convention (C, Eviction_Policy);

   -- Matches `DataType` in `CacheABI.Types`.
   type Data_Type is
     (String_Val,
      Int_Val,
      List_Val,
      Set_Val,
      Hash_Val);
   pragma Convention (C, Data_Type);

   -- Matches `ErrorCode` in `CacheABI.Types`.
   type Error_Code is
     (Not_Found,
      Type_Mismatch,
      Out_Of_Memory,
      Key_Too_Long,
      Value_Too_Large,
      Cas_Conflict);
   pragma Convention (C, Error_Code);

   -- Matches `ReplicationMode` in `CacheABI.Types`.
   type Replication_Mode is
     (None,
      Primary,
      Replica,
      Sentinel);
   pragma Convention (C, Replication_Mode);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "cache_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "cache_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "cache_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "cache_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "cache_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Cache;
