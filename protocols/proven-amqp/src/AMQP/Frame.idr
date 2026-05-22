-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AMQP 0-9-1 Frame Structure
--
-- Every AMQP frame has a fixed 7-byte header (type, channel, size)
-- and a 1-byte end marker (0xCE). This module defines the frame
-- structure, validates frame sizes, and provides construction/parse
-- error types. Malformed frames cannot be represented — they are
-- rejected as parse errors.
--
-- Frame layout per AMQP 0-9-1 Section 2.3.5:
--   +------+--------+------+---------+-----+
--   | type | channel | size | payload | end |
--   |  1B  |   2B    |  4B  |  size B | 1B  |
--   +------+--------+------+---------+-----+

module AMQP.Frame

import AMQP.Types
import AMQP.Properties
import AMQP.Session

%default total

-- ============================================================================
-- Frame end marker
-- ============================================================================

||| The frame end octet per AMQP 0-9-1 Section 2.3.5.
||| Every frame must terminate with this byte.
public export
frameEnd : Bits8
frameEnd = 0xCE

-- ============================================================================
-- Frame header
-- ============================================================================

||| The fixed header of an AMQP frame (7 bytes on the wire).
public export
record FrameHeader where
  constructor MkFrameHeader
  ||| Frame type (Method, Header, Body, Heartbeat).
  frameType : FrameType
  ||| Channel number (0 for connection-level frames).
  channel   : Bits16
  ||| Payload size in bytes (not including the 8-byte header + end marker).
  size      : Bits32

public export
Show FrameHeader where
  show h = show h.frameType
           ++ " ch=" ++ show (cast {to=Nat} h.channel)
           ++ " size=" ++ show (cast {to=Nat} h.size)

-- ============================================================================
-- Method frame payload identification
-- ============================================================================

||| An AMQP method identifier: class ID + method ID.
||| These appear in the first 4 bytes of a method frame payload.
public export
record MethodId where
  constructor MkMethodId
  ||| Method class (Connection=10, Channel=20, Exchange=40, etc.).
  classId  : Bits16
  ||| Method within the class.
  methodId : Bits16

public export
Eq MethodId where
  a == b = a.classId == b.classId && a.methodId == b.methodId

public export
Show MethodId where
  show m = "Method(" ++ show (cast {to=Nat} m.classId)
           ++ "." ++ show (cast {to=Nat} m.methodId) ++ ")"

-- ============================================================================
-- Well-known method IDs (AMQP 0-9-1 Section 4)
-- ============================================================================

||| Connection.Start (10, 10).
public export
connectionStart : MethodId
connectionStart = MkMethodId 10 10

||| Connection.Start-Ok (10, 11).
public export
connectionStartOk : MethodId
connectionStartOk = MkMethodId 10 11

||| Connection.Tune (10, 30).
public export
connectionTune : MethodId
connectionTune = MkMethodId 10 30

||| Connection.Tune-Ok (10, 31).
public export
connectionTuneOk : MethodId
connectionTuneOk = MkMethodId 10 31

||| Connection.Open (10, 40).
public export
connectionOpen : MethodId
connectionOpen = MkMethodId 10 40

||| Connection.Open-Ok (10, 41).
public export
connectionOpenOk : MethodId
connectionOpenOk = MkMethodId 10 41

||| Connection.Close (10, 50).
public export
connectionClose : MethodId
connectionClose = MkMethodId 10 50

||| Connection.Close-Ok (10, 51).
public export
connectionCloseOk : MethodId
connectionCloseOk = MkMethodId 10 51

||| Channel.Open (20, 10).
public export
channelOpen : MethodId
channelOpen = MkMethodId 20 10

||| Channel.Open-Ok (20, 11).
public export
channelOpenOk : MethodId
channelOpenOk = MkMethodId 20 11

||| Channel.Close (20, 40).
public export
channelClose : MethodId
channelClose = MkMethodId 20 40

||| Channel.Close-Ok (20, 41).
public export
channelCloseOk : MethodId
channelCloseOk = MkMethodId 20 41

||| Channel.Flow (20, 20).
public export
channelFlow : MethodId
channelFlow = MkMethodId 20 20

||| Channel.Flow-Ok (20, 21).
public export
channelFlowOk : MethodId
channelFlowOk = MkMethodId 20 21

||| Exchange.Declare (40, 10).
public export
exchangeDeclare : MethodId
exchangeDeclare = MkMethodId 40 10

||| Exchange.Declare-Ok (40, 11).
public export
exchangeDeclareOk : MethodId
exchangeDeclareOk = MkMethodId 40 11

||| Exchange.Delete (40, 20).
public export
exchangeDelete : MethodId
exchangeDelete = MkMethodId 40 20

