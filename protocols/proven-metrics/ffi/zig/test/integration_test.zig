// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-metrics FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Collector lifecycle (create/destroy)
//   - Target management (add/remove/count)
//   - Scraping lifecycle (start/record)
//   - Metric registration
//   - Alert rule management (add/set state/count)
//   - Alerting lifecycle
//   - Stop / Cleanup
//   - Stateless collector transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const metrics = @import("metrics");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), metrics.metrics_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "MetricType encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(metrics.MetricType.counter));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(metrics.MetricType.gauge));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(metrics.MetricType.histogram));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(metrics.MetricType.summary));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(metrics.MetricType.info));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(metrics.MetricType.state_set));
}

test "ScrapeResult encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(metrics.ScrapeResult.success));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(metrics.ScrapeResult.scrape_timeout));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(metrics.ScrapeResult.connection_refused));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(metrics.ScrapeResult.invalid_response));
}

test "AlertState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(metrics.AlertState.inactive));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(metrics.AlertState.pending));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(metrics.AlertState.firing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(metrics.AlertState.resolved));
}

test "AggregationOp encoding matches Types.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(metrics.AggregationOp.sum));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(metrics.AggregationOp.avg));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(metrics.AggregationOp.min));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(metrics.AggregationOp.max));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(metrics.AggregationOp.count));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(metrics.AggregationOp.rate));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(metrics.AggregationOp.increase));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(metrics.AggregationOp.p50));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(metrics.AggregationOp.p90));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(metrics.AggregationOp.p95));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(metrics.AggregationOp.p99));
}

test "QueryError encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(metrics.QueryError.parse_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(metrics.QueryError.execution_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(metrics.QueryError.query_timeout));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(metrics.QueryError.too_many_series));
}

test "CollectorState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(metrics.CollectorState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(metrics.CollectorState.configured));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(metrics.CollectorState.scraping));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(metrics.CollectorState.alerting));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(metrics.CollectorState.stopping));
}

// =========================================================================
// Collector lifecycle
// =========================================================================

test "create returns valid slot in Idle state" {
    const slot = metrics.metrics_create(15000);
    try std.testing.expect(slot >= 0);
    defer metrics.metrics_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_state(slot)); // Idle
}

test "destroy is safe with invalid slot" {
    metrics.metrics_destroy(-1);
    metrics.metrics_destroy(999);
}

// =========================================================================
// Target management
// =========================================================================

test "add_target transitions Idle -> Configured" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const url = "http://localhost:9090/metrics";
    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_add_target(slot, url.ptr, url.len));
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_state(slot)); // Configured
    try std.testing.expectEqual(@as(u32, 1), metrics.metrics_target_count(slot));
}

test "add_target rejects duplicate URL" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const url = "http://localhost:9090/metrics";
    _ = metrics.metrics_add_target(slot, url.ptr, url.len);
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_add_target(slot, url.ptr, url.len));
}

test "remove_target transitions Configured -> Idle when last" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const url = "http://localhost:9090/metrics";
    _ = metrics.metrics_add_target(slot, url.ptr, url.len);
    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_remove_target(slot, url.ptr, url.len));
    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_state(slot)); // Idle
    try std.testing.expectEqual(@as(u32, 0), metrics.metrics_target_count(slot));
}

// =========================================================================
// Scraping lifecycle
// =========================================================================

test "start_scraping transitions Configured -> Scraping" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const url = "http://localhost:9090/metrics";
    _ = metrics.metrics_add_target(slot, url.ptr, url.len);

    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_start_scraping(slot));
    try std.testing.expectEqual(@as(u8, 2), metrics.metrics_state(slot)); // Scraping
}

test "start_scraping rejected from Idle" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_start_scraping(slot));
}

test "record_scrape records result on target" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const url = "http://localhost:9090/metrics";
    _ = metrics.metrics_add_target(slot, url.ptr, url.len);
    _ = metrics.metrics_start_scraping(slot);

    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_record_scrape(slot, 0, 0)); // Success
}

test "record_scrape rejects invalid result" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const url = "http://localhost:9090/metrics";
    _ = metrics.metrics_add_target(slot, url.ptr, url.len);
    _ = metrics.metrics_start_scraping(slot);

    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_record_scrape(slot, 0, 99));
}

