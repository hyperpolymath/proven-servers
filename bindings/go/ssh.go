// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// SSH Bastion protocol bindings for proven-servers.
//
// Wraps the C-ABI functions from protocols/proven-ssh-bastion/ffi/zig/src/ssh_bastion.zig.
// Lifecycle: create -> complete_kex -> authenticate -> open_channel -> disconnect.
package proven

/*
#cgo LDFLAGS: -lproven_ssh_bastion
#include <stdint.h>

extern uint32_t ssh_bastion_abi_version();
extern int ssh_bastion_create(uint8_t kex_method, uint8_t auth_method);
extern void ssh_bastion_destroy(int slot);
extern uint8_t ssh_bastion_state(int slot);
extern uint8_t ssh_bastion_kex_method(int slot);
extern uint8_t ssh_bastion_auth_method(int slot);
extern uint8_t ssh_bastion_can_transfer(int slot);
extern uint8_t ssh_bastion_disconnect_reason(int slot);
extern uint8_t ssh_bastion_auth_failures(int slot);
extern uint8_t ssh_bastion_complete_kex(int slot);
extern uint8_t ssh_bastion_authenticate(int slot, uint16_t user_len);
extern uint8_t ssh_bastion_record_auth_failure(int slot);
extern int ssh_bastion_open_channel(int slot, uint8_t ch_type);
extern uint8_t ssh_bastion_confirm_channel(int slot, uint8_t ch_id);
extern uint8_t ssh_bastion_close_channel(int slot, uint8_t ch_id);
extern uint8_t ssh_bastion_channel_state(int slot, uint8_t ch_id);
extern uint8_t ssh_bastion_channel_type(int slot, uint8_t ch_id);
extern uint8_t ssh_bastion_channel_count(int slot);
extern uint8_t ssh_bastion_rekey(int slot);
extern uint8_t ssh_bastion_disconnect(int slot, uint8_t reason);
extern uint8_t ssh_bastion_can_transition(uint8_t from, uint8_t to);
extern uint32_t ssh_bastion_audit_count(int slot);
extern uint8_t ssh_bastion_audit_entry(int slot, uint32_t entry_idx);
extern uint8_t ssh_bastion_audit_entry_to(int slot, uint32_t entry_idx);
extern uint8_t ssh_bastion_set_recording(int slot, uint8_t enabled);
extern uint8_t ssh_bastion_is_recording(int slot);
*/
import "C"

// BastionState represents the SSH bastion connection state.
// Tags match BastionState in the Idris2 ABI (tags 0-5).
type BastionState uint8

const (
	SshConnected     BastionState = iota // TCP connected
	SshKeyExchanged                      // Key exchange completed
	SshAuthenticated                     // User authenticated
	SshChannelOpen                       // First channel opened
	SshActive                            // Active session (channels confirmed)
	SshClosed                            // Disconnected
)

// SshKexMethod represents an SSH key exchange method (tags 0-5).
type SshKexMethod uint8

const (
	KexCurve25519   SshKexMethod = iota // curve25519-sha256
	KexEcdhSha2P256                     // ecdh-sha2-nistp256
	KexEcdhSha2P384                     // ecdh-sha2-nistp384
	KexEcdhSha2P521                     // ecdh-sha2-nistp521
	KexDhGroup14                         // diffie-hellman-group14-sha256
	KexDhGroup16                        // diffie-hellman-group16-sha512
)

// SshAuthMethod represents an SSH authentication method (tags 0-3).
type SshAuthMethod uint8

const (
	AuthPublicKey SshAuthMethod = iota // Public key
	AuthPassword                       // Password
	AuthKeyboard                       // Keyboard-interactive
	AuthNone                           // None (for banner exchange)
)

// SshChannelType represents an SSH channel type (tags 0-3).
type SshChannelType uint8

const (
	ChannelSession  SshChannelType = iota // Session channel
	ChannelDirect                         // Direct TCP/IP
	ChannelForwarded                      // Forwarded TCP/IP
	ChannelX11                            // X11 forwarding
)

