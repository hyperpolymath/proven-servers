-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| Entry point for proven-timestamp.
|||
||| Prints service identification and runs a small live demo that builds two
||| linked receipts (using fixed SHA3-256 vectors that the Zig engine
||| reproduces) and validates the hash chain through `validateChain`.
module Main

import Timestamp

%default total

-- Fixed SHA3-256 vectors (see ffi/zig/src/timestamp.zig tests):
--   content_hash(hello) and content_hash(world), then the two receipt hashes
--   derived from the canonical pre-image.
ch0 : String
ch0 = "3338be694f50c5f338814986cdf0686453a888b84f424d792af4b9202398f392"

ch1 : String
ch1 = "420baf620e3fcd9b3715b42b92506e9304d56e02d3a103499a3a292560cb66b2"

rh0 : String
rh0 = "f943110b734fe3ff9ac100ecf2bc5cd883e14ec5a4c220b61ebaa25cbd64ca84"

rh1 : String
rh1 = "876a1edc5fe50cefd7dbde74bea4552d5f120f8510a14e2f3dfd3fd79d09a9ef"

receipt0 : Receipt
receipt0 = MkReceipt "0" "2026-06-23T00:00:00Z" Internal SHA3_256 ch0
                     Nothing Nothing genesisHash rh0 Nothing

receipt1 : Receipt
receipt1 = MkReceipt "1" "2026-06-23T00:00:01Z" Internal SHA3_256 ch1
                     (Just "minutes") (Just "case-42") rh0 rh1 Nothing

||| The append-only log, newest first.
demoLog : List Receipt
demoLog = [receipt1, receipt0]

chainStatus : String
chainStatus = case validateChain demoLog of
                Just _  => "VALID (hash chain links check out)"
                Nothing => "INVALID"

covering
main : IO ()
main = do
  putStrLn "proven-timestamp — evidence-preservation timestamp receipts"
  putStrLn $ "  Default port:   " ++ show defaultPort
  putStrLn $ "  Default hash:   " ++ show defaultHashAlgo
  putStrLn $ "  Max content:    " ++ show maxContentBytes ++ " bytes"
  putStrLn $ "  Provider:       " ++ providerName internalProvider
                                   ++ " (" ++ show (providerSource internalProvider) ++ ")"
  putStrLn $ "  Disclaimer:     " ++ disclaimer
  putStrLn ""
  putStrLn "Demo append-only log (newest first):"
  putStrLn $ "  chain status:   " ++ chainStatus
  putStrLn ""
  putStrLn "Canonical pre-image of receipt 0 (the bytes hashed for receipt_hash):"
  putStrLn (canonicalPreimage receipt0)
  putStrLn ""
  putStrLn "Receipt 1 as NDJSON:"
  putStrLn (toNdjson receipt1)
  putStrLn ""
  putStrLn "Receipt 1 as a2ml:"
  putStrLn (toA2ml receipt1)
