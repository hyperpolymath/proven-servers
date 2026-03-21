// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Swift bindings for the proven-ssh-bastion protocol.
// Wraps the C-ABI functions from protocols/proven-ssh-bastion/ffi/zig/src/ssh_bastion.zig.
// Enums match Idris2 ABI tags exactly (SshBastionABI.Types).

import Foundation

// MARK: - C interop declarations

@_silgen_name("ssh_bastion_abi_version")    private func ssh_bastion_abi_version() -> UInt32
@_silgen_name("ssh_bastion_create")         private func ssh_bastion_create(_ kexMethod: UInt8, _ authMethod: UInt8) -> Int32
@_silgen_name("ssh_bastion_destroy")        private func ssh_bastion_destroy(_ slot: Int32)
@_silgen_name("ssh_bastion_state")          private func ssh_bastion_state(_ slot: Int32) -> UInt8
@_silgen_name("ssh_bastion_kex_method")     private func ssh_bastion_kex_method(_ slot: Int32) -> UInt8
@_silgen_name("ssh_bastion_auth_method")    private func ssh_bastion_auth_method(_ slot: Int32) -> UInt8
@_silgen_name("ssh_bastion_can_transfer")   private func ssh_bastion_can_transfer(_ slot: Int32) -> UInt8
@_silgen_name("ssh_bastion_disconnect_reason") private func ssh_bastion_disconnect_reason(_ slot: Int32) -> UInt8
@_silgen_name("ssh_bastion_auth_failures")  private func ssh_bastion_auth_failures(_ slot: Int32) -> UInt8
@_silgen_name("ssh_bastion_complete_kex")   private func ssh_bastion_complete_kex(_ slot: Int32) -> UInt8
@_silgen_name("ssh_bastion_authenticate")   private func ssh_bastion_authenticate(_ slot: Int32, _ userLen: UInt16) -> UInt8
@_silgen_name("ssh_bastion_record_auth_failure") private func ssh_bastion_record_auth_failure(_ slot: Int32) -> UInt8
@_silgen_name("ssh_bastion_open_channel")   private func ssh_bastion_open_channel(_ slot: Int32, _ chType: UInt8) -> Int32
@_silgen_name("ssh_bastion_confirm_channel") private func ssh_bastion_confirm_channel(_ slot: Int32, _ chId: UInt8) -> UInt8
@_silgen_name("ssh_bastion_close_channel")  private func ssh_bastion_close_channel(_ slot: Int32, _ chId: UInt8) -> UInt8
@_silgen_name("ssh_bastion_channel_state")  private func ssh_bastion_channel_state(_ slot: Int32, _ chId: UInt8) -> UInt8
@_silgen_name("ssh_bastion_channel_type")   private func ssh_bastion_channel_type(_ slot: Int32, _ chId: UInt8) -> UInt8
@_silgen_name("ssh_bastion_channel_count")  private func ssh_bastion_channel_count(_ slot: Int32) -> UInt8
@_silgen_name("ssh_bastion_rekey")          private func ssh_bastion_rekey(_ slot: Int32) -> UInt8
@_silgen_name("ssh_bastion_disconnect")     private func ssh_bastion_disconnect(_ slot: Int32, _ reason: UInt8) -> UInt8
@_silgen_name("ssh_bastion_can_transition") private func ssh_bastion_can_transition(_ from: UInt8, _ to: UInt8) -> UInt8
@_silgen_name("ssh_bastion_audit_count")    private func ssh_bastion_audit_count(_ slot: Int32) -> UInt32
@_silgen_name("ssh_bastion_audit_entry")    private func ssh_bastion_audit_entry(_ slot: Int32, _ idx: UInt32) -> UInt8
@_silgen_name("ssh_bastion_audit_entry_to") private func ssh_bastion_audit_entry_to(_ slot: Int32, _ idx: UInt32) -> UInt8
@_silgen_name("ssh_bastion_set_recording")  private func ssh_bastion_set_recording(_ slot: Int32, _ enabled: UInt8) -> UInt8
@_silgen_name("ssh_bastion_is_recording")   private func ssh_bastion_is_recording(_ slot: Int32) -> UInt8

// MARK: - Enums matching Idris2 ABI tags

