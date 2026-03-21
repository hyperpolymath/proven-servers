// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// SMTP protocol bindings for proven-servers.
//
// Wraps the C-ABI functions from protocols/proven-smtp/ffi/zig/src/smtp.zig.
// Lifecycle: create -> greet -> auth -> set_sender -> add_recipient ->
// start_data -> append_data -> finish_data -> quit.
package proven

/*
#cgo LDFLAGS: -lproven_smtp
#include <stdint.h>

extern uint32_t smtp_abi_version();
extern int smtp_create_context();
extern void smtp_destroy_context(int slot);
extern uint8_t smtp_get_state(int slot);
extern uint8_t smtp_get_reply_code(int slot);
extern uint8_t smtp_get_recipient_count(int slot);
extern uint32_t smtp_get_data_size(int slot);
extern uint8_t smtp_get_auth_mechanism(int slot);
extern uint8_t smtp_is_authenticated(int slot);
extern uint8_t smtp_is_tls_active(int slot);
extern uint8_t smtp_greet(int slot, uint8_t is_ehlo);
extern uint8_t smtp_authenticate(int slot, uint8_t mech);
extern uint8_t smtp_auth_complete(int slot, uint8_t success);
extern uint8_t smtp_set_sender(int slot);
extern uint8_t smtp_add_recipient(int slot);
extern uint8_t smtp_start_data(int slot);
extern uint8_t smtp_append_data(int slot, uint32_t len);
extern uint8_t smtp_finish_data(int slot);
extern uint8_t smtp_reset(int slot);
extern uint8_t smtp_quit(int slot);
extern uint8_t smtp_enable_tls(int slot);
extern uint8_t smtp_can_transition(uint8_t from, uint8_t to);
*/
import "C"

// SmtpSessionState represents the SMTP session lifecycle state.
// Tags match the Idris2 ABI.
type SmtpSessionState uint8

const (
	SmtpConnected     SmtpSessionState = iota // TCP connected
	SmtpGreeted                               // HELO/EHLO accepted
	SmtpAuthStarted                           // AUTH exchange in progress
	SmtpAuthenticated                         // AUTH completed successfully
	SmtpMailFrom                              // MAIL FROM set
	SmtpRcptTo                                // RCPT TO added
	SmtpData                                  // DATA transfer in progress
	SmtpMessageRecvd                          // Message received (end-of-data)
	SmtpQuit                                  // QUIT sent
)

// SmtpAuthMechanism represents an SMTP authentication mechanism.
type SmtpAuthMechanism uint8

const (
	SmtpAuthPlain    SmtpAuthMechanism = iota // PLAIN
	SmtpAuthLogin                             // LOGIN
	SmtpAuthCramMd5                           // CRAM-MD5
	SmtpAuthXOAuth2                           // XOAUTH2
)

// SmtpContext wraps a slot in the proven-smtp context pool.
type SmtpContext struct {
	slot C.int
}

// SmtpABIVersion returns the ABI version.
func SmtpABIVersion() uint32 {
	return uint32(C.smtp_abi_version())
}

// SmtpCreateContext allocates a new SMTP session in the Connected state.
func SmtpCreateContext() (*SmtpContext, error) {
	slot := C.smtp_create_context()
	s, err := slotError(slot)
	if err != nil {
		return nil, err
	}
	return &SmtpContext{slot: C.int(s)}, nil
}

// Close releases the SMTP context slot.
func (ctx *SmtpContext) Close() {
	C.smtp_destroy_context(ctx.slot)
}

// State returns the current session state.
func (ctx *SmtpContext) State() (SmtpSessionState, bool) {
	tag := C.smtp_get_state(ctx.slot)
	if tag > 8 {
		return 0, false
	}
	return SmtpSessionState(tag), true
}

// ReplyCode returns the last reply code tag (0-16, maps to ReplyCode).
func (ctx *SmtpContext) ReplyCode() uint8 {
	return uint8(C.smtp_get_reply_code(ctx.slot))
}

