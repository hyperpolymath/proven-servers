-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- VPNABI.Layout: C-ABI-compatible numeric representations of VPN types.
--
-- Maps every constructor of the core VPN sum types to fixed Bits8 values
-- for C interop.  Each type gets a total encoder, partial decoder, and
-- roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/vpn.h) and the
-- Zig FFI enums (ffi/zig/src/vpn.zig) exactly.
--
-- Types covered:
--   TunnelType            (4 constructors, tags 0-3)
--   TunnelPhase           (7 constructors, tags 0-6)
--   EncryptionAlgorithm   (6 constructors, tags 0-5)
--   IntegrityAlgorithm    (5 constructors, tags 0-4)
--   DHGroup               (4 constructors, tags 0-3)
--   SALifecycle           (5 constructors, tags 0-4)
--   IKEVersion            (2 constructors, tags 0-1)
--   ErrorReason           (6 constructors, tags 0-5)

module VPNABI.Layout

import VPN.Types

%default total

---------------------------------------------------------------------------
-- TunnelType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| VPN tunnel protocol types.
public export
data TunnelType : Type where
  ||| IPSec tunnel (IKEv1/IKEv2 + ESP/AH).
  IPSec     : TunnelType
  ||| WireGuard tunnel (Noise protocol framework).
  WireGuard : TunnelType
  ||| OpenVPN tunnel (TLS-based).
  OpenVPN   : TunnelType
  ||| L2TP/IPSec tunnel (Layer 2 Tunneling Protocol over IPSec).
  L2TP      : TunnelType

public export
Eq TunnelType where
  IPSec     == IPSec     = True
  WireGuard == WireGuard = True
  OpenVPN   == OpenVPN   = True
  L2TP      == L2TP      = True
  _         == _         = False

public export
Show TunnelType where
  show IPSec     = "IPSec"
  show WireGuard = "WireGuard"
  show OpenVPN   = "OpenVPN"
  show L2TP      = "L2TP"

public export
tunnelTypeSize : Nat
tunnelTypeSize = 1

public export
tunnelTypeToTag : TunnelType -> Bits8
tunnelTypeToTag IPSec     = 0
tunnelTypeToTag WireGuard = 1
tunnelTypeToTag OpenVPN   = 2
tunnelTypeToTag L2TP      = 3

public export
tagToTunnelType : Bits8 -> Maybe TunnelType
tagToTunnelType 0 = Just IPSec
tagToTunnelType 1 = Just WireGuard
tagToTunnelType 2 = Just OpenVPN
tagToTunnelType 3 = Just L2TP
tagToTunnelType _ = Nothing

public export
tunnelTypeRoundtrip : (t : TunnelType) -> tagToTunnelType (tunnelTypeToTag t) = Just t
tunnelTypeRoundtrip IPSec     = Refl
tunnelTypeRoundtrip WireGuard = Refl
tunnelTypeRoundtrip OpenVPN   = Refl
tunnelTypeRoundtrip L2TP      = Refl

---------------------------------------------------------------------------
-- TunnelPhase (7 constructors, tags 0-6)
--
-- Models the combined IKE/tunnel establishment state machine.
-- Phase 1 (IKE SA): Idle -> Phase1Init -> Phase1Auth -> Phase1Done
-- Phase 2 (Child SA / tunnel): Phase1Done -> Phase2Negotiating -> Established
-- Terminal: Expired (SA lifetime exceeded or rekey failure)
---------------------------------------------------------------------------

public export
data TunnelPhase : Type where
  ||| No tunnel configured. Initial state.
  Idle              : TunnelPhase
  ||| IKE Phase 1: SA_INIT exchange sent/received.
  Phase1Init        : TunnelPhase
  ||| IKE Phase 1: AUTH exchange in progress (identity verification).
  Phase1Auth        : TunnelPhase
  ||| IKE Phase 1 complete: IKE SA established.
  Phase1Done        : TunnelPhase
  ||| IKE Phase 2: Child SA / Quick Mode negotiation in progress.
  Phase2Negotiating : TunnelPhase
  ||| Tunnel fully established. Data can flow.
  Established       : TunnelPhase
  ||| SA expired or rekey failed. Terminal state requiring restart.
  Expired           : TunnelPhase

