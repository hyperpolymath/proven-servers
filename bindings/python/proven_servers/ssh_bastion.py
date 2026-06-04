# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-ssh-bastion Zig FFI.

"""Python bindings for the proven-ssh-bastion protocol FFI."""

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

class BastionState(IntEnum):
    """SSH bastion session states matching the Idris2 ABI tags."""
    CONNECTED = 0
    KEY_EXCHANGED = 1
    AUTHENTICATED = 2
    CHANNEL_OPEN = 3
    ACTIVE = 4
    CLOSED = 5


class KexMethod(IntEnum):
    """SSH key exchange methods matching the Idris2 ABI tags."""
    CURVE25519_SHA256 = 0
    ECDH_SHA2_NISTP256 = 1
    ECDH_SHA2_NISTP384 = 2
    DIFFIE_HELLMAN_GROUP14_SHA256 = 3
    DIFFIE_HELLMAN_GROUP16_SHA512 = 4


class AuthMethod(IntEnum):
    """SSH authentication methods matching the Idris2 ABI tags."""
    PUBLIC_KEY = 0
    PASSWORD = 1
    KEYBOARD_INTERACTIVE = 2
    HOST_BASED = 3


class ChannelType(IntEnum):
    """SSH channel types matching the Idris2 ABI tags."""
    SESSION = 0
    DIRECT_TCPIP = 1
    FORWARDED_TCPIP = 2
    X11 = 3


class ChannelState(IntEnum):
    """SSH channel states matching the Idris2 ABI tags."""
    OPENING = 0
    OPEN = 1
    CLOSED = 2


class DisconnectReason(IntEnum):
    """SSH disconnect reasons matching the Idris2 ABI tags."""
    BY_APPLICATION = 0
    PROTOCOL_ERROR = 1
    KEY_EXCHANGE_FAILED = 2
    AUTH_CANCELLED_BY_USER = 3
    TOO_MANY_CONNECTIONS = 4
    HOST_NOT_ALLOWED = 5
    ILLEGAL_USER_NAME = 6


# ---------------------------------------------------------------------------
# FFI function setup
# ---------------------------------------------------------------------------

_lib: Optional[ctypes.CDLL] = None


def _get_lib() -> ctypes.CDLL:
    """Lazy-load the proven-ssh-bastion shared library."""
    global _lib
    if _lib is None:
        _lib = load_library("ssh_bastion")
        _setup_signatures(_lib)
    return _lib