// SshChannelState represents the per-channel state (tags 0-3).
type SshChannelState uint8

const (
	ChannelOpening SshChannelState = iota // Channel opening
	ChannelOpenSt                         // Channel open
	ChannelClosing                        // Channel closing
	ChannelClosedSt                       // Channel closed
)

// SshDisconnectReason represents SSH disconnect reason codes (tags 0-11).
type SshDisconnectReason uint8

const (
	DisconnectByApp        SshDisconnectReason = iota // Disconnected by application
	DisconnectProtocolErr                             // Protocol error
	DisconnectKeyExchange                             // Key exchange failed
	DisconnectReserved                                // Reserved
	DisconnectMacError                                // MAC error
	DisconnectCompression                             // Compression error
	DisconnectServiceNA                               // Service not available
	DisconnectProtocolVer                             // Protocol version not supported
	DisconnectHostKeyNA                               // Host key not verifiable
	DisconnectConnLost                                // Connection lost
	DisconnectAuthCancel                              // Auth cancelled by user
	DisconnectTooManyConns                            // Too many connections
)

// SshBastionContext wraps a slot in the proven-ssh-bastion context pool.
type SshBastionContext struct {
	slot C.int
}

// SshABIVersion returns the ABI version.
func SshABIVersion() uint32 {
	return uint32(C.ssh_bastion_abi_version())
}

// SshCreate allocates a new SSH bastion session with the given kex and auth methods.
func SshCreate(kex SshKexMethod, auth SshAuthMethod) (*SshBastionContext, error) {
	slot := C.ssh_bastion_create(C.uint8_t(kex), C.uint8_t(auth))
	s, err := slotError(slot)
	if err != nil {
		return nil, err
	}
	return &SshBastionContext{slot: C.int(s)}, nil
}

// Close releases the SSH bastion context slot.
func (ctx *SshBastionContext) Close() {
	C.ssh_bastion_destroy(ctx.slot)
}

// State returns the current bastion state.
func (ctx *SshBastionContext) State() (BastionState, bool) {
	tag := C.ssh_bastion_state(ctx.slot)
	if tag > 5 {
		return 0, false
	}
	return BastionState(tag), true
}

// KexMethod returns the configured key exchange method.
func (ctx *SshBastionContext) KexMethod() (SshKexMethod, bool) {
	tag := C.ssh_bastion_kex_method(ctx.slot)
	if tag > 5 {
		return 0, false
	}
	return SshKexMethod(tag), true
}

// AuthMethod returns the configured authentication method.
func (ctx *SshBastionContext) AuthMethod() (SshAuthMethod, bool) {
	tag := C.ssh_bastion_auth_method(ctx.slot)
	if tag > 3 {
		return 0, false
	}
	return SshAuthMethod(tag), true
}

// CanTransferData checks if data transfer is allowed (Active state).
func (ctx *SshBastionContext) CanTransferData() bool {
	return C.ssh_bastion_can_transfer(ctx.slot) == 1
}

// DisconnectReason returns the disconnect reason, or false if not disconnected.
func (ctx *SshBastionContext) DisconnectReason() (SshDisconnectReason, bool) {
	tag := C.ssh_bastion_disconnect_reason(ctx.slot)
	if tag > 11 {
		return 0, false
	}
	return SshDisconnectReason(tag), true
}

// AuthFailures returns the number of failed auth attempts.
func (ctx *SshBastionContext) AuthFailures() uint8 {
	return uint8(C.ssh_bastion_auth_failures(ctx.slot))
}

// CompleteKex completes key exchange. Transitions Connected -> KeyExchanged.
func (ctx *SshBastionContext) CompleteKex() error {
	return statusError(C.ssh_bastion_complete_kex(ctx.slot))
}

// Authenticate authenticates the user. Transitions KeyExchanged -> Authenticated.
func (ctx *SshBastionContext) Authenticate() error {
	return statusError(C.ssh_bastion_authenticate(ctx.slot, 0))
}