public export
Eq TunnelPhase where
  Idle              == Idle              = True
  Phase1Init        == Phase1Init        = True
  Phase1Auth        == Phase1Auth        = True
  Phase1Done        == Phase1Done        = True
  Phase2Negotiating == Phase2Negotiating = True
  Established       == Established       = True
  Expired           == Expired           = True
  _                 == _                 = False

public export
Show TunnelPhase where
  show Idle              = "Idle"
  show Phase1Init        = "Phase1Init"
  show Phase1Auth        = "Phase1Auth"
  show Phase1Done        = "Phase1Done"
  show Phase2Negotiating = "Phase2Negotiating"
  show Established       = "Established"
  show Expired           = "Expired"

public export
tunnelPhaseSize : Nat
tunnelPhaseSize = 1

public export
tunnelPhaseToTag : TunnelPhase -> Bits8
tunnelPhaseToTag Idle              = 0
tunnelPhaseToTag Phase1Init        = 1
tunnelPhaseToTag Phase1Auth        = 2
tunnelPhaseToTag Phase1Done        = 3
tunnelPhaseToTag Phase2Negotiating = 4
tunnelPhaseToTag Established       = 5
tunnelPhaseToTag Expired           = 6

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

public export
tunnelPhaseRoundtrip : (p : TunnelPhase) -> tagToTunnelPhase (tunnelPhaseToTag p) = Just p
tunnelPhaseRoundtrip Idle              = Refl
tunnelPhaseRoundtrip Phase1Init        = Refl
tunnelPhaseRoundtrip Phase1Auth        = Refl
tunnelPhaseRoundtrip Phase1Done        = Refl
tunnelPhaseRoundtrip Phase2Negotiating = Refl
tunnelPhaseRoundtrip Established       = Refl
tunnelPhaseRoundtrip Expired           = Refl

---------------------------------------------------------------------------
-- EncryptionAlgorithm (6 constructors, tags 0-5)
--
-- Encryption algorithms for ESP/IKE transforms.
-- AES-GCM-256 and ChaCha20-Poly1305 are preferred (AEAD).
---------------------------------------------------------------------------

public export
data EncryptionAlgorithm : Type where
  ||| AES-128 in CBC mode (legacy, IPSec).
  AES128CBC       : EncryptionAlgorithm
  ||| AES-256 in CBC mode (legacy, IPSec).
  AES256CBC       : EncryptionAlgorithm
  ||| AES-128 in GCM mode (AEAD, recommended).
  AES128GCM       : EncryptionAlgorithm
  ||| AES-256 in GCM mode (AEAD, strongly recommended).
  AES256GCM       : EncryptionAlgorithm
  ||| ChaCha20-Poly1305 (AEAD, WireGuard default, RFC 7539).
  ChaCha20Poly1305 : EncryptionAlgorithm
  ||| No encryption (NULL cipher, authentication-only ESP).
  NullCipher      : EncryptionAlgorithm

public export
Eq EncryptionAlgorithm where
  AES128CBC        == AES128CBC        = True
  AES256CBC        == AES256CBC        = True
  AES128GCM        == AES128GCM        = True
  AES256GCM        == AES256GCM        = True
  ChaCha20Poly1305 == ChaCha20Poly1305 = True
  NullCipher       == NullCipher       = True
  _                == _                = False

public export
Show EncryptionAlgorithm where
  show AES128CBC        = "AES-128-CBC"
  show AES256CBC        = "AES-256-CBC"
  show AES128GCM        = "AES-128-GCM"
  show AES256GCM        = "AES-256-GCM"
  show ChaCha20Poly1305 = "ChaCha20-Poly1305"
  show NullCipher       = "NULL"

public export
encryptionAlgorithmSize : Nat
encryptionAlgorithmSize = 1

public export
encryptionAlgorithmToTag : EncryptionAlgorithm -> Bits8
encryptionAlgorithmToTag AES128CBC        = 0
encryptionAlgorithmToTag AES256CBC        = 1
encryptionAlgorithmToTag AES128GCM        = 2
encryptionAlgorithmToTag AES256GCM        = 3
encryptionAlgorithmToTag ChaCha20Poly1305 = 4
encryptionAlgorithmToTag NullCipher       = 5

