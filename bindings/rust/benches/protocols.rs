// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! Comprehensive benchmarks for the proven-servers Rust bindings.
//!
//! Benchmark categories:
//!
//! 1. **Tag roundtrip** — measures from_tag/to_tag (or equivalent codec)
//!    latency for every major enum type across all protocol modules.
//!
//! 2. **State machine validation** — measures validate_http_transition,
//!    validate_stream_transition, and similar state machine checkers
//!    for valid and invalid transitions.
//!
//! 3. **Domain validation** — measures dns::validate_domain_name with
//!    various input patterns (short, deep, boundary, invalid).
//!
//! 4. **Classification helpers** — measures is_success, is_error,
//!    is_client_error, is_control, is_data, is_safe, and similar
//!    boolean predicates across protocols.
//!
//! 5. **Frame construction & validation** — measures WebSocket frame
//!    building helpers and validation routines.
//!
//! All benchmarks use `criterion::black_box` to prevent the compiler
//! from eliding the measured work.

use criterion::{black_box, criterion_group, criterion_main, Criterion};

// Core protocols with the richest type surface — used in benchmarks below.
use proven_servers_rs::amqp;
use proven_servers_rs::dns;
use proven_servers_rs::grpc;
use proven_servers_rs::http;
use proven_servers_rs::mqtt;
use proven_servers_rs::smtp;
use proven_servers_rs::ssh;
use proven_servers_rs::syslog;
use proven_servers_rs::websocket;

// =========================================================================
// Category 1: Tag roundtrip benchmarks
// =========================================================================
//
// These benchmarks measure the cost of encoding an enum variant to its
// C-ABI tag value and decoding back. This is the most performance-critical
// path for FFI interop with the Zig layer.

/// Benchmark HTTP Method from_tag/to_tag for all 9 variants.
fn bench_http_method_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/http_method", |b| {
        b.iter(|| {
            for tag in 0u8..=8 {
                let method = http::Method::from_tag(black_box(tag)).unwrap();
                black_box(method.to_tag());
            }
        });
    });
}

/// Benchmark HTTP StatusCode from_tag/to_tag for all 29 variants.
fn bench_http_status_code_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/http_status_code", |b| {
        b.iter(|| {
            for tag in 0u8..=28 {
                let code = http::StatusCode::from_tag(black_box(tag)).unwrap();
                black_box(code.to_tag());
            }
        });
    });
}

/// Benchmark HTTP Version from_tag/to_tag for all 4 variants.
fn bench_http_version_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/http_version", |b| {
        b.iter(|| {
            for tag in 0u8..=3 {
                let ver = http::Version::from_tag(black_box(tag)).unwrap();
                black_box(ver.to_tag());
            }
        });
    });
}

/// Benchmark HTTP ContentType from_tag/to_tag for all 8 variants.
fn bench_http_content_type_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/http_content_type", |b| {
        b.iter(|| {
            for tag in 0u8..=7 {
                let ct = http::ContentType::from_tag(black_box(tag)).unwrap();
                black_box(ct.to_tag());
            }
        });
    });
}

/// Benchmark HTTP HeaderType from_tag/to_tag for all 10 variants.
fn bench_http_header_type_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/http_header_type", |b| {
        b.iter(|| {
            for tag in 0u8..=9 {
                let ht = http::HeaderType::from_tag(black_box(tag)).unwrap();
                black_box(ht.to_tag());
            }
        });
    });
}

/// Benchmark HTTP RequestPhase from_tag/to_tag for all 7 variants.
fn bench_http_request_phase_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/http_request_phase", |b| {
        b.iter(|| {
            for tag in 0u8..=6 {
                let phase = http::RequestPhase::from_tag(black_box(tag)).unwrap();
                black_box(phase.to_tag());
            }
        });
    });
}

/// Benchmark HTTP Method parse/as_str string roundtrip for all 9 variants.
fn bench_http_method_parse_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/http_method_parse", |b| {
        b.iter(|| {
            for method in http::Method::ALL {
                let s = method.as_str();
                let parsed = http::Method::parse(black_box(s)).unwrap();
                black_box(parsed);
            }
        });
    });
}

/// Benchmark HTTP StatusCode numeric_code/from_numeric roundtrip.
fn bench_http_status_numeric_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/http_status_numeric", |b| {
        b.iter(|| {
            for tag in 0u8..=28 {
                let code = http::StatusCode::from_tag(tag).unwrap();
                let num = code.numeric_code();
                let back = http::StatusCode::from_numeric(black_box(num)).unwrap();
                black_box(back);
            }
        });
    });
}

/// Benchmark gRPC StatusCode from_code/to_code for all 17 variants.
fn bench_grpc_status_code_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/grpc_status_code", |b| {
        b.iter(|| {
            for code in 0u8..=16 {
                let sc = grpc::StatusCode::from_code(black_box(code)).unwrap();
                black_box(sc.to_code());
            }
        });
    });
}

