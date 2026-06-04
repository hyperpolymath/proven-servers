# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-ftp Zig FFI.

"""Python bindings for the proven-ftp protocol FFI."""

from __future__ import annotations

import ctypes
from enum import IntEnum
from types import TracebackType
from typing import Optional

from proven_servers.error import check_slot, check_status
from proven_servers.ffi import load_library


# ---------------------------------------------------------------------------
# Enums matching Idris2 ABI tags
# ---------------------------------------------------------------------------

class FtpSessionState(IntEnum):
    """FTP session states matching the Idris2 ABI tags."""
    CONNECTED = 0
    USER_OK = 1
    AUTHENTICATED = 2
    RENAMING = 3
    QUIT = 4


class TransferState(IntEnum):
    """FTP transfer states matching the Idris2 ABI tags."""
    IDLE = 0
    IN_PROGRESS = 1
    COMPLETED = 2
    ABORTED = 3


class TransferType(IntEnum):
    """FTP transfer type tags."""
    ASCII = 0
    BINARY = 1


class DataMode(IntEnum):
    """FTP data mode tags."""
    ACTIVE = 0
    PASSIVE = 1


# ---------------------------------------------------------------------------
# FFI function setup
# ---------------------------------------------------------------------------

_lib: Optional[ctypes.CDLL] = None


def _get_lib() -> ctypes.CDLL:
    """Lazy-load the proven-ftp shared library."""
    global _lib
    if _lib is None:
        _lib = load_library("ftp")
        _setup_signatures(_lib)
    return _lib


def _setup_signatures(lib: ctypes.CDLL) -> None:
    """Declare ctypes function signatures for type safety."""
    lib.ftp_abi_version.restype = ctypes.c_uint32
    lib.ftp_create.restype = ctypes.c_int
    lib.ftp_destroy.restype = None
    lib.ftp_destroy.argtypes = [ctypes.c_int]
    lib.ftp_state.restype = ctypes.c_uint8
    lib.ftp_state.argtypes = [ctypes.c_int]
    lib.ftp_transfer_type.restype = ctypes.c_uint8
    lib.ftp_transfer_type.argtypes = [ctypes.c_int]
    lib.ftp_data_mode.restype = ctypes.c_uint8
    lib.ftp_data_mode.argtypes = [ctypes.c_int]
    lib.ftp_transfer_state.restype = ctypes.c_uint8
    lib.ftp_transfer_state.argtypes = [ctypes.c_int]
    lib.ftp_bytes_transferred.restype = ctypes.c_uint64
    lib.ftp_bytes_transferred.argtypes = [ctypes.c_int]
    lib.ftp_file_count.restype = ctypes.c_uint32
    lib.ftp_file_count.argtypes = [ctypes.c_int]
    lib.ftp_last_reply_code.restype = ctypes.c_uint16
    lib.ftp_last_reply_code.argtypes = [ctypes.c_int]
    lib.ftp_cwd.restype = ctypes.c_uint32
    lib.ftp_cwd.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32]
    lib.ftp_user.restype = ctypes.c_uint8
    lib.ftp_user.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32]
    lib.ftp_pass.restype = ctypes.c_uint8
    lib.ftp_pass.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32]
    lib.ftp_quit.restype = ctypes.c_uint8
    lib.ftp_quit.argtypes = [ctypes.c_int]
    lib.ftp_cwd_cmd.restype = ctypes.c_uint8
    lib.ftp_cwd_cmd.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32]
    lib.ftp_cdup.restype = ctypes.c_uint8
    lib.ftp_cdup.argtypes = [ctypes.c_int]
    lib.ftp_set_type.restype = ctypes.c_uint8
    lib.ftp_set_type.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.ftp_set_passive.restype = ctypes.c_uint8
    lib.ftp_set_passive.argtypes = [ctypes.c_int]
    lib.ftp_set_active.restype = ctypes.c_uint8
    lib.ftp_set_active.argtypes = [ctypes.c_int, ctypes.c_uint16]
    lib.ftp_begin_transfer.restype = ctypes.c_uint8
    lib.ftp_begin_transfer.argtypes = [ctypes.c_int]
    lib.ftp_add_bytes.restype = ctypes.c_uint8
    lib.ftp_add_bytes.argtypes = [ctypes.c_int, ctypes.c_uint64]
    lib.ftp_complete_transfer.restype = ctypes.c_uint8
    lib.ftp_complete_transfer.argtypes = [ctypes.c_int]
    lib.ftp_abort_transfer.restype = ctypes.c_uint8
    lib.ftp_abort_transfer.argtypes = [ctypes.c_int]
    lib.ftp_begin_rename.restype = ctypes.c_uint8
    lib.ftp_begin_rename.argtypes = [ctypes.c_int]
    lib.ftp_complete_rename.restype = ctypes.c_uint8
    lib.ftp_complete_rename.argtypes = [ctypes.c_int]
    lib.ftp_can_transfer.restype = ctypes.c_uint8
    lib.ftp_can_transfer.argtypes = [ctypes.c_uint8]
    lib.ftp_can_transition.restype = ctypes.c_uint8
    lib.ftp_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]


# ---------------------------------------------------------------------------
# Context manager
# ---------------------------------------------------------------------------

