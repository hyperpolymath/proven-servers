# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-firewall Zig FFI.

"""Python bindings for the proven-firewall protocol FFI."""

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

class FirewallAction(IntEnum):
    """Firewall rule actions matching the Idris2 ABI tags."""
    ACCEPT = 0
    DROP = 1
    REJECT = 2
    LOG = 3
    REDIRECT = 4
    DNAT = 5
    SNAT = 6
    MASQUERADE = 7


class PacketState(IntEnum):
    """Firewall packet lifecycle states matching the Idris2 ABI tags."""
    IDLE = 0
    CLASSIFIED = 1
    EVALUATING = 2
    DECIDED = 3
    COMMITTED = 4


class ConntrackState(IntEnum):
    """Connection tracking states matching the Idris2 ABI tags."""
    NONE = 0
    TRACKING = 1
    ESTABLISHED = 2
    RELATED = 3
    EXPIRED = 4


# ---------------------------------------------------------------------------
# FFI function setup
# ---------------------------------------------------------------------------

_lib: Optional[ctypes.CDLL] = None


def _get_lib() -> ctypes.CDLL:
    """Lazy-load the proven-firewall shared library."""
    global _lib
    if _lib is None:
        _lib = load_library("firewall")
        _setup_signatures(_lib)
    return _lib


def _setup_signatures(lib: ctypes.CDLL) -> None:
    """Declare ctypes function signatures for type safety."""
    lib.fw_abi_version.restype = ctypes.c_uint32
    lib.fw_create_context.restype = ctypes.c_int
    lib.fw_destroy_context.restype = None
    lib.fw_destroy_context.argtypes = [ctypes.c_int]
    lib.fw_packet_state.restype = ctypes.c_uint8
    lib.fw_packet_state.argtypes = [ctypes.c_int]
    lib.fw_conntrack_state.restype = ctypes.c_uint8
    lib.fw_conntrack_state.argtypes = [ctypes.c_int]
    lib.fw_get_decision.restype = ctypes.c_uint8
    lib.fw_get_decision.argtypes = [ctypes.c_int]
    lib.fw_rule_count.restype = ctypes.c_uint16
    lib.fw_rule_count.argtypes = [ctypes.c_int]
    lib.fw_packet_proto.restype = ctypes.c_uint8
    lib.fw_packet_proto.argtypes = [ctypes.c_int]
    lib.fw_packet_chain.restype = ctypes.c_uint8
    lib.fw_packet_chain.argtypes = [ctypes.c_int]
    lib.fw_packet_src_ip.restype = ctypes.c_uint32
    lib.fw_packet_src_ip.argtypes = [ctypes.c_int]
    lib.fw_packet_dst_ip.restype = ctypes.c_uint32
    lib.fw_packet_dst_ip.argtypes = [ctypes.c_int]
    lib.fw_packet_src_port.restype = ctypes.c_uint16
    lib.fw_packet_src_port.argtypes = [ctypes.c_int]
    lib.fw_packet_dst_port.restype = ctypes.c_uint16
    lib.fw_packet_dst_port.argtypes = [ctypes.c_int]
    lib.fw_classify_packet.restype = ctypes.c_uint8
    lib.fw_classify_packet.argtypes = [ctypes.c_int, ctypes.c_uint8, ctypes.c_uint8,
                                        ctypes.c_uint32, ctypes.c_uint32,
                                        ctypes.c_uint16, ctypes.c_uint16]
    lib.fw_begin_chain.restype = ctypes.c_uint8
    lib.fw_begin_chain.argtypes = [ctypes.c_int]
    lib.fw_add_rule.restype = ctypes.c_uint8
    lib.fw_add_rule.argtypes = [ctypes.c_int, ctypes.c_uint8, ctypes.c_uint32, ctypes.c_uint8,
                                 ctypes.c_uint16]
    lib.fw_set_default_action.restype = ctypes.c_uint8
    lib.fw_set_default_action.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.fw_evaluate_rules.restype = ctypes.c_uint8
    lib.fw_evaluate_rules.argtypes = [ctypes.c_int]
    lib.fw_commit.restype = ctypes.c_uint8
    lib.fw_commit.argtypes = [ctypes.c_int]
    lib.fw_begin_tracking.restype = ctypes.c_uint8
    lib.fw_begin_tracking.argtypes = [ctypes.c_int]
    lib.fw_complete_tracking.restype = ctypes.c_uint8
    lib.fw_complete_tracking.argtypes = [ctypes.c_int, ctypes.c_uint8]
    lib.fw_expire_conn.restype = ctypes.c_uint8
    lib.fw_expire_conn.argtypes = [ctypes.c_int]
    lib.fw_can_transition.restype = ctypes.c_uint8
    lib.fw_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]
    lib.fw_can_conntrack_transition.restype = ctypes.c_uint8
    lib.fw_can_conntrack_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]


# ---------------------------------------------------------------------------
# Context manager
# ---------------------------------------------------------------------------

