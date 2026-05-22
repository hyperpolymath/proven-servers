// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Config Mgmt protocol types for proven-servers.

package com.hyperpolymath.proven

/** ResourceType matching the Idris2 ABI tags. */
enum class ResourceType(val tag: Int) {
    FILE(0),
    PACKAGE(1),
    SERVICE(2),
    USER(3),
    GROUP(4),
    CRON(5),
    MOUNT(6),
    FIREWALL(7),
    REGISTRY(8);

    companion object {
        fun fromTag(tag: Int): ResourceType? = entries.find { it.tag == tag }
    }
}

/** ResourceState matching the Idris2 ABI tags. */
enum class ResourceState(val tag: Int) {
    PRESENT(0),
    ABSENT(1),
    RUNNING(2),
    STOPPED(3),
    ENABLED(4),
    DISABLED(5);

    companion object {
        fun fromTag(tag: Int): ResourceState? = entries.find { it.tag == tag }
    }
}

/** ChangeAction matching the Idris2 ABI tags. */
enum class ChangeAction(val tag: Int) {
    CREATE(0),
    MODIFY(1),
    DELETE(2),
    RESTART(3),
    RELOAD(4),
    SKIP(5);

    companion object {
        fun fromTag(tag: Int): ChangeAction? = entries.find { it.tag == tag }
    }
}

/** DriftStatus matching the Idris2 ABI tags. */
enum class DriftStatus(val tag: Int) {
    IN_SYNC(0),
    DRIFTED(1),
    D_UNKNOWN(2),
    UNMANAGED(3);

    companion object {
        fun fromTag(tag: Int): DriftStatus? = entries.find { it.tag == tag }
    }
}

/** ApplyMode matching the Idris2 ABI tags. */
enum class ApplyMode(val tag: Int) {
    ENFORCE(0),
    DRY_RUN(1),
    AUDIT(2);

    companion object {
        fun fromTag(tag: Int): ApplyMode? = entries.find { it.tag == tag }
    }
}
