// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Swift bindings for the proven-ftp protocol.
// Wraps the C-ABI functions from protocols/proven-ftp/ffi/zig/src/ftp.zig.
// Enums match Idris2 ABI tags exactly.

import Foundation

// MARK: - C interop declarations

@_silgen_name("ftp_abi_version")       private func ftp_abi_version() -> UInt32
@_silgen_name("ftp_create")            private func ftp_create() -> Int32
@_silgen_name("ftp_destroy")           private func ftp_destroy(_ slot: Int32)
@_silgen_name("ftp_state")             private func ftp_state(_ slot: Int32) -> UInt8
@_silgen_name("ftp_transfer_type")     private func ftp_transfer_type(_ slot: Int32) -> UInt8
@_silgen_name("ftp_data_mode")         private func ftp_data_mode(_ slot: Int32) -> UInt8
@_silgen_name("ftp_transfer_state")    private func ftp_transfer_state(_ slot: Int32) -> UInt8
@_silgen_name("ftp_bytes_transferred") private func ftp_bytes_transferred(_ slot: Int32) -> UInt64
@_silgen_name("ftp_file_count")        private func ftp_file_count(_ slot: Int32) -> UInt32
@_silgen_name("ftp_last_reply_code")   private func ftp_last_reply_code(_ slot: Int32) -> UInt16
@_silgen_name("ftp_cwd")              private func ftp_cwd(_ slot: Int32, _ buf: UnsafeMutablePointer<UInt8>, _ bufLen: UInt32) -> UInt32
@_silgen_name("ftp_user")             private func ftp_user(_ slot: Int32, _ name: UnsafePointer<UInt8>, _ len: UInt32) -> UInt8
@_silgen_name("ftp_pass")             private func ftp_pass(_ slot: Int32, _ pass: UnsafePointer<UInt8>, _ len: UInt32) -> UInt8
@_silgen_name("ftp_quit")             private func ftp_quit(_ slot: Int32) -> UInt8
@_silgen_name("ftp_cwd_cmd")          private func ftp_cwd_cmd(_ slot: Int32, _ path: UnsafePointer<UInt8>, _ pathLen: UInt32) -> UInt8
@_silgen_name("ftp_cdup")             private func ftp_cdup(_ slot: Int32) -> UInt8
@_silgen_name("ftp_set_type")         private func ftp_set_type(_ slot: Int32, _ typeTag: UInt8) -> UInt8
@_silgen_name("ftp_set_passive")      private func ftp_set_passive(_ slot: Int32) -> UInt8
@_silgen_name("ftp_set_active")       private func ftp_set_active(_ slot: Int32, _ port: UInt16) -> UInt8
@_silgen_name("ftp_begin_transfer")   private func ftp_begin_transfer(_ slot: Int32) -> UInt8
@_silgen_name("ftp_add_bytes")        private func ftp_add_bytes(_ slot: Int32, _ count: UInt64) -> UInt8
@_silgen_name("ftp_complete_transfer") private func ftp_complete_transfer(_ slot: Int32) -> UInt8
@_silgen_name("ftp_abort_transfer")   private func ftp_abort_transfer(_ slot: Int32) -> UInt8
@_silgen_name("ftp_begin_rename")     private func ftp_begin_rename(_ slot: Int32) -> UInt8
@_silgen_name("ftp_complete_rename")  private func ftp_complete_rename(_ slot: Int32) -> UInt8
@_silgen_name("ftp_can_transfer")     private func ftp_can_transfer(_ stateTag: UInt8) -> UInt8
@_silgen_name("ftp_can_transition")   private func ftp_can_transition(_ from: UInt8, _ to: UInt8) -> UInt8

// MARK: - Enums matching Idris2 ABI tags

/// FTP session states (tags 0-4).
public enum FtpSessionState: Int, CaseIterable, Sendable {
    /// TCP connection established.
    case connected = 0
    /// USER accepted, password required.
    case userOk = 1
    /// Fully authenticated.
    case authenticated = 2
    /// Rename in progress (RNFR sent).
    case renaming = 3
    /// Session ended.
    case quit = 4

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// FTP transfer states (tags 0-3).
public enum FtpTransferState: Int, CaseIterable, Sendable {
    /// No transfer in progress.
    case idle = 0
    /// Transfer active.
    case inProgress = 1
    /// Transfer completed successfully.
    case completed = 2
    /// Transfer was aborted.
    case aborted = 3

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

// MARK: - Swift-idiomatic wrapper

/// Swift wrapper for the proven FTP server protocol FFI.
///
/// Manages an opaque FTP session context slot. The context is
/// automatically destroyed when this object is deallocated.
public final class ProvenFtp: @unchecked Sendable {

    private let slot: Int32

