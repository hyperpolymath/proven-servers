//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Tests for proven_servers Gleam bindings.
////
//// Covers tag roundtrips, classification functions, state machine
//// validation, and domain name validation for all 6 foundational
//// protocols plus the core module.

import gleam/option.{None, Some}
import gleeunit
import proven_servers/core
import proven_servers/dns
import proven_servers/graphql
import proven_servers/grpc
import proven_servers/http
import proven_servers/mqtt
import proven_servers/websocket

pub fn main() -> Nil {
  gleeunit.main()
}

// ===========================================================================
// Core module tests
// ===========================================================================

pub fn result_code_roundtrip_test() {
  // Every valid tag should roundtrip through from_int -> to_int.
  let assert Ok(code0) = core.result_from_int(0)
  let assert 0 = core.result_to_int(code0)
  let assert Ok(code4) = core.result_from_int(4)
  let assert 4 = core.result_to_int(code4)
}

pub fn result_code_invalid_tag_test() {
  let assert Error(Nil) = core.result_from_int(5)
  let assert Error(Nil) = core.result_from_int(255)
}

pub fn result_code_classification_test() {
  let assert True = core.result_is_ok(core.ResultOk)
  let assert False = core.result_is_error(core.ResultOk)
  let assert True = core.result_is_error(core.ResultError)
  let assert True = core.result_is_error(core.ResultInvalidParam)
  let assert True = core.result_is_error(core.ResultOutOfMemory)
  let assert True = core.result_is_error(core.ResultNullPointer)
}

pub fn alignment_helpers_test() {
  let assert 0 = core.padding_for(0, 8)
  let assert 4 = core.padding_for(4, 8)
  let assert 0 = core.padding_for(8, 8)
  let assert 3 = core.padding_for(1, 4)
  let assert 8 = core.align_up(4, 8)
  let assert 8 = core.align_up(8, 8)
  let assert 16 = core.align_up(9, 8)
  let assert 0 = core.align_up(0, 8)
}

pub fn platform_ptr_size_test() {
  let assert 64 = core.platform_ptr_size_bits(core.Linux)
  let assert 64 = core.platform_ptr_size_bits(core.MacOS)
  let assert 32 = core.platform_ptr_size_bits(core.Wasm)
  let assert 8 = core.platform_ptr_size_bytes(core.Linux)
  let assert 4 = core.platform_ptr_size_bytes(core.Wasm)
}

// ===========================================================================
// HTTP module tests
// ===========================================================================

pub fn method_roundtrip_test() {
  let assert Ok(m) = http.method_from_int(0)
  let assert 0 = http.method_to_int(m)
  let assert Ok(m8) = http.method_from_int(8)
  let assert 8 = http.method_to_int(m8)
  let assert Error(Nil) = http.method_from_int(9)
}

pub fn method_parse_test() {
  let assert Ok(http.Get) = http.method_parse("GET")
  let assert Ok(http.Post) = http.method_parse("POST")
  let assert Error(Nil) = http.method_parse("INVALID")
}

pub fn method_safety_test() {
  let assert True = http.method_is_safe(http.Get)
  let assert True = http.method_is_safe(http.Head)
  let assert False = http.method_is_safe(http.Post)
  let assert False = http.method_is_safe(http.Delete)
}

pub fn method_idempotency_test() {
  let assert True = http.method_is_idempotent(http.Get)
  let assert True = http.method_is_idempotent(http.Put)
  let assert True = http.method_is_idempotent(http.Delete)
  let assert False = http.method_is_idempotent(http.Post)
  let assert False = http.method_is_idempotent(http.Patch)
}

pub fn status_code_roundtrip_test() {
  let assert Ok(s) = http.status_from_int(2)
  let assert 2 = http.status_to_int(s)
  let assert Ok(s28) = http.status_from_int(28)
  let assert 28 = http.status_to_int(s28)
  let assert Error(Nil) = http.status_from_int(29)
}

