// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// FTP protocol bindings for proven-servers.
//
// Wraps the C-ABI functions from protocols/proven-ftp/ffi/zig/src/ftp.zig.
// Lifecycle: create -> user -> pass -> set_type/mode -> transfer -> quit.
package proven

/*
#cgo LDFLAGS: -lproven_ftp
#include <stdint.h>

extern uint32_t ftp_abi_version();
extern int ftp_create();
extern void ftp_destroy(int slot);
extern uint8_t ftp_state(int slot);
extern uint8_t ftp_transfer_type(int slot);
extern uint8_t ftp_data_mode(int slot);
extern uint8_t ftp_transfer_state(int slot);
extern uint64_t ftp_bytes_transferred(int slot);
extern uint32_t ftp_file_count(int slot);
extern uint16_t ftp_last_reply_code(int slot);
extern uint32_t ftp_cwd(int slot, uint8_t *buf, uint32_t buf_len);
extern uint8_t ftp_user(int slot, const uint8_t *name, uint32_t len);
extern uint8_t ftp_pass(int slot, const uint8_t *pass, uint32_t len);
extern uint8_t ftp_quit(int slot);
extern uint8_t ftp_cwd_cmd(int slot, const uint8_t *path, uint32_t path_len);
extern uint8_t ftp_cdup(int slot);
extern uint8_t ftp_set_type(int slot, uint8_t type_tag);
extern uint8_t ftp_set_passive(int slot);
extern uint8_t ftp_set_active(int slot, uint16_t port);
extern uint8_t ftp_begin_transfer(int slot);
extern uint8_t ftp_add_bytes(int slot, uint64_t count);
extern uint8_t ftp_complete_transfer(int slot);
extern uint8_t ftp_abort_transfer(int slot);
extern uint8_t ftp_begin_rename(int slot);
extern uint8_t ftp_complete_rename(int slot);
extern uint8_t ftp_can_transfer(uint8_t state_tag);
extern uint8_t ftp_can_transition(uint8_t from, uint8_t to);
*/
import "C"
import "unsafe"

// FtpSessionState represents the FTP session lifecycle state.
// Tags match SessionState in ftp.zig.
type FtpSessionState uint8

const (
	FtpConnected     FtpSessionState = iota // TCP connection established
	FtpUserOk                               // USER accepted, password required
	FtpAuthenticated                        // Fully authenticated
	FtpRenaming                             // Rename in progress (RNFR sent)
	FtpQuit                                 // Session ended
)

// FtpTransferState represents the FTP transfer sub-state.
type FtpTransferState uint8

const (
	FtpTransferIdle       FtpTransferState = iota // No transfer in progress
	FtpTransferInProgress                         // Transfer active
	FtpTransferCompleted                          // Transfer completed
	FtpTransferAborted                            // Transfer was aborted
)

// FtpContext wraps a slot in the proven-ftp context pool.
type FtpContext struct {
	slot C.int
}

// FtpABIVersion returns the ABI version.
func FtpABIVersion() uint32 {
	return uint32(C.ftp_abi_version())
}

// FtpCreate allocates a new FTP session in the Connected state.
func FtpCreate() (*FtpContext, error) {
	slot := C.ftp_create()
	s, err := slotError(slot)
	if err != nil {
		return nil, err
	}
	return &FtpContext{slot: C.int(s)}, nil
}

// Close releases the FTP context slot.
func (ctx *FtpContext) Close() {
	C.ftp_destroy(ctx.slot)
}

// State returns the current session state.
func (ctx *FtpContext) State() (FtpSessionState, bool) {
	tag := C.ftp_state(ctx.slot)
	if tag > 4 {
		return 0, false
	}
	return FtpSessionState(tag), true
}

// TransferType returns the transfer type tag (0=ASCII, 1=binary).
func (ctx *FtpContext) TransferType() uint8 {
	return uint8(C.ftp_transfer_type(ctx.slot))
}

// DataMode returns the data mode tag (0=active, 1=passive, 255=unset).
func (ctx *FtpContext) DataMode() uint8 {
	return uint8(C.ftp_data_mode(ctx.slot))
}

