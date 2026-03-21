-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-dns protocol (DNS server).
--
-- Wraps the C-ABI functions from protocols/proven-dns/ffi/zig/src/dns.zig:
--   dns_abi_version, dns_create_context, dns_destroy_context,
--   dns_parse_query, dns_begin_lookup, dns_begin_response,
--   dns_add_answer, dns_add_authority, dns_add_additional,
--   dns_set_rcode, dns_build_response, dns_enable_dnssec,
--   dns_load_dnssec_key, dns_sign_response, dns_validate_dnssec,
--   dns_state, dns_dnssec_state, dns_rcode, dns_answer_count,
--   dns_authority_count, dns_additional_count, dns_query_rtype,
--   dns_query_class, dns_can_transition, dns_can_dnssec_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Dns is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- DNS query lifecycle states matching DnsState in dns.zig.
   type Dns_State is
     (State_Idle,
      State_Query_Received,
      State_Lookup,
      State_Response_Building,
      State_Sent);
   for Dns_State use
     (State_Idle              => 0,
      State_Query_Received    => 1,
      State_Lookup            => 2,
      State_Response_Building => 3,
      State_Sent              => 4);
   pragma Convention (C, Dns_State);

   -- DNSSEC processing states.
   type Dnssec_State is
     (Dnssec_Disabled,
      Dnssec_Enabled,
      Dnssec_Key_Loaded,
      Dnssec_Signed,
      Dnssec_Validated);
   for Dnssec_State use
     (Dnssec_Disabled   => 0,
      Dnssec_Enabled    => 1,
      Dnssec_Key_Loaded => 2,
      Dnssec_Signed     => 3,
      Dnssec_Validated  => 4);
   pragma Convention (C, Dnssec_State);

   -- DNS record types (subset).
   type Record_Type is
     (RType_A,
      RType_AAAA,
      RType_CNAME,
      RType_MX,
      RType_NS,
      RType_PTR,
      RType_SOA,
      RType_SRV,
      RType_TXT);
   pragma Convention (C, Record_Type);

   -- DNS response codes.
   type Rcode is
     (Rcode_NoError,
      Rcode_FormErr,
      Rcode_ServFail,
      Rcode_NXDomain,
      Rcode_NotImp,
      Rcode_Refused);
   for Rcode use
     (Rcode_NoError  => 0,
      Rcode_FormErr  => 1,
      Rcode_ServFail => 2,
      Rcode_NXDomain => 3,
      Rcode_NotImp   => 4,
      Rcode_Refused  => 5);
   pragma Convention (C, Rcode);

   -- DNS record class.
   type Record_Class is (Class_IN, Class_CH, Class_HS, Class_ANY);
   for Record_Class use
     (Class_IN => 0, Class_CH => 1, Class_HS => 2, Class_ANY => 3);
   pragma Convention (C, Record_Class);

   -- DNSSEC algorithm identifiers.
   type Dnssec_Algorithm is
     (Algo_RSASHA256,
      Algo_RSASHA512,
      Algo_ECDSAP256,
      Algo_ECDSAP384,
      Algo_ED25519);
   pragma Convention (C, Dnssec_Algorithm);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "dns_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "dns_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "dns_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "dns_state");

   function Get_Dnssec_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_Dnssec_State, "dns_dnssec_state");

   function Get_Rcode (Slot : int) return unsigned_char;
   pragma Import (C, Get_Rcode, "dns_rcode");

   function Answer_Count (Slot : int) return unsigned_short;
   pragma Import (C, Answer_Count, "dns_answer_count");

   function Authority_Count (Slot : int) return unsigned_short;
   pragma Import (C, Authority_Count, "dns_authority_count");

   function Additional_Count (Slot : int) return unsigned_short;
   pragma Import (C, Additional_Count, "dns_additional_count");

   function Query_Rtype (Slot : int) return unsigned_char;
   pragma Import (C, Query_Rtype, "dns_query_rtype");

   function Query_Class (Slot : int) return unsigned_char;
   pragma Import (C, Query_Class, "dns_query_class");

   function Parse_Query
     (Slot : int;
      Buf  : access unsigned_char;
      Len  : unsigned_short) return unsigned_char;
   pragma Import (C, Parse_Query, "dns_parse_query");

   function Begin_Lookup (Slot : int) return unsigned_char;
   pragma Import (C, Begin_Lookup, "dns_begin_lookup");

   function Begin_Response (Slot : int) return unsigned_char;
   pragma Import (C, Begin_Response, "dns_begin_response");

   function Add_Answer
     (Slot   : int;
      Rtype  : unsigned_char;
      Rclass : unsigned_char;
      TTL    : unsigned;
      Rdata  : access unsigned_char;
      Rdlen  : unsigned_short) return unsigned_char;
   pragma Import (C, Add_Answer, "dns_add_answer");

   function Add_Authority
     (Slot   : int;
      Rtype  : unsigned_char;
      Rclass : unsigned_char;
      TTL    : unsigned;
      Rdata  : access unsigned_char;
      Rdlen  : unsigned_short) return unsigned_char;
   pragma Import (C, Add_Authority, "dns_add_authority");

   function Add_Additional
     (Slot   : int;
      Rtype  : unsigned_char;
      Rclass : unsigned_char;
      TTL    : unsigned;
      Rdata  : access unsigned_char;
      Rdlen  : unsigned_short) return unsigned_char;
   pragma Import (C, Add_Additional, "dns_add_additional");

   function Set_Rcode
     (Slot      : int;
      Rcode_Tag : unsigned_char) return unsigned_char;
   pragma Import (C, Set_Rcode, "dns_set_rcode");

   function Build_Response
     (Slot    : int;
      Out_Buf : access unsigned_char;
      Out_Len : access unsigned_short) return unsigned_char;
   pragma Import (C, Build_Response, "dns_build_response");

   function Enable_Dnssec (Slot : int) return unsigned_char;
   pragma Import (C, Enable_Dnssec, "dns_enable_dnssec");

   function Load_Dnssec_Key
     (Slot : int;
      Algo : unsigned_char) return unsigned_char;
   pragma Import (C, Load_Dnssec_Key, "dns_load_dnssec_key");

   function Sign_Response (Slot : int) return unsigned_char;
   pragma Import (C, Sign_Response, "dns_sign_response");

   function Validate_Dnssec (Slot : int) return unsigned_char;
   pragma Import (C, Validate_Dnssec, "dns_validate_dnssec");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "dns_can_transition");

   function Can_Dnssec_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Dnssec_Transition, "dns_can_dnssec_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);
   procedure Safe_Begin_Lookup (Slot : Proven_Error.Slot_Id);
   procedure Safe_Begin_Response (Slot : Proven_Error.Slot_Id);

end Proven_Dns;
