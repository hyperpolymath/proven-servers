# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-ldp protocol types.

"""LDP protocol types for proven-servers."""

from enum import IntEnum


class ContainerType(IntEnum):
    """ContainerType matching the Idris2 ABI tags."""
    BASIC = 0
    DIRECT = 1
    INDIRECT = 2


class LdpResourceType(IntEnum):
    """LdpResourceType matching the Idris2 ABI tags."""
    RDF_SOURCE = 0
    NON_RDF_SOURCE = 1
    CONTAINER = 2


class Preference(IntEnum):
    """Preference matching the Idris2 ABI tags."""
    MINIMAL_CONTAINER = 0
    INCLUDE_CONTAINMENT = 1
    INCLUDE_MEMBERSHIP = 2
    OMIT_CONTAINMENT = 3
    OMIT_MEMBERSHIP = 4


class InteractionModel(IntEnum):
    """InteractionModel matching the Idris2 ABI tags."""
    LDPR = 0
    LDPC = 1
    LDP_BASIC_CONTAINER = 2
    LDP_DIRECT_CONTAINER = 3
    LDP_INDIRECT_CONTAINER = 4


class ConstraintViolation(IntEnum):
    """ConstraintViolation matching the Idris2 ABI tags."""
    MEMBERSHIP_CONSTANT = 0
    CONTAINS_TRIPLES_MODIFIED = 1
    SERVER_MANAGED = 2
    TYPE_CONFLICT = 3
