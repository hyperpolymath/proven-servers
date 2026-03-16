/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * ids.h -- C-ABI header for proven-ids.
 * Generated from IDSABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_IDS_H
#define PROVEN_IDS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- AlertSeverity (4 constructors, tags 0-3) ----------------------------- */
#define IDS_SEVERITY_LOW      0
#define IDS_SEVERITY_MEDIUM   1
#define IDS_SEVERITY_HIGH     2
#define IDS_SEVERITY_CRITICAL 3

/* -- DetectionMethod (4 constructors, tags 0-3) --------------------------- */
#define IDS_DETECTION_SIGNATURE 0
#define IDS_DETECTION_ANOMALY   1
#define IDS_DETECTION_STATEFUL  2
#define IDS_DETECTION_HEURISTIC 3

/* -- Protocol (7 constructors, tags 0-6) ---------------------------------- */
#define IDS_PROTO_TCP  0
#define IDS_PROTO_UDP  1
#define IDS_PROTO_ICMP 2
#define IDS_PROTO_DNS  3
#define IDS_PROTO_HTTP 4
#define IDS_PROTO_TLS  5
#define IDS_PROTO_SSH  6

/* -- Action (5 constructors, tags 0-4) ------------------------------------ */
#define IDS_ACTION_ALERT 0
#define IDS_ACTION_DROP  1
#define IDS_ACTION_LOG   2
#define IDS_ACTION_BLOCK 3
#define IDS_ACTION_PASS  4

/* -- Direction (3 constructors, tags 0-2) --------------------------------- */
#define IDS_DIR_INBOUND  0
#define IDS_DIR_OUTBOUND 1
#define IDS_DIR_BOTH     2

/* -- ThreatLevel (5 constructors, tags 0-4) ------------------------------- */
#define IDS_THREAT_INFO     0
#define IDS_THREAT_LOW      1
#define IDS_THREAT_MEDIUM   2
#define IDS_THREAT_HIGH     3
#define IDS_THREAT_CRITICAL 4

/* -- RuleMatch (8 constructors, tags 0-7) --------------------------------- */
#define IDS_MATCH_SRC_ADDR   0
#define IDS_MATCH_DST_ADDR   1
#define IDS_MATCH_SRC_PORT   2
#define IDS_MATCH_DST_PORT   3
#define IDS_MATCH_CONTENT    4
#define IDS_MATCH_REGEX      5
#define IDS_MATCH_THRESHOLD  6
#define IDS_MATCH_FLOW_BITS  7

/* -- MatchStatus (3 constructors, tags 0-2) ------------------------------- */
#define IDS_STATUS_NO_MATCH   0
#define IDS_STATUS_MATCHED    1
#define IDS_STATUS_SUPPRESSED 2

/* -- InspectionState (5 constructors, tags 0-4) --------------------------- */
#define IDS_INSPECT_CAPTURED   0
#define IDS_INSPECT_DECODED    1
#define IDS_INSPECT_INSPECTING 2
#define IDS_INSPECT_EVALUATED  3
#define IDS_INSPECT_DISPOSED   4

/* -- AlertState (5 constructors, tags 0-4) -------------------------------- */
#define IDS_ALERT_IDLE         0
#define IDS_ALERT_TRIGGERED    1
#define IDS_ALERT_ESCALATED    2
#define IDS_ALERT_ACKNOWLEDGED 3
#define IDS_ALERT_CLOSED       4

/* -- ABI ------------------------------------------------------------------ */
uint32_t ids_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      ids_create_context(void);
void     ids_destroy_context(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  ids_inspection_state(int slot);
uint8_t  ids_alert_state(int slot);

/* -- Packet inspection transitions ---------------------------------------- */
uint8_t  ids_decode_packet(int slot, uint8_t proto, uint8_t dir,
                           uint32_t src_ip, uint32_t dst_ip,
                           uint16_t src_port, uint16_t dst_port);
uint8_t  ids_begin_inspection(int slot);
uint8_t  ids_add_rule(int slot, uint8_t match_type, uint32_t match_value,
                      uint8_t action, uint8_t severity, uint8_t detection,
                      uint16_t priority);
uint8_t  ids_evaluate_rules(int slot);
uint8_t  ids_dispose(int slot);

/* -- Packet field queries ------------------------------------------------- */
uint8_t  ids_get_action(int slot);
uint8_t  ids_get_match_status(int slot);
uint8_t  ids_get_match_severity(int slot);
uint8_t  ids_get_match_detection(int slot);
uint8_t  ids_get_threat_level(int slot);
uint16_t ids_rule_count(int slot);
uint16_t ids_alert_count(int slot);
uint8_t  ids_packet_proto(int slot);
uint8_t  ids_packet_direction(int slot);
uint32_t ids_packet_src_ip(int slot);
uint32_t ids_packet_dst_ip(int slot);
uint16_t ids_packet_src_port(int slot);
uint16_t ids_packet_dst_port(int slot);

/* -- Alert lifecycle transitions ------------------------------------------ */
uint8_t  ids_trigger_alert(int slot, uint8_t severity);
uint8_t  ids_escalate_alert(int slot);
uint8_t  ids_acknowledge_alert(int slot);
uint8_t  ids_close_alert(int slot);
uint8_t  ids_auto_close_alert(int slot);

/* -- Configuration -------------------------------------------------------- */
uint8_t  ids_set_default_action(int slot, uint8_t action);
uint8_t  ids_get_alert_severity(int slot);

/* -- Stateless queries ---------------------------------------------------- */
uint8_t  ids_can_inspection_transition(uint8_t from, uint8_t to);
uint8_t  ids_can_alert_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_IDS_H */
