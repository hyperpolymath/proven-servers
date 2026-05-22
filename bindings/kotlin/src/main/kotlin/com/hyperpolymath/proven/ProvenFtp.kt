// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kotlin/JNI bindings for the proven-ftp protocol.
// Wraps the C-ABI functions from protocols/proven-ftp/ffi/zig/src/ftp.zig.
// Enum classes match Idris2 ABI tags exactly.

package com.hyperpolymath.proven

/**
 * Kotlin bindings for the proven FTP server protocol.
 *
 * @author Jonathan D.A. Jewell
 */
public class ProvenFtp private constructor(private val slot: Int) : AutoCloseable {

    /** FTP session states (tags 0-4). */
    public enum class SessionState(public val tag: Int) {
        CONNECTED(0), USER_OK(1), AUTHENTICATED(2), RENAMING(3), QUIT(4);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
        }
    }

    /** FTP transfer states (tags 0-3). */
    public enum class TransferState(public val tag: Int) {
        IDLE(0), IN_PROGRESS(1), COMPLETED(2), ABORTED(3);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): TransferState? = entries.find { it.tag == tag }
        }
    }

    private companion object {
        @JvmStatic external fun ftp_abi_version(): Int
        @JvmStatic external fun ftp_create(): Int
        @JvmStatic external fun ftp_destroy(slot: Int)
        @JvmStatic external fun ftp_state(slot: Int): Int
        @JvmStatic external fun ftp_transfer_type(slot: Int): Int
        @JvmStatic external fun ftp_data_mode(slot: Int): Int
        @JvmStatic external fun ftp_transfer_state(slot: Int): Int
        @JvmStatic external fun ftp_bytes_transferred(slot: Int): Long
        @JvmStatic external fun ftp_file_count(slot: Int): Int
        @JvmStatic external fun ftp_last_reply_code(slot: Int): Int
        @JvmStatic external fun ftp_cwd(slot: Int, buf: ByteArray, bufLen: Int): Int
        @JvmStatic external fun ftp_user(slot: Int, name: ByteArray, len: Int): Int
        @JvmStatic external fun ftp_pass(slot: Int, pass: ByteArray, len: Int): Int
        @JvmStatic external fun ftp_quit(slot: Int): Int
        @JvmStatic external fun ftp_cwd_cmd(slot: Int, path: ByteArray, pathLen: Int): Int
        @JvmStatic external fun ftp_cdup(slot: Int): Int
        @JvmStatic external fun ftp_set_type(slot: Int, typeTag: Int): Int
        @JvmStatic external fun ftp_set_passive(slot: Int): Int
        @JvmStatic external fun ftp_set_active(slot: Int, port: Int): Int
        @JvmStatic external fun ftp_begin_transfer(slot: Int): Int
        @JvmStatic external fun ftp_add_bytes(slot: Int, count: Long): Int
        @JvmStatic external fun ftp_complete_transfer(slot: Int): Int
        @JvmStatic external fun ftp_abort_transfer(slot: Int): Int
        @JvmStatic external fun ftp_begin_rename(slot: Int): Int
        @JvmStatic external fun ftp_complete_rename(slot: Int): Int
        @JvmStatic external fun ftp_can_transfer(stateTag: Int): Int
        @JvmStatic external fun ftp_can_transition(from: Int, to: Int): Int
    }

    override fun close() { ftp_destroy(slot) }

    public val state: SessionState? get() = SessionState.fromTag(ftp_state(slot))
    public val transferType: Int get() = ftp_transfer_type(slot)
    public val dataMode: Int get() = ftp_data_mode(slot)
    public val transferState: TransferState? get() = TransferState.fromTag(ftp_transfer_state(slot))
    public val bytesTransferred: Long get() = ftp_bytes_transferred(slot)
    public val fileCount: Int get() = ftp_file_count(slot)
    public val lastReplyCode: Int get() = ftp_last_reply_code(slot)

    public fun currentWorkingDirectory(): String {
        val buf = ByteArray(4096)
        val written = ftp_cwd(slot, buf, buf.size)
        return String(buf, 0, written)
    }

    public fun user(name: String): Result<Unit> = ProvenError.runCatching {
        val bytes = name.toByteArray()
        ProvenError.checkStatus(ftp_user(slot, bytes, bytes.size))
    }

    public fun pass(password: String): Result<Unit> = ProvenError.runCatching {
        val bytes = password.toByteArray()
        ProvenError.checkStatus(ftp_pass(slot, bytes, bytes.size))
    }

    public fun quitSession(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ftp_quit(slot)) }

    public fun changeDir(path: String): Result<Unit> = ProvenError.runCatching {
        val bytes = path.toByteArray()
        ProvenError.checkStatus(ftp_cwd_cmd(slot, bytes, bytes.size))
    }

    public fun changeDirUp(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ftp_cdup(slot)) }
    public fun setType(typeTag: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ftp_set_type(slot, typeTag)) }
    public fun setPassive(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ftp_set_passive(slot)) }
    public fun setActive(port: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ftp_set_active(slot, port)) }
    public fun beginTransfer(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ftp_begin_transfer(slot)) }
    public fun addBytes(count: Long): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ftp_add_bytes(slot, count)) }
    public fun completeTransfer(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ftp_complete_transfer(slot)) }
    public fun abortTransfer(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ftp_abort_transfer(slot)) }
    public fun beginRename(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ftp_begin_rename(slot)) }
    public fun completeRename(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ftp_complete_rename(slot)) }

    public companion object {
        @JvmStatic public fun create(): Result<ProvenFtp> = ProvenError.runCatching {
            ProvenFtp(ProvenError.checkSlot(ftp_create()))
        }

        @JvmStatic public fun abiVersion(): Int = ftp_abi_version()

        @JvmStatic public fun canTransfer(state: SessionState): Boolean = ftp_can_transfer(state.tag) == 1

        @JvmStatic public fun canTransition(from: SessionState, to: SessionState): Boolean =
            ftp_can_transition(from.tag, to.tag) == 1
    }
}
