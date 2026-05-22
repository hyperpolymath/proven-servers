// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// AMQP protocol types for proven-servers.

namespace Proven;

/// <summary>FrameType matching the Idris2 ABI tags (0-3).</summary>
public enum FrameType : byte
{
    Method = 0,
    Header = 1,
    Body = 2,
    Heartbeat = 3
}

/// <summary>MethodClass matching the Idris2 ABI tags (0-6).</summary>
public enum MethodClass : byte
{
    Connection = 0,
    Channel = 1,
    Exchange = 2,
    Queue = 3,
    Basic = 4,
    Tx = 5,
    Confirm = 6
}

/// <summary>ExchangeType matching the Idris2 ABI tags (0-3).</summary>
public enum ExchangeType : byte
{
    Direct = 0,
    Fanout = 1,
    Topic = 2,
    Headers = 3
}

/// <summary>DeliveryMode matching the Idris2 ABI tags (0-1).</summary>
public enum DeliveryMode : byte
{
    NonPersistent = 0,
    Persistent = 1
}

/// <summary>ErrorSeverity matching the Idris2 ABI tags (0-1).</summary>
public enum ErrorSeverity : byte
{
    ChannelLevel = 0,
    ConnectionLevel = 1
}

/// <summary>ConnectionState matching the Idris2 ABI tags (0-4).</summary>
public enum ConnectionState : byte
{
    Idle = 0,
    Negotiating = 1,
    TuningOk = 2,
    Open = 3,
    Closing = 4
}

/// <summary>ChannelState matching the Idris2 ABI tags (0-3).</summary>
public enum ChannelState : byte
{
    Closed = 0,
    Opening = 1,
    ChOpen = 2,
    ChClosing = 3
}

/// <summary>BrokerState matching the Idris2 ABI tags (0-5).</summary>
public enum BrokerState : byte
{
    Idle = 0,
    Connected = 1,
    ChannelOpen = 2,
    Consuming = 3,
    Publishing = 4,
    Disconnecting = 5
}
