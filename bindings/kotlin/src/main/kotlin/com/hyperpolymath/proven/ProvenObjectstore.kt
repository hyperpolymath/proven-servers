// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Object Store protocol types for proven-servers.

package com.hyperpolymath.proven

/** Operation matching the Idris2 ABI tags. */
enum class Operation(val tag: Int) {
    PUT_OBJECT(0),
    GET_OBJECT(1),
    DELETE_OBJECT(2),
    LIST_OBJECTS(3),
    HEAD_OBJECT(4),
    COPY_OBJECT(5),
    CREATE_BUCKET(6),
    DELETE_BUCKET(7),
    LIST_BUCKETS(8),
    INIT_MULTIPART_UPLOAD(9),
    UPLOAD_PART(10),
    COMPLETE_MULTIPART_UPLOAD(11);

    companion object {
        fun fromTag(tag: Int): Operation? = entries.find { it.tag == tag }
    }
}

/** StorageClass matching the Idris2 ABI tags. */
enum class StorageClass(val tag: Int) {
    STANDARD(0),
    INFREQUENT_ACCESS(1),
    GLACIER(2),
    DEEP_ARCHIVE(3),
    ONE_ZONE(4);

    companion object {
        fun fromTag(tag: Int): StorageClass? = entries.find { it.tag == tag }
    }
}

/** Acl matching the Idris2 ABI tags. */
enum class Acl(val tag: Int) {
    PRIVATE(0),
    PUBLIC_READ(1),
    PUBLIC_READ_WRITE(2),
    AUTHENTICATED_READ(3);

    companion object {
        fun fromTag(tag: Int): Acl? = entries.find { it.tag == tag }
    }
}

/** ErrorCode matching the Idris2 ABI tags. */
enum class ErrorCode(val tag: Int) {
    NO_SUCH_BUCKET(0),
    NO_SUCH_KEY(1),
    BUCKET_ALREADY_EXISTS(2),
    BUCKET_NOT_EMPTY(3),
    ACCESS_DENIED(4),
    ENTITY_TOO_LARGE(5),
    INVALID_PART(6),
    INCOMPLETE_BODY(7);

    companion object {
        fun fromTag(tag: Int): ErrorCode? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    READY(1),
    BUCKET_ACTIVE(2),
    UPLOADING(3),
    CLOSING(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
