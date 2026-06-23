-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| The receipt record and its canonical, reproducible serialisations.
|||
||| The canonical pre-image defined here is the single source of truth for
||| how a `receipt_hash` is derived; the Zig engine
||| (ffi/zig/src/timestamp.zig) reproduces it byte-for-byte.  Because the
||| format is pinned, anyone can re-derive a receipt_hash with off-the-shelf
||| tools and check the chain without trusting this server.
module Timestamp.Receipt

import Timestamp.Types
import Data.Maybe
import Data.List
import Data.String

%default total

---------------------------------------------------------------------------
-- The receipt
---------------------------------------------------------------------------

||| A timestamp receipt.  Note: no document contents are ever stored — only
||| the `contentHash`.  `serverSignature` is a reserved placeholder (signing
||| is future work) and is excluded from the hashed pre-image.
public export
record Receipt where
  constructor MkReceipt
  receiptId           : String
  createdAtUtc        : String          -- ISO-8601, UTC ("...Z")
  timestampSource     : TimestampSource
  hashAlgorithm       : HashAlgo
  contentHash         : String          -- hex digest of the content
  submittedLabel      : Maybe String
  submitterReference  : Maybe String
  previousReceiptHash : String          -- genesisHash for the first receipt
  receiptHash         : String          -- hex digest of canonicalPreimage
  serverSignature     : Maybe String    -- reserved; not yet implemented

||| Render an optional string field as "" when absent.
opt : Maybe String -> String
opt = fromMaybe ""

---------------------------------------------------------------------------
-- Canonical pre-image (the hashed bytes)
---------------------------------------------------------------------------

||| The canonical pre-image whose digest is the `receipt_hash`:
||| nine newline-separated fields, with NO trailing newline.
|||
||| Field order is frozen as `proven-timestamp.receipt.v1`.  This function
||| MUST stay byte-for-byte identical to `ts_append`/`ts_preimage` in
||| ffi/zig/src/timestamp.zig — the cross-language tests pin it.
public export
canonicalPreimage : Receipt -> String
canonicalPreimage r =
  fastConcat $ intersperse "\n"
    [ "proven-timestamp.receipt.v1"
    , r.receiptId
    , r.createdAtUtc
    , show r.timestampSource
    , show r.hashAlgorithm
    , r.contentHash
    , opt r.submittedLabel
    , opt r.submitterReference
    , r.previousReceiptHash
    ]

---------------------------------------------------------------------------
-- NDJSON serialisation
---------------------------------------------------------------------------

||| Minimal JSON string escaping (quote, backslash, the common controls).
jsonEsc : String -> String
jsonEsc s = fastConcat (map esc (unpack s))
  where
    esc : Char -> String
    esc '"'  = "\\\""
    esc '\\' = "\\\\"
    esc '\n' = "\\n"
    esc '\r' = "\\r"
    esc '\t' = "\\t"
    esc c    = pack [c]

jField : String -> String -> String
jField k v = "\"" ++ k ++ "\":\"" ++ jsonEsc v ++ "\""

||| The receipt as a single NDJSON line (one JSON object, no newline).
||| Append-only logs are stored as one of these per line.
public export
toNdjson : Receipt -> String
toNdjson r =
  "{" ++
  (fastConcat $ intersperse ","
    [ jField "receipt_id"               r.receiptId
    , jField "created_at_utc"           r.createdAtUtc
    , jField "timestamp_source"         (show r.timestampSource)
    , jField "hash_algorithm"           (show r.hashAlgorithm)
    , jField "content_hash"             r.contentHash
    , jField "submitted_label"          (opt r.submittedLabel)
    , jField "submitter_reference"      (opt r.submitterReference)
    , jField "previous_receipt_hash"    r.previousReceiptHash
    , jField "receipt_hash"             r.receiptHash
    , jField "server_signature"         (opt r.serverSignature)
    , jField "verification_instructions" verificationInstructions
    , jField "disclaimer"               disclaimer
    ])
  ++ "}"

---------------------------------------------------------------------------
-- a2ml serialisation (machine-readable, TOML-shaped — repo house style)
---------------------------------------------------------------------------

tomlEsc : String -> String
tomlEsc s = fastConcat (map e (unpack s))
  where
    e : Char -> String
    e '"'  = "\\\""
    e '\\' = "\\\\"
    e '\n' = "\\n"
    e c    = pack [c]

kv : String -> String -> String
kv k v = k ++ " = \"" ++ tomlEsc v ++ "\""

||| The receipt as an a2ml document (downloadable receipt artefact).
public export
toA2ml : Receipt -> String
toA2ml r =
  fastConcat $ intersperse "\n"
    [ "# SPDX-License-Identifier: MPL-2.0"
    , "# proven-timestamp receipt"
    , "[receipt]"
    , kv "receipt_id"                r.receiptId
    , kv "created_at_utc"            r.createdAtUtc
    , kv "timestamp_source"          (show r.timestampSource)
    , kv "hash_algorithm"            (show r.hashAlgorithm)
    , kv "content_hash"              r.contentHash
    , kv "submitted_label"           (opt r.submittedLabel)
    , kv "submitter_reference"       (opt r.submitterReference)
    , kv "previous_receipt_hash"     r.previousReceiptHash
    , kv "receipt_hash"              r.receiptHash
    , kv "server_signature"          (opt r.serverSignature)
    , kv "verification_instructions" verificationInstructions
    , kv "disclaimer"                disclaimer
    ]