pub fn status_code_numeric_test() {
  let assert 200 = http.status_numeric_code(http.StatusOk)
  let assert 404 = http.status_numeric_code(http.NotFound)
  let assert 500 = http.status_numeric_code(http.InternalError)
}

pub fn status_from_numeric_test() {
  let assert Ok(http.StatusOk) = http.status_from_numeric(200)
  let assert Ok(http.NotFound) = http.status_from_numeric(404)
  let assert Error(Nil) = http.status_from_numeric(999)
}

pub fn status_category_test() {
  let assert True = http.status_is_success(http.StatusOk)
  let assert True = http.status_is_error(http.NotFound)
  let assert True = http.status_is_error(http.InternalError)
  let assert True = http.status_is_redirect(http.MovedPermanently)
  let assert False = http.status_is_error(http.StatusOk)
}

pub fn valid_http_transitions_test() {
  let assert Some(http.StartReceiving) =
    http.validate_http_transition(http.Idle, http.Receiving)
  let assert Some(http.ParseHeaders) =
    http.validate_http_transition(http.Receiving, http.HeadersParsed)
  let assert Some(http.KeepAliveRecycle) =
    http.validate_http_transition(http.Sent, http.Idle)
  let assert Some(http.AbortReceiving) =
    http.validate_http_transition(http.Receiving, http.Sent)
}

pub fn invalid_http_transitions_test() {
  let assert None =
    http.validate_http_transition(http.Idle, http.PhaseComplete)
  let assert None =
    http.validate_http_transition(http.Idle, http.Responding)
  let assert None =
    http.validate_http_transition(http.PhaseComplete, http.Receiving)
  let assert None = http.validate_http_transition(http.Idle, http.Idle)
}

pub fn content_type_roundtrip_test() {
  let assert Ok(ct) = http.content_type_from_int(2)
  let assert 2 = http.content_type_to_int(ct)
  let assert "application/json" = http.content_type_mime(http.ApplicationJson)
  let assert Error(Nil) = http.content_type_from_int(8)
}

// ===========================================================================
// gRPC module tests
// ===========================================================================

pub fn grpc_status_roundtrip_test() {
  let assert Ok(s) = grpc.status_from_int(0)
  let assert 0 = grpc.status_to_int(s)
  let assert Ok(s16) = grpc.status_from_int(16)
  let assert 16 = grpc.status_to_int(s16)
  let assert Error(Nil) = grpc.status_from_int(17)
}

pub fn grpc_status_is_ok_test() {
  let assert True = grpc.status_is_ok(grpc.GrpcOk)
  let assert False = grpc.status_is_ok(grpc.Internal)
}

pub fn stream_type_classification_test() {
  let assert False = grpc.stream_is_client_streaming(grpc.Unary)
  let assert False = grpc.stream_is_server_streaming(grpc.Unary)
  let assert True = grpc.stream_is_server_streaming(grpc.ServerStreaming)
  let assert False = grpc.stream_is_client_streaming(grpc.ServerStreaming)
  let assert True = grpc.stream_is_client_streaming(grpc.ClientStreaming)
  let assert True = grpc.stream_is_client_streaming(grpc.BidiStreaming)
  let assert True = grpc.stream_is_server_streaming(grpc.BidiStreaming)
}

pub fn stream_state_data_capabilities_test() {
  let assert True = grpc.can_send_data(grpc.Open)
  let assert True = grpc.can_send_data(grpc.HalfClosedRemote)
  let assert False = grpc.can_send_data(grpc.HalfClosedLocal)
  let assert False = grpc.can_send_data(grpc.Closed)

  let assert True = grpc.can_receive_data(grpc.Open)
  let assert True = grpc.can_receive_data(grpc.HalfClosedLocal)
  let assert False = grpc.can_receive_data(grpc.HalfClosedRemote)
  let assert False = grpc.can_receive_data(grpc.Closed)
}

pub fn closed_is_terminal_test() {
  let assert True = grpc.stream_is_terminal(grpc.Closed)
  let assert None = grpc.validate_stream_transition(grpc.Closed, grpc.Open)
  let assert None =
    grpc.validate_stream_transition(grpc.Closed, grpc.StreamIdle)
  let assert None =
    grpc.validate_stream_transition(grpc.Closed, grpc.Closed)
}

