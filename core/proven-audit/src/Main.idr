-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-audit.
-- Prints the primitive name and shows all type constructors.

module Main

import Audit

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-audit type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-audit — Provably complete audit trail"
  putStrLn ""
  showConstructors "AuditLevel"
    [ show None, show Minimal, show Standard, show Verbose, show Full ]
  showConstructors "EventCategory"
    [ show StateTransition, show Authentication, show Authorization
    , show DataAccess, show Configuration, show Error
    , show Security, show Lifecycle ]
  showConstructors "Integrity"
    [ show Unsigned, show HMAC, show Signed
    , show Chained, show MerkleProof ]
  showConstructors "RetentionPolicy"
    [ show Ephemeral, show Session, show Daily
    , show Indefinite, show Regulatory ]
  showConstructors "AuditError"
    [ show StorageFull, show WriteFailure, show IntegrityViolation
    , show TimestampError, show ChainBroken ]
  putStrLn ""
  putStrLn $ "  maxEventSize     = " ++ show maxEventSize
  putStrLn $ "  defaultRetention = " ++ show defaultRetention
  putStrLn $ "  chainAlgorithm   = " ++ show chainAlgorithm
