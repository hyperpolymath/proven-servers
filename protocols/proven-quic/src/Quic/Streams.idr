-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| Stream identity and access rules (RFC 9000 Sections 2.1 and 3).
|||
||| The two least-significant bits of a stream ID encode the stream kind:
|||   bit 0 -> initiator (0 = client, 1 = server)
|||   bit 1 -> directionality (0 = bidirectional, 1 = unidirectional)
|||
||| The full 62-bit ID arithmetic lives in the Zig engine; here we model the
||| semantic 2-bit code and prove the identity and access invariants on it.
module Quic.Streams

import Quic.Types

%default total

---------------------------------------------------------------------------
-- Decompose / compose a stream kind
---------------------------------------------------------------------------

||| The endpoint that opened a stream of this kind.
public export
initiator : StreamKind -> Endpoint
initiator ClientBidi = Client
initiator ServerBidi = Server
initiator ClientUni  = Client
initiator ServerUni  = Server

||| The directionality of a stream of this kind.
public export
direction : StreamKind -> Direction
direction ClientBidi = Bidi
direction ServerBidi = Bidi
direction ClientUni  = Uni
direction ServerUni  = Uni

||| Build a stream kind from initiator and directionality.
public export
mkStreamKind : Endpoint -> Direction -> StreamKind
mkStreamKind Client Bidi = ClientBidi
mkStreamKind Server Bidi = ServerBidi
mkStreamKind Client Uni  = ClientUni
mkStreamKind Server Uni  = ServerUni

||| Composition is a left inverse of the initiator projection.
public export
initiatorRoundtrip : (e : Endpoint) -> (d : Direction) -> initiator (mkStreamKind e d) = e
initiatorRoundtrip Client Bidi = Refl
initiatorRoundtrip Server Bidi = Refl
initiatorRoundtrip Client Uni  = Refl
initiatorRoundtrip Server Uni  = Refl

||| Composition is a left inverse of the direction projection.
public export
directionRoundtrip : (e : Endpoint) -> (d : Direction) -> direction (mkStreamKind e d) = d
directionRoundtrip Client Bidi = Refl
directionRoundtrip Server Bidi = Refl
directionRoundtrip Client Uni  = Refl
directionRoundtrip Server Uni  = Refl

||| Decomposing then recomposing yields the same kind.
public export
streamKindRoundtrip : (k : StreamKind) -> mkStreamKind (initiator k) (direction k) = k
streamKindRoundtrip ClientBidi = Refl
streamKindRoundtrip ServerBidi = Refl
streamKindRoundtrip ClientUni  = Refl
streamKindRoundtrip ServerUni  = Refl

---------------------------------------------------------------------------
-- Two-bit wire code (RFC 9000 Section 2.1): (direction << 1) | initiator
---------------------------------------------------------------------------

||| The low two bits of a stream ID for this kind.
public export
streamKindCode : StreamKind -> Bits8
streamKindCode ClientBidi = 0
streamKindCode ServerBidi = 1
streamKindCode ClientUni  = 2
streamKindCode ServerUni  = 3

||| Decode the low two bits of a stream ID into a kind.
public export
codeToStreamKind : Bits8 -> Maybe StreamKind
codeToStreamKind 0 = Just ClientBidi
codeToStreamKind 1 = Just ServerBidi
codeToStreamKind 2 = Just ClientUni
codeToStreamKind 3 = Just ServerUni
codeToStreamKind _ = Nothing

public export
streamKindCodeRoundtrip : (k : StreamKind) -> codeToStreamKind (streamKindCode k) = Just k
streamKindCodeRoundtrip ClientBidi = Refl
streamKindCodeRoundtrip ServerBidi = Refl
streamKindCodeRoundtrip ClientUni  = Refl
streamKindCodeRoundtrip ServerUni  = Refl

---------------------------------------------------------------------------
-- Access rules (RFC 9000 Sections 2.1 and 3)
---------------------------------------------------------------------------

||| Whether `ep` may send on a stream of kind `k`.  Both peers send on
||| bidirectional streams; only the initiator sends on a unidirectional one.
public export
canSend : Endpoint -> StreamKind -> Bool
canSend ep k = case direction k of
  Bidi => True
  Uni  => ep == initiator k

||| Whether `ep` may receive on a stream of kind `k`.  Both peers receive on
||| bidirectional streams; only the non-initiator receives on a uni stream.
public export
canReceive : Endpoint -> StreamKind -> Bool
canReceive ep k = case direction k of
  Bidi => True
  Uni  => not (ep == initiator k)

---------------------------------------------------------------------------
-- Proven access facts
---------------------------------------------------------------------------

||| A client may never send on a server-initiated unidirectional stream.
public export
clientCannotSendServerUni : canSend Client ServerUni = False
clientCannotSendServerUni = Refl

||| A server may never send on a client-initiated unidirectional stream.
public export
serverCannotSendClientUni : canSend Server ClientUni = False
serverCannotSendClientUni = Refl

||| The initiator of a unidirectional stream may not receive on it.
public export
clientCannotReceiveClientUni : canReceive Client ClientUni = False
clientCannotReceiveClientUni = Refl

||| Both endpoints may send on a bidirectional stream.
public export
bidiClientCanSend : canSend Client ClientBidi = True
bidiClientCanSend = Refl

public export
bidiServerCanSend : canSend Server ClientBidi = True
bidiServerCanSend = Refl
