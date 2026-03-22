-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-vpn protocol (Virtual Private Network).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Vpn is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Tunnel types (tags 0-3).
   type Tunnel_Type is (Tun_Ipsec, Tun_Wireguard, Tun_Openvpn, Tun_L2tp);
   for Tunnel_Type use
     (Tun_Ipsec => 0, Tun_Wireguard => 1, Tun_Openvpn => 2, Tun_L2tp => 3);
   pragma Convention (C, Tunnel_Type);

   -- Tunnel phases (tags 0-6).
   type Tunnel_Phase is
     (Phase_Idle, Phase_1_Init, Phase_1_Auth, Phase_1_Done,
      Phase_2_Negotiating, Phase_Established, Phase_Expired);
   for Tunnel_Phase use
     (Phase_Idle           => 0, Phase_1_Init          => 1,
      Phase_1_Auth         => 2, Phase_1_Done          => 3,
      Phase_2_Negotiating  => 4, Phase_Established     => 5,
      Phase_Expired        => 6);
   pragma Convention (C, Tunnel_Phase);

   -- Encryption algorithms (tags 0-5).
   type Encryption_Algorithm is
     (Enc_Aes128_Cbc, Enc_Aes256_Cbc, Enc_Aes128_Gcm,
      Enc_Aes256_Gcm, Enc_Chacha20_Poly1305, Enc_Null_Cipher);
   for Encryption_Algorithm use
     (Enc_Aes128_Cbc        => 0, Enc_Aes256_Cbc        => 1,
      Enc_Aes128_Gcm        => 2, Enc_Aes256_Gcm        => 3,
      Enc_Chacha20_Poly1305 => 4, Enc_Null_Cipher       => 5);
   pragma Convention (C, Encryption_Algorithm);

   -- Integrity algorithms (tags 0-4).
   type Integrity_Algorithm is
     (Integ_Hmac_Sha1, Integ_Hmac_Sha256, Integ_Hmac_Sha384,
      Integ_Hmac_Sha512, Integ_No_Integrity);
   for Integrity_Algorithm use
     (Integ_Hmac_Sha1   => 0, Integ_Hmac_Sha256 => 1,
      Integ_Hmac_Sha384 => 2, Integ_Hmac_Sha512 => 3,
      Integ_No_Integrity => 4);
   pragma Convention (C, Integrity_Algorithm);

   -- Diffie-Hellman groups (tags 0-3).
   type Dh_Group is (Dh_14, Dh_Ecp256, Dh_Ecp384, Dh_Curve25519);
   for Dh_Group use
     (Dh_14 => 0, Dh_Ecp256 => 1, Dh_Ecp384 => 2, Dh_Curve25519 => 3);
   pragma Convention (C, Dh_Group);

   -- SA lifecycle (tags 0-4).
   type Sa_Lifecycle is
     (Sa_None, Sa_Active, Sa_Rekeying, Sa_Expired, Sa_Deleted);
   for Sa_Lifecycle use
     (Sa_None => 0, Sa_Active => 1, Sa_Rekeying => 2,
      Sa_Expired => 3, Sa_Deleted => 4);
   pragma Convention (C, Sa_Lifecycle);

   -- IKE versions (tags 0-1).
   type Ike_Version is (Ike_V1, Ike_V2);
   for Ike_Version use (Ike_V1 => 0, Ike_V2 => 1);
   pragma Convention (C, Ike_Version);

   -- VPN error codes (tags 0-5).
   type Vpn_Error is
     (Err_Authentication_Failed, Err_No_Proposal_Chosen,
      Err_Lifetime_Expired, Err_Invalid_Spi,
      Err_Replay_Detected, Err_Negotiation_Timeout);
   for Vpn_Error use
     (Err_Authentication_Failed => 0, Err_No_Proposal_Chosen => 1,
      Err_Lifetime_Expired      => 2, Err_Invalid_Spi        => 3,
      Err_Replay_Detected       => 4, Err_Negotiation_Timeout => 5);
   pragma Convention (C, Vpn_Error);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "vpn_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "vpn_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "vpn_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "vpn_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "vpn_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Vpn;