/// Benchmark gRPC StreamState from_tag/to_tag for all 6 variants.
fn bench_grpc_stream_state_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/grpc_stream_state", |b| {
        b.iter(|| {
            for tag in 0u8..=5 {
                let state = grpc::StreamState::from_tag(black_box(tag)).unwrap();
                black_box(state.to_tag());
            }
        });
    });
}

/// Benchmark MQTT QoS from_code/to_code for all 3 variants.
fn bench_mqtt_qos_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/mqtt_qos", |b| {
        b.iter(|| {
            for code in 0u8..=2 {
                let qos = mqtt::QoS::from_code(black_box(code)).unwrap();
                black_box(qos.to_code());
            }
        });
    });
}

/// Benchmark MQTT PacketType from_code/to_code for all 15 variants.
fn bench_mqtt_packet_type_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/mqtt_packet_type", |b| {
        b.iter(|| {
            for code in 1u8..=15 {
                let pt = mqtt::PacketType::from_code(black_box(code)).unwrap();
                black_box(pt.to_code());
            }
        });
    });
}

/// Benchmark MQTT SubAckCode from_byte/to_byte for all 4 variants.
fn bench_mqtt_suback_code_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/mqtt_suback_code", |b| {
        b.iter(|| {
            for byte in [0x00u8, 0x01, 0x02, 0x80] {
                let code = mqtt::SubAckCode::from_byte(black_box(byte)).unwrap();
                black_box(code.to_byte());
            }
        });
    });
}

/// Benchmark DNS RecordType from_type_code/to_type_code for all 9 variants.
fn bench_dns_record_type_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/dns_record_type", |b| {
        b.iter(|| {
            for rt in dns::RecordType::ALL {
                let code = rt.to_type_code();
                let back = dns::RecordType::from_type_code(black_box(code)).unwrap();
                black_box(back);
            }
        });
    });
}

/// Benchmark DNS ResponseCode from_rcode/to_rcode for all 6 variants.
fn bench_dns_response_code_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/dns_response_code", |b| {
        b.iter(|| {
            for code in 0u8..=5 {
                let rc = dns::ResponseCode::from_rcode(black_box(code)).unwrap();
                black_box(rc.to_rcode());
            }
        });
    });
}

/// Benchmark SSH SshMessageType from_tag/to_tag for all 8 variants.
fn bench_ssh_message_type_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/ssh_message_type", |b| {
        b.iter(|| {
            for msg in ssh::SshMessageType::ALL {
                let tag = msg.to_tag();
                let back = ssh::SshMessageType::from_tag(black_box(tag)).unwrap();
                black_box(back);
            }
        });
    });
}

/// Benchmark SSH AuthMethod from_tag/to_tag for all 4 variants.
fn bench_ssh_auth_method_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/ssh_auth_method", |b| {
        b.iter(|| {
            for tag in 0u8..=3 {
                let method = ssh::AuthMethod::from_tag(black_box(tag)).unwrap();
                black_box(method.to_tag());
            }
        });
    });
}

/// Benchmark SSH KexMethod from_tag/to_tag for all 6 variants.
fn bench_ssh_kex_method_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/ssh_kex_method", |b| {
        b.iter(|| {
            for tag in 0u8..=5 {
                let kex = ssh::KexMethod::from_tag(black_box(tag)).unwrap();
                black_box(kex.to_tag());
            }
        });
    });
}

/// Benchmark SSH CipherAlgorithm from_tag/to_tag for all 6 variants.
fn bench_ssh_cipher_algorithm_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/ssh_cipher_algorithm", |b| {
        b.iter(|| {
            for tag in 0u8..=5 {
                let cipher = ssh::CipherAlgorithm::from_tag(black_box(tag)).unwrap();
                black_box(cipher.to_tag());
            }
        });
    });
}

/// Benchmark SSH HostKeyAlgorithm from_tag/to_tag for all 4 variants.
fn bench_ssh_host_key_algorithm_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/ssh_host_key_algorithm", |b| {
        b.iter(|| {
            for tag in 0u8..=3 {
                let alg = ssh::HostKeyAlgorithm::from_tag(black_box(tag)).unwrap();
                black_box(alg.to_tag());
            }
        });
    });
}

/// Benchmark SSH BastionState from_tag/to_tag for all 6 variants.
fn bench_ssh_bastion_state_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/ssh_bastion_state", |b| {
        b.iter(|| {
            for tag in 0u8..=5 {
                let state = ssh::BastionState::from_tag(black_box(tag)).unwrap();
                black_box(state.to_tag());
            }
        });
    });
}

/// Benchmark SSH ChannelType from_tag/to_tag for all 4 variants.
fn bench_ssh_channel_type_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/ssh_channel_type", |b| {
        b.iter(|| {
            for tag in 0u8..=3 {
                let ct = ssh::ChannelType::from_tag(black_box(tag)).unwrap();
                black_box(ct.to_tag());
            }
        });
    });
}