public export
tagToEncryptionAlgorithm : Bits8 -> Maybe EncryptionAlgorithm
tagToEncryptionAlgorithm 0 = Just AES128CBC
tagToEncryptionAlgorithm 1 = Just AES256CBC
tagToEncryptionAlgorithm 2 = Just AES128GCM
tagToEncryptionAlgorithm 3 = Just AES256GCM
tagToEncryptionAlgorithm 4 = Just ChaCha20Poly1305
tagToEncryptionAlgorithm 5 = Just NullCipher
tagToEncryptionAlgorithm _ = Nothing

public export
encryptionAlgorithmRoundtrip : (a : EncryptionAlgorithm) -> tagToEncryptionAlgorithm (encryptionAlgorithmToTag a) = Just a
encryptionAlgorithmRoundtrip AES128CBC        = Refl
encryptionAlgorithmRoundtrip AES256CBC        = Refl
encryptionAlgorithmRoundtrip AES128GCM        = Refl
encryptionAlgorithmRoundtrip AES256GCM        = Refl
encryptionAlgorithmRoundtrip ChaCha20Poly1305 = Refl
encryptionAlgorithmRoundtrip NullCipher       = Refl

---------------------------------------------------------------------------
-- IntegrityAlgorithm (5 constructors, tags 0-4)
--
-- Message authentication / integrity algorithms for ESP/IKE.
-- HMAC-SHA256 and HMAC-SHA384 are recommended.
-- None is valid only when using AEAD ciphers (GCM, ChaCha20-Poly1305).
---------------------------------------------------------------------------

public export
data IntegrityAlgorithm : Type where
  ||| HMAC-SHA-1-96 (legacy, 96-bit truncated).
  HMACSHA1       : IntegrityAlgorithm
  ||| HMAC-SHA-256-128 (recommended, 128-bit truncated).
  HMACSHA256     : IntegrityAlgorithm
  ||| HMAC-SHA-384-192 (strong, 192-bit truncated).
  HMACSHA384     : IntegrityAlgorithm
  ||| HMAC-SHA-512-256 (strongest, 256-bit truncated).
  HMACSHA512     : IntegrityAlgorithm
  ||| No separate integrity (valid only with AEAD ciphers).
  NoIntegrity    : IntegrityAlgorithm

public export
Eq IntegrityAlgorithm where
  HMACSHA1    == HMACSHA1    = True
  HMACSHA256  == HMACSHA256  = True
  HMACSHA384  == HMACSHA384  = True
  HMACSHA512  == HMACSHA512  = True
  NoIntegrity == NoIntegrity = True
  _           == _           = False

public export
Show IntegrityAlgorithm where
  show HMACSHA1    = "HMAC-SHA-1-96"
  show HMACSHA256  = "HMAC-SHA-256-128"
  show HMACSHA384  = "HMAC-SHA-384-192"
  show HMACSHA512  = "HMAC-SHA-512-256"
  show NoIntegrity = "None"

public export
integrityAlgorithmSize : Nat
integrityAlgorithmSize = 1

public export
integrityAlgorithmToTag : IntegrityAlgorithm -> Bits8
integrityAlgorithmToTag HMACSHA1    = 0
integrityAlgorithmToTag HMACSHA256  = 1
integrityAlgorithmToTag HMACSHA384  = 2
integrityAlgorithmToTag HMACSHA512  = 3
integrityAlgorithmToTag NoIntegrity = 4

public export
tagToIntegrityAlgorithm : Bits8 -> Maybe IntegrityAlgorithm
tagToIntegrityAlgorithm 0 = Just HMACSHA1
tagToIntegrityAlgorithm 1 = Just HMACSHA256
tagToIntegrityAlgorithm 2 = Just HMACSHA384
tagToIntegrityAlgorithm 3 = Just HMACSHA512
tagToIntegrityAlgorithm 4 = Just NoIntegrity
tagToIntegrityAlgorithm _ = Nothing

public export
integrityAlgorithmRoundtrip : (a : IntegrityAlgorithm) -> tagToIntegrityAlgorithm (integrityAlgorithmToTag a) = Just a
integrityAlgorithmRoundtrip HMACSHA1    = Refl
integrityAlgorithmRoundtrip HMACSHA256  = Refl
integrityAlgorithmRoundtrip HMACSHA384  = Refl
integrityAlgorithmRoundtrip HMACSHA512  = Refl
integrityAlgorithmRoundtrip NoIntegrity = Refl

