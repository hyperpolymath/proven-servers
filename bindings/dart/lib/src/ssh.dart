// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// SSH Bastion protocol bindings for proven-servers.
///
/// Mirrors the Idris2 module `SshBastionABI.Types`. All discriminant
/// values match the Idris2 ABI tag definitions exactly.
///
/// See `protocols/proven-ssh-bastion/src/` for the Idris2 definitions.

import 'dart:ffi';

import 'error.dart';
import 'ffi.dart';

// ---------------------------------------------------------------------------
// SSH Constants
// ---------------------------------------------------------------------------

/// Standard SSH port (RFC 4253).
const int sshPort = 22;

// ---------------------------------------------------------------------------
// SshMessageType (tags 0-7)
// ---------------------------------------------------------------------------

/// SSH message types.
///
/// Matches `SshMessageType` in `SshBastionABI.Types`.
enum SshMessageType {
  kexinit(0),
  newkeys(1),
  serviceRequest(2),
  userauthRequest(3),
  channelOpen(4),
  channelData(5),
  channelClose(6),
  disconnect(7);

  final int tag;
  const SshMessageType(this.tag);

  static SshMessageType? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// AuthMethod (tags 0-3)
// ---------------------------------------------------------------------------

/// SSH authentication methods.
enum SshAuthMethod {
  password(0),
  publicKey(1),
  keyboardInteractive(2),
  none(3);

  final int tag;
  const SshAuthMethod(this.tag);

  static SshAuthMethod? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// KexMethod (tags 0-5)
// ---------------------------------------------------------------------------

/// SSH key exchange methods.
enum SshKexMethod {
  curve25519Sha256(0),
  ecdhSha2Nistp256(1),
  ecdhSha2Nistp384(2),
  ecdhSha2Nistp521(3),
  diffieHellmanGroup14Sha256(4),
  diffieHellmanGroup16Sha512(5);

  final int tag;
  const SshKexMethod(this.tag);

  static SshKexMethod? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// ChannelType (tags 0-3)
// ---------------------------------------------------------------------------

/// SSH channel types.
enum SshChannelType {
  session(0),
  directTcpip(1),
  forwardedTcpip(2),
  x11(3);

  final int tag;
  const SshChannelType(this.tag);

  static SshChannelType? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// BastionState (tags 0-5)
// ---------------------------------------------------------------------------

/// SSH bastion connection state machine.
enum SshBastionState {
  initial(0),
  kexInProgress(1),
  authenticated(2),
  channelOpen(3),
  dataTransfer(4),
  disconnected(5);

  final int tag;
  const SshBastionState(this.tag);

  static SshBastionState? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// HostKeyAlgorithm (tags 0-3)
// ---------------------------------------------------------------------------

/// SSH host key algorithms.
enum SshHostKeyAlgorithm {
  sshEd25519(0),
  ecdsaSha2Nistp256(1),
  rsaSha2_256(2),
  rsaSha2_512(3);

  final int tag;
  const SshHostKeyAlgorithm(this.tag);

  static SshHostKeyAlgorithm? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// CipherAlgorithm (tags 0-5)
// ---------------------------------------------------------------------------

/// SSH symmetric cipher algorithms.
enum SshCipherAlgorithm {
  chacha20Poly1305(0),
  aes256Gcm(1),
  aes128Gcm(2),
  aes256Ctr(3),
  aes192Ctr(4),
  aes128Ctr(5);

  final int tag;
  const SshCipherAlgorithm(this.tag);

  static SshCipherAlgorithm? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// DisconnectReason (tags 0-11)
// ---------------------------------------------------------------------------

/// SSH disconnect reason codes (RFC 4253 Section 11.1).
enum SshDisconnectReason {
  hostNotAllowed(0),
  protocolError(1),
  keyExchangeFailed(2),
  reserved(3),
  macError(4),
  compressionError(5),
  serviceNotAvailable(6),
  protocolVersion(7),
  hostKeyNotVerifiable(8),
  connectionLost(9),
  byApplication(10),
  tooManyConnections(11);

  final int tag;
  const SshDisconnectReason(this.tag);

  static SshDisconnectReason? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// ChannelOpenFailure (tags 0-3)
// ---------------------------------------------------------------------------

/// SSH channel open failure reasons.
enum SshChannelOpenFailure {
  administrativelyProhibited(0),
  connectFailed(1),
  unknownChannelType(2),
  resourceShortage(3);

  final int tag;
  const SshChannelOpenFailure(this.tag);

  static SshChannelOpenFailure? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// SshContext — safe wrapper with dispose pattern
// ---------------------------------------------------------------------------

/// An SSH context slot in the Zig FFI pool.
///
/// Wraps the `ssh_*` C functions with automatic resource cleanup.
class SshContext {
  final ProvenFfi _ffi;
  final int _slot;
  bool _disposed = false;

  late final _destroy = _ffi.lookupDestroyContext('ssh_destroy_context');
  late final _getState = _ffi.lookupGetTag('ssh_get_state');
  late final _setAuthMethod = _ffi.lookupSetTag('ssh_set_auth_method');
  late final _setKexMethod = _ffi.lookupSetTag('ssh_set_kex_method');
  late final _getMessageType = _ffi.lookupGetTag('ssh_get_message_type');

  SshContext._(this._ffi, this._slot);

  /// Create a new SSH context.
  ///
  /// Throws [ProvenError] if the pool is exhausted.
  factory SshContext.create(ProvenFfi ffi) {
    final create = ffi.lookupCreateContext('ssh_create_context');
    final slot = ProvenError.checkSlot(create());
    return SshContext._(ffi, slot);
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

  /// Get the current bastion state.
  SshBastionState? getState() {
    _checkDisposed();
    return SshBastionState.fromTag(_getState(_slot));
  }

  /// Set the authentication method.
  ///
  /// Throws [ProvenError] on invalid parameter.
  void setAuthMethod(SshAuthMethod method) {
    _checkDisposed();
    ProvenError.checkParamStatus(_setAuthMethod(_slot, method.tag));
  }

  /// Set the key exchange method.
  ///
  /// Throws [ProvenError] on invalid parameter.
  void setKexMethod(SshKexMethod method) {
    _checkDisposed();
    ProvenError.checkParamStatus(_setKexMethod(_slot, method.tag));
  }

  /// Get the last processed message type.
  SshMessageType? getMessageType() {
    _checkDisposed();
    return SshMessageType.fromTag(_getMessageType(_slot));
  }
}
