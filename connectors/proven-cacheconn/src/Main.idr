-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-cacheconn.
-- Prints the connector name and shows all type constructors.

module Main

import CacheConn

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-cacheconn type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-cacheconn — Cache connector interface types"
  putStrLn ""
  showConstructors "CacheOp"
    [ show Get, show Set, show Delete, show Exists
    , show Expire, show Increment, show Decrement, show Flush ]
  showConstructors "CacheResult"
    [ show Hit, show Miss, show Stored, show Deleted
    , show Expired, show Error ]
  showConstructors "EvictionPolicy"
    [ show LRU, show LFU, show FIFO, show TTLBased
    , show Random, show NoEviction ]
  showConstructors "CacheState"
    [ show Disconnected, show Connected, show Degraded, show Failed ]
  showConstructors "CacheError"
    [ show ConnectionLost, show KeyNotFound, show ValueTooLarge
    , show CapacityExceeded, show SerializationError, show Timeout ]
  putStrLn ""
  putStrLn $ "  defaultTTL   = " ++ show defaultTTL
  putStrLn $ "  maxKeyLength = " ++ show maxKeyLength
  putStrLn $ "  maxValueSize = " ++ show maxValueSize
