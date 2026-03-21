// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// FTP protocol bindings for proven-servers.
///
/// Mirrors the Idris2 module `FtpABI.Types`. Tag values match the ABI
/// definitions for `SessionState`, `TransferType`, `DataMode`,
/// `TransferState`, `ReplyCategory`, and `Command`.
///
/// See `protocols/proven-ftp/src/` for the Idris2 definitions.

import 'dart:ffi';

import 'error.dart';
import 'ffi.dart';

// ---------------------------------------------------------------------------
// FTP Constants
// ---------------------------------------------------------------------------

/// Standard FTP control port (RFC 959).
const int ftpControlPort = 21;

/// Standard FTP data port (RFC 959).
const int ftpDataPort = 20;

/// FTPS (implicit TLS) control port.
const int ftpsPort = 990;

// ---------------------------------------------------------------------------
// SessionState (tags 0-4)
// ---------------------------------------------------------------------------

/// FTP session state machine.
///
/// Matches `SessionState` in `FtpABI.Types`.
enum FtpSessionState {
  connected(0),
  userOk(1),
  authenticated(2),
  renaming(3),
  quit(4);

  final int tag;
  const FtpSessionState(this.tag);

  static FtpSessionState? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// TransferType (tags 0-1)
// ---------------------------------------------------------------------------

/// FTP data transfer types.
enum FtpTransferType {
  ascii(0),
  binary(1);

  final int tag;
  const FtpTransferType(this.tag);

  static FtpTransferType? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// DataMode (tags 0-1)
// ---------------------------------------------------------------------------

/// FTP data connection modes.
enum FtpDataMode {
  active(0),
  passive(1);

  final int tag;
  const FtpDataMode(this.tag);

  static FtpDataMode? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// TransferState (tags 0-3)
// ---------------------------------------------------------------------------

/// FTP file transfer state machine.
enum FtpTransferState {
  idle(0),
  inProgress(1),
  complete(2),
  aborted(3);

  final int tag;
  const FtpTransferState(this.tag);

  static FtpTransferState? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// Command (tags 0-22)
// ---------------------------------------------------------------------------

/// FTP commands (RFC 959).
///
/// Matches `Command` in `FtpABI.Types`.
enum FtpCommand {
  user(0, 'USER'),
  pass_(1, 'PASS'),
  acct(2, 'ACCT'),
  cwd(3, 'CWD'),
  cdup(4, 'CDUP'),
  quit(5, 'QUIT'),
  port(6, 'PORT'),
  pasv(7, 'PASV'),
  type_(8, 'TYPE'),
  retr(9, 'RETR'),
  stor(10, 'STOR'),
  appe(11, 'APPE'),
  rnfr(12, 'RNFR'),
  rnto(13, 'RNTO'),
  dele(14, 'DELE'),
  rmd(15, 'RMD'),
  mkd(16, 'MKD'),
  pwd(17, 'PWD'),
  list_(18, 'LIST'),
  nlst(19, 'NLST'),
  syst(20, 'SYST'),
  noop(21, 'NOOP'),
  feat(22, 'FEAT');

  final int tag;
  final String keyword;
  const FtpCommand(this.tag, this.keyword);

  static FtpCommand? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// ReplyCategory (tags 0-4)
// ---------------------------------------------------------------------------

/// FTP reply categories (RFC 959 Section 4.2).
enum FtpReplyCategory {
  positivePreliminary(0),
  positiveCompletion(1),
  positiveIntermediate(2),
  negativeTransient(3),
  negativePermanent(4);

  final int tag;
  const FtpReplyCategory(this.tag);

  static FtpReplyCategory? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// FtpContext — safe wrapper with dispose pattern
// ---------------------------------------------------------------------------

/// An FTP context slot in the Zig FFI pool.
///
/// Wraps the `ftp_*` C functions with automatic resource cleanup.
class FtpContext {
  final ProvenFfi _ffi;
  final int _slot;
  bool _disposed = false;

  late final _destroy = _ffi.lookupDestroyContext('ftp_destroy_context');
  late final _getCommand = _ffi.lookupGetTag('ftp_get_command');
  late final _getSessionState = _ffi.lookupGetTag('ftp_get_session_state');
  late final _sendReply = _ffi.lookupSend('ftp_send_reply');

  FtpContext._(this._ffi, this._slot);

  /// Create a new FTP context.
  ///
  /// Throws [ProvenError] if the pool is exhausted.
  factory FtpContext.create(ProvenFfi ffi) {
    final create = ffi.lookupCreateContext('ftp_create_context');
    final slot = ProvenError.checkSlot(create());
    return FtpContext._(ffi, slot);
  }

  /// Release the context slot back to the pool.
  void dispose() {
    if (!_disposed) {
      _destroy(_slot);
      _disposed = true;
    }
  }

  void _checkDisposed() {
    if (_disposed) throw const ProvenError('context already disposed');
  }

  /// Get the parsed FTP command.
  FtpCommand? getCommand() {
    _checkDisposed();
    return FtpCommand.fromTag(_getCommand(_slot));
  }

  /// Get the current session state.
  FtpSessionState? getSessionState() {
    _checkDisposed();
    return FtpSessionState.fromTag(_getSessionState(_slot));
  }

  /// Send the constructed reply.
  ///
  /// Throws [ProvenError] on failure.
  void sendReply() {
    _checkDisposed();
    ProvenError.checkStatus(_sendReply(_slot));
  }
}
