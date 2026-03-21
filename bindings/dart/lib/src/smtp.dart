// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// SMTP protocol bindings for proven-servers.
///
/// Mirrors the Idris2 module `SmtpABI.Types`. Tag values match the ABI
/// definitions for `SmtpCommand`, `SmtpSessionState`, `ReplyCategory`,
/// `AuthMechanism`, and `SmtpExtension`.
///
/// See `protocols/proven-smtp/src/` for the Idris2 definitions.

import 'dart:ffi';

import 'error.dart';
import 'ffi.dart';

// ---------------------------------------------------------------------------
// SMTP Constants
// ---------------------------------------------------------------------------

/// Standard SMTP port (RFC 5321).
const int smtpPort = 25;

/// SMTP submission port (RFC 6409).
const int submissionPort = 587;

/// SMTPS (implicit TLS) port.
const int smtpsPort = 465;

// ---------------------------------------------------------------------------
// SmtpCommand (tags 0-11)
// ---------------------------------------------------------------------------

/// SMTP protocol commands (RFC 5321).
///
/// Tag values match `SmtpCommandTag` in `SmtpABI.Types`.
enum SmtpCommand {
  helo(0, 'HELO'),
  ehlo(1, 'EHLO'),
  mailFrom(2, 'MAIL FROM'),
  rcptTo(3, 'RCPT TO'),
  data(4, 'DATA'),
  quit(5, 'QUIT'),
  rset(6, 'RSET'),
  noop(7, 'NOOP'),
  vrfy(8, 'VRFY'),
  expn(9, 'EXPN'),
  auth(10, 'AUTH'),
  starttls(11, 'STARTTLS');

  final int tag;
  final String keyword;
  const SmtpCommand(this.tag, this.keyword);

  static SmtpCommand? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// SmtpSessionState (tags 0-8)
// ---------------------------------------------------------------------------

/// SMTP session state machine.
enum SmtpSessionState {
  connected(0),
  greeted(1),
  mailStarted(2),
  rcptAdded(3),
  dataMode(4),
  dataDone(5),
  authStarted(6),
  authComplete(7),
  quitSent(8);

  final int tag;
  const SmtpSessionState(this.tag);

  static SmtpSessionState? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// AuthMechanism (tags 0-3)
// ---------------------------------------------------------------------------

/// SASL authentication mechanisms.
enum SmtpAuthMechanism {
  plain(0),
  login(1),
  cramMd5(2),
  xoauth2(3);

  final int tag;
  const SmtpAuthMechanism(this.tag);

  static SmtpAuthMechanism? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// SmtpExtension (tags 0-6)
// ---------------------------------------------------------------------------

/// ESMTP extensions.
enum SmtpExtension {
  eightBitMime(0),
  pipelining(1),
  size(2),
  starttls(3),
  auth(4),
  chunking(5),
  dsn(6);

  final int tag;
  const SmtpExtension(this.tag);

  static SmtpExtension? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// ReplyCategory (tags 0-3)
// ---------------------------------------------------------------------------

/// SMTP reply severity categories.
enum SmtpReplyCategory {
  positiveCompletion(0),
  positiveIntermediate(1),
  negativeTransient(2),
  negativePermanent(3);

  final int tag;
  const SmtpReplyCategory(this.tag);

  static SmtpReplyCategory? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// SmtpContext — safe wrapper with dispose pattern
// ---------------------------------------------------------------------------

/// An SMTP context slot in the Zig FFI pool.
///
/// Wraps the `smtp_*` C functions with automatic resource cleanup.
class SmtpContext {
  final ProvenFfi _ffi;
  final int _slot;
  bool _disposed = false;

  late final _destroy = _ffi.lookupDestroyContext('smtp_destroy_context');
  late final _getCommand = _ffi.lookupGetTag('smtp_get_command');
  late final _getState = _ffi.lookupGetTag('smtp_get_state');
  late final _sendReply = _ffi.lookupSend('smtp_send_reply');

  SmtpContext._(this._ffi, this._slot);

  /// Create a new SMTP context.
  ///
  /// Throws [ProvenError] if the pool is exhausted.
  factory SmtpContext.create(ProvenFfi ffi) {
    final create = ffi.lookupCreateContext('smtp_create_context');
    final slot = ProvenError.checkSlot(create());
    return SmtpContext._(ffi, slot);
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

  /// Get the parsed SMTP command.
  SmtpCommand? getCommand() {
    _checkDisposed();
    return SmtpCommand.fromTag(_getCommand(_slot));
  }

  /// Get the current session state.
  SmtpSessionState? getState() {
    _checkDisposed();
    return SmtpSessionState.fromTag(_getState(_slot));
  }

  /// Send the constructed reply.
  ///
  /// Throws [ProvenError] on failure.
  void sendReply() {
    _checkDisposed();
    ProvenError.checkStatus(_sendReply(_slot));
  }
}
