# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-mqtt Zig FFI.

"""Python bindings for the proven-mqtt protocol FFI."""

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

class MqttSessionState(IntEnum):
    """MQTT broker session states matching the Idris2 ABI tags."""
    IDLE = 0
    CONNECTED = 1
    DISCONNECTED = 2


class MqttVersion(IntEnum):
    """MQTT protocol versions."""
    V3_1_1 = 0
    V5_0 = 1


class QoS(IntEnum):
    """MQTT Quality of Service levels."""
    AT_MOST_ONCE = 0
    AT_LEAST_ONCE = 1
    EXACTLY_ONCE = 2


# ---------------------------------------------------------------------------
# FFI function setup
# ---------------------------------------------------------------------------

_lib: Optional[ctypes.CDLL] = None


def _get_lib() -> ctypes.CDLL:
    """Lazy-load the proven-mqtt shared library."""
    global _lib
    if _lib is None:
        _lib = load_library("mqtt")
        _setup_signatures(_lib)
    return _lib


def _setup_signatures(lib: ctypes.CDLL) -> None:
    """Declare ctypes function signatures for type safety."""
    lib.mqtt_abi_version.restype = ctypes.c_uint32
    lib.mqtt_create.restype = ctypes.c_int
    lib.mqtt_create.argtypes = [ctypes.c_uint8, ctypes.c_uint8, ctypes.c_uint16]
    lib.mqtt_destroy.restype = None
    lib.mqtt_destroy.argtypes = [ctypes.c_int]
    lib.mqtt_state.restype = ctypes.c_uint8
    lib.mqtt_state.argtypes = [ctypes.c_int]
    lib.mqtt_version.restype = ctypes.c_uint8
    lib.mqtt_version.argtypes = [ctypes.c_int]
    lib.mqtt_can_publish.restype = ctypes.c_uint8
    lib.mqtt_can_publish.argtypes = [ctypes.c_int]
    lib.mqtt_can_subscribe.restype = ctypes.c_uint8
    lib.mqtt_can_subscribe.argtypes = [ctypes.c_int]
    lib.mqtt_subscription_count.restype = ctypes.c_uint32
    lib.mqtt_subscription_count.argtypes = [ctypes.c_int]
    lib.mqtt_subscribe.restype = ctypes.c_uint8
    lib.mqtt_subscribe.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32,
                                    ctypes.c_uint8]
    lib.mqtt_unsubscribe.restype = ctypes.c_uint8
    lib.mqtt_unsubscribe.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32]
    lib.mqtt_publish.restype = ctypes.c_uint8
    lib.mqtt_publish.argtypes = [ctypes.c_int, ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32,
                                  ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32,
                                  ctypes.c_uint8, ctypes.c_uint8, ctypes.c_uint16]
    lib.mqtt_puback.restype = ctypes.c_uint8
    lib.mqtt_puback.argtypes = [ctypes.c_int, ctypes.c_uint16]
    lib.mqtt_pubrec.restype = ctypes.c_uint8
    lib.mqtt_pubrec.argtypes = [ctypes.c_int, ctypes.c_uint16]
    lib.mqtt_pubrel.restype = ctypes.c_uint8
    lib.mqtt_pubrel.argtypes = [ctypes.c_int, ctypes.c_uint16]
    lib.mqtt_pubcomp.restype = ctypes.c_uint8
    lib.mqtt_pubcomp.argtypes = [ctypes.c_int, ctypes.c_uint16]
    lib.mqtt_qos_state.restype = ctypes.c_uint8
    lib.mqtt_qos_state.argtypes = [ctypes.c_int, ctypes.c_uint16]
    lib.mqtt_disconnect.restype = ctypes.c_uint8
    lib.mqtt_disconnect.argtypes = [ctypes.c_int]
    lib.mqtt_cleanup.restype = ctypes.c_uint8
    lib.mqtt_cleanup.argtypes = [ctypes.c_int]
    lib.mqtt_retained_count.restype = ctypes.c_uint32
    lib.mqtt_can_transition.restype = ctypes.c_uint8
    lib.mqtt_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8]
    lib.mqtt_qos_can_transition.restype = ctypes.c_uint8
    lib.mqtt_qos_can_transition.argtypes = [ctypes.c_uint8, ctypes.c_uint8, ctypes.c_uint8]
    lib.mqtt_topic_matches.restype = ctypes.c_uint8
    lib.mqtt_topic_matches.argtypes = [ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32,
                                        ctypes.POINTER(ctypes.c_uint8), ctypes.c_uint32]


# ---------------------------------------------------------------------------
# Context manager
# ---------------------------------------------------------------------------