    /// Create a new FTP session in the Connected state.
    ///
    /// - Throws: ``ProvenError/poolExhausted`` if all 64 slots are in use.
    public init() throws {
        self.slot = try ProvenError.checkSlot(ftp_create())
    }

    deinit { ftp_destroy(slot) }

    /// The ABI version.
    public static var abiVersion: UInt32 { ftp_abi_version() }

    /// The current session state.
    public var state: FtpSessionState? { FtpSessionState(tag: ftp_state(slot)) }

    /// The transfer type tag (0=ASCII, 1=binary).
    public var transferType: UInt8 { ftp_transfer_type(slot) }

    /// The data mode tag (0=active, 1=passive, 255=unset).
    public var dataMode: UInt8 { ftp_data_mode(slot) }

    /// The transfer state.
    public var transferState: FtpTransferState? { FtpTransferState(tag: ftp_transfer_state(slot)) }

    /// Bytes transferred in the current/last transfer.
    public var bytesTransferred: UInt64 { ftp_bytes_transferred(slot) }

    /// Total file count.
    public var fileCount: UInt32 { ftp_file_count(slot) }

    /// The last FTP numeric reply code (e.g. 220, 331, 230).
    public var lastReplyCode: UInt16 { ftp_last_reply_code(slot) }

    /// The current working directory.
    public func currentWorkingDirectory() -> String {
        var buf = [UInt8](repeating: 0, count: 4096)
        let written = ftp_cwd(slot, &buf, UInt32(buf.count))
        return String(bytes: buf.prefix(Int(written)), encoding: .utf8) ?? ""
    }

    /// USER command. Transitions Connected -> UserOk.
    public func user(_ name: String) throws {
        let result = name.withCString { cStr in
            ftp_user(slot, UnsafePointer<UInt8>(OpaquePointer(cStr)), UInt32(name.utf8.count))
        }
        try ProvenError.checkStatus(result)
    }

    /// PASS command. Transitions UserOk -> Authenticated.
    public func pass(_ password: String) throws {
        let result = password.withCString { cStr in
            ftp_pass(slot, UnsafePointer<UInt8>(OpaquePointer(cStr)), UInt32(password.utf8.count))
        }
        try ProvenError.checkStatus(result)
    }

    /// QUIT command.
    public func quitSession() throws {
        try ProvenError.checkStatus(ftp_quit(slot))
    }

    /// CWD command. Changes directory (path validated against traversal).
    public func changeDir(_ path: String) throws {
        let result = path.withCString { cStr in
            ftp_cwd_cmd(slot, UnsafePointer<UInt8>(OpaquePointer(cStr)), UInt32(path.utf8.count))
        }
        try ProvenError.checkStatus(result)
    }

    /// CDUP command. Changes to parent directory.
    public func changeDirUp() throws {
        try ProvenError.checkStatus(ftp_cdup(slot))
    }

    /// TYPE command. Sets transfer type (0=ASCII, 1=binary).
    public func setType(_ typeTag: UInt8) throws {
        try ProvenError.checkStatus(ftp_set_type(slot, typeTag))
    }

    /// PASV command. Sets passive data mode.
    public func setPassive() throws {
        try ProvenError.checkStatus(ftp_set_passive(slot))
    }

    /// PORT command. Sets active data mode with the given port.
    public func setActive(port: UInt16) throws {
        try ProvenError.checkStatus(ftp_set_active(slot, port))
    }

    /// Begin a data transfer.
    public func beginTransfer() throws {
        try ProvenError.checkStatus(ftp_begin_transfer(slot))
    }

    /// Add bytes to the transfer counter.
    public func addBytes(_ count: UInt64) throws {
        try ProvenError.checkStatus(ftp_add_bytes(slot, count))
    }

    /// Complete a data transfer.
    public func completeTransfer() throws {
        try ProvenError.checkStatus(ftp_complete_transfer(slot))
    }

    /// Abort a data transfer.
    public func abortTransfer() throws {
        try ProvenError.checkStatus(ftp_abort_transfer(slot))
    }

    /// RNFR: begin rename operation. Transitions Authenticated -> Renaming.
    public func beginRename() throws {
        try ProvenError.checkStatus(ftp_begin_rename(slot))
    }

    /// RNTO: complete rename operation. Transitions Renaming -> Authenticated.
    public func completeRename() throws {
        try ProvenError.checkStatus(ftp_complete_rename(slot))
    }

    /// Stateless query: check if transfers are allowed from the given state.
    public static func canTransfer(from state: FtpSessionState) -> Bool {
        ftp_can_transfer(state.tag) == 1
    }

    /// Stateless query: check whether a session state transition is valid.
    public static func canTransition(from: FtpSessionState, to: FtpSessionState) -> Bool {
        ftp_can_transition(from.tag, to.tag) == 1
    }
}