pub fn valid_stream_transitions_test() {
  let assert Some(grpc.SendHeaders) =
    grpc.validate_stream_transition(grpc.StreamIdle, grpc.Open)
  let assert Some(grpc.LocalEndStream) =
    grpc.validate_stream_transition(grpc.Open, grpc.HalfClosedLocal)
  let assert Some(grpc.ResetFromOpen) =
    grpc.validate_stream_transition(grpc.Open, grpc.Closed)
  let assert Some(grpc.CloseHalfLocal) =
    grpc.validate_stream_transition(grpc.HalfClosedLocal, grpc.Closed)
}

pub fn impossible_stream_transitions_test() {
  let assert None =
    grpc.validate_stream_transition(grpc.StreamIdle, grpc.HalfClosedLocal)
  let assert None =
    grpc.validate_stream_transition(grpc.HalfClosedLocal, grpc.Open)
  let assert None =
    grpc.validate_stream_transition(grpc.Reserved, grpc.Open)
}

// ===========================================================================
// GraphQL module tests
// ===========================================================================

pub fn operation_type_roundtrip_test() {
  let assert Ok(op) = graphql.operation_from_int(0)
  let assert 0 = graphql.operation_to_int(op)
  let assert Ok(op2) = graphql.operation_from_int(2)
  let assert 2 = graphql.operation_to_int(op2)
  let assert Error(Nil) = graphql.operation_from_int(3)
}

pub fn type_kind_roundtrip_test() {
  let assert Ok(tk) = graphql.type_kind_from_int(0)
  let assert 0 = graphql.type_kind_to_int(tk)
  let assert Ok(tk7) = graphql.type_kind_from_int(7)
  let assert 7 = graphql.type_kind_to_int(tk7)
  let assert Error(Nil) = graphql.type_kind_from_int(8)
}

pub fn type_kind_classification_test() {
  let assert True = graphql.type_kind_is_wrapper(graphql.List)
  let assert True = graphql.type_kind_is_wrapper(graphql.NonNull)
  let assert False = graphql.type_kind_is_wrapper(graphql.Scalar)

  let assert True = graphql.type_kind_is_composite(graphql.Object)
  let assert True = graphql.type_kind_is_composite(graphql.Interface)
  let assert True = graphql.type_kind_is_composite(graphql.Union)
  let assert False = graphql.type_kind_is_composite(graphql.Scalar)
  let assert False = graphql.type_kind_is_composite(graphql.Enum)
}

pub fn directive_location_roundtrip_test() {
  let assert Ok(loc) = graphql.directive_location_from_int(0)
  let assert 0 = graphql.directive_location_to_int(loc)
  let assert Ok(loc17) = graphql.directive_location_from_int(17)
  let assert 17 = graphql.directive_location_to_int(loc17)
  let assert Error(Nil) = graphql.directive_location_from_int(18)
}

pub fn directive_location_classification_test() {
  let assert True =
    graphql.directive_location_is_executable(graphql.DlQuery)
  let assert True =
    graphql.directive_location_is_executable(graphql.DlField)
  let assert False =
    graphql.directive_location_is_executable(graphql.DlSchema)
  let assert True =
    graphql.directive_location_is_type_system(graphql.DlSchema)
  let assert True =
    graphql.directive_location_is_type_system(graphql.DlFieldDefinition)
}

pub fn error_category_roundtrip_test() {
  let assert Ok(ec) = graphql.error_category_from_int(0)
  let assert 0 = graphql.error_category_to_int(ec)
  let assert Ok(ec4) = graphql.error_category_from_int(4)
  let assert 4 = graphql.error_category_to_int(ec4)
  let assert Error(Nil) = graphql.error_category_from_int(5)
}

// ===========================================================================
// WebSocket module tests
// ===========================================================================