---------------------------------------------------------------------------
-- DHGroup (4 constructors, tags 0-3)
--
-- Diffie-Hellman groups for IKE key exchange.
---------------------------------------------------------------------------

public export
data DHGroup : Type where
  ||| DH Group 14 (2048-bit MODP, RFC 3526).
  DH14       : DHGroup
  ||| DH Group 19 (256-bit ECP, RFC 5903). Recommended.
  ECP256     : DHGroup
  ||| DH Group 20 (384-bit ECP, RFC 5903). Strong.
  ECP384     : DHGroup
  ||| Curve25519 (RFC 8031). WireGuard default.
  Curve25519 : DHGroup

public export
Eq DHGroup where
  DH14       == DH14       = True
  ECP256     == ECP256     = True
  ECP384     == ECP384     = True
  Curve25519 == Curve25519 = True
  _          == _          = False

public export
Show DHGroup where
  show DH14       = "DH-14 (2048-bit MODP)"
  show ECP256     = "ECP-256"
  show ECP384     = "ECP-384"
  show Curve25519 = "Curve25519"

public export
dhGroupSize : Nat
dhGroupSize = 1

public export
dhGroupToTag : DHGroup -> Bits8
dhGroupToTag DH14       = 0
dhGroupToTag ECP256     = 1
dhGroupToTag ECP384     = 2
dhGroupToTag Curve25519 = 3

public export
tagToDHGroup : Bits8 -> Maybe DHGroup
tagToDHGroup 0 = Just DH14
tagToDHGroup 1 = Just ECP256
tagToDHGroup 2 = Just ECP384
tagToDHGroup 3 = Just Curve25519
tagToDHGroup _ = Nothing

public export
dhGroupRoundtrip : (g : DHGroup) -> tagToDHGroup (dhGroupToTag g) = Just g
dhGroupRoundtrip DH14       = Refl
dhGroupRoundtrip ECP256     = Refl
dhGroupRoundtrip ECP384     = Refl
dhGroupRoundtrip Curve25519 = Refl

---------------------------------------------------------------------------
-- SALifecycle (5 constructors, tags 0-4)
--
-- Security Association lifecycle states.
-- Tracks the SA from creation through rekeying to expiry.
---------------------------------------------------------------------------

public export
data SALifecycle : Type where
  ||| SA not yet created.
  SANone      : SALifecycle
  ||| SA is active and within its lifetime.
  SAActive    : SALifecycle
  ||| SA is approaching expiry, rekey initiated.
  SARekeying  : SALifecycle
  ||| SA has expired (hard lifetime reached).
  SAExpired   : SALifecycle
  ||| SA was explicitly deleted (DELETE payload received).
  SADeleted   : SALifecycle

public export
Eq SALifecycle where
  SANone     == SANone     = True
  SAActive   == SAActive   = True
  SARekeying == SARekeying = True
  SAExpired  == SAExpired  = True
  SADeleted  == SADeleted  = True
  _          == _          = False

public export
Show SALifecycle where
  show SANone     = "None"
  show SAActive   = "Active"
  show SARekeying = "Rekeying"
  show SAExpired  = "Expired"
  show SADeleted  = "Deleted"

public export
saLifecycleSize : Nat
saLifecycleSize = 1

public export
saLifecycleToTag : SALifecycle -> Bits8
saLifecycleToTag SANone     = 0
saLifecycleToTag SAActive   = 1
saLifecycleToTag SARekeying = 2
saLifecycleToTag SAExpired  = 3
saLifecycleToTag SADeleted  = 4

public export
tagToSALifecycle : Bits8 -> Maybe SALifecycle
tagToSALifecycle 0 = Just SANone
tagToSALifecycle 1 = Just SAActive
tagToSALifecycle 2 = Just SARekeying
tagToSALifecycle 3 = Just SAExpired
tagToSALifecycle 4 = Just SADeleted
tagToSALifecycle _ = Nothing

public export
saLifecycleRoundtrip : (s : SALifecycle) -> tagToSALifecycle (saLifecycleToTag s) = Just s
saLifecycleRoundtrip SANone     = Refl
saLifecycleRoundtrip SAActive   = Refl
saLifecycleRoundtrip SARekeying = Refl
saLifecycleRoundtrip SAExpired  = Refl
saLifecycleRoundtrip SADeleted  = Refl

