-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TLSABI.Transitions: Valid TLS handshake state transitions.
--
-- Models the TLS 1.3 handshake lifecycle (RFC 8446 section 2):
--
--   ClientHello --> ServerHello --> EncryptedExtensions --> Certificate
--   --> CertificateVerify --> Finished --> Established --> Closed
--
-- With additional edges:
--   Any pre-Established state --Alert--> Closed  (fatal alert aborts)
--   Established --KeyUpdate--> Established       (post-handshake rekey)
--   Closed is terminal (no outbound edges)
--
-- The key invariant: once Closed, no transition is possible.  The
-- handshake must proceed in order; skipping states is forbidden.

module TLSABI.Transitions

import TLS.Types

%default total

---------------------------------------------------------------------------
-- ValidHandshakeTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that a TLS handshake state transition is valid.
public export
data ValidHandshakeTransition : HandshakeState -> HandshakeState -> Type where
  ||| ClientHello -> ServerHello (server responds).
  SvrHelloReply      : ValidHandshakeTransition ClientHello ServerHello
  ||| ServerHello -> EncryptedExtensions.
  SendEncExt         : ValidHandshakeTransition ServerHello EncryptedExtensions
  ||| EncryptedExtensions -> Certificate.
  SendCert           : ValidHandshakeTransition EncryptedExtensions Certificate
  ||| Certificate -> CertificateVerify.
  SendCertVerify     : ValidHandshakeTransition Certificate CertificateVerify
  ||| CertificateVerify -> Finished.
  SendFinished       : ValidHandshakeTransition CertificateVerify Finished
  ||| Finished -> Established (handshake complete, application data flows).
  HandshakeDone      : ValidHandshakeTransition Finished Established
  ||| Established -> Established (TLS 1.3 KeyUpdate, post-handshake rekey).
  KeyUpdate          : ValidHandshakeTransition Established Established
  ||| Established -> Closed (graceful close_notify or fatal alert).
  GracefulClose      : ValidHandshakeTransition Established Closed
  ||| ClientHello -> Closed (fatal alert during handshake).
  AbortClientHello   : ValidHandshakeTransition ClientHello Closed
  ||| ServerHello -> Closed (fatal alert during handshake).
  AbortServerHello   : ValidHandshakeTransition ServerHello Closed
  ||| EncryptedExtensions -> Closed (fatal alert during handshake).
  AbortEncExt        : ValidHandshakeTransition EncryptedExtensions Closed
  ||| Certificate -> Closed (fatal alert during handshake).
  AbortCert          : ValidHandshakeTransition Certificate Closed
  ||| CertificateVerify -> Closed (fatal alert during handshake).
  AbortCertVerify    : ValidHandshakeTransition CertificateVerify Closed
  ||| Finished -> Closed (fatal alert during handshake).
  AbortFinished      : ValidHandshakeTransition Finished Closed

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a session can send/receive application data.
public export
data CanSendData : HandshakeState -> Type where
  EstablishedCanSend : CanSendData Established

||| Proof that a session can perform a key update.
public export
data CanKeyUpdate : HandshakeState -> Type where
  EstablishedCanRekey : CanKeyUpdate Established

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot leave the Closed state — it is terminal.
public export
closedIsTerminal : ValidHandshakeTransition Closed s -> Void
closedIsTerminal _ impossible

||| Cannot skip from ClientHello directly to Established.
public export
cannotSkipHandshake : ValidHandshakeTransition ClientHello Established -> Void
cannotSkipHandshake _ impossible

||| Cannot go backwards from Established to ServerHello.
public export
cannotGoBackwards : ValidHandshakeTransition Established ServerHello -> Void
cannotGoBackwards _ impossible

||| Cannot send data before handshake completes (e.g. from Certificate).
public export
cannotSendFromCertificate : CanSendData Certificate -> Void
cannotSendFromCertificate _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a TLS handshake state transition is valid.
public export
validateHandshakeTransition : (from : HandshakeState) -> (to : HandshakeState)
                           -> Maybe (ValidHandshakeTransition from to)
validateHandshakeTransition ClientHello         ServerHello         = Just SvrHelloReply
validateHandshakeTransition ServerHello         EncryptedExtensions = Just SendEncExt
validateHandshakeTransition EncryptedExtensions Certificate         = Just SendCert
validateHandshakeTransition Certificate         CertificateVerify   = Just SendCertVerify
validateHandshakeTransition CertificateVerify   Finished            = Just SendFinished
validateHandshakeTransition Finished            Established         = Just HandshakeDone
validateHandshakeTransition Established         Established         = Just KeyUpdate
validateHandshakeTransition Established         Closed              = Just GracefulClose
validateHandshakeTransition ClientHello         Closed              = Just AbortClientHello
validateHandshakeTransition ServerHello         Closed              = Just AbortServerHello
validateHandshakeTransition EncryptedExtensions Closed              = Just AbortEncExt
validateHandshakeTransition Certificate         Closed              = Just AbortCert
validateHandshakeTransition CertificateVerify   Closed              = Just AbortCertVerify
validateHandshakeTransition Finished            Closed              = Just AbortFinished
validateHandshakeTransition _ _                                     = Nothing
