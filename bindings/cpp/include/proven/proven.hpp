// SPDX-License-Identifier: MPL-2.0
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

#include "proven/error.hpp"
#include "proven/httpd.hpp"
#include "proven/dns.hpp"
#include "proven/firewall.hpp"
#include "proven/ftp.hpp"
#include "proven/graphql.hpp"
#include "proven/grpc.hpp"
#include "proven/mqtt.hpp"
#include "proven/smtp.hpp"
#include "proven/ssh.hpp"
#include "proven/websocket.hpp"

#endif // PROVEN_HPP
