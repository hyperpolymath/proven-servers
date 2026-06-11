# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-objectstore protocol types.

"""Object Store protocol types for proven-servers."""

from enum import IntEnum


class Operation(IntEnum):
    """Operation matching the Idris2 ABI tags."""
    PUT_OBJECT = 0
    GET_OBJECT = 1
    DELETE_OBJECT = 2
    LIST_OBJECTS = 3
    HEAD_OBJECT = 4
    COPY_OBJECT = 5
    CREATE_BUCKET = 6
    DELETE_BUCKET = 7
    LIST_BUCKETS = 8
    INIT_MULTIPART_UPLOAD = 9
    UPLOAD_PART = 10
    COMPLETE_MULTIPART_UPLOAD = 11


class StorageClass(IntEnum):
    """StorageClass matching the Idris2 ABI tags."""
    STANDARD = 0
    INFREQUENT_ACCESS = 1
    GLACIER = 2
    DEEP_ARCHIVE = 3
    ONE_ZONE = 4


class Acl(IntEnum):
    """Acl matching the Idris2 ABI tags."""
    PRIVATE = 0
    PUBLIC_READ = 1
    PUBLIC_READ_WRITE = 2
    AUTHENTICATED_READ = 3


class ErrorCode(IntEnum):
    """ErrorCode matching the Idris2 ABI tags."""
    NO_SUCH_BUCKET = 0
    NO_SUCH_KEY = 1
    BUCKET_ALREADY_EXISTS = 2
    BUCKET_NOT_EMPTY = 3
    ACCESS_DENIED = 4
    ENTITY_TOO_LARGE = 5
    INVALID_PART = 6
    INCOMPLETE_BODY = 7


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    READY = 1
    BUCKET_ACTIVE = 2
    UPLOADING = 3
    CLOSING = 4
