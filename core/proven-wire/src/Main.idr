-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-wire.
-- Prints the primitive name and shows all type constructors.

module Main

import Wire

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-wire type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-wire — Verified serialisation/deserialisation"
  putStrLn ""
  showConstructors "Endianness"
    [ show BigEndian, show LittleEndian
    , show NetworkOrder, show HostOrder ]
  showConstructors "WireType"
    [ show UInt8, show UInt16, show UInt32, show UInt64
    , show Int8, show Int16, show Int32, show Int64
    , show Float32, show Float64, show Bool
    , show UTF8String, show Bytes
    , show Optional, show Sequence, show Record ]
  showConstructors "EncodeError"
    [ show Overflow, show Underflow, show InvalidUTF8
    , show BufferFull, show FieldMissing, show TypeMismatch ]
  showConstructors "DecodeError"
    [ show UnexpectedEOF, show InvalidTag, show InvalidLength
    , show MalformedData, show UnsupportedVersion, show ChecksumMismatch ]
  showConstructors "Codec"
    [ show Encode, show Decode, show Roundtrip ]
  putStrLn ""
  putStrLn $ "  maxWireSize  = " ++ show maxWireSize
  putStrLn $ "  checksumNone = " ++ show checksumNone