/// Benchmark SSH DisconnectReason from_tag/to_tag for all 12 variants.
fn bench_ssh_disconnect_reason_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/ssh_disconnect_reason", |b| {
        b.iter(|| {
            for tag in 0u8..=11 {
                let reason = ssh::DisconnectReason::from_tag(black_box(tag)).unwrap();
                black_box(reason.to_tag());
            }
        });
    });
}

/// Benchmark WebSocket Opcode from_nibble/to_nibble for all 6 variants.
fn bench_ws_opcode_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/ws_opcode", |b| {
        b.iter(|| {
            for nibble in [0x0u8, 0x1, 0x2, 0x8, 0x9, 0xA] {
                let op = websocket::Opcode::from_nibble(black_box(nibble)).unwrap();
                black_box(op.to_nibble());
            }
        });
    });
}

/// Benchmark WebSocket CloseCode from_wire/to_wire for all 11 variants.
fn bench_ws_close_code_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/ws_close_code", |b| {
        let codes: [u16; 11] = [
            1000, 1001, 1002, 1003, 1005, 1006, 1007, 1008, 1009, 1010, 1011,
        ];
        b.iter(|| {
            for wire in codes {
                let code = websocket::CloseCode::from_wire(black_box(wire)).unwrap();
                black_box(code.to_wire());
            }
        });
    });
}

/// Benchmark AMQP FrameType from_tag/to_tag for all 4 variants.
fn bench_amqp_frame_type_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/amqp_frame_type", |b| {
        b.iter(|| {
            for tag in 0u8..=3 {
                let ft = amqp::FrameType::from_tag(black_box(tag)).unwrap();
                black_box(ft.to_tag());
            }
        });
    });
}

/// Benchmark SMTP SmtpCommand from_tag/to_tag for all 12 variants.
fn bench_smtp_command_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/smtp_command", |b| {
        b.iter(|| {
            for tag in 0u8..=11 {
                let cmd = smtp::SmtpCommand::from_tag(black_box(tag)).unwrap();
                black_box(cmd.to_tag());
            }
        });
    });
}

/// Benchmark Syslog Severity from_tag/to_tag for all 8 variants.
fn bench_syslog_severity_roundtrip(c: &mut Criterion) {
    c.bench_function("roundtrip/syslog_severity", |b| {
        b.iter(|| {
            for tag in 0u8..=7 {
                let sev = syslog::Severity::from_tag(black_box(tag)).unwrap();
                black_box(sev.to_tag());
            }
        });
    });
}

// =========================================================================
// Category 2: State machine validation benchmarks
// =========================================================================
//
// These benchmarks measure the cost of validating protocol state transitions.
// State machines are a core correctness mechanism — the Idris2 proofs
// guarantee that only valid transitions are possible, and these Rust
// functions replicate that checking at runtime.

/// Benchmark HTTP request lifecycle validation for all valid transitions.
fn bench_http_transition_valid(c: &mut Criterion) {
    let valid_pairs: [(http::RequestPhase, http::RequestPhase); 12] = [
        (http::RequestPhase::Idle, http::RequestPhase::Receiving),
        (http::RequestPhase::Receiving, http::RequestPhase::HeadersParsed),
        (http::RequestPhase::HeadersParsed, http::RequestPhase::BodyReceiving),
        (http::RequestPhase::HeadersParsed, http::RequestPhase::Complete),
        (http::RequestPhase::BodyReceiving, http::RequestPhase::Complete),
        (http::RequestPhase::Complete, http::RequestPhase::Responding),
        (http::RequestPhase::Responding, http::RequestPhase::Sent),
        (http::RequestPhase::Sent, http::RequestPhase::Idle),
        // Abort transitions
        (http::RequestPhase::Receiving, http::RequestPhase::Sent),
        (http::RequestPhase::HeadersParsed, http::RequestPhase::Sent),
        (http::RequestPhase::BodyReceiving, http::RequestPhase::Sent),
        (http::RequestPhase::Complete, http::RequestPhase::Sent),
    ];
    c.bench_function("state_machine/http_transition_valid", |b| {
        b.iter(|| {
            for (from, to) in &valid_pairs {
                let result = http::validate_http_transition(
                    black_box(*from),
                    black_box(*to),
                );
                let _ = black_box(result);
            }
        });
    });
}

/// Benchmark HTTP request lifecycle validation for invalid transitions.
fn bench_http_transition_invalid(c: &mut Criterion) {
    let invalid_pairs: [(http::RequestPhase, http::RequestPhase); 5] = [
        (http::RequestPhase::Idle, http::RequestPhase::Complete),
        (http::RequestPhase::Idle, http::RequestPhase::Responding),
        (http::RequestPhase::Complete, http::RequestPhase::Receiving),
        (http::RequestPhase::Responding, http::RequestPhase::HeadersParsed),
        (http::RequestPhase::Idle, http::RequestPhase::Idle),
    ];
    c.bench_function("state_machine/http_transition_invalid", |b| {
        b.iter(|| {
            for (from, to) in &invalid_pairs {
                let result = http::validate_http_transition(
                    black_box(*from),
                    black_box(*to),
                );
                let _ = black_box(result);
            }
        });
    });
}

