-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Top-level package spec for proven-servers Ada bindings.
--
-- This package serves as the root namespace for all proven-servers
-- protocol bindings. Each protocol is exposed as a child package
-- (e.g. Proven_Servers.Httpd, Proven_Servers.Dns, etc.).
--
-- All child packages use pragma Import (C, ...) to call into the
-- Zig FFI shared libraries, and pragma Convention (C, ...) on
-- enumeration types to ensure C ABI compatibility with the Idris2
-- type definitions.

package Proven_Servers is
   pragma Pure;

   -- Library version. Must match the Zig FFI ABI version.
   ABI_Version : constant := 1;

end Proven_Servers;
