/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * smtp.h -- C-ABI header for proven-smtp.
 * Generated from SMTPABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_SMTP_H
#define PROVEN_SMTP_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- SmtpCommandTag (12 constructors, tags 0-11) -------------------------- */
#define SMTP_CMD_HELO      0
#define SMTP_CMD_EHLO      1
#define SMTP_CMD_MAIL_FROM 2
#define SMTP_CMD_RCPT_TO   3
#define SMTP_CMD_DATA      4
#define SMTP_CMD_QUIT      5
#define SMTP_CMD_RSET      6
#define SMTP_CMD_NOOP      7
#define SMTP_CMD_VRFY      8
#define SMTP_CMD_EXPN      9
#define SMTP_CMD_STARTTLS  10
#define SMTP_CMD_AUTH      11

/* -- ReplyCategory (4 constructors, tags 0-3) ----------------------------- */
#define SMTP_REPLY_CAT_POSITIVE           0
#define SMTP_REPLY_CAT_INTERMEDIATE       1
#define SMTP_REPLY_CAT_TRANSIENT_NEGATIVE 2
#define SMTP_REPLY_CAT_PERMANENT_NEGATIVE 3

/* -- ReplyCode (17 constructors, tags 0-16) ------------------------------- */
#define SMTP_REPLY_SERVICE_READY        0
#define SMTP_REPLY_SERVICE_CLOSING      1
#define SMTP_REPLY_ACTION_OK            2
#define SMTP_REPLY_WILL_FORWARD         3
#define SMTP_REPLY_START_MAIL_INPUT     4
#define SMTP_REPLY_SERVICE_UNAVAILABLE  5
#define SMTP_REPLY_MAILBOX_BUSY         6
#define SMTP_REPLY_LOCAL_ERROR          7
#define SMTP_REPLY_INSUFFICIENT_STORAGE 8
#define SMTP_REPLY_SYNTAX_ERROR         9
#define SMTP_REPLY_PARAM_SYNTAX_ERROR   10
#define SMTP_REPLY_NOT_IMPLEMENTED      11
#define SMTP_REPLY_BAD_SEQUENCE         12
#define SMTP_REPLY_PARAM_NOT_IMPLEMENTED 13
#define SMTP_REPLY_MAILBOX_UNAVAILABLE  14
#define SMTP_REPLY_MAILBOX_NAME_INVALID 15
#define SMTP_REPLY_TRANSACTION_FAILED   16
#define SMTP_REPLY_NONE                 255

/* -- AuthMechTag (4 constructors, tags 0-3) ------------------------------- */
#define SMTP_AUTH_PLAIN    0
#define SMTP_AUTH_LOGIN    1
#define SMTP_AUTH_CRAM_MD5 2
#define SMTP_AUTH_XOAUTH2  3
#define SMTP_AUTH_NONE     255

/* -- SmtpExtension (7 constructors, tags 0-6) ----------------------------- */
#define SMTP_EXT_SIZE       0
#define SMTP_EXT_PIPELINING 1
#define SMTP_EXT_8BITMIME   2
#define SMTP_EXT_STARTTLS   3
#define SMTP_EXT_AUTH       4
#define SMTP_EXT_DSN        5
#define SMTP_EXT_CHUNKING   6

/* -- SmtpSessionState (9 constructors, tags 0-8) -------------------------- */
#define SMTP_STATE_CONNECTED        0
#define SMTP_STATE_GREETED          1
#define SMTP_STATE_AUTH_STARTED     2
#define SMTP_STATE_AUTHENTICATED    3
#define SMTP_STATE_MAIL_FROM        4
#define SMTP_STATE_RCPT_TO          5
#define SMTP_STATE_DATA             6
#define SMTP_STATE_MESSAGE_RECEIVED 7
#define SMTP_STATE_QUIT             8

/* -- ABI ------------------------------------------------------------------ */
uint32_t smtp_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      smtp_create_context(void);
void     smtp_destroy_context(int slot);

/* -- SMTP operations ------------------------------------------------------ */
uint8_t  smtp_greet(int slot, uint8_t is_ehlo);
uint8_t  smtp_authenticate(int slot, uint8_t mech);
uint8_t  smtp_auth_complete(int slot, uint8_t success);
uint8_t  smtp_set_sender(int slot);
uint8_t  smtp_add_recipient(int slot);
uint8_t  smtp_start_data(int slot);
uint8_t  smtp_append_data(int slot, uint32_t len);
uint8_t  smtp_finish_data(int slot);
uint8_t  smtp_reset(int slot);
uint8_t  smtp_quit(int slot);
uint8_t  smtp_enable_tls(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  smtp_get_state(int slot);
uint8_t  smtp_get_reply_code(int slot);
uint8_t  smtp_get_recipient_count(int slot);
uint32_t smtp_get_data_size(int slot);
uint8_t  smtp_get_auth_mechanism(int slot);
uint8_t  smtp_is_authenticated(int slot);
uint8_t  smtp_is_tls_active(int slot);

/* -- Stateless queries ---------------------------------------------------- */
uint8_t  smtp_can_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_SMTP_H */