/// SSH authentication methods (SshBastionABI.Types, tags 0-3).
public enum SshAuthMethod: Int, CaseIterable, Sendable {
    /// Public key authentication.
    case publickey = 0
    /// Password authentication.
    case password = 1
    /// Keyboard-interactive authentication.
    case keyboardInteractive = 2
    /// No authentication / "none" method.
    case none = 3

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// SSH key exchange methods (SshBastionABI.Types, tags 0-5).
public enum SshKexMethod: Int, CaseIterable, Sendable {
    /// diffie-hellman-group14-sha256.
    case diffieHellmanGroup14Sha256 = 0
    /// curve25519-sha256.
    case curve25519Sha256 = 1
    /// diffie-hellman-group16-sha512.
    case diffieHellmanGroup16Sha512 = 2
    /// diffie-hellman-group18-sha512.
    case diffieHellmanGroup18Sha512 = 3
    /// ecdh-sha2-nistp256.
    case ecdhSha2Nistp256 = 4
    /// ecdh-sha2-nistp384.
    case ecdhSha2Nistp384 = 5

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// SSH channel types (SshBastionABI.Types, tags 0-3).
public enum SshChannelType: Int, CaseIterable, Sendable {
    /// Interactive shell session.
    case session = 0
    /// Direct TCP/IP forwarding.
    case directTcpip = 1
    /// Forwarded TCP/IP from remote.
    case forwardedTcpip = 2
    /// X11 forwarding.
    case x11 = 3

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// SSH bastion connection states (SshBastionABI.Types, tags 0-5).
public enum SshBastionState: Int, CaseIterable, Sendable {
    /// TCP connection established, no SSH handshake yet.
    case connected = 0
    /// Key exchange completed successfully.
    case keyExchanged = 1
    /// User authentication succeeded.
    case authenticated = 2
    /// At least one channel is open.
    case channelOpen = 3
    /// Actively transferring data.
    case active = 4
    /// Connection closed.
    case closed = 5

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// SSH channel states (SshBastionABI.Types, tags 0-3).
public enum SshChannelState: Int, CaseIterable, Sendable {
    /// Channel open request sent, awaiting confirmation.
    case opening = 0
    /// Channel is open and active.
    case open = 1
    /// Channel close has been initiated.
    case closing = 2
    /// Channel is fully closed.
    case closed = 3

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// SSH disconnect reason codes (SshBastionABI.Types, tags 0-11).
public enum SshDisconnectReason: Int, CaseIterable, Sendable {
    /// Host not allowed to connect.
    case hostNotAllowed = 0
    /// Protocol error detected.
    case protocolError = 1
    /// Key exchange failed.
    case keyExchangeFailed = 2
    /// Host authentication failed.
    case hostAuthFailed = 3
    /// MAC verification error.
    case macError = 4
    /// Requested service not available.
    case serviceNotAvailable = 5
    /// Protocol version not supported.
    case versionNotSupported = 6
    /// Host key not verifiable.
    case hostKeyNotVerifiable = 7
    /// Connection lost unexpectedly.
    case connectionLost = 8
    /// Disconnected by application.
    case byApplication = 9
    /// Too many concurrent connections.
    case tooManyConnections = 10
    /// Authentication cancelled by user.
    case authCancelled = 11

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

// MARK: - Swift-idiomatic wrapper

/// Swift wrapper for the proven SSH bastion protocol FFI.
///
/// Manages an opaque SSH bastion session context slot. The context is
/// automatically destroyed when this object is deallocated.
///
/// Lifecycle: Connected -> KeyExchanged -> Authenticated -> ChannelOpen -> Active -> Closed.
public final class ProvenSsh: @unchecked Sendable {

    private let slot: Int32

    /// Create a new SSH bastion session with the given key exchange and auth methods.
    ///
    /// - Parameters:
    ///   - kexMethod: The key exchange method.
    ///   - authMethod: The authentication method.
    /// - Throws: ``ProvenError/poolExhausted`` if all 64 slots are in use.
    public init(kexMethod: SshKexMethod, authMethod: SshAuthMethod) throws {
        self.slot = try ProvenError.checkSlot(ssh_bastion_create(kexMethod.tag, authMethod.tag))
    }

    deinit { ssh_bastion_destroy(slot) }

    /// The ABI version.
    public static var abiVersion: UInt32 { ssh_bastion_abi_version() }

