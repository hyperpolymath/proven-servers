-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AMQP 0-9-1 Core Protocol Types
--
-- Defines frame types, method classes, exchange types, delivery modes,
-- and error codes as closed sum types with Show/Eq instances.
-- All constructors map to AMQP 0-9-1 specification sections.

module AMQP.Types

%default total

-- ============================================================================
-- AMQP Frame Types (AMQP 0-9-1 Section 2.3.5)
-- ============================================================================

||| AMQP frame types per AMQP 0-9-1 specification Section 2.3.5.
||| Every AMQP frame begins with a type byte identifying the frame kind.
public export
data FrameType : Type where
  ||| Method frame (type 1): carries AMQP method invocations.
  Method     : FrameType
  ||| Header frame (type 2): carries content header properties.
  Header     : FrameType
  ||| Body frame (type 3): carries message body data.
  Body       : FrameType
  ||| Heartbeat frame (type 8): connection keep-alive signal.
  Heartbeat  : FrameType

public export
Eq FrameType where
  Method    == Method    = True
  Header    == Header    = True
  Body      == Body      = True
  Heartbeat == Heartbeat = True
  _         == _         = False

public export
Show FrameType where
  show Method    = "Method"
  show Header    = "Header"
  show Body      = "Body"
  show Heartbeat = "Heartbeat"

||| Convert a FrameType to its AMQP wire code.
public export
frameTypeCode : FrameType -> Bits8
frameTypeCode Method    = 1
frameTypeCode Header    = 2
frameTypeCode Body      = 3
frameTypeCode Heartbeat = 8

||| Decode an AMQP wire code to a FrameType.
||| Returns Nothing for unknown/reserved values.
public export
frameTypeFromCode : Bits8 -> Maybe FrameType
frameTypeFromCode 1 = Just Method
frameTypeFromCode 2 = Just Header
frameTypeFromCode 3 = Just Body
frameTypeFromCode 8 = Just Heartbeat
frameTypeFromCode _ = Nothing

-- ============================================================================
-- AMQP Method Classes (AMQP 0-9-1 Section 4)
-- ============================================================================

||| AMQP method classes per AMQP 0-9-1 specification Section 4.
||| Each class groups related operations (e.g., Connection, Channel, Basic).
public export
data MethodClass : Type where
  ||| Connection class (10): connection lifecycle management.
  Connection : MethodClass
  ||| Channel class (20): channel multiplexing.
  Channel    : MethodClass
  ||| Exchange class (40): exchange declaration and management.
  Exchange   : MethodClass
  ||| Queue class (50): queue declaration and management.
  Queue      : MethodClass
  ||| Basic class (60): message publishing and consumption.
  Basic      : MethodClass
  ||| Tx class (90): transaction support.
  Tx         : MethodClass
  ||| Confirm class (85): publisher confirms (RabbitMQ extension).
  Confirm    : MethodClass

public export
Eq MethodClass where
  Connection == Connection = True
  Channel    == Channel    = True
  Exchange   == Exchange   = True
  Queue      == Queue      = True
  Basic      == Basic      = True
  Tx         == Tx         = True
  Confirm    == Confirm    = True
  _          == _          = False

public export
Show MethodClass where
  show Connection = "Connection"
  show Channel    = "Channel"
  show Exchange   = "Exchange"
  show Queue      = "Queue"
  show Basic      = "Basic"
  show Tx         = "Tx"
  show Confirm    = "Confirm"

||| Convert a MethodClass to its AMQP wire class ID.
public export
methodClassId : MethodClass -> Bits16
methodClassId Connection = 10
methodClassId Channel    = 20
methodClassId Exchange   = 40
methodClassId Queue      = 50
methodClassId Basic      = 60
methodClassId Confirm    = 85
methodClassId Tx         = 90

||| Decode an AMQP wire class ID to a MethodClass.
public export
methodClassFromId : Bits16 -> Maybe MethodClass
methodClassFromId 10 = Just Connection
methodClassFromId 20 = Just Channel
methodClassFromId 40 = Just Exchange
methodClassFromId 50 = Just Queue
methodClassFromId 60 = Just Basic
methodClassFromId 85 = Just Confirm
methodClassFromId 90 = Just Tx
methodClassFromId _  = Nothing

-- ============================================================================
-- AMQP Exchange Types (AMQP 0-9-1 Section 3.1.3)
-- ============================================================================

||| AMQP exchange types per AMQP 0-9-1 specification Section 3.1.3.
||| Each exchange type defines a different routing algorithm.
public export
data ExchangeType : Type where
  ||| Direct exchange: routes by exact routing key match.
  Direct   : ExchangeType
  ||| Fanout exchange: routes to all bound queues (ignores routing key).
  Fanout   : ExchangeType
  ||| Topic exchange: routes by routing key pattern matching with wildcards.
  Topic    : ExchangeType
  ||| Headers exchange: routes by header attribute matching.
  Headers  : ExchangeType