/// Benchmark gRPC/HTTP2 stream state validation for all valid transitions.
fn bench_grpc_stream_transition_valid(c: &mut Criterion) {
    let valid_pairs: [(grpc::StreamState, grpc::StreamState); 9] = [
        (grpc::StreamState::Idle, grpc::StreamState::Open),
        (grpc::StreamState::Open, grpc::StreamState::HalfClosedLocal),
        (grpc::StreamState::Open, grpc::StreamState::HalfClosedRemote),
        (grpc::StreamState::Open, grpc::StreamState::Closed),
        (grpc::StreamState::HalfClosedLocal, grpc::StreamState::Closed),
        (grpc::StreamState::HalfClosedRemote, grpc::StreamState::Closed),
        (grpc::StreamState::Idle, grpc::StreamState::Reserved),
        (grpc::StreamState::Reserved, grpc::StreamState::HalfClosedRemote),
        (grpc::StreamState::Reserved, grpc::StreamState::Closed),
    ];
    c.bench_function("state_machine/grpc_stream_transition_valid", |b| {
        b.iter(|| {
            for (from, to) in &valid_pairs {
                let result = grpc::validate_stream_transition(
                    black_box(*from),
                    black_box(*to),
                );
                let _ = black_box(result);
            }
        });
    });
}

/// Benchmark gRPC stream state: closed-is-terminal invariant check.
fn bench_grpc_closed_is_terminal(c: &mut Criterion) {
    c.bench_function("state_machine/grpc_closed_is_terminal", |b| {
        b.iter(|| {
            for to_tag in 0u8..=5 {
                let to = grpc::StreamState::from_tag(to_tag).unwrap();
                let result = grpc::validate_stream_transition(
                    black_box(grpc::StreamState::Closed),
                    black_box(to),
                );
                let _ = black_box(result);
            }
        });
    });
}

/// Benchmark SSH bastion state machine transitions.
fn bench_ssh_bastion_transition(c: &mut Criterion) {
    c.bench_function("state_machine/ssh_bastion_transition", |b| {
        b.iter(|| {
            // Valid forward transitions
            black_box(ssh::BastionState::Connected.can_transition_to(
                black_box(ssh::BastionState::KeyExchanged),
            ));
            black_box(ssh::BastionState::KeyExchanged.can_transition_to(
                black_box(ssh::BastionState::Authenticated),
            ));
            black_box(ssh::BastionState::Authenticated.can_transition_to(
                black_box(ssh::BastionState::ChannelOpen),
            ));
            black_box(ssh::BastionState::ChannelOpen.can_transition_to(
                black_box(ssh::BastionState::Active),
            ));
            // Close from any state
            for tag in 0u8..=4 {
                let state = ssh::BastionState::from_tag(tag).unwrap();
                black_box(state.can_transition_to(
                    black_box(ssh::BastionState::Closed),
                ));
            }
            // Invalid transitions
            black_box(ssh::BastionState::Connected.can_transition_to(
                black_box(ssh::BastionState::Authenticated),
            ));
            black_box(ssh::BastionState::Closed.can_transition_to(
                black_box(ssh::BastionState::Connected),
            ));
        });
    });
}

/// Benchmark SSH channel state machine transitions.
fn bench_ssh_channel_transition(c: &mut Criterion) {
    c.bench_function("state_machine/ssh_channel_transition", |b| {
        b.iter(|| {
            black_box(ssh::ChannelState::Opening.can_transition_to(
                black_box(ssh::ChannelState::Open),
            ));
            black_box(ssh::ChannelState::Opening.can_transition_to(
                black_box(ssh::ChannelState::Closed),
            ));
            black_box(ssh::ChannelState::Open.can_transition_to(
                black_box(ssh::ChannelState::Closing),
            ));
            black_box(ssh::ChannelState::Closing.can_transition_to(
                black_box(ssh::ChannelState::Closed),
            ));
            // Invalid
            black_box(ssh::ChannelState::Closed.can_transition_to(
                black_box(ssh::ChannelState::Opening),
            ));
        });
    });
}

// =========================================================================
// Category 3: Domain validation benchmarks
// =========================================================================
//
// DNS domain name validation is used on every incoming query. These
// benchmarks cover realistic domain patterns and edge cases.

/// Benchmark domain validation for typical short domains.
fn bench_dns_validate_short_domain(c: &mut Criterion) {
    c.bench_function("validation/dns_domain_short", |b| {
        b.iter(|| {
            let _ = black_box(dns::validate_domain_name(black_box("example.com")));
        });
    });
}

