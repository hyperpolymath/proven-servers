# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-smtp Zig FFI.

"""Python bindings for the proven-smtp protocol FFI."""

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

class SmtpSessionState(IntEnum):
    """SMTP session states matching the Idris2 ABI tags."""
    CONNECTED = 0
    GREETED = 1
    AUTH_STARTED = 2
    AUTHENTICATED = 3
    MAIL_FROM = 4
    RCPT_TO = 5
    DATA = 6
    MESSAGE_RECEIVED = 7
    QUIT = 8


class AuthMechanism(IntEnum):
    """SMTP AUTH mechanisms matching the Idris2 ABI tags."""
    PLAIN = 0
    LOGIN = 1
    CRAM_MD5 = 2
    XOAUTH2 = 3


# ---------------------------------------------------------------------------
# FFI function setup
# ---------------------------------------------------------------------------

_lib: Optional[ctypes.CDLL] = None


def _get_lib() -> ctypes.CDLL:
    """Lazy-load the proven-smtp shared library."""
    global _lib
    if _lib is None:
        _lib = load_library("smtp")
        _setup_signatures(_lib)
    return _lib


def _setup_signatures(lib: ctypes.CDLL) -> None:
    """Declare ctypes function signatures for type safety."""
    lib.smtp_abi_version.restype = ctypes.c_uint32
    lib.smtp_create_context.restype = ctypes.c_int
    lib.smtp_destroy_context.restype = None
    lib.smtp_destroy_context.argtypes = [ctypes.c_int]
    lib.smtp_get_state.restype = ctypes.c_uint8
    lib.smtp_get_state.argtypes = [ctypes.c_int]
    lib.smtp_get_reply_code.restype = ctypes.c_uint8
    lib.smtp_get_reply_code.argtypes = [ctypes.c_int]
    lib.smtp_get_recipient_count.restype = ctypes.c_uint8
    lib.smtp_get_recipient_count.argtypes = [ctypes.c_int]
    lib.smtp_get_data_size.restype = ctypes.c_uint32
    lib.smtp_get_data_size.argtypes = [ctypes.c_int]
    lib.smtp_get_auth_mechanism.restype = ctypes.c_uint8
    lib.smtp_get_auth_mechanism.argtypes = [ctypes.c_int]
    lib.smtp_is_authenticated.restype = ctypes.c_uint8
    lib.smtp_is_authenticated.argtypes = [ctypes.c_int]
    lib.smtp_is_tls_active.restype = ctypes.c_uint8
    lib.smtp_is_tls_active.argtypes = [ctypes.c_int]
    lib.smtp_greet.restype = ctypes.c_uint8
    lib.smtp_greet.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.smtp_authenticate.restype = ctypes.c_uint8
    lib.smtp_authenticate.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.smtp_auth_complete.restype = ctypes.c_uint8
    lib.smtp_auth_complete.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.smtp_set_sender.restype = ctypes.c_uint8
    lib.smtp_set_sender.argtypes = [ctypes.c_int]
    lib.smtp_add_recipient.restype = ctypes.c_uint8
    lib.smtp_add_recipient.argtypes = [ctypes.c_int]
    lib.smtp_start_data.restype = ctypes.c_uint8
    lib.smtp_start_data.argtypes = [ctypes.c_int]
    lib.smtp_append_data.restype = ctypes.c_uint8
    lib.smtp_append_data.argtypes = [ctypes.c_int, ctypes.c_uint32]
    lib.smtp_finish_data.restype = ctypes.c_uint8
    lib.smtp_finish_data.argtypes = [ctypes.c_int]
    lib.smtp_reset.restype = ctypes.c_uint8
    lib.smtp_reset.argtypes = [ctypes.c_int]
    lib.smtp_quit.restype = ctypes.c_uint8
    lib.smtp_quit.argtypes = [ctypes.c_int]
    lib.smtp_enable_tls.restype = ctypes.c_uint8
    lib.smtp_enable_tls.argtypes = [ctypes.c_int]
    lib.smtp_can_transition.restype = ctypes.c_uint8
    lib.smtp_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]


# ---------------------------------------------------------------------------
# Context manager
# ---------------------------------------------------------------------------

