// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file amqp.hpp
/// @brief AMQP protocol types for proven-servers.

#ifndef PROVEN_AMQP_HPP
#define PROVEN_AMQP_HPP

#include <cstdint>

namespace proven {

/// @brief FrameType matching the Idris2 ABI tags.
enum class FrameType : uint8_t {
    Method = 0,
    Header = 1,
    Body = 2,
    Heartbeat = 3
};

/// @brief MethodClass matching the Idris2 ABI tags.
enum class MethodClass : uint8_t {
    Connection = 0,
    Channel = 1,
    Exchange = 2,
    Queue = 3,
    Basic = 4,
    Tx = 5,
    Confirm = 6
};

/// @brief ExchangeType matching the Idris2 ABI tags.
enum class ExchangeType : uint8_t {
    Direct = 0,
    Fanout = 1,
    Topic = 2,
    Headers = 3
};

/// @brief DeliveryMode matching the Idris2 ABI tags.
enum class DeliveryMode : uint8_t {
    NonPersistent = 0,
    Persistent = 1
};

/// @brief ErrorSeverity matching the Idris2 ABI tags.
enum class ErrorSeverity : uint8_t {
    ChannelLevel = 0,
    ConnectionLevel = 1
};

/// @brief ConnectionState matching the Idris2 ABI tags.
enum class ConnectionState : uint8_t {
    Idle = 0,
    Negotiating = 1,
    TuningOk = 2,
    Open = 3,
    Closing = 4
};

/// @brief ChannelState matching the Idris2 ABI tags.
enum class ChannelState : uint8_t {
    Closed = 0,
    Opening = 1,
    ChOpen = 2,
    ChClosing = 3
};

/// @brief BrokerState matching the Idris2 ABI tags.
enum class BrokerState : uint8_t {
    Idle = 0,
    Connected = 1,
    ChannelOpen = 2,
    Consuming = 3,
    Publishing = 4,
    Disconnecting = 5
};

} // namespace proven

#endif // PROVEN_AMQP_HPP