// RecipientCount returns the number of recipients in the current transaction.
func (ctx *SmtpContext) RecipientCount() uint8 {
	return uint8(C.smtp_get_recipient_count(ctx.slot))
}

// DataSize returns the accumulated message data size in bytes.
func (ctx *SmtpContext) DataSize() uint32 {
	return uint32(C.smtp_get_data_size(ctx.slot))
}

// AuthMechanism returns the current AUTH mechanism, or false if unset.
func (ctx *SmtpContext) AuthMechanism() (SmtpAuthMechanism, bool) {
	tag := C.smtp_get_auth_mechanism(ctx.slot)
	if tag > 3 {
		return 0, false
	}
	return SmtpAuthMechanism(tag), true
}

// IsAuthenticated checks if the session is authenticated.
func (ctx *SmtpContext) IsAuthenticated() bool {
	return C.smtp_is_authenticated(ctx.slot) == 1
}

// IsTLSActive checks if TLS is active.
func (ctx *SmtpContext) IsTLSActive() bool {
	return C.smtp_is_tls_active(ctx.slot) == 1
}

// Greet sends HELO/EHLO. Transitions Connected -> Greeted.
// ehlo=true selects EHLO, ehlo=false selects HELO.
func (ctx *SmtpContext) Greet(ehlo bool) error {
	var e C.uint8_t
	if ehlo {
		e = 1
	}
	return statusError(C.smtp_greet(ctx.slot, e))
}

// Authenticate begins AUTH exchange. Transitions Greeted -> AuthStarted.
func (ctx *SmtpContext) Authenticate(mechanism SmtpAuthMechanism) error {
	return statusError(C.smtp_authenticate(ctx.slot, C.uint8_t(mechanism)))
}

// AuthComplete completes AUTH exchange.
// success=true: AuthStarted -> Authenticated.
// success=false: AuthStarted -> Greeted.
func (ctx *SmtpContext) AuthComplete(success bool) error {
	var s C.uint8_t
	if success {
		s = 1
	}
	return statusError(C.smtp_auth_complete(ctx.slot, s))
}

// SetSender sends MAIL FROM. Transitions Greeted/Authenticated -> MailFrom.
func (ctx *SmtpContext) SetSender() error {
	return statusError(C.smtp_set_sender(ctx.slot))
}

// AddRecipient sends RCPT TO. Transitions MailFrom/RcptTo -> RcptTo.
func (ctx *SmtpContext) AddRecipient() error {
	return statusError(C.smtp_add_recipient(ctx.slot))
}

// StartData begins DATA transfer. Transitions RcptTo -> Data.
func (ctx *SmtpContext) StartData() error {
	return statusError(C.smtp_start_data(ctx.slot))
}

// AppendData appends data bytes to the message.
func (ctx *SmtpContext) AppendData(length uint32) error {
	return statusError(C.smtp_append_data(ctx.slot, C.uint32_t(length)))
}

// FinishData finishes data transfer. Transitions Data -> MessageReceived.
func (ctx *SmtpContext) FinishData() error {
	return statusError(C.smtp_finish_data(ctx.slot))
}

// Reset resets the mail transaction (RSET). Returns to Greeted or Authenticated.
func (ctx *SmtpContext) Reset() error {
	return statusError(C.smtp_reset(ctx.slot))
}

// Quit ends the session (QUIT). Transitions to Quit.
func (ctx *SmtpContext) Quit() error {
	return statusError(C.smtp_quit(ctx.slot))
}

// EnableTLS enables TLS on the connection (STARTTLS).
func (ctx *SmtpContext) EnableTLS() error {
	return statusError(C.smtp_enable_tls(ctx.slot))
}

// SmtpCanTransition checks whether a session state transition is valid.
func SmtpCanTransition(from, to SmtpSessionState) bool {
	return C.smtp_can_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}
