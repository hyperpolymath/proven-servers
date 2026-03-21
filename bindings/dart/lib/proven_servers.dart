// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// Dart FFI bindings for the proven-servers formally verified protocol ABI.
///
/// This library provides type-safe Dart wrappers for the proven-servers
/// shared library, covering 10 core protocols. All enum values and type
/// layouts mirror the Idris2 ABI definitions in `src/abi/` exactly.
///
/// ## Architecture
///
/// - **Enums**: Dart enums with integer values matching the C-ABI tags.
/// - **FFI**: `dart:ffi` `DynamicLibrary` loading and `NativeFunction` bindings.
/// - **Wrappers**: Safe context classes with `dispose()` for resource cleanup.
///
/// ## Protocols covered
///
/// | Module     | Protocol       | Idris2 source                        |
/// |------------|----------------|--------------------------------------|
/// | httpd      | HTTP/1.1+      | `protocols/proven-httpd/src/`        |
/// | dns        | DNS            | `protocols/proven-dns/src/`          |
/// | smtp       | SMTP           | `protocols/proven-smtp/src/`         |
/// | ftp        | FTP            | `protocols/proven-ftp/src/`          |
/// | ssh        | SSH Bastion    | `protocols/proven-ssh-bastion/src/`  |
/// | mqtt       | MQTT 3.1.1+    | `protocols/proven-mqtt/src/`         |
/// | grpc       | gRPC/HTTP2     | `protocols/proven-grpc/src/`         |
/// | graphql    | GraphQL        | `protocols/proven-graphql/src/`      |
/// | firewall   | Firewall       | `protocols/proven-firewall/src/`     |
/// | websocket  | WebSocket      | `protocols/proven-ws/src/`           |
library proven_servers;

export 'src/error.dart';
export 'src/ffi.dart';
export 'src/httpd.dart';
export 'src/dns.dart';
export 'src/smtp.dart';
export 'src/ftp.dart';
export 'src/ssh.dart';
export 'src/mqtt.dart';
export 'src/grpc.dart';
export 'src/graphql.dart';
export 'src/firewall.dart';
export 'src/websocket.dart';
