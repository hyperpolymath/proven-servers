-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AMQPABI.Connector: the uniform-connector signature table (pilot).
--
-- Every function a native connector may call through `ps_invoke` is listed
-- here once, with its logical argument kinds. AMQPABI.Emit prints the table
-- as `FN` manifest lines; tools/gen-abi.sh renders them into
-- amqp_abi_gen.zig, and a comptime guard in the shared Zig dispatcher
-- (ffi/zig/connector/ps_connector.zig) checks every entry against the real
-- `amqp_*` export. A mismatch is a build error.
--
-- A `KBytes` argument is one logical argument that the Zig export takes as a
-- (pointer, u32 length) pair. Function tags are positions in `signatures`,
-- starting at 1, so appending keeps existing tags stable.

module AMQPABI.Connector

%default total

||| Logical argument / result kinds carried by a `ps_invoke` value cell.
public export
data Kind = KVoid | KI32 | KU8 | KU16 | KU32 | KU64 | KBytes

||| Wire tag for each kind (the `kind` byte of a value cell).
public export
kindToTag : Kind -> Bits8
kindToTag KVoid  = 0
kindToTag KI32   = 1
kindToTag KU8    = 2
kindToTag KU16   = 3
kindToTag KU32   = 4
kindToTag KU64   = 5
kindToTag KBytes = 6

||| Manifest spelling of each kind.
public export
kindName : Kind -> String
kindName KVoid  = "VOID"
kindName KI32   = "I32"
kindName KU8    = "U8"
kindName KU16   = "U16"
kindName KU32   = "U32"
kindName KU64   = "U64"
kindName KBytes = "BYTES"

||| Every kind, in tag order (drives the KIND manifest lines).
public export
allKinds : List Kind
allKinds = [KVoid, KI32, KU8, KU16, KU32, KU64, KBytes]

||| Version of the uniform connector ABI (ps_abi_version, ps_manifest,
||| ps_invoke, and the value-cell layout). Distinct from the AMQP abiVersion.
public export
connectorAbiVersion : Bits8
connectorAbiVersion = 1

||| Result of `ps_invoke` itself (not of the called function).
public export
data Status = SOk | SUnknownFn | SArity | SKindMismatch | SRange | SNullPtr

public export
statusToTag : Status -> Bits8
statusToTag SOk           = 0
statusToTag SUnknownFn    = 1
statusToTag SArity        = 2
statusToTag SKindMismatch = 3
statusToTag SRange        = 4
statusToTag SNullPtr      = 5

statusName : Status -> String
statusName SOk           = "OK"
statusName SUnknownFn    = "UNKNOWN_FN"
statusName SArity        = "ARITY"
statusName SKindMismatch = "KIND_MISMATCH"
statusName SRange        = "RANGE"
statusName SNullPtr      = "NULL_PTR"

allStatuses : List Status
allStatuses = [SOk, SUnknownFn, SArity, SKindMismatch, SRange, SNullPtr]

||| The value cell, 32 bytes on every target: kind byte, 7 zero bytes, then
||| three native-endian u64 words. `word` carries an integer (an I32 is
||| stored sign-extended to 64 bits); for BYTES, `addr` is the buffer address
||| and `len` its length. Using a u64 address keeps the layout the same on
||| 32-bit and 64-bit targets.
public export
valueLayout : List (String, Nat)
valueLayout =
  [ ("PS_VALUE_SIZE", 32), ("PS_VALUE_ALIGN", 8)
  , ("PS_VALUE_OFF_KIND", 0), ("PS_VALUE_OFF_WORD", 8)
  , ("PS_VALUE_OFF_ADDR", 16), ("PS_VALUE_OFF_LEN", 24) ]

||| One callable function: its name without the `amqp_` prefix, its result
||| kind, and its named logical arguments.
public export
record Sig where
  constructor MkSig
  sigName : String
  sigRet  : Kind
  sigArgs : List (String, Kind)