/// Benchmark domain validation for deeply nested subdomains.
fn bench_dns_validate_deep_domain(c: &mut Criterion) {
    c.bench_function("validation/dns_domain_deep", |b| {
        b.iter(|| {
            let _ = black_box(dns::validate_domain_name(black_box(
                "a.b.c.d.e.f.g.h.i.j.k.example.com",
            )));
        });
    });
}

/// Benchmark domain validation at the maximum allowed length boundary.
fn bench_dns_validate_boundary_domain(c: &mut Criterion) {
    // Build a domain exactly at the 253-byte limit: 4 labels of 62 chars + dots
    let label = "a".repeat(62);
    let domain = format!("{}.{}.{}.{}.x", label, label, label, label);
    // Verify it is exactly at or just under the limit
    assert!(domain.len() <= 253, "test domain should be within limit");
    c.bench_function("validation/dns_domain_boundary", |b| {
        b.iter(|| {
            let _ = black_box(dns::validate_domain_name(black_box(&domain)));
        });
    });
}

/// Benchmark domain validation for an invalid (too long) domain.
fn bench_dns_validate_toolong_domain(c: &mut Criterion) {
    let label = "a".repeat(63);
    let domain = format!("{}.{}.{}.{}.x", label, label, label, label);
    assert!(domain.len() > 253, "test domain should exceed limit");
    c.bench_function("validation/dns_domain_toolong", |b| {
        b.iter(|| {
            let _ = black_box(dns::validate_domain_name(black_box(&domain)));
        });
    });
}

/// Benchmark domain validation for an empty domain (invalid).
fn bench_dns_validate_empty_domain(c: &mut Criterion) {
    c.bench_function("validation/dns_domain_empty", |b| {
        b.iter(|| {
            let _ = black_box(dns::validate_domain_name(black_box("")));
        });
    });
}

/// Benchmark domain validation for a domain with empty labels (invalid).
fn bench_dns_validate_empty_label_domain(c: &mut Criterion) {
    c.bench_function("validation/dns_domain_empty_label", |b| {
        b.iter(|| {
            let _ = black_box(dns::validate_domain_name(black_box("example..com")));
        });
    });
}

/// Benchmark domain validation for a label exceeding 63 bytes (invalid).
fn bench_dns_validate_label_too_long(c: &mut Criterion) {
    let long_label = "a".repeat(64);
    let domain = format!("{}.com", long_label);
    c.bench_function("validation/dns_label_too_long", |b| {
        b.iter(|| {
            let _ = black_box(dns::validate_domain_name(black_box(&domain)));
        });
    });
}

// =========================================================================
// Category 4: Classification helper benchmarks
// =========================================================================
//
// Classification helpers are used in hot paths for routing, filtering,
// and logging. These benchmarks measure the cost of boolean predicates
// on enum variants.

/// Benchmark HTTP Method classification helpers (is_safe, is_idempotent,
/// has_request_body) for all 9 variants.
fn bench_http_method_classification(c: &mut Criterion) {
    c.bench_function("classification/http_method_properties", |b| {
        b.iter(|| {
            for method in http::Method::ALL {
                let m = black_box(method);
                black_box(m.is_safe());
                black_box(m.is_idempotent());
                black_box(m.has_request_body());
            }
        });
    });
}

/// Benchmark HTTP StatusCode classification (is_success, is_error,
/// is_redirect, category) for all 29 variants.
fn bench_http_status_classification(c: &mut Criterion) {
    c.bench_function("classification/http_status_properties", |b| {
        b.iter(|| {
            for tag in 0u8..=28 {
                let code = http::StatusCode::from_tag(tag).unwrap();
                let c = black_box(code);
                black_box(c.is_success());
                black_box(c.is_error());
                black_box(c.is_redirect());
                black_box(c.category());
            }
        });
    });
}

/// Benchmark gRPC StatusCode is_ok predicate for all 17 variants.
fn bench_grpc_status_is_ok(c: &mut Criterion) {
    c.bench_function("classification/grpc_status_is_ok", |b| {
        b.iter(|| {
            for code in 0u8..=16 {
                let sc = grpc::StatusCode::from_code(code).unwrap();
                black_box(black_box(sc).is_ok());
            }
        });
    });
}

/// Benchmark gRPC StreamState data capability checks for all 6 variants.
fn bench_grpc_stream_capabilities(c: &mut Criterion) {
    c.bench_function("classification/grpc_stream_capabilities", |b| {
        b.iter(|| {
            for tag in 0u8..=5 {
                let state = grpc::StreamState::from_tag(tag).unwrap();
                let s = black_box(state);
                black_box(s.can_send_data());
                black_box(s.can_receive_data());
                black_box(s.can_update_window());
                black_box(s.is_terminal());
            }
        });
    });
}