public export
Eq ExchangeType where
  Direct  == Direct  = True
  Fanout  == Fanout  = True
  Topic   == Topic   = True
  Headers == Headers = True
  _       == _       = False

public export
Show ExchangeType where
  show Direct  = "direct"
  show Fanout  = "fanout"
  show Topic   = "topic"
  show Headers = "headers"

-- ============================================================================
-- AMQP Delivery Modes (AMQP 0-9-1 Section 4.2.6)
-- ============================================================================

||| AMQP delivery modes per AMQP 0-9-1 specification Section 4.2.6.
||| Controls whether messages survive broker restart.
public export
data DeliveryMode : Type where
  ||| Non-persistent (1): message may be lost on broker restart.
  NonPersistent : DeliveryMode
  ||| Persistent (2): message is written to disk for durability.
  Persistent    : DeliveryMode

public export
Eq DeliveryMode where
  NonPersistent == NonPersistent = True
  Persistent    == Persistent    = True
  _             == _             = False

public export
Show DeliveryMode where
  show NonPersistent = "NonPersistent"
  show Persistent    = "Persistent"

||| Convert a DeliveryMode to its AMQP wire code.
public export
deliveryModeCode : DeliveryMode -> Bits8
deliveryModeCode NonPersistent = 1
deliveryModeCode Persistent    = 2

||| Decode an AMQP wire code to a DeliveryMode.
public export
deliveryModeFromCode : Bits8 -> Maybe DeliveryMode
deliveryModeFromCode 1 = Just NonPersistent
deliveryModeFromCode 2 = Just Persistent
deliveryModeFromCode _ = Nothing

-- ============================================================================
-- AMQP Error Codes (AMQP 0-9-1 Appendix A)
-- ============================================================================

||| AMQP error/reply codes per AMQP 0-9-1 specification Appendix A.
||| These appear in Connection.Close and Channel.Close methods.
public export
data ErrorCode : Type where
  ||| 200: Reply success (normal operation).
  ReplySuccess      : ErrorCode
  ||| 311: Content too large for the channel.
  ContentTooLarge   : ErrorCode
  ||| 313: No consumers available for the queue.
  NoConsumers       : ErrorCode
  ||| 320: Connection forced closed by operator.
  ConnectionForced  : ErrorCode
  ||| 402: Invalid virtual host path.
  InvalidPath       : ErrorCode
  ||| 403: Access refused (insufficient permissions).
  AccessRefused     : ErrorCode
  ||| 404: Resource not found (exchange/queue does not exist).
  NotFound          : ErrorCode
  ||| 405: Resource locked (exclusive access conflict).
  ResourceLocked    : ErrorCode
  ||| 406: Precondition failed (redeclare with different parameters).
  PreconditionFailed : ErrorCode
  ||| 501: Frame error (malformed frame).
  FrameError        : ErrorCode
  ||| 502: Syntax error (malformed method arguments).
  SyntaxError       : ErrorCode
  ||| 503: Command invalid in current state.
  CommandInvalid    : ErrorCode
  ||| 504: Channel error (invalid channel number).
  ChannelError      : ErrorCode
  ||| 505: Unexpected frame type received.
  UnexpectedFrame   : ErrorCode
  ||| 506: Resource error (out of memory/disk).
  ResourceError     : ErrorCode
  ||| 530: Not allowed (operation not permitted).
  NotAllowed        : ErrorCode
  ||| 540: Not implemented on this broker.
  NotImplemented    : ErrorCode
  ||| 541: Internal error (unexpected broker failure).
  InternalError     : ErrorCode

public export
Eq ErrorCode where
  ReplySuccess       == ReplySuccess       = True
  ContentTooLarge    == ContentTooLarge     = True
  NoConsumers        == NoConsumers         = True
  ConnectionForced   == ConnectionForced    = True
  InvalidPath        == InvalidPath         = True
  AccessRefused      == AccessRefused       = True
  NotFound           == NotFound            = True
  ResourceLocked     == ResourceLocked      = True
  PreconditionFailed == PreconditionFailed  = True
  FrameError         == FrameError          = True
  SyntaxError        == SyntaxError         = True
  CommandInvalid     == CommandInvalid      = True
  ChannelError       == ChannelError        = True
  UnexpectedFrame    == UnexpectedFrame     = True
  ResourceError      == ResourceError       = True
  NotAllowed         == NotAllowed          = True
  NotImplemented     == NotImplemented      = True
  InternalError      == InternalError       = True
  _                  == _                   = False