// TransferState returns the current transfer state.
func (ctx *FtpContext) TransferState() (FtpTransferState, bool) {
	tag := C.ftp_transfer_state(ctx.slot)
	if tag > 3 {
		return 0, false
	}
	return FtpTransferState(tag), true
}

// BytesTransferred returns the bytes transferred in the current/last transfer.
func (ctx *FtpContext) BytesTransferred() uint64 {
	return uint64(C.ftp_bytes_transferred(ctx.slot))
}

// FileCount returns the total file count.
func (ctx *FtpContext) FileCount() uint32 {
	return uint32(C.ftp_file_count(ctx.slot))
}

// LastReplyCode returns the last FTP numeric reply code (e.g. 220, 331).
func (ctx *FtpContext) LastReplyCode() uint16 {
	return uint16(C.ftp_last_reply_code(ctx.slot))
}

// Cwd copies the current working directory into buf. Returns bytes written.
func (ctx *FtpContext) Cwd(buf []byte) int {
	if len(buf) == 0 {
		return 0
	}
	return int(C.ftp_cwd(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&buf[0])), C.uint32_t(len(buf))))
}

// User sends the USER command. Transitions Connected -> UserOk.
func (ctx *FtpContext) User(name string) error {
	b := []byte(name)
	return statusError(C.ftp_user(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&b[0])), C.uint32_t(len(b))))
}

// Pass sends the PASS command. Transitions UserOk -> Authenticated.
func (ctx *FtpContext) Pass(password string) error {
	b := []byte(password)
	return statusError(C.ftp_pass(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&b[0])), C.uint32_t(len(b))))
}

// Quit sends the QUIT command. Transitions to Quit.
func (ctx *FtpContext) Quit() error {
	return statusError(C.ftp_quit(ctx.slot))
}

// ChangeDir sends the CWD command. Path is validated against traversal.
func (ctx *FtpContext) ChangeDir(path string) error {
	b := []byte(path)
	return statusError(C.ftp_cwd_cmd(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&b[0])), C.uint32_t(len(b))))
}

// ChangeDirUp sends the CDUP command. Changes to parent directory.
func (ctx *FtpContext) ChangeDirUp() error {
	return statusError(C.ftp_cdup(ctx.slot))
}

// SetType sets the transfer type (0=ASCII, 1=binary).
func (ctx *FtpContext) SetType(typeTag uint8) error {
	return statusError(C.ftp_set_type(ctx.slot, C.uint8_t(typeTag)))
}

// SetPassive sets passive data mode.
func (ctx *FtpContext) SetPassive() error {
	return statusError(C.ftp_set_passive(ctx.slot))
}

// SetActive sets active data mode with the given port.
func (ctx *FtpContext) SetActive(port uint16) error {
	return statusError(C.ftp_set_active(ctx.slot, C.uint16_t(port)))
}

// BeginTransfer begins a data transfer.
func (ctx *FtpContext) BeginTransfer() error {
	return statusError(C.ftp_begin_transfer(ctx.slot))
}

// AddBytes adds bytes to the transfer counter.
func (ctx *FtpContext) AddBytes(count uint64) error {
	return statusError(C.ftp_add_bytes(ctx.slot, C.uint64_t(count)))
}

// CompleteTransfer completes a data transfer.
func (ctx *FtpContext) CompleteTransfer() error {
	return statusError(C.ftp_complete_transfer(ctx.slot))
}

// AbortTransfer aborts a data transfer.
func (ctx *FtpContext) AbortTransfer() error {
	return statusError(C.ftp_abort_transfer(ctx.slot))
}

// BeginRename starts a rename operation (RNFR). Authenticated -> Renaming.
func (ctx *FtpContext) BeginRename() error {
	return statusError(C.ftp_begin_rename(ctx.slot))
}

// CompleteRename finishes rename (RNTO). Renaming -> Authenticated.
func (ctx *FtpContext) CompleteRename() error {
	return statusError(C.ftp_complete_rename(ctx.slot))
}

// FtpCanTransfer checks if transfers are allowed from the given state.
func FtpCanTransfer(state FtpSessionState) bool {
	return C.ftp_can_transfer(C.uint8_t(state)) == 1
}

// FtpCanTransition checks whether a session state transition is valid.
func FtpCanTransition(from, to FtpSessionState) bool {
	return C.ftp_can_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}