/// Benchmark gRPC StreamType classification (is_client_streaming,
/// is_server_streaming) for all 4 variants.
fn bench_grpc_stream_type_classification(c: &mut Criterion) {
    let stream_types = [
        grpc::StreamType::Unary,
        grpc::StreamType::ServerStreaming,
        grpc::StreamType::ClientStreaming,
        grpc::StreamType::BidiStreaming,
    ];
    c.bench_function("classification/grpc_stream_type", |b| {
        b.iter(|| {
            for st in stream_types {
                let s = black_box(st);
                black_box(s.is_client_streaming());
                black_box(s.is_server_streaming());
            }
        });
    });
}

/// Benchmark MQTT QoS classification helpers (requires_ack,
/// ack_packet_count) for all 3 variants.
fn bench_mqtt_qos_classification(c: &mut Criterion) {
    c.bench_function("classification/mqtt_qos_properties", |b| {
        b.iter(|| {
            for code in 0u8..=2 {
                let qos = mqtt::QoS::from_code(code).unwrap();
                let q = black_box(qos);
                black_box(q.requires_ack());
                black_box(q.ack_packet_count());
            }
        });
    });
}

/// Benchmark MQTT QoS negotiation (effective, delivery) across all
/// combinations of QoS levels.
fn bench_mqtt_qos_negotiation(c: &mut Criterion) {
    c.bench_function("classification/mqtt_qos_negotiation", |b| {
        b.iter(|| {
            for req in 0u8..=2 {
                for grant in 0u8..=2 {
                    let r = mqtt::QoS::from_code(req).unwrap();
                    let g = mqtt::QoS::from_code(grant).unwrap();
                    black_box(mqtt::QoS::effective(black_box(r), black_box(g)));
                    black_box(mqtt::QoS::delivery(black_box(r), black_box(g)));
                }
            }
        });
    });
}

/// Benchmark MQTT PacketType direction and requires_packet_id for
/// all 15 packet types.
fn bench_mqtt_packet_type_classification(c: &mut Criterion) {
    c.bench_function("classification/mqtt_packet_direction", |b| {
        b.iter(|| {
            for code in 1u8..=15 {
                let pt = mqtt::PacketType::from_code(code).unwrap();
                let p = black_box(pt);
                black_box(p.direction());
                black_box(p.requires_packet_id());
            }
        });
    });
}

/// Benchmark DNS RecordType classification (is_address, is_infrastructure)
/// for all 9 variants.
fn bench_dns_record_type_classification(c: &mut Criterion) {
    c.bench_function("classification/dns_record_type", |b| {
        b.iter(|| {
            for rt in dns::RecordType::ALL {
                let r = black_box(rt);
                black_box(r.is_address());
                black_box(r.is_infrastructure());
            }
        });
    });
}

/// Benchmark DNS ResponseCode classification (is_success, is_nxdomain)
/// for all 6 variants.
fn bench_dns_response_code_classification(c: &mut Criterion) {
    c.bench_function("classification/dns_response_code", |b| {
        b.iter(|| {
            for code in 0u8..=5 {
                let rc = dns::ResponseCode::from_rcode(code).unwrap();
                let r = black_box(rc);
                black_box(r.is_success());
                black_box(r.is_nxdomain());
            }
        });
    });
}

/// Benchmark SSH AuthMethod is_secure for all 4 variants.
fn bench_ssh_auth_method_classification(c: &mut Criterion) {
    c.bench_function("classification/ssh_auth_method_secure", |b| {
        b.iter(|| {
            for tag in 0u8..=3 {
                let method = ssh::AuthMethod::from_tag(tag).unwrap();
                black_box(black_box(method).is_secure());
            }
        });
    });
}

/// Benchmark SSH KexMethod is_ecc for all 6 variants.
fn bench_ssh_kex_method_classification(c: &mut Criterion) {
    c.bench_function("classification/ssh_kex_method_ecc", |b| {
        b.iter(|| {
            for tag in 0u8..=5 {
                let kex = ssh::KexMethod::from_tag(tag).unwrap();
                black_box(black_box(kex).is_ecc());
            }
        });
    });
}

/// Benchmark SSH CipherAlgorithm is_aead and key_bits for all 6 variants.
fn bench_ssh_cipher_classification(c: &mut Criterion) {
    c.bench_function("classification/ssh_cipher_properties", |b| {
        b.iter(|| {
            for tag in 0u8..=5 {
                let cipher = ssh::CipherAlgorithm::from_tag(tag).unwrap();
                let c = black_box(cipher);
                black_box(c.is_aead());
                black_box(c.key_bits());
            }
        });
    });
}

/// Benchmark SSH DisconnectReason is_security_related for all 12 variants.
fn bench_ssh_disconnect_classification(c: &mut Criterion) {
    c.bench_function("classification/ssh_disconnect_security", |b| {
        b.iter(|| {
            for tag in 0u8..=11 {
                let reason = ssh::DisconnectReason::from_tag(tag).unwrap();
                black_box(black_box(reason).is_security_related());
            }
        });
    });
}

