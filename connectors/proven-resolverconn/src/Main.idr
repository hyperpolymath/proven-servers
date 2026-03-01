-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-resolverconn.
-- Prints the connector name and shows all type constructors.

module Main

import ResolverConn

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-resolverconn type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-resolverconn — DNS resolver connector interface types"
  putStrLn ""
  showConstructors "RecordType"
    [ show A, show AAAA, show CNAME, show MX, show TXT, show SRV
    , show NS, show SOA, show PTR, show CAA, show TLSA
    , show SVCB, show HTTPS ]
  showConstructors "ResolverState"
    [ show Ready, show Querying, show Cached, show Failed ]
  showConstructors "DNSSECStatus"
    [ show Secure, show Insecure, show Bogus, show Indeterminate ]
  showConstructors "ResolverError"
    [ show NXDOMAIN, show ServerFailure, show Refused, show Timeout
    , show DNSSECValidationFailed, show NetworkUnreachable
    , show TruncatedResponse ]
  showConstructors "CachePolicy"
    [ show UseCache, show BypassCache, show CacheOnly, show RefreshCache ]
  putStrLn ""
  putStrLn $ "  defaultTimeout  = " ++ show defaultTimeout
  putStrLn $ "  maxRetries      = " ++ show maxRetries
  putStrLn $ "  maxCacheEntries = " ++ show maxCacheEntries
  putStrLn $ "  minTTL          = " ++ show minTTL