class SmtpContext:
    """Context manager for an SMTP session lifecycle.

    Usage::

        with SmtpContext() as ctx:
            ctx.greet(ehlo=True)
            ctx.set_sender()
            ctx.add_recipient()
            ctx.start_data()
            ctx.append_data(1024)
            ctx.finish_data()
            ctx.quit()
    """

    def __init__(self) -> None:
        lib = _get_lib()
        self._slot: int = check_slot(lib.smtp_create_context())
        self._lib = lib
        self._closed = False

    def __enter__(self) -> SmtpContext:
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
            self._lib.smtp_destroy_context(self._slot)
            self._closed = True

    # -- State queries -----------------------------------------------------

    def get_state(self) -> Optional[SmtpSessionState]:
        """Get the current session state."""
        tag = self._lib.smtp_get_state(self._slot)
        try:
            return SmtpSessionState(tag)
        except ValueError:
            return None

    def get_reply_code(self) -> int:
        """Get the last reply code tag."""
        return self._lib.smtp_get_reply_code(self._slot)

    def get_recipient_count(self) -> int:
        """Get the number of recipients in the current transaction."""
        return self._lib.smtp_get_recipient_count(self._slot)

    def get_data_size(self) -> int:
        """Get the accumulated message data size in bytes."""
        return self._lib.smtp_get_data_size(self._slot)

    def get_auth_mechanism(self) -> Optional[AuthMechanism]:
        """Get the current AUTH mechanism (None if unset)."""
        tag = self._lib.smtp_get_auth_mechanism(self._slot)
        try:
            return AuthMechanism(tag)
        except ValueError:
            return None

    def is_authenticated(self) -> bool:
        """Check if the session is authenticated."""
        return self._lib.smtp_is_authenticated(self._slot) == 1

    def is_tls_active(self) -> bool:
        """Check if TLS is active."""
        return self._lib.smtp_is_tls_active(self._slot) == 1

    # -- Commands ----------------------------------------------------------

    def greet(self, ehlo: bool = True) -> None:
        """HELO/EHLO: greet the server. Transitions Connected -> Greeted."""
        check_status(self._lib.smtp_greet(self._slot, 1 if ehlo else 0))

    def authenticate(self, mechanism: AuthMechanism) -> None:
        """Begin AUTH exchange. Transitions Greeted -> AuthStarted."""
        check_status(self._lib.smtp_authenticate(self._slot, mechanism.value))

    def auth_complete(self, success: bool) -> None:
        """Complete AUTH exchange."""
        check_status(self._lib.smtp_auth_complete(self._slot, 1 if success else 0))

    def set_sender(self) -> None:
        """MAIL FROM: set the sender."""
        check_status(self._lib.smtp_set_sender(self._slot))

    def add_recipient(self) -> None:
        """RCPT TO: add a recipient."""
        check_status(self._lib.smtp_add_recipient(self._slot))

    def start_data(self) -> None:
        """DATA: begin message body transfer."""
        check_status(self._lib.smtp_start_data(self._slot))

    def append_data(self, length: int) -> None:
        """Append data bytes to the message."""
        check_status(self._lib.smtp_append_data(self._slot, length))

    def finish_data(self) -> None:
        """Finish data transfer (end-of-data marker)."""
        check_status(self._lib.smtp_finish_data(self._slot))

    def reset(self) -> None:
        """RSET: reset the mail transaction."""
        check_status(self._lib.smtp_reset(self._slot))

    def quit(self) -> None:
        """QUIT: end the session."""
        check_status(self._lib.smtp_quit(self._slot))

    def enable_tls(self) -> None:
        """STARTTLS: enable TLS on the connection."""
        check_status(self._lib.smtp_enable_tls(self._slot))


# ---------------------------------------------------------------------------
# Module-level functions
# ---------------------------------------------------------------------------

def abi_version() -> int:
    """Return the ABI version of the linked SMTP library."""
    return _get_lib().smtp_abi_version()


def can_transition(from_state: SmtpSessionState, to_state: SmtpSessionState) -> bool:
    """Stateless query: check whether a session state transition is valid."""
    return _get_lib().smtp_can_transition(from_state.value, to_state.value) == 1