/// Benchmark SSH ChannelType is_forwarding for all 4 variants.
fn bench_ssh_channel_type_classification(c: &mut Criterion) {
    c.bench_function("classification/ssh_channel_forwarding", |b| {
        b.iter(|| {
            for tag in 0u8..=3 {
                let ct = ssh::ChannelType::from_tag(tag).unwrap();
                black_box(black_box(ct).is_forwarding());
            }
        });
    });
}

/// Benchmark WebSocket Opcode classification (is_data, is_control,
/// is_message_start, requires_response) for all 6 variants.
fn bench_ws_opcode_classification(c: &mut Criterion) {
    c.bench_function("classification/ws_opcode_properties", |b| {
        b.iter(|| {
            for nibble in [0x0u8, 0x1, 0x2, 0x8, 0x9, 0xA] {
                let op = websocket::Opcode::from_nibble(nibble).unwrap();
                let o = black_box(op);
                black_box(o.is_data());
                black_box(o.is_control());
                black_box(o.is_message_start());
                black_box(o.requires_response());
            }
        });
    });
}

/// Benchmark WebSocket CloseCode classification (is_normal, is_error,
/// is_sendable) for all 11 variants.
fn bench_ws_close_code_classification(c: &mut Criterion) {
    c.bench_function("classification/ws_close_code_properties", |b| {
        let codes: [u16; 11] = [
            1000, 1001, 1002, 1003, 1005, 1006, 1007, 1008, 1009, 1010, 1011,
        ];
        b.iter(|| {
            for wire in codes {
                let code = websocket::CloseCode::from_wire(wire).unwrap();
                let c = black_box(code);
                black_box(c.is_normal());
                black_box(c.is_error());
                black_box(c.is_sendable());
            }
        });
    });
}

/// Benchmark WebSocket CloseCode application/private range checks.
fn bench_ws_close_code_range_checks(c: &mut Criterion) {
    c.bench_function("classification/ws_close_code_ranges", |b| {
        b.iter(|| {
            for code in [999u16, 3000, 3500, 3999, 4000, 4500, 4999, 5000] {
                black_box(websocket::CloseCode::is_application_code(black_box(code)));
                black_box(websocket::CloseCode::is_private_code(black_box(code)));
            }
        });
    });
}

// =========================================================================
// Category 5: Frame construction & validation benchmarks
// =========================================================================
//
// WebSocket frame construction and validation is on the critical path
// for every WebSocket message. These benchmarks cover the builder
// helpers and the RFC 6455 validation logic.

/// Benchmark WebSocket text frame construction.
fn bench_ws_frame_text_construction(c: &mut Criterion) {
    c.bench_function("frame/ws_text_construction", |b| {
        b.iter(|| {
            let frame = websocket::Frame::text(black_box(b"hello world".to_vec()));
            black_box(frame);
        });
    });
}

/// Benchmark WebSocket binary frame construction with a larger payload.
fn bench_ws_frame_binary_construction(c: &mut Criterion) {
    let payload = vec![0xABu8; 1024];
    c.bench_function("frame/ws_binary_construction", |b| {
        b.iter(|| {
            let frame = websocket::Frame::binary(black_box(payload.clone()));
            black_box(frame);
        });
    });
}

/// Benchmark WebSocket ping frame construction.
fn bench_ws_frame_ping_construction(c: &mut Criterion) {
    c.bench_function("frame/ws_ping_construction", |b| {
        b.iter(|| {
            let frame = websocket::Frame::ping(black_box(vec![1, 2, 3, 4]));
            black_box(frame);
        });
    });
}

/// Benchmark WebSocket pong frame construction (echoing a ping payload).
fn bench_ws_frame_pong_construction(c: &mut Criterion) {
    c.bench_function("frame/ws_pong_construction", |b| {
        b.iter(|| {
            let frame = websocket::Frame::pong(black_box(vec![1, 2, 3, 4]));
            black_box(frame);
        });
    });
}

/// Benchmark WebSocket close frame construction with status code and reason.
fn bench_ws_frame_close_construction(c: &mut Criterion) {
    c.bench_function("frame/ws_close_construction", |b| {
        b.iter(|| {
            let frame = websocket::Frame::close(
                black_box(Some(1000)),
                black_box(b"normal closure"),
            );
            black_box(frame);
        });
    });
}

/// Benchmark WebSocket server frame validation (valid text frame).
fn bench_ws_frame_validate_server_valid(c: &mut Criterion) {
    let frame = websocket::Frame::text(b"hello world".to_vec());
    c.bench_function("frame/ws_validate_server_valid", |b| {
        b.iter(|| {
            let result = black_box(&frame).validate_server_frame(black_box(65536));
            let _ = black_box(result);
        });
    });
}

