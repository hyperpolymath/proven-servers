-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- VpnABI.Types: C-ABI-compatible numeric representations of Vpn types.
--
-- Maps every constructor of the core Vpn sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/vpn.zig) exactly.
--
-- Types covered:
--   TunnelType                (4 constructors, tags 0-3)
--   TunnelPhase               (7 constructors, tags 0-6)
--   EncryptionAlgorithm       (6 constructors, tags 0-5)
--   IntegrityAlgorithm        (5 constructors, tags 0-4)
--   DHGroup                   (4 constructors, tags 0-3)
--   SALifecycle               (5 constructors, tags 0-4)
--   IKEVersion                (2 constructors, tags 0-1)
--   VPNError                  (6 constructors, tags 0-5)

module VpnABI.Types

%default total

---------------------------------------------------------------------------
-- TunnelType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
tunnel_typeSize : Nat
tunnel_typeSize = 1

||| TunnelType sum type for ABI encoding.
public export
data TunnelType : Type where
  Ipsec : TunnelType
  Wireguard : TunnelType
  Openvpn : TunnelType
  L2tp : TunnelType

||| Encode a TunnelType to its ABI tag value.
public export
tunnel_typeToTag : TunnelType -> Bits8
tunnel_typeToTag Ipsec = 0
tunnel_typeToTag Wireguard = 1
tunnel_typeToTag Openvpn = 2
tunnel_typeToTag L2tp = 3

||| Decode an ABI tag to a TunnelType.
public export
tagToTunnelType : Bits8 -> Maybe TunnelType
tagToTunnelType 0 = Just Ipsec
tagToTunnelType 1 = Just Wireguard
tagToTunnelType 2 = Just Openvpn
tagToTunnelType 3 = Just L2tp
tagToTunnelType _ = Nothing

||| Roundtrip proof: decoding an encoded TunnelType yields the original.
public export
tunnel_typeRoundtrip : (x : TunnelType) -> tagToTunnelType (tunnel_typeToTag x) = Just x
tunnel_typeRoundtrip Ipsec = Refl
tunnel_typeRoundtrip Wireguard = Refl
tunnel_typeRoundtrip Openvpn = Refl
tunnel_typeRoundtrip L2tp = Refl

