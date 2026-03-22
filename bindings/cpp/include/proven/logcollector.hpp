// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file logcollector.hpp
/// @brief Log Collector protocol types for proven-servers.

#ifndef PROVEN_LOGCOLLECTOR_HPP
#define PROVEN_LOGCOLLECTOR_HPP

#include <cstdint>

namespace proven {

/// @brief LogLevel matching the Idris2 ABI tags.
enum class LogLevel : uint8_t {
    Trace = 0,
    Debug = 1,
    Info = 2,
    Warn = 3,
    Err = 4,
    Fatal = 5
};

/// @brief InputFormat matching the Idris2 ABI tags.
enum class InputFormat : uint8_t {
    Json = 0,
    Logfmt = 1,
    Syslog = 2,
    Cef = 3,
    Gelf = 4,
    Raw = 5
};

/// @brief OutputTarget matching the Idris2 ABI tags.
enum class OutputTarget : uint8_t {
    File = 0,
    Elasticsearch = 1,
    S3 = 2,
    Kafka = 3,
    Stdout = 4
};

/// @brief FilterOp matching the Idris2 ABI tags.
enum class FilterOp : uint8_t {
    Include = 0,
    Exclude = 1,
    Transform = 2,
    Redact = 3,
    Sample = 4
};

/// @brief PipelineStage matching the Idris2 ABI tags.
enum class PipelineStage : uint8_t {
    Input = 0,
    Parse = 1,
    Filter = 2,
    PipelineTransform = 3,
    Output = 4
};

} // namespace proven

#endif // PROVEN_LOGCOLLECTOR_HPP
