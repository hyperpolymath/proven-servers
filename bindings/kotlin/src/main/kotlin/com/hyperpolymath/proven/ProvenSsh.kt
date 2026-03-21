// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kotlin/JNI bindings for the proven-ssh-bastion protocol.
// Wraps the C-ABI functions from protocols/proven-ssh-bastion/ffi/zig/src/ssh_bastion.zig.
// Enum classes match Idris2 ABI tags exactly (SshBastionABI.Types).

package com.hyperpolymath.proven

/**
 * Kotlin bindings for the proven SSH bastion protocol.
 *
 * Lifecycle: Connected -> KeyExchanged -> Authenticated -> ChannelOpen -> Active -> Closed.
 *
 * @author Jonathan D.A. Jewell
 */
public class ProvenSsh private constructor(private val slot: Int) : AutoCloseable {

    /** SSH authentication methods (tags 0-3). */
    public enum class AuthMethod(public val tag: Int) {
        PUBLICKEY(0), PASSWORD(1), KEYBOARD_INTERACTIVE(2), NONE(3);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): AuthMethod? = entries.find { it.tag == tag }
        }
    }

    /** SSH key exchange methods (tags 0-5). */
    public enum class KexMethod(public val tag: Int) {
        DH_GROUP14_SHA256(0), CURVE25519_SHA256(1), DH_GROUP16_SHA512(2),
        DH_GROUP18_SHA512(3), ECDH_SHA2_NISTP256(4), ECDH_SHA2_NISTP384(5);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): KexMethod? = entries.find { it.tag == tag }
        }
    }

    /** SSH channel types (tags 0-3). */
    public enum class ChannelType(public val tag: Int) {
        SESSION(0), DIRECT_TCPIP(1), FORWARDED_TCPIP(2), X11(3);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): ChannelType? = entries.find { it.tag == tag }
        }
    }

    /** SSH bastion connection states (tags 0-5). */
    public enum class BastionState(public val tag: Int) {
        CONNECTED(0), KEY_EXCHANGED(1), AUTHENTICATED(2),
        CHANNEL_OPEN(3), ACTIVE(4), CLOSED(5);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): BastionState? = entries.find { it.tag == tag }
        }
    }

    /** SSH channel states (tags 0-3). */
    public enum class ChannelState(public val tag: Int) {
        OPENING(0), OPEN(1), CLOSING(2), CLOSED(3);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): ChannelState? = entries.find { it.tag == tag }
        }
    }

    /** SSH disconnect reason codes (tags 0-11). */
    public enum class DisconnectReason(public val tag: Int) {
        HOST_NOT_ALLOWED(0), PROTOCOL_ERROR(1), KEY_EXCHANGE_FAILED(2),
        HOST_AUTH_FAILED(3), MAC_ERROR(4), SERVICE_NOT_AVAILABLE(5),
        VERSION_NOT_SUPPORTED(6), HOST_KEY_NOT_VERIFIABLE(7),
        CONNECTION_LOST(8), BY_APPLICATION(9), TOO_MANY_CONNECTIONS(10),
        AUTH_CANCELLED(11);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): DisconnectReason? = entries.find { it.tag == tag }
        }
    }

    private companion object {
        @JvmStatic external fun ssh_bastion_abi_version(): Int
        @JvmStatic external fun ssh_bastion_create(kexMethod: Int, authMethod: Int): Int
        @JvmStatic external fun ssh_bastion_destroy(slot: Int)
        @JvmStatic external fun ssh_bastion_state(slot: Int): Int
        @JvmStatic external fun ssh_bastion_kex_method(slot: Int): Int
        @JvmStatic external fun ssh_bastion_auth_method(slot: Int): Int
        @JvmStatic external fun ssh_bastion_can_transfer(slot: Int): Int
        @JvmStatic external fun ssh_bastion_disconnect_reason(slot: Int): Int
        @JvmStatic external fun ssh_bastion_auth_failures(slot: Int): Int
        @JvmStatic external fun ssh_bastion_complete_kex(slot: Int): Int
        @JvmStatic external fun ssh_bastion_authenticate(slot: Int, userLen: Int): Int
        @JvmStatic external fun ssh_bastion_record_auth_failure(slot: Int): Int
        @JvmStatic external fun ssh_bastion_open_channel(slot: Int, chType: Int): Int
        @JvmStatic external fun ssh_bastion_confirm_channel(slot: Int, chId: Int): Int
        @JvmStatic external fun ssh_bastion_close_channel(slot: Int, chId: Int): Int
        @JvmStatic external fun ssh_bastion_channel_state(slot: Int, chId: Int): Int
        @JvmStatic external fun ssh_bastion_channel_type(slot: Int, chId: Int): Int
        @JvmStatic external fun ssh_bastion_channel_count(slot: Int): Int
        @JvmStatic external fun ssh_bastion_rekey(slot: Int): Int
        @JvmStatic external fun ssh_bastion_disconnect(slot: Int, reason: Int): Int
        @JvmStatic external fun ssh_bastion_can_transition(from: Int, to: Int): Int
        @JvmStatic external fun ssh_bastion_audit_count(slot: Int): Int
        @JvmStatic external fun ssh_bastion_audit_entry(slot: Int, idx: Int): Int
        @JvmStatic external fun ssh_bastion_audit_entry_to(slot: Int, idx: Int): Int
        @JvmStatic external fun ssh_bastion_set_recording(slot: Int, enabled: Int): Int
        @JvmStatic external fun ssh_bastion_is_recording(slot: Int): Int
    }

    override fun close() { ssh_bastion_destroy(slot) }

    public val state: BastionState? get() = BastionState.fromTag(ssh_bastion_state(slot))
    public val kexMethod: KexMethod? get() = KexMethod.fromTag(ssh_bastion_kex_method(slot))
    public val authMethod: AuthMethod? get() = AuthMethod.fromTag(ssh_bastion_auth_method(slot))
    public val canTransferData: Boolean get() = ssh_bastion_can_transfer(slot) == 1
    public val disconnectReason: DisconnectReason? get() = DisconnectReason.fromTag(ssh_bastion_disconnect_reason(slot))
    public val authFailures: Int get() = ssh_bastion_auth_failures(slot)
    public val channelCount: Int get() = ssh_bastion_channel_count(slot)
    public val auditCount: Int get() = ssh_bastion_audit_count(slot)
    public val isRecording: Boolean get() = ssh_bastion_is_recording(slot) == 1

    public fun completeKex(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ssh_bastion_complete_kex(slot)) }
    public fun authenticate(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ssh_bastion_authenticate(slot, 0)) }
    public fun recordAuthFailure(): Boolean = ssh_bastion_record_auth_failure(slot) == 1

    public fun openChannel(type: ChannelType): Result<Int> = ProvenError.runCatching {
        ProvenError.checkSlot(ssh_bastion_open_channel(slot, type.tag))
    }

    public fun confirmChannel(channelId: Int): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(ssh_bastion_confirm_channel(slot, channelId))
    }

    public fun closeChannel(channelId: Int): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(ssh_bastion_close_channel(slot, channelId))
    }

    public fun channelState(channelId: Int): ChannelState? = ChannelState.fromTag(ssh_bastion_channel_state(slot, channelId))
    public fun channelType(channelId: Int): ChannelType? = ChannelType.fromTag(ssh_bastion_channel_type(slot, channelId))

    public fun rekey(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(ssh_bastion_rekey(slot)) }

    public fun disconnect(reason: DisconnectReason): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(ssh_bastion_disconnect(slot, reason.tag))
    }

    public fun auditEntryFrom(index: Int): BastionState? = BastionState.fromTag(ssh_bastion_audit_entry(slot, index))
    public fun auditEntryTo(index: Int): BastionState? = BastionState.fromTag(ssh_bastion_audit_entry_to(slot, index))

    public fun setRecording(enabled: Boolean): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(ssh_bastion_set_recording(slot, if (enabled) 1 else 0))
    }

    public companion object {
        @JvmStatic public fun create(kex: KexMethod, auth: AuthMethod): Result<ProvenSsh> = ProvenError.runCatching {
            ProvenSsh(ProvenError.checkSlot(ssh_bastion_create(kex.tag, auth.tag)))
        }

        @JvmStatic public fun abiVersion(): Int = ssh_bastion_abi_version()

        @JvmStatic public fun canTransition(from: BastionState, to: BastionState): Boolean =
            ssh_bastion_can_transition(from.tag, to.tag) == 1
    }
}