/// Benchmark WebSocket client frame validation (unmasked -> error path).
fn bench_ws_frame_validate_client_unmasked(c: &mut Criterion) {
    let frame = websocket::Frame::text(b"hello".to_vec()); // unmasked
    c.bench_function("frame/ws_validate_client_unmasked", |b| {
        b.iter(|| {
            let result = black_box(&frame).validate_client_frame(black_box(65536));
            let _ = black_box(result);
        });
    });
}

/// Benchmark WebSocket control frame validation (oversized ping -> error).
fn bench_ws_frame_validate_control_too_large(c: &mut Criterion) {
    let frame = websocket::Frame::ping(vec![0u8; 126]); // exceeds 125 limit
    c.bench_function("frame/ws_validate_control_too_large", |b| {
        b.iter(|| {
            let result = black_box(&frame).validate_server_frame(black_box(65536));
            let _ = black_box(result);
        });
    });
}

/// Benchmark WebSocket client frame validation (properly masked, valid).
fn bench_ws_frame_validate_client_masked(c: &mut Criterion) {
    let mut frame = websocket::Frame::text(b"hello world".to_vec());
    frame.masked = true;
    frame.masking_key = Some([0xAA, 0xBB, 0xCC, 0xDD]);
    c.bench_function("frame/ws_validate_client_masked", |b| {
        b.iter(|| {
            let result = black_box(&frame).validate_client_frame(black_box(65536));
            let _ = black_box(result);
        });
    });
}

// =========================================================================
// Criterion groups and main
// =========================================================================

criterion_group!(
    roundtrip,
    bench_http_method_roundtrip,
    bench_http_status_code_roundtrip,
    bench_http_version_roundtrip,
    bench_http_content_type_roundtrip,
    bench_http_header_type_roundtrip,
    bench_http_request_phase_roundtrip,
    bench_http_method_parse_roundtrip,
    bench_http_status_numeric_roundtrip,
    bench_grpc_status_code_roundtrip,
    bench_grpc_stream_state_roundtrip,
    bench_mqtt_qos_roundtrip,
    bench_mqtt_packet_type_roundtrip,
    bench_mqtt_suback_code_roundtrip,
    bench_dns_record_type_roundtrip,
    bench_dns_response_code_roundtrip,
    bench_ssh_message_type_roundtrip,
    bench_ssh_auth_method_roundtrip,
    bench_ssh_kex_method_roundtrip,
    bench_ssh_cipher_algorithm_roundtrip,
    bench_ssh_host_key_algorithm_roundtrip,
    bench_ssh_bastion_state_roundtrip,
    bench_ssh_channel_type_roundtrip,
    bench_ssh_disconnect_reason_roundtrip,
    bench_ws_opcode_roundtrip,
    bench_ws_close_code_roundtrip,
    bench_amqp_frame_type_roundtrip,
    bench_smtp_command_roundtrip,
    bench_syslog_severity_roundtrip,
);

criterion_group!(
    state_machine,
    bench_http_transition_valid,
    bench_http_transition_invalid,
    bench_grpc_stream_transition_valid,
    bench_grpc_closed_is_terminal,
    bench_ssh_bastion_transition,
    bench_ssh_channel_transition,
);

criterion_group!(
    validation,
    bench_dns_validate_short_domain,
    bench_dns_validate_deep_domain,
    bench_dns_validate_boundary_domain,
    bench_dns_validate_toolong_domain,
    bench_dns_validate_empty_domain,
    bench_dns_validate_empty_label_domain,
    bench_dns_validate_label_too_long,
);

criterion_group!(
    classification,
    bench_http_method_classification,
    bench_http_status_classification,
    bench_grpc_status_is_ok,
    bench_grpc_stream_capabilities,
    bench_grpc_stream_type_classification,
    bench_mqtt_qos_classification,
    bench_mqtt_qos_negotiation,
    bench_mqtt_packet_type_classification,
    bench_dns_record_type_classification,
    bench_dns_response_code_classification,
    bench_ssh_auth_method_classification,
    bench_ssh_kex_method_classification,
    bench_ssh_cipher_classification,
    bench_ssh_disconnect_classification,
    bench_ssh_channel_type_classification,
    bench_ws_opcode_classification,
    bench_ws_close_code_classification,
    bench_ws_close_code_range_checks,
);

criterion_group!(
    frame,
    bench_ws_frame_text_construction,
    bench_ws_frame_binary_construction,
    bench_ws_frame_ping_construction,
    bench_ws_frame_pong_construction,
    bench_ws_frame_close_construction,
    bench_ws_frame_validate_server_valid,
    bench_ws_frame_validate_client_unmasked,
    bench_ws_frame_validate_control_too_large,
    bench_ws_frame_validate_client_masked,
);

criterion_main!(roundtrip, state_machine, validation, classification, frame);