pub fn opcode_roundtrip_test() {
  let assert Ok(websocket.Continuation) = websocket.opcode_from_int(0x0)
  let assert Ok(websocket.Text) = websocket.opcode_from_int(0x1)
  let assert Ok(websocket.Binary) = websocket.opcode_from_int(0x2)
  let assert Ok(websocket.Close) = websocket.opcode_from_int(0x8)
  let assert Ok(websocket.Ping) = websocket.opcode_from_int(0x9)
  let assert Ok(websocket.Pong) = websocket.opcode_from_int(0xA)
  let assert 0x1 = websocket.opcode_to_int(websocket.Text)
  let assert 0x8 = websocket.opcode_to_int(websocket.Close)
}

pub fn opcode_reserved_rejected_test() {
  let assert Error(Nil) = websocket.opcode_from_int(0x3)
  let assert Error(Nil) = websocket.opcode_from_int(0x7)
  let assert Error(Nil) = websocket.opcode_from_int(0xB)
  let assert Error(Nil) = websocket.opcode_from_int(0xF)
}

pub fn opcode_classification_test() {
  let assert True = websocket.opcode_is_data(websocket.Text)
  let assert True = websocket.opcode_is_data(websocket.Binary)
  let assert True = websocket.opcode_is_data(websocket.Continuation)
  let assert False = websocket.opcode_is_data(websocket.Close)

  let assert True = websocket.opcode_is_control(websocket.Close)
  let assert True = websocket.opcode_is_control(websocket.Ping)
  let assert True = websocket.opcode_is_control(websocket.Pong)
  let assert False = websocket.opcode_is_control(websocket.Text)

  let assert True = websocket.opcode_is_message_start(websocket.Text)
  let assert True = websocket.opcode_is_message_start(websocket.Binary)
  let assert False = websocket.opcode_is_message_start(websocket.Continuation)

  let assert True = websocket.opcode_requires_response(websocket.Ping)
  let assert True = websocket.opcode_requires_response(websocket.Close)
  let assert False = websocket.opcode_requires_response(websocket.Text)
}

pub fn close_code_roundtrip_test() {
  let assert Ok(websocket.Normal) = websocket.close_code_from_int(1000)
  let assert Ok(websocket.GoingAway) = websocket.close_code_from_int(1001)
  let assert Ok(websocket.InternalError) = websocket.close_code_from_int(1011)
  let assert 1000 = websocket.close_code_to_int(websocket.Normal)
  let assert 1011 = websocket.close_code_to_int(websocket.InternalError)
}

pub fn close_code_unknown_rejected_test() {
  let assert Error(Nil) = websocket.close_code_from_int(1004)
  let assert Error(Nil) = websocket.close_code_from_int(999)
  let assert Error(Nil) = websocket.close_code_from_int(1012)
}

pub fn close_code_classification_test() {
  let assert True = websocket.close_code_is_normal(websocket.Normal)
  let assert True = websocket.close_code_is_normal(websocket.GoingAway)
  let assert False = websocket.close_code_is_normal(websocket.ProtocolError)

  let assert True = websocket.close_code_is_error(websocket.ProtocolError)
  let assert True = websocket.close_code_is_error(websocket.InternalError)
  let assert False = websocket.close_code_is_error(websocket.Normal)
  let assert False = websocket.close_code_is_error(websocket.NoStatus)

  let assert True = websocket.close_code_is_sendable(websocket.Normal)
  let assert False = websocket.close_code_is_sendable(websocket.NoStatus)
  let assert False = websocket.close_code_is_sendable(websocket.Abnormal)
}

pub fn close_code_ranges_test() {
  let assert True = websocket.is_application_code(4000)
  let assert True = websocket.is_application_code(4999)
  let assert False = websocket.is_application_code(3999)
  let assert False = websocket.is_application_code(5000)

  let assert True = websocket.is_private_code(3000)
  let assert True = websocket.is_private_code(3999)
  let assert False = websocket.is_private_code(2999)
  let assert False = websocket.is_private_code(4000)
}

