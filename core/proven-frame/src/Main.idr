-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-frame.
-- Prints the primitive name and shows all type constructors.

module Main

import Frame

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-frame type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-frame — Framing strategies"
  putStrLn ""
  showConstructors "FrameStrategy"
    [ show LineDelimited, show LengthPrefixed, show HTTPFrame
    , show FixedSize, show ChunkEncoded, show RawBytes, show TLVFrame ]
  showConstructors "Delimiter"
    [ show CRLF, show LF, show Null, show Custom ]
  showConstructors "LengthEncoding"
    [ show BigEndian16, show BigEndian32
    , show LittleEndian16, show LittleEndian32, show Varint ]
  showConstructors "FrameError"
    [ show Incomplete, show Oversized, show InvalidDelimiter
    , show InvalidLength, show MalformedHeader, show EncodingError ]
  showConstructors "FrameState"
    [ show AwaitingHeader, show AwaitingPayload
    , show Complete, show Failed ]
  putStrLn ""
  putStrLn $ "  maxFrameSize      = " ++ show maxFrameSize
  putStrLn $ "  defaultBufferSize = " ++ show defaultBufferSize