class FirewallContext:
    """Context manager for a firewall packet evaluation lifecycle.

    Usage::

        with FirewallContext() as ctx:
            ctx.classify_packet(proto=6, chain=0, src_ip=0xC0A80001,
                               dst_ip=0xC0A80002, src_port=12345, dst_port=80)
            ctx.begin_chain()
            ctx.add_rule(match_type=0, match_value=80, action=FirewallAction.ACCEPT,
                        priority=100)
            ctx.set_default_action(FirewallAction.DROP)
            ctx.evaluate_rules()
            decision = ctx.get_decision()
            ctx.commit()
    """

    def __init__(self) -> None:
        lib = _get_lib()
        self._slot: int = check_slot(lib.fw_create_context())
        self._lib = lib
        self._closed = False

    def __enter__(self) -> FirewallContext:
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
            self._lib.fw_destroy_context(self._slot)
            self._closed = True

    # -- State queries -----------------------------------------------------

    def packet_state(self) -> Optional[PacketState]:
        """Get the current packet lifecycle state."""
        tag = self._lib.fw_packet_state(self._slot)
        try:
            return PacketState(tag)
        except ValueError:
            return None

    def conntrack_state(self) -> Optional[ConntrackState]:
        """Get the current connection tracking state."""
        tag = self._lib.fw_conntrack_state(self._slot)
        try:
            return ConntrackState(tag)
        except ValueError:
            return None

    def get_decision(self) -> Optional[FirewallAction]:
        """Get the decision action (only meaningful after evaluation)."""
        tag = self._lib.fw_get_decision(self._slot)
        try:
            return FirewallAction(tag)
        except ValueError:
            return None

    def rule_count(self) -> int:
        """Get the number of rules in the chain."""
        return self._lib.fw_rule_count(self._slot)

    def packet_proto(self) -> int:
        """Get the classified packet protocol tag."""
        return self._lib.fw_packet_proto(self._slot)

    def packet_chain(self) -> int:
        """Get the classified packet chain tag."""
        return self._lib.fw_packet_chain(self._slot)

    def packet_src_ip(self) -> int:
        """Get the source IP (raw u32 in network order)."""
        return self._lib.fw_packet_src_ip(self._slot)

    def packet_dst_ip(self) -> int:
        """Get the destination IP."""
        return self._lib.fw_packet_dst_ip(self._slot)

    def packet_src_port(self) -> int:
        """Get the source port."""
        return self._lib.fw_packet_src_port(self._slot)

    def packet_dst_port(self) -> int:
        """Get the destination port."""
        return self._lib.fw_packet_dst_port(self._slot)

    # -- Packet classification ---------------------------------------------

    def classify_packet(self, proto: int, chain: int, src_ip: int, dst_ip: int,
                        src_port: int, dst_port: int) -> None:
        """Classify a packet. Transitions Idle -> Classified."""
        check_status(self._lib.fw_classify_packet(
            self._slot, proto, chain, src_ip, dst_ip, src_port, dst_port,
        ))

    # -- Chain evaluation --------------------------------------------------

    def begin_chain(self) -> None:
        """Begin chain evaluation. Transitions Classified -> Evaluating."""
        check_status(self._lib.fw_begin_chain(self._slot))

    def add_rule(self, match_type: int, match_value: int,
                 action: FirewallAction, priority: int) -> None:
        """Add a rule to the evaluation chain."""
        check_status(self._lib.fw_add_rule(
            self._slot, match_type, match_value, action.value, priority,
        ))

    def set_default_action(self, action: FirewallAction) -> None:
        """Set the default action (applied when no rules match)."""
        check_status(self._lib.fw_set_default_action(self._slot, action.value))

    def evaluate_rules(self) -> None:
        """Evaluate rules against the classified packet. Transitions Evaluating -> Decided."""
        check_status(self._lib.fw_evaluate_rules(self._slot))

    def commit(self) -> None:
        """Commit the decision. Transitions Decided -> Committed."""
        check_status(self._lib.fw_commit(self._slot))

    # -- Connection tracking -----------------------------------------------

    def begin_tracking(self) -> None:
        """Begin connection tracking. Transitions None -> Tracking."""
        check_status(self._lib.fw_begin_tracking(self._slot))

    def complete_tracking(self, conn_state: ConntrackState) -> None:
        """Complete connection tracking with a state."""
        check_status(self._lib.fw_complete_tracking(self._slot, conn_state.value))

    def expire_conn(self) -> None:
        """Expire a connection. Transitions Established/Related -> Expired."""
        check_status(self._lib.fw_expire_conn(self._slot))


# ---------------------------------------------------------------------------
# Module-level functions
# ---------------------------------------------------------------------------

def abi_version() -> int:
    """Return the ABI version."""
    return _get_lib().fw_abi_version()


def can_transition(from_state: PacketState, to_state: PacketState) -> bool:
    """Stateless query: check whether a packet state transition is valid."""
    return _get_lib().fw_can_transition(from_state.value, to_state.value) == 1


def can_conntrack_transition(from_state: ConntrackState, to_state: ConntrackState) -> bool:
    """Stateless query: check whether a conntrack state transition is valid."""
    return _get_lib().fw_can_conntrack_transition(from_state.value, to_state.value) == 1
