// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kerberos protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module KerberosABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard Kerberos KDC port (RFC 4120).
let kerberosPort = 88

// ===========================================================================
// MessageType (tags 0-9)
// ===========================================================================

/// Standard Kerberos KDC port (RFC 4120).
type messageType =
  | @as(0) AsReq
  | @as(1) AsRep
  | @as(2) TgsReq
  | @as(3) TgsRep
  | @as(4) ApReq
  | @as(5) ApRep
  | @as(6) KrbError
  | @as(7) KrbSafe
  | @as(8) KrbPriv
  | @as(9) KrbCred

/// Decode from the C-ABI tag value.
let messageTypeFromTag = (tag: int): option<messageType> =>
  switch tag {
  | 0 => Some(AsReq)
  | 1 => Some(AsRep)
  | 2 => Some(TgsReq)
  | 3 => Some(TgsRep)
  | 4 => Some(ApReq)
  | 5 => Some(ApRep)
  | 6 => Some(KrbError)
  | 7 => Some(KrbSafe)
  | 8 => Some(KrbPriv)
  | 9 => Some(KrbCred)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let messageTypeToTag = (v: messageType): int =>
  switch v {
  | AsReq => 0
  | AsRep => 1
  | TgsReq => 2
  | TgsRep => 3
  | ApReq => 4
  | ApRep => 5
  | KrbError => 6
  | KrbSafe => 7
  | KrbPriv => 8
  | KrbCred => 9
  }

/// Whether this message is a request.
let messageTypeIsRequest = (v: messageType): bool =>
  switch v {
  | AsReq | TgsReq | ApReq => true
  | _ => false
  }

/// Whether this message is a reply.
let messageTypeIsReply = (v: messageType): bool =>
  switch v {
  | AsRep | TgsRep | ApRep => true
  | _ => false
  }

// ===========================================================================
// EncryptionType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type encryptionType =
  | @as(0) Aes256CtsHmacSha1
  | @as(1) Aes128CtsHmacSha1
  | @as(2) Aes256CtsHmacSha384
  | @as(3) Rc4Hmac
  | @as(4) Des3CbcSha1

/// Decode from the C-ABI tag value.
let encryptionTypeFromTag = (tag: int): option<encryptionType> =>
  switch tag {
  | 0 => Some(Aes256CtsHmacSha1)
  | 1 => Some(Aes128CtsHmacSha1)
  | 2 => Some(Aes256CtsHmacSha384)
  | 3 => Some(Rc4Hmac)
  | 4 => Some(Des3CbcSha1)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let encryptionTypeToTag = (v: encryptionType): int =>
  switch v {
  | Aes256CtsHmacSha1 => 0
  | Aes128CtsHmacSha1 => 1
  | Aes256CtsHmacSha384 => 2
  | Rc4Hmac => 3
  | Des3CbcSha1 => 4
  }

/// Whether this encryption type is considered legacy/deprecated.
let encryptionTypeIsLegacy = (v: encryptionType): bool =>
  switch v {
  | Rc4Hmac | Des3CbcSha1 => true
  | _ => false
  }

// ===========================================================================
// PrincipalType (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type principalType =
  | @as(0) NtUnknown
  | @as(1) NtPrincipal
  | @as(2) NtSrvInst
  | @as(3) NtSrvHst
  | @as(4) NtUid
  | @as(5) NtX500
  | @as(6) NtEnterprise

/// Decode from the C-ABI tag value.
let principalTypeFromTag = (tag: int): option<principalType> =>
  switch tag {
  | 0 => Some(NtUnknown)
  | 1 => Some(NtPrincipal)
  | 2 => Some(NtSrvInst)
  | 3 => Some(NtSrvHst)
  | 4 => Some(NtUid)
  | 5 => Some(NtX500)
  | 6 => Some(NtEnterprise)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let principalTypeToTag = (v: principalType): int =>
  switch v {
  | NtUnknown => 0
  | NtPrincipal => 1
  | NtSrvInst => 2
  | NtSrvHst => 3
  | NtUid => 4
  | NtX500 => 5
  | NtEnterprise => 6
  }

// ===========================================================================
// TicketFlag (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type ticketFlag =
  | @as(0) Forwardable
  | @as(1) Forwarded
  | @as(2) Proxiable
  | @as(3) Proxy
  | @as(4) Renewable
  | @as(5) PreAuthent
  | @as(6) HwAuthent

/// Decode from the C-ABI tag value.
let ticketFlagFromTag = (tag: int): option<ticketFlag> =>
  switch tag {
  | 0 => Some(Forwardable)
  | 1 => Some(Forwarded)
  | 2 => Some(Proxiable)
  | 3 => Some(Proxy)
  | 4 => Some(Renewable)
  | 5 => Some(PreAuthent)
  | 6 => Some(HwAuthent)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let ticketFlagToTag = (v: ticketFlag): int =>
  switch v {
  | Forwardable => 0
  | Forwarded => 1
  | Proxiable => 2
  | Proxy => 3
  | Renewable => 4
  | PreAuthent => 5
  | HwAuthent => 6
  }

/// Whether this flag relates to delegation.
let ticketFlagIsDelegation = (v: ticketFlag): bool =>
  switch v {
  | Forwardable | Forwarded | Proxiable | Proxy => true
  | _ => false
  }

// ===========================================================================
// ErrorCode (tags 0-9)
// ===========================================================================

/// Decode from an ABI tag value.
type errorCode =
  | @as(0) KdcErrNone
  | @as(1) KdcErrNameExp
  | @as(2) KdcErrServiceExp
  | @as(3) KdcErrBadPvno
  | @as(4) KdcErrCOldMastKvno
  | @as(5) KdcErrSOldMastKvno
  | @as(6) KdcErrCPrincipalUnknown
  | @as(7) KdcErrSPrincipalUnknown
  | @as(8) KdcErrPreauthFailed
  | @as(9) KdcErrPreauthRequired

/// Decode from the C-ABI tag value.
let errorCodeFromTag = (tag: int): option<errorCode> =>
  switch tag {
  | 0 => Some(KdcErrNone)
  | 1 => Some(KdcErrNameExp)
  | 2 => Some(KdcErrServiceExp)
  | 3 => Some(KdcErrBadPvno)
  | 4 => Some(KdcErrCOldMastKvno)
  | 5 => Some(KdcErrSOldMastKvno)
  | 6 => Some(KdcErrCPrincipalUnknown)
  | 7 => Some(KdcErrSPrincipalUnknown)
  | 8 => Some(KdcErrPreauthFailed)
  | 9 => Some(KdcErrPreauthRequired)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorCodeToTag = (v: errorCode): int =>
  switch v {
  | KdcErrNone => 0
  | KdcErrNameExp => 1
  | KdcErrServiceExp => 2
  | KdcErrBadPvno => 3
  | KdcErrCOldMastKvno => 4
  | KdcErrSOldMastKvno => 5
  | KdcErrCPrincipalUnknown => 6
  | KdcErrSPrincipalUnknown => 7
  | KdcErrPreauthFailed => 8
  | KdcErrPreauthRequired => 9
  }

/// Whether this code indicates success.
let errorCodeIsSuccess = (v: errorCode): bool =>
  switch v {
  | KdcErrNone => true
  | _ => false
  }

// ===========================================================================
// AuthState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type authState =
  | @as(0) Initial
  | @as(1) TgtObtained
  | @as(2) ServiceTicketObtained
  | @as(3) Authenticated
  | @as(4) AuthFailed

/// Decode from the C-ABI tag value.
let authStateFromTag = (tag: int): option<authState> =>
  switch tag {
  | 0 => Some(Initial)
  | 1 => Some(TgtObtained)
  | 2 => Some(ServiceTicketObtained)
  | 3 => Some(Authenticated)
  | 4 => Some(AuthFailed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authStateToTag = (v: authState): int =>
  switch v {
  | Initial => 0
  | TgtObtained => 1
  | ServiceTicketObtained => 2
  | Authenticated => 3
  | AuthFailed => 4
  }

/// Validate whether a state transition is allowed.
let authStateCanTransitionTo = (from: authState, to: authState): bool =>
  switch (from, to) {
  | _ => false
  }

// ===========================================================================
// EncStrength (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type encStrength =
  | @as(0) Strong
  | @as(1) Medium
  | @as(2) Weak

/// Decode from the C-ABI tag value.
let encStrengthFromTag = (tag: int): option<encStrength> =>
  switch tag {
  | 0 => Some(Strong)
  | 1 => Some(Medium)
  | 2 => Some(Weak)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let encStrengthToTag = (v: encStrength): int =>
  switch v {
  | Strong => 0
  | Medium => 1
  | Weak => 2
  }

// ===========================================================================
// PreAuthType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type preAuthType =
  | @as(0) PaEncTimestamp
  | @as(1) PaEtypeInfo2
  | @as(2) PaFxFast
  | @as(3) PaFxCookie

/// Decode from the C-ABI tag value.
let preAuthTypeFromTag = (tag: int): option<preAuthType> =>
  switch tag {
  | 0 => Some(PaEncTimestamp)
  | 1 => Some(PaEtypeInfo2)
  | 2 => Some(PaFxFast)
  | 3 => Some(PaFxCookie)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let preAuthTypeToTag = (v: preAuthType): int =>
  switch v {
  | PaEncTimestamp => 0
  | PaEtypeInfo2 => 1
  | PaFxFast => 2
  | PaFxCookie => 3
  }

// ===========================================================================
// NegotiationState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type negotiationState =
  | @as(0) NegIdle
  | @as(1) Proposed
  | @as(2) Selected
  | @as(3) NegFailed

/// Decode from the C-ABI tag value.
let negotiationStateFromTag = (tag: int): option<negotiationState> =>
  switch tag {
  | 0 => Some(NegIdle)
  | 1 => Some(Proposed)
  | 2 => Some(Selected)
  | 3 => Some(NegFailed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let negotiationStateToTag = (v: negotiationState): int =>
  switch v {
  | NegIdle => 0
  | Proposed => 1
  | Selected => 2
  | NegFailed => 3
  }