---------------------------------------------------------------------------
-- IKEVersion (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
data IKEVersion : Type where
  ||| IKEv1 (RFC 2409). Legacy.
  IKEv1 : IKEVersion
  ||| IKEv2 (RFC 7296). Strongly recommended.
  IKEv2 : IKEVersion

public export
Eq IKEVersion where
  IKEv1 == IKEv1 = True
  IKEv2 == IKEv2 = True
  _     == _     = False

public export
Show IKEVersion where
  show IKEv1 = "IKEv1"
  show IKEv2 = "IKEv2"

public export
ikeVersionSize : Nat
ikeVersionSize = 1

public export
ikeVersionToTag : IKEVersion -> Bits8
ikeVersionToTag IKEv1 = 0
ikeVersionToTag IKEv2 = 1

public export
tagToIKEVersion : Bits8 -> Maybe IKEVersion
tagToIKEVersion 0 = Just IKEv1
tagToIKEVersion 1 = Just IKEv2
tagToIKEVersion _ = Nothing

public export
ikeVersionRoundtrip : (v : IKEVersion) -> tagToIKEVersion (ikeVersionToTag v) = Just v
ikeVersionRoundtrip IKEv1 = Refl
ikeVersionRoundtrip IKEv2 = Refl

---------------------------------------------------------------------------
-- VPNError (6 constructors, tags 0-5)
--
-- Error reasons specific to VPN tunnel operations.
---------------------------------------------------------------------------

public export
data VPNError : Type where
  ||| Peer authentication failed (bad certificate / PSK / signature).
  AuthenticationFailed  : VPNError
  ||| No acceptable proposal found during SA negotiation.
  NoProposalChosen      : VPNError
  ||| SA lifetime expired (hard timeout).
  LifetimeExpired       : VPNError
  ||| Invalid SPI (Security Parameter Index) received.
  InvalidSPI            : VPNError
  ||| Replay attack detected (anti-replay window).
  VPNReplayDetected     : VPNError
  ||| Negotiation timeout (no response within deadline).
  NegotiationTimeout    : VPNError

public export
Eq VPNError where
  AuthenticationFailed == AuthenticationFailed = True
  NoProposalChosen     == NoProposalChosen     = True
  LifetimeExpired      == LifetimeExpired      = True
  InvalidSPI           == InvalidSPI           = True
  VPNReplayDetected    == VPNReplayDetected    = True
  NegotiationTimeout   == NegotiationTimeout   = True
  _                    == _                    = False

public export
Show VPNError where
  show AuthenticationFailed = "AuthenticationFailed"
  show NoProposalChosen     = "NoProposalChosen"
  show LifetimeExpired      = "LifetimeExpired"
  show InvalidSPI           = "InvalidSPI"
  show VPNReplayDetected    = "ReplayDetected"
  show NegotiationTimeout   = "NegotiationTimeout"

public export
vpnErrorSize : Nat
vpnErrorSize = 1

public export
vpnErrorToTag : VPNError -> Bits8
vpnErrorToTag AuthenticationFailed = 0
vpnErrorToTag NoProposalChosen     = 1
vpnErrorToTag LifetimeExpired      = 2
vpnErrorToTag InvalidSPI           = 3
vpnErrorToTag VPNReplayDetected    = 4
vpnErrorToTag NegotiationTimeout   = 5

public export
tagToVPNError : Bits8 -> Maybe VPNError
tagToVPNError 0 = Just AuthenticationFailed
tagToVPNError 1 = Just NoProposalChosen
tagToVPNError 2 = Just LifetimeExpired
tagToVPNError 3 = Just InvalidSPI
tagToVPNError 4 = Just VPNReplayDetected
tagToVPNError 5 = Just NegotiationTimeout
tagToVPNError _ = Nothing

public export
vpnErrorRoundtrip : (e : VPNError) -> tagToVPNError (vpnErrorToTag e) = Just e
vpnErrorRoundtrip AuthenticationFailed = Refl
vpnErrorRoundtrip NoProposalChosen     = Refl
vpnErrorRoundtrip LifetimeExpired      = Refl
vpnErrorRoundtrip InvalidSPI           = Refl
vpnErrorRoundtrip VPNReplayDetected    = Refl
vpnErrorRoundtrip NegotiationTimeout   = Refl
