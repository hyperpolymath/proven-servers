-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CAABI.Transitions: Valid certificate lifecycle state transitions.
--
-- Models the X.509 certificate lifecycle managed by a CA:
--
--   Pending --Sign--> Active --Revoke--> Revoked   (terminal)
--                     Active --Expire--> Expired    (terminal)
--                     Active --Suspend-> Suspended
--                     Suspended --Reinstate-> Active
--                     Suspended --Revoke--> Revoked  (terminal)
--                     Pending --Reject--> Revoked   (terminal)
--                     Active --Renew--> Pending     (new cert cycle)
--
-- CA hierarchy validation: Root can issue Intermediate/CrossSigned,
-- Intermediate can issue EndEntity/CodeSigning/EmailProtection/OCSPSigning,
-- EndEntity/CrossSigned/CodeSigning/EmailProtection/OCSPSigning are leaf.
--
-- Key invariants:
--   - Revoked and Expired are terminal states
--   - Only Active certs can be suspended, expired, or renewed
--   - Only Suspended certs can be reinstated
--   - Root certs cannot be issued by non-root CAs

module CAABI.Transitions

import CA.Types

%default total

---------------------------------------------------------------------------
-- ValidCertTransition: exhaustive enumeration of legal state transitions.
---------------------------------------------------------------------------

||| Proof witness that a certificate state transition is valid.
public export
data ValidCertTransition : CertState -> CertState -> Type where
  ||| Pending -> Active (CA signs the certificate request).
  SignCert       : ValidCertTransition Pending Active
  ||| Active -> Revoked (certificate is revoked for cause).
  RevokeCert     : ValidCertTransition Active Revoked
  ||| Active -> Expired (certificate validity period ends).
  ExpireCert     : ValidCertTransition Active Expired
  ||| Active -> Suspended (temporary hold, e.g. investigation).
  SuspendCert    : ValidCertTransition Active Suspended
  ||| Active -> Pending (renewal triggers new signing cycle).
  RenewCert      : ValidCertTransition Active Pending
  ||| Suspended -> Active (hold lifted, cert reinstated).
  ReinstateCert  : ValidCertTransition Suspended Active
  ||| Suspended -> Revoked (investigation confirmed compromise).
  RevokeSuspended : ValidCertTransition Suspended Revoked
  ||| Pending -> Revoked (CSR rejected or key compromised before signing).
  RejectPending  : ValidCertTransition Pending Revoked

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a certificate can be used for signing operations.
public export
data CanSign : CertState -> Type where
  ActiveCanSign : CanSign Active

||| Proof that a certificate can be revoked.
public export
data CanRevoke : CertState -> Type where
  ActiveCanRevoke    : CanRevoke Active
  SuspendedCanRevoke : CanRevoke Suspended

||| Proof that a certificate can be renewed.
public export
data CanRenew : CertState -> Type where
  ActiveCanRenew : CanRenew Active

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Revoked is a terminal state — no transitions out.
public export
revokedIsTerminal : ValidCertTransition Revoked s -> Void
revokedIsTerminal _ impossible

||| Expired is a terminal state — no transitions out.
public export
expiredIsTerminal : ValidCertTransition Expired s -> Void
expiredIsTerminal _ impossible

||| Cannot sign with a Pending certificate.
public export
cannotSignFromPending : CanSign Pending -> Void
cannotSignFromPending _ impossible

||| Cannot sign with a Revoked certificate.
public export
cannotSignFromRevoked : CanSign Revoked -> Void
cannotSignFromRevoked _ impossible

||| Cannot sign with an Expired certificate.
public export
cannotSignFromExpired : CanSign Expired -> Void
cannotSignFromExpired _ impossible

||| Cannot sign with a Suspended certificate.
public export
cannotSignFromSuspended : CanSign Suspended -> Void
cannotSignFromSuspended _ impossible

||| Cannot skip from Pending directly to Expired.
public export
cannotSkipToExpired : ValidCertTransition Pending Expired -> Void
cannotSkipToExpired _ impossible

