# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Shared FFI loading utilities for the proven-servers Python bindings.
#
# Loads the Zig-compiled shared library (.so / .dylib / .dll) using ctypes.
# Each protocol module calls load_library() with its protocol-specific
# library name to obtain a ctypes.CDLL handle.

"""FFI library loading for proven-servers Zig shared libraries."""

from __future__ import annotations

import ctypes
import os
import platform
import sys
from pathlib import Path
from typing import Optional


def get_library_path(protocol: str, search_dir: Optional[str] = None) -> Path:
    """Locate the shared library for a given protocol.

    Searches in order:
      1. The PROVEN_LIB_DIR environment variable (if set).
      2. The search_dir argument (if provided).
      3. Relative paths from this package for in-tree builds.
      4. Standard system library paths.

    Args:
        protocol: Protocol name, e.g. "httpd", "dns", "firewall".
        search_dir: Optional directory to search first.

    Returns:
        Path to the shared library file.

    Raises:
        FileNotFoundError: If the library cannot be found.
    """
    lib_name = _library_filename(protocol)

    # Priority 1: environment variable
    env_dir = os.environ.get("PROVEN_LIB_DIR")
    if env_dir:
        candidate = Path(env_dir) / lib_name
        if candidate.exists():
            return candidate

    # Priority 2: explicit search directory
    if search_dir:
        candidate = Path(search_dir) / lib_name
        if candidate.exists():
            return candidate

    # Priority 3: relative to package (in-tree builds)
    pkg_root = Path(__file__).resolve().parent.parent.parent.parent
    for rel in [
        f"ffi/zig/zig-out/lib/{lib_name}",
        f"protocols/proven-{protocol}/ffi/zig/zig-out/lib/{lib_name}",
        f"target/release/{lib_name}",
    ]:
        candidate = pkg_root / rel
        if candidate.exists():
            return candidate

    # Priority 4: system library paths
    for sys_dir in ["/usr/local/lib", "/usr/lib"]:
        candidate = Path(sys_dir) / lib_name
        if candidate.exists():
            return candidate

    raise FileNotFoundError(
        f"Cannot find proven-{protocol} shared library ({lib_name}). "
        f"Set PROVEN_LIB_DIR or pass search_dir."
    )


def load_library(protocol: str, search_dir: Optional[str] = None) -> ctypes.CDLL:
    """Load the Zig FFI shared library for a given protocol.

    Args:
        protocol: Protocol name, e.g. "httpd", "dns", "firewall".
        search_dir: Optional directory to search first.

    Returns:
        A ctypes.CDLL handle for calling FFI functions.

    Raises:
        FileNotFoundError: If the library cannot be found.
        OSError: If the library cannot be loaded.
    """
    lib_path = get_library_path(protocol, search_dir)
    return ctypes.CDLL(str(lib_path))


def _library_filename(protocol: str) -> str:
    """Build the platform-specific shared library filename.

    Args:
        protocol: Protocol name without the "proven-" prefix.

    Returns:
        The filename string, e.g. "libproven_httpd.so" on Linux.
    """
    base = f"proven_{protocol.replace('-', '_')}"
    system = platform.system()
    if system == "Linux":
        return f"lib{base}.so"
    elif system == "Darwin":
        return f"lib{base}.dylib"
    elif system == "Windows":
        return f"{base}.dll"
    else:
        return f"lib{base}.so"
