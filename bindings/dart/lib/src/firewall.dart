// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// Firewall (netfilter) bindings for proven-servers.
///
/// Mirrors the Idris2 module `FirewallABI.Types`. Tag values match the
/// ABI definitions for `Action`, `Protocol`, `ChainType`,
/// `RuleMatchType`, and `ConnState`.
///
/// See `protocols/proven-firewall/src/` for the Idris2 definitions.

import 'dart:ffi';

import 'error.dart';
import 'ffi.dart';

// ---------------------------------------------------------------------------
// Action (tags 0-7)
// ---------------------------------------------------------------------------

/// Firewall rule actions.
///
/// Matches `Action` in `FirewallABI.Types`.
enum FirewallAction {
  accept(0),
  drop(1),
  reject(2),
  log(3),
  redirect(4),
  dnat(5),
  snat(6),
  masquerade(7);

  final int tag;
  const FirewallAction(this.tag);

  static FirewallAction? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// Protocol (tags 0-5)
// ---------------------------------------------------------------------------

/// Network protocols for firewall rules.
enum FirewallProtocol {
  tcp(0),
  udp(1),
  icmp(2),
  sctp(3),
  gre(4),
  any(5);

  final int tag;
  const FirewallProtocol(this.tag);

  static FirewallProtocol? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// ChainType (tags 0-4)
// ---------------------------------------------------------------------------

/// Firewall chain types (netfilter).
enum FirewallChainType {
  input(0),
  output(1),
  forward(2),
  prerouting(3),
  postrouting(4);

  final int tag;
  const FirewallChainType(this.tag);

  static FirewallChainType? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// RuleMatchType (tags 0-5)
// ---------------------------------------------------------------------------

/// Firewall rule match criteria types.
enum FirewallRuleMatchType {
  sourceIp(0),
  destIp(1),
  sourcePort(2),
  destPort(3),
  protocol(4),
  connState(5);

  final int tag;
  const FirewallRuleMatchType(this.tag);

  static FirewallRuleMatchType? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// ConnState (tags 0-3)
// ---------------------------------------------------------------------------

/// Connection tracking states.
enum FirewallConnState {
  new_(0),
  established(1),
  related(2),
  invalid(3);

  final int tag;
  const FirewallConnState(this.tag);

  static FirewallConnState? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// FirewallContext — safe wrapper with dispose pattern
// ---------------------------------------------------------------------------

/// A firewall context slot in the Zig FFI pool.
///
/// Wraps the `firewall_*` C functions with automatic resource cleanup.
class FirewallContext {
  final ProvenFfi _ffi;
  final int _slot;
  bool _disposed = false;

  late final _destroy = _ffi.lookupDestroyContext('firewall_destroy_context');
  late final _getAction = _ffi.lookupGetTag('firewall_get_action');

  FirewallContext._(this._ffi, this._slot);

  /// Create a new Firewall context.
  ///
  /// Throws [ProvenError] if the pool is exhausted.
  factory FirewallContext.create(ProvenFfi ffi) {
    final create = ffi.lookupCreateContext('firewall_create_context');
    final slot = ProvenError.checkSlot(create());
    return FirewallContext._(ffi, slot);
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

  /// Get the action resulting from the last rule evaluation.
  FirewallAction? getAction() {
    _checkDisposed();
    return FirewallAction.fromTag(_getAction(_slot));
  }
}
