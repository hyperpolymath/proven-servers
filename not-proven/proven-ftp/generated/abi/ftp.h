/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * ftp.h -- C-ABI header for proven-ftp.
 * Generated from FTPABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_FTP_H
#define PROVEN_FTP_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- SessionState (5 constructors, tags 0-4) ------------------------------ */
#define FTP_STATE_CONNECTED     0
#define FTP_STATE_USER_OK       1
#define FTP_STATE_AUTHENTICATED 2
#define FTP_STATE_RENAMING      3
#define FTP_STATE_QUIT          4

/* -- TransferType (2 constructors, tags 0-1) ------------------------------ */
#define FTP_TYPE_ASCII  0
#define FTP_TYPE_BINARY 1

/* -- DataModeTag (2 constructors, tags 0-1) ------------------------------- */
#define FTP_MODE_ACTIVE  0
#define FTP_MODE_PASSIVE 1
#define FTP_MODE_NONE    255

/* -- TransferStateTag (4 constructors, tags 0-3) -------------------------- */
#define FTP_XFER_IDLE        0
#define FTP_XFER_IN_PROGRESS 1
#define FTP_XFER_COMPLETED   2
#define FTP_XFER_ABORTED     3

/* -- ReplyCategory (5 constructors, tags 0-4) ----------------------------- */
#define FTP_REPLY_PRELIMINARY   0
#define FTP_REPLY_COMPLETION    1
#define FTP_REPLY_INTERMEDIATE  2
#define FTP_REPLY_TRANSIENT_NEG 3
#define FTP_REPLY_PERMANENT_NEG 4

/* -- CommandTag (23 constructors, tags 0-22) ------------------------------ */
#define FTP_CMD_USER 0
#define FTP_CMD_PASS 1
#define FTP_CMD_ACCT 2
#define FTP_CMD_CWD  3
#define FTP_CMD_CDUP 4
#define FTP_CMD_QUIT 5
#define FTP_CMD_PASV 6
#define FTP_CMD_PORT 7
#define FTP_CMD_TYPE 8
#define FTP_CMD_RETR 9
#define FTP_CMD_STOR 10
#define FTP_CMD_DELE 11
#define FTP_CMD_RMD  12
#define FTP_CMD_MKD  13
#define FTP_CMD_PWD  14
#define FTP_CMD_LIST 15
#define FTP_CMD_NLST 16
#define FTP_CMD_SYST 17
#define FTP_CMD_STAT 18
#define FTP_CMD_NOOP 19
#define FTP_CMD_RNFR 20
#define FTP_CMD_RNTO 21
#define FTP_CMD_SIZE 22

/* -- ABI ------------------------------------------------------------------ */
uint32_t ftp_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      ftp_create(void);
void     ftp_destroy(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  ftp_state(int slot);
uint8_t  ftp_transfer_type(int slot);
uint8_t  ftp_data_mode(int slot);
uint8_t  ftp_transfer_state(int slot);
uint64_t ftp_bytes_transferred(int slot);
uint32_t ftp_file_count(int slot);
uint16_t ftp_last_reply_code(int slot);
uint32_t ftp_cwd(int slot, uint8_t *buf, uint32_t buf_len);

/* -- Commands: Authentication --------------------------------------------- */
uint8_t ftp_user(int slot, const uint8_t *name, uint32_t name_len);
uint8_t ftp_pass(int slot, const uint8_t *pw, uint32_t pw_len);
uint8_t ftp_quit(int slot);

/* -- Commands: Navigation ------------------------------------------------- */
uint8_t ftp_cwd_cmd(int slot, const uint8_t *path, uint32_t path_len);
uint8_t ftp_cdup(int slot);

/* -- Commands: Transfer parameters ---------------------------------------- */
uint8_t ftp_set_type(int slot, uint8_t type_tag);
uint8_t ftp_set_passive(int slot);
uint8_t ftp_set_active(int slot, uint16_t port);

/* -- Commands: Data transfer ---------------------------------------------- */
uint8_t ftp_begin_transfer(int slot);
uint8_t ftp_add_bytes(int slot, uint64_t count);
uint8_t ftp_complete_transfer(int slot);
uint8_t ftp_abort_transfer(int slot);

/* -- Commands: Rename ----------------------------------------------------- */
uint8_t ftp_begin_rename(int slot);
uint8_t ftp_complete_rename(int slot);

/* -- Stateless queries ---------------------------------------------------- */
uint8_t ftp_can_transfer(uint8_t state_tag);
uint8_t ftp_can_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_FTP_H */
