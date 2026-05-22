<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// AMQP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** FrameType matching the Idris2 ABI tags. */
enum FrameType: int
{
    case Method = 0;
    case Header = 1;
    case Body = 2;
    case Heartbeat = 3;
}

/** MethodClass matching the Idris2 ABI tags. */
enum MethodClass: int
{
    case Connection = 0;
    case Channel = 1;
    case Exchange = 2;
    case Queue = 3;
    case Basic = 4;
    case Tx = 5;
    case Confirm = 6;
}

/** ExchangeType matching the Idris2 ABI tags. */
enum ExchangeType: int
{
    case Direct = 0;
    case Fanout = 1;
    case Topic = 2;
    case Headers = 3;
}

/** DeliveryMode matching the Idris2 ABI tags. */
enum DeliveryMode: int
{
    case NonPersistent = 0;
    case Persistent = 1;
}

/** ErrorSeverity matching the Idris2 ABI tags. */
enum ErrorSeverity: int
{
    case ChannelLevel = 0;
    case ConnectionLevel = 1;
}

/** ConnectionState matching the Idris2 ABI tags. */
enum ConnectionState: int
{
    case ConnectionState_Idle = 0;
    case Negotiating = 1;
    case TuningOk = 2;
    case Open = 3;
    case Closing = 4;
}

/** ChannelState matching the Idris2 ABI tags. */
enum ChannelState: int
{
    case Closed = 0;
    case Opening = 1;
    case ChOpen = 2;
    case ChClosing = 3;
}

/** BrokerState matching the Idris2 ABI tags. */
enum BrokerState: int
{
    case BrokerState_Idle = 0;
    case Connected = 1;
    case ChannelOpen = 2;
    case Consuming = 3;
    case Publishing = 4;
    case Disconnecting = 5;
}