// RecordAuthFailure records a failed auth attempt. Returns true if locked out (3+).
func (ctx *SshBastionContext) RecordAuthFailure() bool {
	return C.ssh_bastion_record_auth_failure(ctx.slot) == 1
}

// OpenChannel opens a channel. Returns the channel ID (0-9).
func (ctx *SshBastionContext) OpenChannel(chType SshChannelType) (uint8, error) {
	chID := C.ssh_bastion_open_channel(ctx.slot, C.uint8_t(chType))
	s, err := slotError(chID)
	if err != nil {
		return 0, err
	}
	return uint8(s), nil
}

// ConfirmChannel confirms a channel (Opening -> Open).
func (ctx *SshBastionContext) ConfirmChannel(chID uint8) error {
	return statusError(C.ssh_bastion_confirm_channel(ctx.slot, C.uint8_t(chID)))
}

// CloseChannel closes a specific channel.
func (ctx *SshBastionContext) CloseChannel(chID uint8) error {
	return statusError(C.ssh_bastion_close_channel(ctx.slot, C.uint8_t(chID)))
}

// ChannelState returns the state of a specific channel.
func (ctx *SshBastionContext) ChannelState(chID uint8) (SshChannelState, bool) {
	tag := C.ssh_bastion_channel_state(ctx.slot, C.uint8_t(chID))
	if tag > 3 {
		return 0, false
	}
	return SshChannelState(tag), true
}

// ChannelType returns the type of a specific channel.
func (ctx *SshBastionContext) ChannelType(chID uint8) (SshChannelType, bool) {
	tag := C.ssh_bastion_channel_type(ctx.slot, C.uint8_t(chID))
	if tag > 3 {
		return 0, false
	}
	return SshChannelType(tag), true
}

// ChannelCount returns the count of active (non-closed) channels.
func (ctx *SshBastionContext) ChannelCount() uint8 {
	return uint8(C.ssh_bastion_channel_count(ctx.slot))
}

// Rekey re-keys the session. Only valid in Active state.
func (ctx *SshBastionContext) Rekey() error {
	return statusError(C.ssh_bastion_rekey(ctx.slot))
}

// Disconnect disconnects with a reason. Transitions any non-Closed -> Closed.
func (ctx *SshBastionContext) Disconnect(reason SshDisconnectReason) error {
	return statusError(C.ssh_bastion_disconnect(ctx.slot, C.uint8_t(reason)))
}

// SshCanTransition checks whether a bastion state transition is valid.
func SshCanTransition(from, to BastionState) bool {
	return C.ssh_bastion_can_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}

// AuditCount returns the number of audit log entries.
func (ctx *SshBastionContext) AuditCount() uint32 {
	return uint32(C.ssh_bastion_audit_count(ctx.slot))
}

// AuditEntryFrom reads the from_state of an audit log entry.
func (ctx *SshBastionContext) AuditEntryFrom(index uint32) (BastionState, bool) {
	tag := C.ssh_bastion_audit_entry(ctx.slot, C.uint32_t(index))
	if tag > 5 {
		return 0, false
	}
	return BastionState(tag), true
}

// AuditEntryTo reads the to_state of an audit log entry.
func (ctx *SshBastionContext) AuditEntryTo(index uint32) (BastionState, bool) {
	tag := C.ssh_bastion_audit_entry_to(ctx.slot, C.uint32_t(index))
	if tag > 5 {
		return 0, false
	}
	return BastionState(tag), true
}

// SetRecording enables or disables session recording.
func (ctx *SshBastionContext) SetRecording(enabled bool) error {
	var e C.uint8_t
	if enabled {
		e = 1
	}
	return statusError(C.ssh_bastion_set_recording(ctx.slot, e))
}

// IsRecording checks whether session recording is active.
func (ctx *SshBastionContext) IsRecording() bool {
	return C.ssh_bastion_is_recording(ctx.slot) == 1
}