public export
Show ErrorCode where
  show ReplySuccess       = "ReplySuccess"
  show ContentTooLarge    = "ContentTooLarge"
  show NoConsumers        = "NoConsumers"
  show ConnectionForced   = "ConnectionForced"
  show InvalidPath        = "InvalidPath"
  show AccessRefused      = "AccessRefused"
  show NotFound           = "NotFound"
  show ResourceLocked     = "ResourceLocked"
  show PreconditionFailed = "PreconditionFailed"
  show FrameError         = "FrameError"
  show SyntaxError        = "SyntaxError"
  show CommandInvalid     = "CommandInvalid"
  show ChannelError       = "ChannelError"
  show UnexpectedFrame    = "UnexpectedFrame"
  show ResourceError      = "ResourceError"
  show NotAllowed         = "NotAllowed"
  show NotImplemented     = "NotImplemented"
  show InternalError      = "InternalError"

||| Convert an ErrorCode to its AMQP wire reply code.
public export
errorCodeValue : ErrorCode -> Bits16
errorCodeValue ReplySuccess       = 200
errorCodeValue ContentTooLarge    = 311
errorCodeValue NoConsumers        = 313
errorCodeValue ConnectionForced   = 320
errorCodeValue InvalidPath        = 402
errorCodeValue AccessRefused      = 403
errorCodeValue NotFound           = 404
errorCodeValue ResourceLocked     = 405
errorCodeValue PreconditionFailed = 406
errorCodeValue FrameError         = 501
errorCodeValue SyntaxError        = 502
errorCodeValue CommandInvalid     = 503
errorCodeValue ChannelError       = 504
errorCodeValue UnexpectedFrame    = 505
errorCodeValue ResourceError      = 506
errorCodeValue NotAllowed         = 530
errorCodeValue NotImplemented     = 540
errorCodeValue InternalError      = 541

||| Decode an AMQP wire reply code to an ErrorCode.
public export
errorCodeFromValue : Bits16 -> Maybe ErrorCode
errorCodeFromValue 200 = Just ReplySuccess
errorCodeFromValue 311 = Just ContentTooLarge
errorCodeFromValue 313 = Just NoConsumers
errorCodeFromValue 320 = Just ConnectionForced
errorCodeFromValue 402 = Just InvalidPath
errorCodeFromValue 403 = Just AccessRefused
errorCodeFromValue 404 = Just NotFound
errorCodeFromValue 405 = Just ResourceLocked
errorCodeFromValue 406 = Just PreconditionFailed
errorCodeFromValue 501 = Just FrameError
errorCodeFromValue 502 = Just SyntaxError
errorCodeFromValue 503 = Just CommandInvalid
errorCodeFromValue 504 = Just ChannelError
errorCodeFromValue 505 = Just UnexpectedFrame
errorCodeFromValue 506 = Just ResourceError
errorCodeFromValue 530 = Just NotAllowed
errorCodeFromValue 540 = Just NotImplemented
errorCodeFromValue 541 = Just InternalError
errorCodeFromValue _   = Nothing

-- ============================================================================
-- Error severity classification
-- ============================================================================

||| Error severity: whether an error closes the channel or the connection.
public export
data ErrorSeverity : Type where
  ||| Soft error: only the channel is closed (codes 3xx, 4xx).
  ChannelLevel    : ErrorSeverity
  ||| Hard error: the entire connection is closed (codes 5xx).
  ConnectionLevel : ErrorSeverity

public export
Eq ErrorSeverity where
  ChannelLevel    == ChannelLevel    = True
  ConnectionLevel == ConnectionLevel = True
  _               == _               = False

public export
Show ErrorSeverity where
  show ChannelLevel    = "Channel-level (soft)"
  show ConnectionLevel = "Connection-level (hard)"

||| Determine the severity of an error code.
||| AMQP 0-9-1 classifies 3xx/4xx as channel-level and 5xx as connection-level.
||| ReplySuccess is technically not an error, but is classified as channel-level
||| for completeness.
public export
errorSeverity : ErrorCode -> ErrorSeverity
errorSeverity ReplySuccess       = ChannelLevel
errorSeverity ContentTooLarge    = ChannelLevel
errorSeverity NoConsumers        = ChannelLevel
errorSeverity ConnectionForced   = ConnectionLevel
errorSeverity InvalidPath        = ConnectionLevel
errorSeverity AccessRefused      = ChannelLevel
errorSeverity NotFound           = ChannelLevel
errorSeverity ResourceLocked     = ChannelLevel
errorSeverity PreconditionFailed = ChannelLevel
errorSeverity FrameError         = ConnectionLevel
errorSeverity SyntaxError        = ConnectionLevel
errorSeverity CommandInvalid     = ConnectionLevel
errorSeverity ChannelError       = ConnectionLevel
errorSeverity UnexpectedFrame    = ConnectionLevel
errorSeverity ResourceError      = ConnectionLevel
errorSeverity NotAllowed         = ConnectionLevel
errorSeverity NotImplemented     = ConnectionLevel
errorSeverity InternalError      = ConnectionLevel
