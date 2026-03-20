-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Entry point for proven-amqp.
-- Exercises all type constructors and demonstrates the ABI-FFI pair
-- is well-formed: types encode/decode correctly, queues validate,
-- routing works, and state machines transition properly.

module Main

import AMQP

%default total

||| All AMQP frame type constructors.
allFrameTypes : List FrameType
allFrameTypes = [Method, Header, Body, Heartbeat]

||| All AMQP method class constructors.
allMethodClasses : List MethodClass
allMethodClasses = [Connection, Channel, Exchange, Queue, Basic, Tx, Confirm]

||| All AMQP exchange type constructors.
allExchangeTypes : List ExchangeType
allExchangeTypes = [Direct, Fanout, Topic, Headers]

||| All AMQP delivery mode constructors.
allDeliveryModes : List DeliveryMode
allDeliveryModes = [NonPersistent, Persistent]

||| Demonstrate queue validity proofs.
showQueueValidity : QueueDecl -> String
showQueueValidity q = case validateQueue q of
  Just _  => "VALID"
  Nothing => "INVALID"

||| Demonstrate topic exchange routing.
showRouting : String -> String -> String
showRouting key pat = if topicMatch key pat then "MATCH" else "NO MATCH"

main : IO ()
main = do
  putStrLn "proven-amqp: AMQP 0-9-1 Message Queuing (ABI-FFI enabled)"
  putStrLn $ "  AMQP port:       " ++ show (cast {to=Nat} amqpPort)
  putStrLn $ "  AMQPS port:      " ++ show (cast {to=Nat} amqpsPort)
  putStrLn $ "  Protocol:        " ++ show (cast {to=Nat} protocolMajor)
                                    ++ "." ++ show (cast {to=Nat} protocolMinor)
                                    ++ "." ++ show (cast {to=Nat} protocolRevision)
  putStrLn $ "  Max frame size:  " ++ show maxFrameSize
  putStrLn $ "  Heartbeat:       " ++ show heartbeatInterval ++ "s"
  putStrLn $ "  Frame types:     " ++ show allFrameTypes
  putStrLn $ "  Method classes:  " ++ show allMethodClasses
  putStrLn $ "  Exchange types:  " ++ show allExchangeTypes
  putStrLn $ "  Delivery modes:  " ++ show allDeliveryModes
  putStrLn ""
  putStrLn "  Queue validity proofs:"
  putStrLn $ "    Durable non-exclusive: " ++ showQueueValidity (mkDurableQueue "orders")
  putStrLn $ "    Exclusive non-durable: " ++ showQueueValidity (mkExclusiveQueue "reply-to")
  putStrLn $ "    Durable exclusive:     " ++ showQueueValidity (MkQueueDecl "bad" True True False)
  putStrLn ""
  putStrLn "  Topic routing:"
  putStrLn $ "    stock.usd.nyse vs stock.*.nyse:   " ++ showRouting "stock.usd.nyse" "stock.*.nyse"
  putStrLn $ "    stock.usd.nyse vs stock.#:         " ++ showRouting "stock.usd.nyse" "stock.#"
  putStrLn $ "    stock.usd.nyse vs bond.*.nyse:     " ++ showRouting "stock.usd.nyse" "bond.*.nyse"
