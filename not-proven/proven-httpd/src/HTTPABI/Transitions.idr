-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- HTTPABI.Transitions: Valid HTTP request lifecycle transitions.
--
-- Models the HTTP request processing lifecycle (RFC 7230/7231):
--
--   Idle --> Receiving --> HeadersParsed --> BodyReceiving --> Complete
--   --> Responding --> Sent
--
-- With additional edges:
--   HeadersParsed --> Complete          (no-body requests like GET/HEAD)
--   Any non-Sent state --> Sent        (error abort sends error response)
--   Sent --> Idle                      (keep-alive recycle)
--   Sent is terminal for non-keep-alive connections
--
-- The key invariant: a response can only be constructed once the request
-- is Complete. Headers must be parsed before the body can be received.
-- The lifecycle must proceed in order; skipping states is forbidden.

module HTTPABI.Transitions

import HTTPABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidHttpTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that an HTTP request lifecycle transition is valid.
public export
data ValidHttpTransition : RequestPhase -> RequestPhase -> Type where
  ||| Idle -> Receiving (new request data arrives).
  StartReceiving     : ValidHttpTransition Idle Receiving
  ||| Receiving -> HeadersParsed (full header section received).
  ParseHeaders       : ValidHttpTransition Receiving HeadersParsed
  ||| HeadersParsed -> BodyReceiving (Content-Length > 0, start reading body).
  StartBody          : ValidHttpTransition HeadersParsed BodyReceiving
  ||| HeadersParsed -> Complete (no body expected, e.g. GET/HEAD request).
  NoBodyComplete     : ValidHttpTransition HeadersParsed Complete
  ||| BodyReceiving -> Complete (full body received).
  BodyDone           : ValidHttpTransition BodyReceiving Complete
  ||| Complete -> Responding (handler begins constructing response).
  BeginResponse      : ValidHttpTransition Complete Responding
  ||| Responding -> Sent (response fully written to socket).
  FinishSend         : ValidHttpTransition Responding Sent
  ||| Sent -> Idle (connection keep-alive, ready for next request).
  KeepAliveRecycle   : ValidHttpTransition Sent Idle
  ||| Receiving -> Sent (malformed request line, send 400 and close).
  AbortReceiving     : ValidHttpTransition Receiving Sent
  ||| HeadersParsed -> Sent (error during header validation, e.g. 431).
  AbortHeadersParsed : ValidHttpTransition HeadersParsed Sent
  ||| BodyReceiving -> Sent (error during body read, e.g. 413).
  AbortBodyReceiving : ValidHttpTransition BodyReceiving Sent
  ||| Complete -> Sent (handler error, send 500).
  AbortComplete      : ValidHttpTransition Complete Sent

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a request can have its body parsed.
||| Body parsing requires that headers have been successfully parsed.
public export
data CanParseBody : RequestPhase -> Type where
  HeadersParsedCanParseBody : CanParseBody HeadersParsed

||| Proof that a request can be responded to.
||| Responding requires that the full request has been received.
public export
data CanRespond : RequestPhase -> Type where
  CompleteCanRespond : CanRespond Complete

||| Proof that a connection can be recycled for keep-alive.
public export
data CanKeepAlive : RequestPhase -> Type where
  SentCanKeepAlive : CanKeepAlive Sent

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot respond before headers are parsed.
public export
cannotRespondFromIdle : CanRespond Idle -> Void
cannotRespondFromIdle _ impossible

||| Cannot respond from Receiving phase.
public export
cannotRespondFromReceiving : CanRespond Receiving -> Void
cannotRespondFromReceiving _ impossible

||| Cannot respond directly from HeadersParsed (must reach Complete first).
public export
cannotRespondFromHeadersParsed : CanRespond HeadersParsed -> Void
cannotRespondFromHeadersParsed _ impossible

||| Cannot parse body from Idle (must receive and parse headers first).
public export
cannotParseBodyFromIdle : CanParseBody Idle -> Void
cannotParseBodyFromIdle _ impossible

||| Cannot parse body from Receiving (headers not yet parsed).
public export
cannotParseBodyFromReceiving : CanParseBody Receiving -> Void
cannotParseBodyFromReceiving _ impossible

||| Cannot skip from Idle directly to Complete.
public export
cannotSkipToComplete : ValidHttpTransition Idle Complete -> Void
cannotSkipToComplete _ impossible

||| Cannot skip from Idle directly to Responding.
public export
cannotSkipToResponding : ValidHttpTransition Idle Responding -> Void
cannotSkipToResponding _ impossible

||| Cannot go backwards from Complete to Receiving.
public export
cannotGoBackwards : ValidHttpTransition Complete Receiving -> Void
cannotGoBackwards _ impossible

||| Cannot go backwards from Responding to HeadersParsed.
public export
cannotUndoResponse : ValidHttpTransition Responding HeadersParsed -> Void
cannotUndoResponse _ impossible

||| Cannot recycle from a non-Sent state.
public export
cannotRecycleFromIdle : ValidHttpTransition Idle Idle -> Void
cannotRecycleFromIdle _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether an HTTP request lifecycle transition is valid.
public export
validateHttpTransition : (from : RequestPhase) -> (to : RequestPhase)
                       -> Maybe (ValidHttpTransition from to)
validateHttpTransition Idle          Receiving     = Just StartReceiving
validateHttpTransition Receiving     HeadersParsed = Just ParseHeaders
validateHttpTransition HeadersParsed BodyReceiving = Just StartBody
validateHttpTransition HeadersParsed Complete      = Just NoBodyComplete
validateHttpTransition BodyReceiving Complete      = Just BodyDone
validateHttpTransition Complete      Responding    = Just BeginResponse
validateHttpTransition Responding    Sent          = Just FinishSend
validateHttpTransition Sent          Idle          = Just KeepAliveRecycle
validateHttpTransition Receiving     Sent          = Just AbortReceiving
validateHttpTransition HeadersParsed Sent          = Just AbortHeadersParsed
validateHttpTransition BodyReceiving Sent          = Just AbortBodyReceiving
validateHttpTransition Complete      Sent          = Just AbortComplete
validateHttpTransition _             _             = Nothing
