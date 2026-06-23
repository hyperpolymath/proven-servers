-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| The HTTP/3 request-stream frame-sequence state machine (RFC 9114
||| Section 4.1): HEADERS, then optional DATA, then optional trailing
||| HEADERS.  `ValidReqTransition from to` is inhabited only for legal
||| moves, so a frame sequence that violates the ordering cannot be built.
module Http3.Request

import Http3.Types

%default total

public export
data ValidReqTransition : ReqState -> ReqState -> Type where
  ||| The request HEADERS frame opens the exchange.
  RecvHeaders         : ValidReqTransition RInit       RReqHeaders
  ||| The first DATA frame begins the message body.
  StartBody           : ValidReqTransition RReqHeaders RData
  ||| Further DATA frames continue the body.
  MoreBody            : ValidReqTransition RData       RData
  ||| Trailing HEADERS may follow the request headers (empty body).
  TrailersNoBody      : ValidReqTransition RReqHeaders RTrailers
  ||| Trailing HEADERS may follow the body.
  TrailersAfterBody   : ValidReqTransition RData       RTrailers
  ||| The stream may end after headers, after the body, or after trailers.
  DoneAfterHeaders    : ValidReqTransition RReqHeaders RDone
  DoneAfterBody       : ValidReqTransition RData       RDone
  DoneAfterTrailers   : ValidReqTransition RTrailers   RDone

public export
validateReqTransition : (from : ReqState) -> (to : ReqState)
                      -> Maybe (ValidReqTransition from to)
validateReqTransition RInit       RReqHeaders = Just RecvHeaders
validateReqTransition RReqHeaders RData       = Just StartBody
validateReqTransition RData       RData       = Just MoreBody
validateReqTransition RReqHeaders RTrailers   = Just TrailersNoBody
validateReqTransition RData       RTrailers   = Just TrailersAfterBody
validateReqTransition RReqHeaders RDone       = Just DoneAfterHeaders
validateReqTransition RData       RDone       = Just DoneAfterBody
validateReqTransition RTrailers   RDone       = Just DoneAfterTrailers
validateReqTransition _           _           = Nothing

---------------------------------------------------------------------------
-- Impossibility proofs (illegal frame orderings)
---------------------------------------------------------------------------

||| A DATA frame before the request HEADERS is illegal (RFC 9114 4.1).
public export
dataBeforeHeaders : ValidReqTransition RInit RData -> Void
dataBeforeHeaders _ impossible

||| No frame may precede the request HEADERS except by opening with HEADERS;
||| in particular the stream cannot complete straight from Init.
public export
doneBeforeHeaders : ValidReqTransition RInit RDone -> Void
doneBeforeHeaders _ impossible

||| DATA after trailing HEADERS is illegal — trailers are final content.
public export
bodyAfterTrailers : ValidReqTransition RTrailers RData -> Void
bodyAfterTrailers _ impossible

||| A completed request stream is terminal.
public export
doneIsTerminal : ValidReqTransition RDone s -> Void
doneIsTerminal _ impossible