||| The callable surface of proven-amqp, in tag order (tag = position + 1).
public export
signatures : List Sig
signatures =
  [ MkSig "abi_version" KU32 []
  , MkSig "create" KI32
      [("vhost", KBytes), ("frame_max", KU32), ("channel_max", KU16), ("heartbeat", KU16)]
  , MkSig "destroy" KVoid [("slot", KI32)]
  , MkSig "state" KU8 [("slot", KI32)]
  , MkSig "can_publish" KU8 [("slot", KI32)]
  , MkSig "can_consume" KU8 [("slot", KI32)]
  , MkSig "channel_open" KU8 [("slot", KI32), ("channel", KU16)]
  , MkSig "channel_close" KU8 [("slot", KI32), ("channel", KU16)]
  , MkSig "channel_count" KU16 [("slot", KI32)]
  , MkSig "exchange_declare" KU8
      [ ("slot", KI32), ("channel", KU16), ("name", KBytes), ("exch_type", KU8)
      , ("durable", KU8), ("auto_delete", KU8), ("internal", KU8) ]
  , MkSig "queue_declare" KU8
      [ ("slot", KI32), ("channel", KU16), ("name", KBytes)
      , ("durable", KU8), ("exclusive", KU8), ("auto_delete", KU8) ]
  , MkSig "queue_bind" KU8
      [ ("slot", KI32), ("channel", KU16), ("queue", KBytes)
      , ("exchange", KBytes), ("routing_key", KBytes) ]
  , MkSig "basic_publish" KU8
      [ ("slot", KI32), ("channel", KU16), ("exchange", KBytes)
      , ("routing_key", KBytes), ("body", KBytes), ("delivery_mode", KU8)
      , ("priority", KU8), ("mandatory", KU8) ]
  , MkSig "basic_consume" KU8
      [ ("slot", KI32), ("channel", KU16), ("queue", KBytes)
      , ("consumer_tag", KBytes), ("no_ack", KU8), ("exclusive", KU8) ]
  , MkSig "basic_cancel" KU8
      [("slot", KI32), ("channel", KU16), ("consumer_tag", KBytes)]
  , MkSig "basic_ack" KU8
      [("slot", KI32), ("channel", KU16), ("delivery_tag", KU64), ("multiple", KU8)]
  , MkSig "basic_nack" KU8
      [ ("slot", KI32), ("channel", KU16), ("delivery_tag", KU64)
      , ("multiple", KU8), ("requeue", KU8) ]
  , MkSig "basic_reject" KU8
      [("slot", KI32), ("channel", KU16), ("delivery_tag", KU64), ("requeue", KU8)]
  , MkSig "basic_qos" KU8
      [ ("slot", KI32), ("channel", KU16), ("prefetch_count", KU16)
      , ("prefetch_size", KU32), ("global", KU8) ]
  , MkSig "consumer_count" KU32 [("slot", KI32)]
  , MkSig "disconnect" KU8 [("slot", KI32)]
  , MkSig "cleanup" KU8 [("slot", KI32)]
  , MkSig "can_transition" KU8 [("from", KU8), ("to", KU8)]
  , MkSig "routing_match" KU8
      [("routing_key", KBytes), ("pattern", KBytes), ("exch_type", KU8)]
  ]

argText : (String, Kind) -> String
argText (n, k) = " " ++ n ++ ":" ++ kindName k

sigLine : Nat -> Sig -> String
sigLine tag s =
  "FN " ++ show tag ++ " " ++ sigName s ++ " " ++ kindName (sigRet s)
    ++ concatMap argText (sigArgs s)

numbered : Nat -> List Sig -> List String
numbered _ [] = []
numbered n (s :: ss) = sigLine n s :: numbered (S n) ss

||| Manifest lines for the connector surface: the connector ABI version, the
||| value-cell layout, the kind and status tags, then one `FN` line per
||| signature.
public export
connectorLines : List String
connectorLines =
  ("CONNECTOR ABI " ++ show connectorAbiVersion)
    :: map (\(n, v) => "LAYOUT " ++ n ++ " " ++ show v) valueLayout
    ++ map (\k => "KIND " ++ kindName k ++ " " ++ show (kindToTag k)) allKinds
    ++ map (\s => "STATUS " ++ statusName s ++ " " ++ show (statusToTag s)) allStatuses
    ++ numbered 1 signatures
