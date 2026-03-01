-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-dbconn.
-- Prints the connector name and shows all type constructors.

module Main

import DBConn

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-dbconn type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-dbconn — Database connector interface types"
  putStrLn ""
  showConstructors "ConnState"
    [ show Disconnected, show Connected, show InTransaction, show Failed ]
  showConstructors "IsolationLevel"
    [ show ReadUncommitted, show ReadCommitted, show RepeatableRead
    , show Serializable, show Snapshot ]
  showConstructors "ParamType"
    [ show PText, show PInt, show PFloat, show PBool
    , show PNull, show PBytes, show PTimestamp, show PUUID ]
  showConstructors "QueryResult"
    [ show ResultSet, show RowCount, show Empty, show Error ]
  showConstructors "ConnError"
    [ show ConnectionRefused, show AuthenticationFailed, show QueryError
    , show TransactionError, show Timeout, show PoolExhausted
    , show ProtocolError, show TLSRequired ]
  showConstructors "PoolState"
    [ show Idle, show Active, show Draining, show Closed ]
  putStrLn ""
  putStrLn $ "  defaultPort   = " ++ show defaultPort
  putStrLn $ "  maxPoolSize   = " ++ show maxPoolSize
  putStrLn $ "  queryTimeout  = " ++ show queryTimeout
  putStrLn $ "  maxParamCount = " ++ show maxParamCount
