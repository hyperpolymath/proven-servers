-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- AMQPABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into amqp_abi_gen.zig for the comptime guard.

module AMQPABI.Emit

import AMQP.Types
import AMQP.Session
import AMQPABI.Layout
import AMQPABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "FRAME" "METHOD"    (frameTypeToTag Method)
  , line "FRAME" "HEADER"    (frameTypeToTag Header)
  , line "FRAME" "BODY"      (frameTypeToTag Body)
  , line "FRAME" "HEARTBEAT" (frameTypeToTag Heartbeat)
  , line "CLASS" "CONNECTION" (methodClassToTag Connection)
  , line "CLASS" "CHANNEL"    (methodClassToTag Channel)
  , line "CLASS" "EXCHANGE"   (methodClassToTag Exchange)
  , line "CLASS" "QUEUE"      (methodClassToTag Queue)
  , line "CLASS" "BASIC"      (methodClassToTag Basic)
  , line "CLASS" "TX"         (methodClassToTag Tx)
  , line "CLASS" "CONFIRM"    (methodClassToTag Confirm)
  , line "EXCH" "DIRECT"  (exchangeTypeToTag Direct)
  , line "EXCH" "FANOUT"  (exchangeTypeToTag Fanout)
  , line "EXCH" "TOPIC"   (exchangeTypeToTag Topic)
  , line "EXCH" "HEADERS" (exchangeTypeToTag Headers)
  , line "DMODE" "NON_PERSISTENT" (deliveryModeToTag NonPersistent)
  , line "DMODE" "PERSISTENT"     (deliveryModeToTag Persistent)
  , line "SEV" "CHANNEL_LEVEL"    (errorSeverityToTag ChannelLevel)
  , line "SEV" "CONNECTION_LEVEL" (errorSeverityToTag ConnectionLevel)
  , line "CONN" "IDLE"        (connectionStateToTag Idle)
  , line "CONN" "NEGOTIATING" (connectionStateToTag Negotiating)
  , line "CONN" "TUNING_OK"   (connectionStateToTag TuningOk)
  , line "CONN" "OPEN"        (connectionStateToTag Open)
  , line "CONN" "CLOSING"     (connectionStateToTag Closing)
  , line "CHAN" "CLOSED"     (channelStateToTag Closed)
  , line "CHAN" "OPENING"    (channelStateToTag Opening)
  , line "CHAN" "CH_OPEN"    (channelStateToTag ChOpen)
  , line "CHAN" "CH_CLOSING" (channelStateToTag ChClosing)
  , line "BROKER" "IDLE"          (brokerStateToTag BSIdle)
  , line "BROKER" "CONNECTED"     (brokerStateToTag BSConnected)
  , line "BROKER" "CHANNEL_OPEN"  (brokerStateToTag BSChannelOpen)
  , line "BROKER" "CONSUMING"     (brokerStateToTag BSConsuming)
  , line "BROKER" "PUBLISHING"    (brokerStateToTag BSPublishing)
  , line "BROKER" "DISCONNECTING" (brokerStateToTag BSDisconnecting)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
