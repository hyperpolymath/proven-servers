// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// File Server protocol types for proven-servers.

package com.hyperpolymath.proven

/** FileOperation matching the Idris2 ABI tags. */
enum class FileOperation(val tag: Int) {
    READ(0),
    WRITE(1),
    CREATE(2),
    DELETE(3),
    RENAME(4),
    LIST(5),
    STAT(6),
    LOCK(7),
    UNLOCK(8),
    WATCH(9);

    companion object {
        fun fromTag(tag: Int): FileOperation? = entries.find { it.tag == tag }
    }
}

/** FileType matching the Idris2 ABI tags. */
enum class FileType(val tag: Int) {
    REGULAR(0),
    DIRECTORY(1),
    SYMLINK(2),
    BLOCK_DEVICE(3),
    CHAR_DEVICE(4),
    FIFO(5),
    SOCKET(6);

    companion object {
        fun fromTag(tag: Int): FileType? = entries.find { it.tag == tag }
    }
}

/** FilePermission matching the Idris2 ABI tags. */
enum class FilePermission(val tag: Int) {
    OWNER_READ(0),
    OWNER_WRITE(1),
    OWNER_EXECUTE(2),
    GROUP_READ(3),
    GROUP_WRITE(4),
    GROUP_EXECUTE(5),
    OTHER_READ(6),
    OTHER_WRITE(7),
    OTHER_EXECUTE(8);

    companion object {
        fun fromTag(tag: Int): FilePermission? = entries.find { it.tag == tag }
    }
}

/** LockType matching the Idris2 ABI tags. */
enum class LockType(val tag: Int) {
    SHARED(0),
    EXCLUSIVE(1),
    ADVISORY(2),
    MANDATORY(3);

    companion object {
        fun fromTag(tag: Int): LockType? = entries.find { it.tag == tag }
    }
}

/** FileErrorCode matching the Idris2 ABI tags. */
enum class FileErrorCode(val tag: Int) {
    NOT_FOUND(0),
    PERMISSION_DENIED(1),
    ALREADY_EXISTS(2),
    NOT_EMPTY(3),
    IS_DIRECTORY(4),
    NOT_DIRECTORY(5),
    NO_SPACE(6),
    READ_ONLY(7),
    LOCKED(8),
    IO_ERROR(9);

    companion object {
        fun fromTag(tag: Int): FileErrorCode? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    CONNECTED(1),
    OPERATING(2),
    FS_LOCKED(3),
    DISCONNECTING(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