class MqttContext:
    """Context manager for an MQTT session lifecycle.

    Usage::

        with MqttContext(MqttVersion.V5_0, clean_session=True, keep_alive=60) as ctx:
            ctx.subscribe("sensor/temp", QoS.AT_LEAST_ONCE)
            ctx.publish("sensor/temp", b"22.5", QoS.AT_LEAST_ONCE)
            ctx.disconnect()
    """

    def __init__(self, version: MqttVersion = MqttVersion.V3_1_1,
                 clean_session: bool = True, keep_alive: int = 60) -> None:
        lib = _get_lib()
        self._slot: int = check_slot(lib.mqtt_create(
            version.value, 1 if clean_session else 0, keep_alive,
        ))
        self._lib = lib
        self._closed = False

    def __enter__(self) -> MqttContext:
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
            self._lib.mqtt_destroy(self._slot)
            self._closed = True

    # -- State queries -----------------------------------------------------

    def state(self) -> Optional[MqttSessionState]:
        """Get the current session state."""
        tag = self._lib.mqtt_state(self._slot)
        try:
            return MqttSessionState(tag)
        except ValueError:
            return None

    def version(self) -> int:
        """Get the MQTT protocol version tag."""
        return self._lib.mqtt_version(self._slot)

    def can_publish(self) -> bool:
        """Check if the session can publish messages."""
        return self._lib.mqtt_can_publish(self._slot) == 1

    def can_subscribe(self) -> bool:
        """Check if the session can subscribe to topics."""
        return self._lib.mqtt_can_subscribe(self._slot) == 1

    def subscription_count(self) -> int:
        """Get the number of active subscriptions."""
        return self._lib.mqtt_subscription_count(self._slot)

    # -- Pub/Sub -----------------------------------------------------------

    def subscribe(self, topic: str, qos: QoS) -> None:
        """Subscribe to a topic with the given QoS level."""
        data = topic.encode("utf-8")
        buf = (ctypes.c_uint8 * len(data))(*data)
        check_status(self._lib.mqtt_subscribe(self._slot, buf, len(data), qos.value))

    def unsubscribe(self, topic: str) -> None:
        """Unsubscribe from a topic."""
        data = topic.encode("utf-8")
        buf = (ctypes.c_uint8 * len(data))(*data)
        check_status(self._lib.mqtt_unsubscribe(self._slot, buf, len(data)))

    def publish(self, topic: str, payload: bytes, qos: QoS,
                retain: bool = False, packet_id: int = 0) -> None:
        """Publish a message to a topic."""
        t = topic.encode("utf-8")
        t_buf = (ctypes.c_uint8 * len(t))(*t)
        p_buf = (ctypes.c_uint8 * len(payload))(*payload)
        check_status(self._lib.mqtt_publish(
            self._slot, t_buf, len(t), p_buf, len(payload),
            qos.value, 1 if retain else 0, packet_id,
        ))

    # -- QoS handshake -----------------------------------------------------

    def puback(self, packet_id: int) -> None:
        """Acknowledge a QoS 1 publish (PUBACK)."""
        check_status(self._lib.mqtt_puback(self._slot, packet_id))

    def pubrec(self, packet_id: int) -> None:
        """QoS 2 step 1: publish received (PUBREC)."""
        check_status(self._lib.mqtt_pubrec(self._slot, packet_id))

    def pubrel(self, packet_id: int) -> None:
        """QoS 2 step 2: publish release (PUBREL)."""
        check_status(self._lib.mqtt_pubrel(self._slot, packet_id))

    def pubcomp(self, packet_id: int) -> None:
        """QoS 2 step 3: publish complete (PUBCOMP)."""
        check_status(self._lib.mqtt_pubcomp(self._slot, packet_id))

    def qos_state(self, packet_id: int) -> int:
        """Get the QoS delivery state for a packet ID (ABI tag)."""
        return self._lib.mqtt_qos_state(self._slot, packet_id)

    # -- Session lifecycle -------------------------------------------------

    def disconnect(self) -> None:
        """Disconnect the session cleanly."""
        check_status(self._lib.mqtt_disconnect(self._slot))

    def cleanup(self) -> None:
        """Clean up session resources (subscriptions, QoS state)."""
        check_status(self._lib.mqtt_cleanup(self._slot))


# ---------------------------------------------------------------------------
# Module-level functions
# ---------------------------------------------------------------------------

def abi_version() -> int:
    """Return the ABI version."""
    return _get_lib().mqtt_abi_version()


def retained_count() -> int:
    """Get the global retained message count."""
    return _get_lib().mqtt_retained_count()


def can_transition(from_state: MqttSessionState, to_state: MqttSessionState) -> bool:
    """Stateless query: check whether a session state transition is valid."""
    return _get_lib().mqtt_can_transition(from_state.value, to_state.value) == 1


def qos_can_transition(qos_level: QoS, from_tag: int, to_tag: int) -> bool:
    """Stateless query: check whether a QoS delivery state transition is valid."""
    return _get_lib().mqtt_qos_can_transition(qos_level.value, from_tag, to_tag) == 1


def topic_matches(filter_str: str, topic: str) -> bool:
    """Stateless query: check if a topic matches a subscription filter.

    Supports MQTT wildcards: + (single level), # (multi level).
    """
    lib = _get_lib()
    f = filter_str.encode("utf-8")
    t = topic.encode("utf-8")
    f_buf = (ctypes.c_uint8 * len(f))(*f)
    t_buf = (ctypes.c_uint8 * len(t))(*t)
    return lib.mqtt_topic_matches(f_buf, len(f), t_buf, len(t)) == 1