pub fn frame_validate_client_unmasked_test() {
  let frame =
    websocket.Frame(fin: True, opcode: websocket.Text, masked: False, payload_length: 5)
  let assert Error(websocket.ClientFrameNotMasked) =
    websocket.validate_client_frame(frame, 65_536)
}

pub fn frame_validate_server_masked_test() {
  let frame =
    websocket.Frame(fin: True, opcode: websocket.Text, masked: True, payload_length: 5)
  let assert Error(websocket.ServerFrameMasked) =
    websocket.validate_server_frame(frame, 65_536)
}

pub fn frame_validate_control_too_large_test() {
  let frame =
    websocket.Frame(
      fin: True,
      opcode: websocket.Ping,
      masked: False,
      payload_length: 126,
    )
  let assert Error(websocket.ControlFrameTooLarge(..)) =
    websocket.validate_server_frame(frame, 65_536)
}

pub fn frame_validate_control_fragmented_test() {
  let frame =
    websocket.Frame(
      fin: False,
      opcode: websocket.Ping,
      masked: False,
      payload_length: 3,
    )
  let assert Error(websocket.ControlFrameFragmented(..)) =
    websocket.validate_server_frame(frame, 65_536)
}

// ===========================================================================
// MQTT module tests
// ===========================================================================

pub fn qos_roundtrip_test() {
  let assert Ok(q0) = mqtt.qos_from_int(0)
  let assert 0 = mqtt.qos_to_int(q0)
  let assert Ok(q2) = mqtt.qos_from_int(2)
  let assert 2 = mqtt.qos_to_int(q2)
  let assert Error(Nil) = mqtt.qos_from_int(3)
}

pub fn qos_ack_requirements_test() {
  let assert False = mqtt.qos_requires_ack(mqtt.AtMostOnce)
  let assert True = mqtt.qos_requires_ack(mqtt.AtLeastOnce)
  let assert True = mqtt.qos_requires_ack(mqtt.ExactlyOnce)

  let assert 0 = mqtt.qos_ack_packet_count(mqtt.AtMostOnce)
  let assert 1 = mqtt.qos_ack_packet_count(mqtt.AtLeastOnce)
  let assert 3 = mqtt.qos_ack_packet_count(mqtt.ExactlyOnce)
}

pub fn qos_negotiation_test() {
  let assert mqtt.AtLeastOnce =
    mqtt.qos_effective(mqtt.ExactlyOnce, mqtt.AtLeastOnce)
  let assert mqtt.AtMostOnce =
    mqtt.qos_effective(mqtt.AtMostOnce, mqtt.ExactlyOnce)
  let assert mqtt.AtMostOnce =
    mqtt.qos_delivery(mqtt.ExactlyOnce, mqtt.AtMostOnce)
}

pub fn suback_code_roundtrip_test() {
  let assert Ok(mqtt.GrantedQoS0) = mqtt.suback_from_int(0x00)
  let assert Ok(mqtt.GrantedQoS1) = mqtt.suback_from_int(0x01)
  let assert Ok(mqtt.GrantedQoS2) = mqtt.suback_from_int(0x02)
  let assert Ok(mqtt.SubFailure) = mqtt.suback_from_int(0x80)
  let assert 0x00 = mqtt.suback_to_int(mqtt.GrantedQoS0)
  let assert 0x80 = mqtt.suback_to_int(mqtt.SubFailure)
}

pub fn suback_to_qos_test() {
  let assert Ok(mqtt.AtMostOnce) = mqtt.suback_to_qos(mqtt.GrantedQoS0)
  let assert Ok(mqtt.AtLeastOnce) = mqtt.suback_to_qos(mqtt.GrantedQoS1)
  let assert Ok(mqtt.ExactlyOnce) = mqtt.suback_to_qos(mqtt.GrantedQoS2)
  let assert Error(Nil) = mqtt.suback_to_qos(mqtt.SubFailure)
}