def _setup_signatures(lib: ctypes.CDLL) -> None:
    """Declare ctypes function signatures for type safety."""
    lib.ssh_bastion_abi_version.restype = ctypes.c_uint32
    lib.ssh_bastion_create.restype = ctypes.c_int
    lib.ssh_bastion_create.argtypes = [ctypes.c_uint8, ctypes.c_uint8]
    lib.ssh_bastion_destroy.restype = None
    lib.ssh_bastion_destroy.argtypes = [ctypes.c_int]
    lib.ssh_bastion_state.restype = ctypes.c_uint8
    lib.ssh_bastion_state.argtypes = [ctypes.c_int]
    lib.ssh_bastion_kex_method.restype = ctypes.c_uint8
    lib.ssh_bastion_kex_method.argtypes = [ctypes.c_int]
    lib.ssh_bastion_auth_method.restype = ctypes.c_uint8
    lib.ssh_bastion_auth_method.argtypes = [ctypes.c_int]
    lib.ssh_bastion_can_transfer.restype = ctypes.c_uint8
    lib.ssh_bastion_can_transfer.argtypes = [ctypes.c_int]
    lib.ssh_bastion_disconnect_reason.restype = ctypes.c_uint8
    lib.ssh_bastion_disconnect_reason.argtypes = [ctypes.c_int]
    lib.ssh_bastion_auth_failures.restype = ctypes.c_uint8
    lib.ssh_bastion_auth_failures.argtypes = [ctypes.c_int]
    lib.ssh_bastion_complete_kex.restype = ctypes.c_uint8
    lib.ssh_bastion_complete_kex.argtypes = [ctypes.c_int]
    lib.ssh_bastion_authenticate.restype = ctypes.c_uint8
    lib.ssh_bastion_authenticate.argtypes = [ctypes.c_int, ctypes.c_uint16]
    lib.ssh_bastion_record_auth_failure.restype = ctypes.c_uint8
    lib.ssh_bastion_record_auth_failure.argtypes = [ctypes.c_int]
    lib.ssh_bastion_open_channel.restype = ctypes.c_int
    lib.ssh_bastion_open_channel.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.ssh_bastion_confirm_channel.restype = ctypes.c_uint8
    lib.ssh_bastion_confirm_channel.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.ssh_bastion_close_channel.restype = ctypes.c_uint8
    lib.ssh_bastion_close_channel.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.ssh_bastion_channel_state.restype = ctypes.c_uint8
    lib.ssh_bastion_channel_state.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.ssh_bastion_channel_type.restype = ctypes.c_uint8
    lib.ssh_bastion_channel_type.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.ssh_bastion_channel_count.restype = ctypes.c_uint8
    lib.ssh_bastion_channel_count.argtypes = [ctypes.c_int]
    lib.ssh_bastion_rekey.restype = ctypes.c_uint8
    lib.ssh_bastion_rekey.argtypes = [ctypes.c_int]
    lib.ssh_bastion_disconnect.restype = ctypes.c_uint8
    lib.ssh_bastion_disconnect.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.ssh_bastion_can_transition.restype = ctypes.c_uint8
    lib.ssh_bastion_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]
    lib.ssh_bastion_audit_count.restype = ctypes.c_uint32
    lib.ssh_bastion_audit_count.argtypes = [ctypes.c_int]
    lib.ssh_bastion_audit_entry.restype = ctypes.c_uint8
    lib.ssh_bastion_audit_entry.argtypes = [ctypes.c_int, ctypes.c_uint32]
    lib.ssh_bastion_audit_entry_to.restype = ctypes.c_uint8
    lib.ssh_bastion_audit_entry_to.argtypes = [ctypes.c_int, ctypes.c_uint32]
    lib.ssh_bastion_set_recording.restype = ctypes.c_uint8
    lib.ssh_bastion_set_recording.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.ssh_bastion_is_recording.restype = ctypes.c_uint8
    lib.ssh_bastion_is_recording.argtypes = [ctypes.c_int]


# ---------------------------------------------------------------------------
# Context manager
# ---------------------------------------------------------------------------