---------------------------------------------------------------------------
-- TunnelPhase (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
tunnel_phaseSize : Nat
tunnel_phaseSize = 1

||| TunnelPhase sum type for ABI encoding.
public export
data TunnelPhase : Type where
  Idle : TunnelPhase
  Phase1Init : TunnelPhase
  Phase1Auth : TunnelPhase
  Phase1Done : TunnelPhase
  Phase2Negotiating : TunnelPhase
  Established : TunnelPhase
  Expired : TunnelPhase

||| Encode a TunnelPhase to its ABI tag value.
public export
tunnel_phaseToTag : TunnelPhase -> Bits8
tunnel_phaseToTag Idle = 0
tunnel_phaseToTag Phase1Init = 1
tunnel_phaseToTag Phase1Auth = 2
tunnel_phaseToTag Phase1Done = 3
tunnel_phaseToTag Phase2Negotiating = 4
tunnel_phaseToTag Established = 5
tunnel_phaseToTag Expired = 6

||| Decode an ABI tag to a TunnelPhase.
public export
tagToTunnelPhase : Bits8 -> Maybe TunnelPhase
tagToTunnelPhase 0 = Just Idle
tagToTunnelPhase 1 = Just Phase1Init
tagToTunnelPhase 2 = Just Phase1Auth
tagToTunnelPhase 3 = Just Phase1Done
tagToTunnelPhase 4 = Just Phase2Negotiating
tagToTunnelPhase 5 = Just Established
tagToTunnelPhase 6 = Just Expired
tagToTunnelPhase _ = Nothing

||| Roundtrip proof: decoding an encoded TunnelPhase yields the original.
public export
tunnel_phaseRoundtrip : (x : TunnelPhase) -> tagToTunnelPhase (tunnel_phaseToTag x) = Just x
tunnel_phaseRoundtrip Idle = Refl
tunnel_phaseRoundtrip Phase1Init = Refl
tunnel_phaseRoundtrip Phase1Auth = Refl
tunnel_phaseRoundtrip Phase1Done = Refl
tunnel_phaseRoundtrip Phase2Negotiating = Refl
tunnel_phaseRoundtrip Established = Refl
tunnel_phaseRoundtrip Expired = Refl

---------------------------------------------------------------------------
-- EncryptionAlgorithm (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
encryption_algorithmSize : Nat
encryption_algorithmSize = 1

||| EncryptionAlgorithm sum type for ABI encoding.
public export
data EncryptionAlgorithm : Type where
  Aes128Cbc : EncryptionAlgorithm
  Aes256Cbc : EncryptionAlgorithm
  Aes128Gcm : EncryptionAlgorithm
  Aes256Gcm : EncryptionAlgorithm
  Chacha20Poly1305 : EncryptionAlgorithm
  NullCipher : EncryptionAlgorithm

||| Encode a EncryptionAlgorithm to its ABI tag value.
public export
encryption_algorithmToTag : EncryptionAlgorithm -> Bits8
encryption_algorithmToTag Aes128Cbc = 0
encryption_algorithmToTag Aes256Cbc = 1
encryption_algorithmToTag Aes128Gcm = 2
encryption_algorithmToTag Aes256Gcm = 3
encryption_algorithmToTag Chacha20Poly1305 = 4
encryption_algorithmToTag NullCipher = 5

||| Decode an ABI tag to a EncryptionAlgorithm.
public export
tagToEncryptionAlgorithm : Bits8 -> Maybe EncryptionAlgorithm
tagToEncryptionAlgorithm 0 = Just Aes128Cbc
tagToEncryptionAlgorithm 1 = Just Aes256Cbc
tagToEncryptionAlgorithm 2 = Just Aes128Gcm
tagToEncryptionAlgorithm 3 = Just Aes256Gcm
tagToEncryptionAlgorithm 4 = Just Chacha20Poly1305
tagToEncryptionAlgorithm 5 = Just NullCipher
tagToEncryptionAlgorithm _ = Nothing

||| Roundtrip proof: decoding an encoded EncryptionAlgorithm yields the original.
public export
encryption_algorithmRoundtrip : (x : EncryptionAlgorithm) -> tagToEncryptionAlgorithm (encryption_algorithmToTag x) = Just x
encryption_algorithmRoundtrip Aes128Cbc = Refl
encryption_algorithmRoundtrip Aes256Cbc = Refl
encryption_algorithmRoundtrip Aes128Gcm = Refl
encryption_algorithmRoundtrip Aes256Gcm = Refl
encryption_algorithmRoundtrip Chacha20Poly1305 = Refl
encryption_algorithmRoundtrip NullCipher = Refl

---------------------------------------------------------------------------
-- IntegrityAlgorithm (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
integrity_algorithmSize : Nat
integrity_algorithmSize = 1

||| IntegrityAlgorithm sum type for ABI encoding.
public export
data IntegrityAlgorithm : Type where
  HmacSha1 : IntegrityAlgorithm
  HmacSha256 : IntegrityAlgorithm
  HmacSha384 : IntegrityAlgorithm
  HmacSha512 : IntegrityAlgorithm
  NoIntegrity : IntegrityAlgorithm

||| Encode a IntegrityAlgorithm to its ABI tag value.
public export
integrity_algorithmToTag : IntegrityAlgorithm -> Bits8
integrity_algorithmToTag HmacSha1 = 0
integrity_algorithmToTag HmacSha256 = 1
integrity_algorithmToTag HmacSha384 = 2
integrity_algorithmToTag HmacSha512 = 3
integrity_algorithmToTag NoIntegrity = 4

||| Decode an ABI tag to a IntegrityAlgorithm.
public export
tagToIntegrityAlgorithm : Bits8 -> Maybe IntegrityAlgorithm
tagToIntegrityAlgorithm 0 = Just HmacSha1
tagToIntegrityAlgorithm 1 = Just HmacSha256
tagToIntegrityAlgorithm 2 = Just HmacSha384
tagToIntegrityAlgorithm 3 = Just HmacSha512
tagToIntegrityAlgorithm 4 = Just NoIntegrity
tagToIntegrityAlgorithm _ = Nothing

||| Roundtrip proof: decoding an encoded IntegrityAlgorithm yields the original.
public export
integrity_algorithmRoundtrip : (x : IntegrityAlgorithm) -> tagToIntegrityAlgorithm (integrity_algorithmToTag x) = Just x
integrity_algorithmRoundtrip HmacSha1 = Refl
integrity_algorithmRoundtrip HmacSha256 = Refl
integrity_algorithmRoundtrip HmacSha384 = Refl
integrity_algorithmRoundtrip HmacSha512 = Refl
integrity_algorithmRoundtrip NoIntegrity = Refl

---------------------------------------------------------------------------
-- DHGroup (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
d_h_groupSize : Nat
d_h_groupSize = 1

||| DHGroup sum type for ABI encoding.
public export
data DHGroup : Type where
  Dh14 : DHGroup
  Ecp256 : DHGroup
  Ecp384 : DHGroup
  Curve25519 : DHGroup

||| Encode a DHGroup to its ABI tag value.
public export
d_h_groupToTag : DHGroup -> Bits8
d_h_groupToTag Dh14 = 0
d_h_groupToTag Ecp256 = 1
d_h_groupToTag Ecp384 = 2
d_h_groupToTag Curve25519 = 3

||| Decode an ABI tag to a DHGroup.
public export
tagToDHGroup : Bits8 -> Maybe DHGroup
tagToDHGroup 0 = Just Dh14
tagToDHGroup 1 = Just Ecp256
tagToDHGroup 2 = Just Ecp384
tagToDHGroup 3 = Just Curve25519
tagToDHGroup _ = Nothing

||| Roundtrip proof: decoding an encoded DHGroup yields the original.
public export
d_h_groupRoundtrip : (x : DHGroup) -> tagToDHGroup (d_h_groupToTag x) = Just x
d_h_groupRoundtrip Dh14 = Refl
d_h_groupRoundtrip Ecp256 = Refl
d_h_groupRoundtrip Ecp384 = Refl
d_h_groupRoundtrip Curve25519 = Refl

---------------------------------------------------------------------------
-- SALifecycle (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
s_a_lifecycleSize : Nat
s_a_lifecycleSize = 1

||| SALifecycle sum type for ABI encoding.
public export
data SALifecycle : Type where
  SaNone : SALifecycle
  SaActive : SALifecycle
  SaRekeying : SALifecycle
  SaExpired : SALifecycle
  SaDeleted : SALifecycle

||| Encode a SALifecycle to its ABI tag value.
public export
s_a_lifecycleToTag : SALifecycle -> Bits8
s_a_lifecycleToTag SaNone = 0
s_a_lifecycleToTag SaActive = 1
s_a_lifecycleToTag SaRekeying = 2
s_a_lifecycleToTag SaExpired = 3
s_a_lifecycleToTag SaDeleted = 4

||| Decode an ABI tag to a SALifecycle.
public export
tagToSALifecycle : Bits8 -> Maybe SALifecycle
tagToSALifecycle 0 = Just SaNone
tagToSALifecycle 1 = Just SaActive
tagToSALifecycle 2 = Just SaRekeying
tagToSALifecycle 3 = Just SaExpired
tagToSALifecycle 4 = Just SaDeleted
tagToSALifecycle _ = Nothing

||| Roundtrip proof: decoding an encoded SALifecycle yields the original.
public export
s_a_lifecycleRoundtrip : (x : SALifecycle) -> tagToSALifecycle (s_a_lifecycleToTag x) = Just x
s_a_lifecycleRoundtrip SaNone = Refl
s_a_lifecycleRoundtrip SaActive = Refl
s_a_lifecycleRoundtrip SaRekeying = Refl
s_a_lifecycleRoundtrip SaExpired = Refl
s_a_lifecycleRoundtrip SaDeleted = Refl

---------------------------------------------------------------------------
-- IKEVersion (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
i_k_e_versionSize : Nat
i_k_e_versionSize = 1

||| IKEVersion sum type for ABI encoding.
public export
data IKEVersion : Type where
  Ikev1 : IKEVersion
  Ikev2 : IKEVersion

||| Encode a IKEVersion to its ABI tag value.
public export
i_k_e_versionToTag : IKEVersion -> Bits8
i_k_e_versionToTag Ikev1 = 0
i_k_e_versionToTag Ikev2 = 1

||| Decode an ABI tag to a IKEVersion.
public export
tagToIKEVersion : Bits8 -> Maybe IKEVersion
tagToIKEVersion 0 = Just Ikev1
tagToIKEVersion 1 = Just Ikev2
tagToIKEVersion _ = Nothing

||| Roundtrip proof: decoding an encoded IKEVersion yields the original.
public export
i_k_e_versionRoundtrip : (x : IKEVersion) -> tagToIKEVersion (i_k_e_versionToTag x) = Just x
i_k_e_versionRoundtrip Ikev1 = Refl
i_k_e_versionRoundtrip Ikev2 = Refl

---------------------------------------------------------------------------
-- VPNError (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
v_p_n_errorSize : Nat
v_p_n_errorSize = 1

||| VPNError sum type for ABI encoding.
public export
data VPNError : Type where
  AuthenticationFailed : VPNError
  NoProposalChosen : VPNError
  LifetimeExpired : VPNError
  InvalidSpi : VPNError
  ReplayDetected : VPNError
  NegotiationTimeout : VPNError

||| Encode a VPNError to its ABI tag value.
public export
v_p_n_errorToTag : VPNError -> Bits8
v_p_n_errorToTag AuthenticationFailed = 0
v_p_n_errorToTag NoProposalChosen = 1
v_p_n_errorToTag LifetimeExpired = 2
v_p_n_errorToTag InvalidSpi = 3
v_p_n_errorToTag ReplayDetected = 4
v_p_n_errorToTag NegotiationTimeout = 5

||| Decode an ABI tag to a VPNError.
public export
tagToVPNError : Bits8 -> Maybe VPNError
tagToVPNError 0 = Just AuthenticationFailed
tagToVPNError 1 = Just NoProposalChosen
tagToVPNError 2 = Just LifetimeExpired
tagToVPNError 3 = Just InvalidSpi
tagToVPNError 4 = Just ReplayDetected
tagToVPNError 5 = Just NegotiationTimeout
tagToVPNError _ = Nothing

||| Roundtrip proof: decoding an encoded VPNError yields the original.
public export
v_p_n_errorRoundtrip : (x : VPNError) -> tagToVPNError (v_p_n_errorToTag x) = Just x
v_p_n_errorRoundtrip AuthenticationFailed = Refl
v_p_n_errorRoundtrip NoProposalChosen = Refl
v_p_n_errorRoundtrip LifetimeExpired = Refl
v_p_n_errorRoundtrip InvalidSpi = Refl
v_p_n_errorRoundtrip ReplayDetected = Refl
v_p_n_errorRoundtrip NegotiationTimeout = Refl