||| Queue.Declare (50, 10).
public export
queueDeclare : MethodId
queueDeclare = MkMethodId 50 10

||| Queue.Declare-Ok (50, 11).
public export
queueDeclareOk : MethodId
queueDeclareOk = MkMethodId 50 11

||| Queue.Bind (50, 20).
public export
queueBind : MethodId
queueBind = MkMethodId 50 20

||| Queue.Unbind (50, 50).
public export
queueUnbind : MethodId
queueUnbind = MkMethodId 50 50

||| Queue.Delete (50, 40).
public export
queueDelete : MethodId
queueDelete = MkMethodId 50 40

||| Basic.Qos (60, 10).
public export
basicQos : MethodId
basicQos = MkMethodId 60 10

||| Basic.Consume (60, 20).
public export
basicConsume : MethodId
basicConsume = MkMethodId 60 20

||| Basic.Cancel (60, 30).
public export
basicCancel : MethodId
basicCancel = MkMethodId 60 30

||| Basic.Publish (60, 40).
public export
basicPublish : MethodId
basicPublish = MkMethodId 60 40

||| Basic.Deliver (60, 60).
public export
basicDeliver : MethodId
basicDeliver = MkMethodId 60 60

||| Basic.Ack (60, 80).
public export
basicAck : MethodId
basicAck = MkMethodId 60 80

||| Basic.Reject (60, 90).
public export
basicReject : MethodId
basicReject = MkMethodId 60 90

||| Basic.Nack (60, 120) — RabbitMQ extension.
public export
basicNack : MethodId
basicNack = MkMethodId 60 120

-- ============================================================================
-- Parse errors
-- ============================================================================

||| Errors that can occur during AMQP frame parsing.
||| These are values, not exceptions — no crashes possible.
public export
data AMQPParseError : Type where
  ||| Frame end marker is not 0xCE.
  InvalidFrameEnd      : (actual : Bits8) -> AMQPParseError
  ||| Unknown frame type byte.
  UnknownFrameType     : (code : Bits8) -> AMQPParseError
  ||| Frame payload exceeds negotiated maximum frame size.
  FrameTooLarge        : (actual : Nat) -> (maxAllowed : Nat) -> AMQPParseError
  ||| Frame payload is shorter than required for its type.
  FrameTooShort        : (expected : Nat) -> (actual : Nat) -> AMQPParseError
  ||| Unknown method class/method ID combination.
  UnknownMethod        : (classId : Bits16) -> (methodId : Bits16) -> AMQPParseError
  ||| Heartbeat frame has non-zero channel or non-zero payload size.
  InvalidHeartbeat     : AMQPParseError
  ||| Method frame received on channel 0 for a non-Connection method.
  MethodOnWrongChannel : MethodId -> (channel : Bits16) -> AMQPParseError

public export
Show AMQPParseError where
  show (InvalidFrameEnd a) = "Invalid frame end: expected 0xCE, got " ++ show (cast {to=Nat} a)
  show (UnknownFrameType c) = "Unknown frame type: " ++ show (cast {to=Nat} c)
  show (FrameTooLarge a m) = "Frame too large: " ++ show a ++ " bytes (max " ++ show m ++ ")"
  show (FrameTooShort e a) = "Frame too short: need " ++ show e ++ ", got " ++ show a
  show (UnknownMethod c m) = "Unknown method: " ++ show (cast {to=Nat} c) ++ "." ++ show (cast {to=Nat} m)
  show InvalidHeartbeat = "Invalid heartbeat (non-zero channel or payload)"
  show (MethodOnWrongChannel m c) = "Method " ++ show m ++ " on wrong channel " ++ show (cast {to=Nat} c)

-- ============================================================================
-- Heartbeat validation
-- ============================================================================

||| Validate that a heartbeat frame has channel=0 and size=0.
public export
validateHeartbeat : FrameHeader -> Either AMQPParseError ()
validateHeartbeat h =
  if h.channel /= 0 || h.size /= 0
    then Left InvalidHeartbeat
    else Right ()

-- ============================================================================
-- Channel 0 method validation
-- ============================================================================

||| Check if a method belongs to the Connection class (must use channel 0).
public export
isConnectionMethod : MethodId -> Bool
isConnectionMethod m = m.classId == 10

||| Validate that connection methods use channel 0 and other methods don't.
public export
validateMethodChannel : MethodId -> (channel : Bits16) -> Either AMQPParseError ()
validateMethodChannel m ch =
  if isConnectionMethod m && ch /= 0
    then Left (MethodOnWrongChannel m ch)
    else if not (isConnectionMethod m) && ch == 0
      then Left (MethodOnWrongChannel m ch)
      else Right ()
