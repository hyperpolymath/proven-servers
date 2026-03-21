// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file proven.hpp
/// @brief Top-level header for proven-servers C++ bindings.
///
/// Includes all 10 core protocol headers and the shared error type.
/// Each protocol provides:
/// - C++ enum class types matching the Idris2 ABI tag values
/// - extern "C" declarations for the Zig FFI functions
/// - RAII wrapper classes managing context slot lifetime
/// - std::optional / std::variant where appropriate (C++17)

#ifndef PROVEN_HPP
#define PROVEN_HPP

#include "error.hpp"
#include "httpd.hpp"
#include "dns.hpp"
#include "firewall.hpp"
#include "ftp.hpp"
#include "graphql.hpp"
#include "grpc.hpp"
#include "mqtt.hpp"
#include "smtp.hpp"
#include "ssh.hpp"
#include "websocket.hpp"

#endif // PROVEN_HPP