||| Cannot skip from Pending directly to Suspended.
public export
cannotSkipToSuspended : ValidCertTransition Pending Suspended -> Void
cannotSkipToSuspended _ impossible

||| Cannot reinstate from a non-Suspended state.
public export
cannotReinstateFromActive : ValidCertTransition Active Active -> Void
cannotReinstateFromActive _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a certificate state transition is valid.
public export
validateCertTransition : (from : CertState) -> (to : CertState)
                       -> Maybe (ValidCertTransition from to)
validateCertTransition Pending   Active    = Just SignCert
validateCertTransition Active    Revoked   = Just RevokeCert
validateCertTransition Active    Expired   = Just ExpireCert
validateCertTransition Active    Suspended = Just SuspendCert
validateCertTransition Active    Pending   = Just RenewCert
validateCertTransition Suspended Active    = Just ReinstateCert
validateCertTransition Suspended Revoked   = Just RevokeSuspended
validateCertTransition Pending   Revoked   = Just RejectPending
validateCertTransition _ _                 = Nothing

---------------------------------------------------------------------------
-- CA hierarchy: which CertType can issue which CertType.
---------------------------------------------------------------------------

||| Proof witness that a CA of one cert type may issue another cert type.
public export
data CanIssue : CertType -> CertType -> Type where
  ||| Root CA can issue Intermediate certificates.
  RootIssuesIntermediate : CanIssue Root Intermediate
  ||| Root CA can issue CrossSigned certificates.
  RootIssuesCrossSigned  : CanIssue Root CrossSigned
  ||| Root CA can issue EndEntity (for small PKI deployments).
  RootIssuesEndEntity    : CanIssue Root EndEntity
  ||| Intermediate CA can issue EndEntity certificates.
  IntIssuesEndEntity     : CanIssue Intermediate EndEntity
  ||| Intermediate CA can issue CodeSigning certificates.
  IntIssuesCodeSigning   : CanIssue Intermediate CodeSigning
  ||| Intermediate CA can issue EmailProtection certificates.
  IntIssuesEmail         : CanIssue Intermediate EmailProtection
  ||| Intermediate CA can issue OCSP signing certificates.
  IntIssuesOCSP          : CanIssue Intermediate OCSPSigning
  ||| CrossSigned CA can issue EndEntity certificates.
  CrossIssuesEndEntity   : CanIssue CrossSigned EndEntity

||| EndEntity certificates cannot issue anything.
public export
endEntityCannotIssue : CanIssue EndEntity child -> Void
endEntityCannotIssue _ impossible

||| CodeSigning certificates cannot issue anything.
public export
codeSigningCannotIssue : CanIssue CodeSigning child -> Void
codeSigningCannotIssue _ impossible

||| EmailProtection certificates cannot issue anything.
public export
emailCannotIssue : CanIssue EmailProtection child -> Void
emailCannotIssue _ impossible

||| OCSPSigning certificates cannot issue anything.
public export
ocspCannotIssue : CanIssue OCSPSigning child -> Void
ocspCannotIssue _ impossible

||| Validate whether an issuer cert type may issue a child cert type.
public export
validateIssuance : (issuer : CertType) -> (child : CertType)
                -> Maybe (CanIssue issuer child)
validateIssuance Root         Intermediate    = Just RootIssuesIntermediate
validateIssuance Root         CrossSigned     = Just RootIssuesCrossSigned
validateIssuance Root         EndEntity       = Just RootIssuesEndEntity
validateIssuance Intermediate EndEntity       = Just IntIssuesEndEntity
validateIssuance Intermediate CodeSigning     = Just IntIssuesCodeSigning
validateIssuance Intermediate EmailProtection = Just IntIssuesEmail
validateIssuance Intermediate OCSPSigning     = Just IntIssuesOCSP
validateIssuance CrossSigned  EndEntity       = Just CrossIssuesEndEntity
validateIssuance _ _                          = Nothing
