-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-queueconn.
-- Prints the connector name and shows all type constructors.

module Main

import QueueConn

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-queueconn type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-queueconn — Message queue connector interface types"
  putStrLn ""
  showConstructors "QueueOp"
    [ show Publish, show Subscribe, show Acknowledge
    , show Reject, show Peek, show Purge ]
  showConstructors "DeliveryGuarantee"
    [ show AtMostOnce, show AtLeastOnce, show ExactlyOnce ]
  showConstructors "QueueState"
    [ show Disconnected, show Connected, show Consuming
    , show Producing, show Failed ]
  showConstructors "MessageState"
    [ show Pending, show Delivered, show Acknowledged
    , show Rejected, show DeadLettered, show Expired ]
  showConstructors "QueueError"
    [ show ConnectionLost, show QueueNotFound, show MessageTooLarge
    , show QuotaExceeded, show AckTimeout, show Unauthorized
    , show SerializationError ]
  putStrLn ""
  putStrLn $ "  maxMessageSize  = " ++ show maxMessageSize
  putStrLn $ "  defaultPrefetch = " ++ show defaultPrefetch
  putStrLn $ "  ackTimeout      = " ++ show ackTimeout