class SshBastionContext:
    """Context manager for an SSH bastion session lifecycle.

    Usage::

        with SshBastionContext(KexMethod.CURVE25519_SHA256, AuthMethod.PUBLIC_KEY) as ctx:
            ctx.complete_kex()
            ctx.authenticate()
            ch_id = ctx.open_channel(ChannelType.SESSION)
            ctx.confirm_channel(ch_id)
            ctx.close_channel(ch_id)
            ctx.disconnect(DisconnectReason.BY_APPLICATION)
    """

    def __init__(self, kex: KexMethod = KexMethod.CURVE25519_SHA256,
                 auth: AuthMethod = AuthMethod.PUBLIC_KEY) -> None:
        lib = _get_lib()
        self._slot: int = check_slot(lib.ssh_bastion_create(kex.value, auth.value))
        self._lib = lib
        self._closed = False

    def __enter__(self) -> SshBastionContext:
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
            self._lib.ssh_bastion_destroy(self._slot)
            self._closed = True

    # -- State queries -----------------------------------------------------

    def state(self) -> Optional[BastionState]:
        """Get the current bastion state."""
        tag = self._lib.ssh_bastion_state(self._slot)
        try:
            return BastionState(tag)
        except ValueError:
            return None

    def kex_method(self) -> Optional[KexMethod]:
        """Get the configured key exchange method."""
        tag = self._lib.ssh_bastion_kex_method(self._slot)
        try:
            return KexMethod(tag)
        except ValueError:
            return None

    def auth_method(self) -> Optional[AuthMethod]:
        """Get the configured authentication method."""
        tag = self._lib.ssh_bastion_auth_method(self._slot)
        try:
            return AuthMethod(tag)
        except ValueError:
            return None

    def can_transfer_data(self) -> bool:
        """Check if data transfer is allowed (session must be Active)."""
        return self._lib.ssh_bastion_can_transfer(self._slot) == 1

    def disconnect_reason(self) -> Optional[DisconnectReason]:
        """Get the disconnect reason (None if not disconnected)."""
        tag = self._lib.ssh_bastion_disconnect_reason(self._slot)
        try:
            return DisconnectReason(tag)
        except ValueError:
            return None

    def auth_failures(self) -> int:
        """Get the number of failed auth attempts."""
        return self._lib.ssh_bastion_auth_failures(self._slot)

    # -- Session commands --------------------------------------------------

    def complete_kex(self) -> None:
        """Complete key exchange. Transitions Connected -> KeyExchanged."""
        check_status(self._lib.ssh_bastion_complete_kex(self._slot))

    def authenticate(self) -> None:
        """Authenticate the user. Transitions KeyExchanged -> Authenticated."""
        check_status(self._lib.ssh_bastion_authenticate(self._slot, 0))

    def record_auth_failure(self) -> bool:
        """Record a failed auth attempt. Returns True if locked out (3+ failures)."""
        return self._lib.ssh_bastion_record_auth_failure(self._slot) == 1

    # -- Channel management ------------------------------------------------

    def open_channel(self, ch_type: ChannelType) -> int:
        """Open a channel. Returns the channel ID (0-9)."""
        return check_slot(self._lib.ssh_bastion_open_channel(self._slot, ch_type.value))

    def confirm_channel(self, ch_id: int) -> None:
        """Confirm a channel (Opening -> Open)."""
        check_status(self._lib.ssh_bastion_confirm_channel(self._slot, ch_id))

    def close_channel(self, ch_id: int) -> None:
        """Close a specific channel."""
        check_status(self._lib.ssh_bastion_close_channel(self._slot, ch_id))

    def channel_state(self, ch_id: int) -> Optional[ChannelState]:
        """Get the state of a specific channel."""
        tag = self._lib.ssh_bastion_channel_state(self._slot, ch_id)
        try:
            return ChannelState(tag)
        except ValueError:
            return None

    def channel_type(self, ch_id: int) -> Optional[ChannelType]:
        """Get the type of a specific channel."""
        tag = self._lib.ssh_bastion_channel_type(self._slot, ch_id)
        try:
            return ChannelType(tag)
        except ValueError:
            return None

    def channel_count(self) -> int:
        """Get the count of active (non-closed) channels."""
        return self._lib.ssh_bastion_channel_count(self._slot)

    # -- Session lifecycle -------------------------------------------------

    def rekey(self) -> None:
        """Re-key the session. Only valid in Active state."""
        check_status(self._lib.ssh_bastion_rekey(self._slot))

    def disconnect(self, reason: DisconnectReason) -> None:
        """Disconnect with a reason. Transitions any non-Closed -> Closed."""
        check_status(self._lib.ssh_bastion_disconnect(self._slot, reason.value))

    # -- Audit -------------------------------------------------------------

    def audit_count(self) -> int:
        """Get the number of audit log entries."""
        return self._lib.ssh_bastion_audit_count(self._slot)

    def audit_entry_from(self, index: int) -> Optional[BastionState]:
        """Read the from_state of an audit log entry."""
        tag = self._lib.ssh_bastion_audit_entry(self._slot, index)
        try:
            return BastionState(tag)
        except ValueError:
            return None

    def audit_entry_to(self, index: int) -> Optional[BastionState]:
        """Read the to_state of an audit log entry."""
        tag = self._lib.ssh_bastion_audit_entry_to(self._slot, index)
        try:
            return BastionState(tag)
        except ValueError:
            return None

    # -- Recording ---------------------------------------------------------

    def set_recording(self, enabled: bool) -> None:
        """Enable or disable session recording."""
        check_status(self._lib.ssh_bastion_set_recording(self._slot, 1 if enabled else 0))

    def is_recording(self) -> bool:
        """Check whether session recording is active."""
        return self._lib.ssh_bastion_is_recording(self._slot) == 1


# ---------------------------------------------------------------------------
# Module-level functions
# ---------------------------------------------------------------------------

def abi_version() -> int:
    """Return the ABI version."""
    return _get_lib().ssh_bastion_abi_version()


def can_transition(from_state: BastionState, to_state: BastionState) -> bool:
    """Stateless query: check whether a bastion state transition is valid."""
    return _get_lib().ssh_bastion_can_transition(from_state.value, to_state.value) == 1