    /// The current bastion state.
    public var state: SshBastionState? { SshBastionState(tag: ssh_bastion_state(slot)) }

    /// The configured key exchange method.
    public var kexMethod: SshKexMethod? { SshKexMethod(tag: ssh_bastion_kex_method(slot)) }

    /// The configured authentication method.
    public var authMethod: SshAuthMethod? { SshAuthMethod(tag: ssh_bastion_auth_method(slot)) }

    /// Whether data transfer is allowed (session must be Active).
    public var canTransferData: Bool { ssh_bastion_can_transfer(slot) == 1 }

    /// The disconnect reason, or `nil` if not disconnected.
    public var disconnectReason: SshDisconnectReason? {
        SshDisconnectReason(tag: ssh_bastion_disconnect_reason(slot))
    }

    /// The number of failed auth attempts.
    public var authFailures: UInt8 { ssh_bastion_auth_failures(slot) }

    /// Complete key exchange. Transitions Connected -> KeyExchanged.
    public func completeKex() throws {
        try ProvenError.checkStatus(ssh_bastion_complete_kex(slot))
    }

    /// Authenticate the user. Transitions KeyExchanged -> Authenticated.
    public func authenticate() throws {
        try ProvenError.checkStatus(ssh_bastion_authenticate(slot, 0))
    }

    /// Record a failed auth attempt.
    ///
    /// - Returns: `true` if locked out (3+ failures).
    public func recordAuthFailure() -> Bool {
        ssh_bastion_record_auth_failure(slot) == 1
    }

    /// Open a channel.
    ///
    /// - Parameter type: The channel type.
    /// - Returns: The channel ID (0-9).
    /// - Throws: ``ProvenError/poolExhausted`` if no channel slots available.
    public func openChannel(type: SshChannelType) throws -> UInt8 {
        let chId = try ProvenError.checkSlot(ssh_bastion_open_channel(slot, type.tag))
        return UInt8(chId)
    }

    /// Confirm a channel (Opening -> Open).
    public func confirmChannel(_ channelId: UInt8) throws {
        try ProvenError.checkStatus(ssh_bastion_confirm_channel(slot, channelId))
    }

    /// Close a specific channel.
    public func closeChannel(_ channelId: UInt8) throws {
        try ProvenError.checkStatus(ssh_bastion_close_channel(slot, channelId))
    }

    /// Get the state of a specific channel.
    public func channelState(_ channelId: UInt8) -> SshChannelState? {
        SshChannelState(tag: ssh_bastion_channel_state(slot, channelId))
    }

    /// Get the type of a specific channel.
    public func channelType(_ channelId: UInt8) -> SshChannelType? {
        SshChannelType(tag: ssh_bastion_channel_type(slot, channelId))
    }

    /// The count of active (non-closed) channels.
    public var channelCount: UInt8 { ssh_bastion_channel_count(slot) }

    /// Re-key the session. Only valid in Active state.
    public func rekey() throws {
        try ProvenError.checkStatus(ssh_bastion_rekey(slot))
    }

    /// Disconnect with a reason.
    public func disconnect(reason: SshDisconnectReason) throws {
        try ProvenError.checkStatus(ssh_bastion_disconnect(slot, reason.tag))
    }

    /// The number of audit log entries.
    public var auditCount: UInt32 { ssh_bastion_audit_count(slot) }

    /// Read the from-state of an audit log entry.
    public func auditEntryFrom(index: UInt32) -> SshBastionState? {
        SshBastionState(tag: ssh_bastion_audit_entry(slot, index))
    }

    /// Read the to-state of an audit log entry.
    public func auditEntryTo(index: UInt32) -> SshBastionState? {
        SshBastionState(tag: ssh_bastion_audit_entry_to(slot, index))
    }

    /// Enable or disable session recording.
    public func setRecording(_ enabled: Bool) throws {
        try ProvenError.checkStatus(ssh_bastion_set_recording(slot, enabled ? 1 : 0))
    }

    /// Whether session recording is active.
    public var isRecording: Bool { ssh_bastion_is_recording(slot) == 1 }

    /// Stateless query: check whether a bastion state transition is valid.
    public static func canTransition(from: SshBastionState, to: SshBastionState) -> Bool {
        ssh_bastion_can_transition(from.tag, to.tag) == 1
    }
}