// =========================================================================
// Metric registration
// =========================================================================

test "register_metric adds a metric family" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const name = "http_requests_total";
    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_register_metric(
        slot, name.ptr, name.len, 0,
    )); // Counter
    try std.testing.expectEqual(@as(u32, 1), metrics.metrics_metric_count(slot));
}

test "register_metric rejects invalid type" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const name = "bad";
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_register_metric(slot, name.ptr, name.len, 99));
}

// =========================================================================
// Alert management
// =========================================================================

test "add_alert and set_alert_state" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const name = "HighLatency";
    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_add_alert(slot, name.ptr, name.len));
    try std.testing.expectEqual(@as(u32, 1), metrics.metrics_alert_count(slot));

    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_set_alert_state(slot, 0, 2)); // Firing
}

test "set_alert_state rejects invalid state" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const name = "test";
    _ = metrics.metrics_add_alert(slot, name.ptr, name.len);
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_set_alert_state(slot, 0, 99));
}

// =========================================================================
// Alerting lifecycle
// =========================================================================

test "start_alerting transitions Scraping -> Alerting" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const url = "http://localhost:9090/metrics";
    _ = metrics.metrics_add_target(slot, url.ptr, url.len);
    _ = metrics.metrics_start_scraping(slot);

    const alert_name = "HighCPU";
    _ = metrics.metrics_add_alert(slot, alert_name.ptr, alert_name.len);

    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_start_alerting(slot));
    try std.testing.expectEqual(@as(u8, 3), metrics.metrics_state(slot)); // Alerting
}

test "start_alerting rejected without alerts" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const url = "http://localhost:9090/metrics";
    _ = metrics.metrics_add_target(slot, url.ptr, url.len);
    _ = metrics.metrics_start_scraping(slot);

    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_start_alerting(slot));
}

// =========================================================================
// Stop / Cleanup
// =========================================================================

test "stop transitions Scraping -> Stopping" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const url = "http://localhost:9090/metrics";
    _ = metrics.metrics_add_target(slot, url.ptr, url.len);
    _ = metrics.metrics_start_scraping(slot);

    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_stop(slot));
    try std.testing.expectEqual(@as(u8, 4), metrics.metrics_state(slot)); // Stopping
}

test "cleanup transitions Stopping -> Idle" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    const url = "http://localhost:9090/metrics";
    _ = metrics.metrics_add_target(slot, url.ptr, url.len);
    _ = metrics.metrics_start_scraping(slot);
    _ = metrics.metrics_stop(slot);

    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_state(slot)); // Idle
    try std.testing.expectEqual(@as(u32, 0), metrics.metrics_target_count(slot));
    try std.testing.expectEqual(@as(u32, 0), metrics.metrics_metric_count(slot));
    try std.testing.expectEqual(@as(u32, 0), metrics.metrics_alert_count(slot));
}

test "cleanup rejected from non-Stopping" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_cleanup(slot));
}

test "stop rejected from Idle" {
    const slot = metrics.metrics_create(15000);
    defer metrics.metrics_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_stop(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "metrics_can_transition matches state machine" {
    // Valid
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_can_transition(0, 1)); // Idle -> Configured
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_can_transition(1, 0)); // Configured -> Idle
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_can_transition(1, 2)); // Configured -> Scraping
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_can_transition(2, 3)); // Scraping -> Alerting
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_can_transition(1, 4)); // Configured -> Stopping
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_can_transition(2, 4)); // Scraping -> Stopping
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_can_transition(3, 4)); // Alerting -> Stopping
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_can_transition(4, 0)); // Stopping -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_can_transition(0, 2)); // Idle -/-> Scraping
    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_can_transition(0, 3)); // Idle -/-> Alerting
    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_can_transition(4, 1)); // Stopping -/-> Configured
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), metrics.metrics_state(-1));
    try std.testing.expectEqual(@as(u32, 0), metrics.metrics_target_count(-1));
    try std.testing.expectEqual(@as(u32, 0), metrics.metrics_metric_count(-1));
    try std.testing.expectEqual(@as(u32, 0), metrics.metrics_alert_count(-1));
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_stop(-1));
    try std.testing.expectEqual(@as(u8, 1), metrics.metrics_cleanup(-1));
}
