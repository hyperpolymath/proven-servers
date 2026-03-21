# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# proven_servers — Python bindings for the proven-servers Zig FFI libraries.
#
# This package provides type-safe ctypes wrappers for all 10 core protocols:
# httpd, dns, smtp, ftp, ssh_bastion, mqtt, grpc, graphql, tls, firewall.
#
# Each protocol module exposes:
#   - IntEnum classes matching Idris2 ABI tags
#   - ctypes wrapper functions calling the Zig shared library
#   - A context manager for session lifecycle (create/destroy)
#   - Full type hints and docstrings

"""proven_servers — Python bindings for formally verified protocol libraries."""

__version__ = "0.1.0"
__author__ = "Jonathan D.A. Jewell"
__license__ = "PMPL-1.0-or-later"

from proven_servers.error import ProvenError, ProvenErrorCode
from proven_servers.ffi import get_library_path, load_library

__all__ = [
    "ProvenError",
    "ProvenErrorCode",
    "get_library_path",
    "load_library",
    # Protocol modules (import individually):
    # proven_servers.httpd
    # proven_servers.dns
    # proven_servers.smtp
    # proven_servers.ftp
    # proven_servers.ssh_bastion
    # proven_servers.mqtt
    # proven_servers.grpc
    # proven_servers.graphql
    # proven_servers.tls
    # proven_servers.firewall
]