class FtpContext:
    """Context manager for an FTP session lifecycle.

    Usage::

        with FtpContext() as ctx:
            ctx.user("anonymous")
            ctx.password("user@example.com")
            ctx.set_passive()
            ctx.begin_transfer()
            ctx.add_bytes(1024)
            ctx.complete_transfer()
            ctx.quit_session()
    """

    def __init__(self) -> None:
        lib = _get_lib()
        self._slot: int = check_slot(lib.ftp_create())
        self._lib = lib
        self._closed = False

    def __enter__(self) -> FtpContext:
        return self

    def __exit__(self, exc_type: Optional[type[BaseException]],
                 exc_val: Optional[BaseException],
                 exc_tb: Optional[TracebackType]) -> None:
        self.close()

    def __del__(self) -> None:
        self.close()

    def close(self) -> None:
        """Release the context slot back to the pool."""
        if not self._closed:
            self._lib.ftp_destroy(self._slot)
            self._closed = True

    # -- State queries -----------------------------------------------------

    def state(self) -> Optional[FtpSessionState]:
        """Get the current session state."""
        tag = self._lib.ftp_state(self._slot)
        try:
            return FtpSessionState(tag)
        except ValueError:
            return None

    def transfer_type(self) -> int:
        """Get the transfer type tag (0=ASCII, 1=binary)."""
        return self._lib.ftp_transfer_type(self._slot)

    def data_mode(self) -> int:
        """Get the data mode tag (0=active, 1=passive, 255=unset)."""
        return self._lib.ftp_data_mode(self._slot)

    def transfer_state(self) -> Optional[TransferState]:
        """Get the transfer state."""
        tag = self._lib.ftp_transfer_state(self._slot)
        try:
            return TransferState(tag)
        except ValueError:
            return None

    def bytes_transferred(self) -> int:
        """Get bytes transferred in the current/last transfer."""
        return self._lib.ftp_bytes_transferred(self._slot)

    def file_count(self) -> int:
        """Get total file count."""
        return self._lib.ftp_file_count(self._slot)

    def last_reply_code(self) -> int:
        """Get the last FTP numeric reply code (e.g. 220, 331, 230)."""
        return self._lib.ftp_last_reply_code(self._slot)

    def cwd(self, max_len: int = 4096) -> str:
        """Get the current working directory."""
        buf = (ctypes.c_uint8 * max_len)()
        written = self._lib.ftp_cwd(self._slot, buf, max_len)
        return bytes(buf[:written]).decode("utf-8", errors="replace")

    # -- Commands ----------------------------------------------------------

    def user(self, name: str) -> None:
        """USER command. Transitions Connected -> UserOk."""
        data = name.encode("utf-8")
        buf = (ctypes.c_uint8 * len(data))(*data)
        check_status(self._lib.ftp_user(self._slot, buf, len(data)))

    def password(self, password: str) -> None:
        """PASS command. Transitions UserOk -> Authenticated."""
        data = password.encode("utf-8")
        buf = (ctypes.c_uint8 * len(data))(*data)
        check_status(self._lib.ftp_pass(self._slot, buf, len(data)))

    def quit_session(self) -> None:
        """QUIT command. Transitions to Quit."""
        check_status(self._lib.ftp_quit(self._slot))

    def change_dir(self, path: str) -> None:
        """CWD command. Changes directory."""
        data = path.encode("utf-8")
        buf = (ctypes.c_uint8 * len(data))(*data)
        check_status(self._lib.ftp_cwd_cmd(self._slot, buf, len(data)))

    def change_dir_up(self) -> None:
        """CDUP command. Changes to parent directory."""
        check_status(self._lib.ftp_cdup(self._slot))

    def set_type(self, type_tag: TransferType) -> None:
        """TYPE command. Sets transfer type."""
        check_status(self._lib.ftp_set_type(self._slot, type_tag.value))

    def set_passive(self) -> None:
        """PASV command. Sets passive data mode."""
        check_status(self._lib.ftp_set_passive(self._slot))

    def set_active(self, port: int) -> None:
        """PORT command. Sets active data mode with the given port."""
        check_status(self._lib.ftp_set_active(self._slot, port))

    def begin_transfer(self) -> None:
        """Begin a data transfer."""
        check_status(self._lib.ftp_begin_transfer(self._slot))

    def add_bytes(self, count: int) -> None:
        """Add bytes to the transfer counter."""
        check_status(self._lib.ftp_add_bytes(self._slot, count))

    def complete_transfer(self) -> None:
        """Complete a data transfer."""
        check_status(self._lib.ftp_complete_transfer(self._slot))

    def abort_transfer(self) -> None:
        """Abort a data transfer."""
        check_status(self._lib.ftp_abort_transfer(self._slot))

    def begin_rename(self) -> None:
        """RNFR: begin rename operation."""
        check_status(self._lib.ftp_begin_rename(self._slot))

    def complete_rename(self) -> None:
        """RNTO: complete rename operation."""
        check_status(self._lib.ftp_complete_rename(self._slot))


# ---------------------------------------------------------------------------
# Module-level functions
# ---------------------------------------------------------------------------

def abi_version() -> int:
    """Return the ABI version."""
    return _get_lib().ftp_abi_version()


def can_transfer(state: FtpSessionState) -> bool:
    """Stateless query: check if transfers are allowed from the given state."""
    return _get_lib().ftp_can_transfer(state.value) == 1


def can_transition(from_state: FtpSessionState, to_state: FtpSessionState) -> bool:
    """Stateless query: check whether a session state transition is valid."""
    return _get_lib().ftp_can_transition(from_state.value, to_state.value) == 1