pub fn packet_type_roundtrip_test() {
  let assert Ok(pt1) = mqtt.packet_type_from_int(1)
  let assert 1 = mqtt.packet_type_to_int(pt1)
  let assert Ok(pt15) = mqtt.packet_type_from_int(15)
  let assert 15 = mqtt.packet_type_to_int(pt15)
  let assert Error(Nil) = mqtt.packet_type_from_int(0)
  let assert Error(Nil) = mqtt.packet_type_from_int(16)
}

pub fn packet_type_direction_test() {
  let assert mqtt.ClientToServer = mqtt.packet_direction(mqtt.MqttConnect)
  let assert mqtt.ServerToClient = mqtt.packet_direction(mqtt.Connack)
  let assert mqtt.Bidirectional = mqtt.packet_direction(mqtt.Publish)
  let assert mqtt.ClientToServer = mqtt.packet_direction(mqtt.Subscribe)
  let assert mqtt.ServerToClient = mqtt.packet_direction(mqtt.Suback)
}

pub fn packet_type_packet_id_test() {
  let assert True = mqtt.packet_requires_id(mqtt.Puback)
  let assert True = mqtt.packet_requires_id(mqtt.Subscribe)
  let assert False = mqtt.packet_requires_id(mqtt.MqttConnect)
  let assert False = mqtt.packet_requires_id(mqtt.Publish)
  let assert False = mqtt.packet_requires_id(mqtt.Auth)
}

// ===========================================================================
// DNS module tests
// ===========================================================================

pub fn record_type_roundtrip_test() {
  let assert Ok(dns.A) = dns.record_type_from_int(1)
  let assert 1 = dns.record_type_to_int(dns.A)
  let assert Ok(dns.Aaaa) = dns.record_type_from_int(28)
  let assert 28 = dns.record_type_to_int(dns.Aaaa)
  let assert Ok(dns.Srv) = dns.record_type_from_int(33)
  let assert 33 = dns.record_type_to_int(dns.Srv)
}

pub fn record_type_unknown_rejected_test() {
  let assert Error(Nil) = dns.record_type_from_int(0)
  let assert Error(Nil) = dns.record_type_from_int(255)
}

pub fn record_type_classification_test() {
  let assert True = dns.record_type_is_address(dns.A)
  let assert True = dns.record_type_is_address(dns.Aaaa)
  let assert False = dns.record_type_is_address(dns.Cname)
  let assert True = dns.record_type_is_infrastructure(dns.Ns)
  let assert True = dns.record_type_is_infrastructure(dns.Soa)
  let assert False = dns.record_type_is_infrastructure(dns.Mx)
}

pub fn response_code_roundtrip_test() {
  let assert Ok(rc0) = dns.response_code_from_int(0)
  let assert 0 = dns.response_code_to_int(rc0)
  let assert Ok(rc5) = dns.response_code_from_int(5)
  let assert 5 = dns.response_code_to_int(rc5)
  let assert Error(Nil) = dns.response_code_from_int(6)
}

pub fn response_code_classification_test() {
  let assert True = dns.response_code_is_success(dns.NoError)
  let assert False = dns.response_code_is_success(dns.NameError)
  let assert True = dns.response_code_is_nxdomain(dns.NameError)
  let assert False = dns.response_code_is_nxdomain(dns.NoError)
}

pub fn domain_name_valid_test() {
  let assert Ok(Nil) = dns.validate_domain_name("example.com")
  let assert Ok(Nil) = dns.validate_domain_name("sub.example.com")
  let assert Ok(Nil) = dns.validate_domain_name("a")
}

pub fn domain_name_empty_test() {
  let assert Error(dns.EmptyName) = dns.validate_domain_name("")
}

pub fn domain_name_empty_label_test() {
  let assert Error(dns.EmptyLabel) = dns.validate_domain_name("example..com")
}

pub fn constants_match_idris_test() {
  let assert 53 = dns.dns_port
  let assert 512 = dns.max_udp_size
  let assert 65_535 = dns.max_tcp_size
  let assert 63 = dns.max_label_length
  let assert 253 = dns.max_name_length
  let assert 4096 = dns.edns_udp_size
}
