// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Container protocol types for proven-servers.

/// ContainerState matching the Idris2 ABI tags.
enum ContainerState {
  creating(0),
  running(1),
  paused(2),
  restarting(3),
  stopped(4),
  removing(5),
  dead(6);

  const ContainerState(this.tag);
  final int tag;

  static ContainerState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ContainerOperation matching the Idris2 ABI tags.
enum ContainerOperation {
  create(0),
  start(1),
  stop(2),
  restart(3),
  pause(4),
  unpause(5),
  kill(6),
  remove(7),
  exec(8),
  logs(9),
  inspect(10);

  const ContainerOperation(this.tag);
  final int tag;

  static ContainerOperation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NetworkMode matching the Idris2 ABI tags.
enum NetworkMode {
  bridge(0),
  host(1),
  none(2),
  overlay(3),
  macvlan(4);

  const NetworkMode(this.tag);
  final int tag;

  static NetworkMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// VolumeType matching the Idris2 ABI tags.
enum VolumeType {
  bind(0),
  named(1),
  tmpfs(2);

  const VolumeType(this.tag);
  final int tag;

  static VolumeType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// RestartPolicy matching the Idris2 ABI tags.
enum RestartPolicy {
  no(0),
  always(1),
  onFailure(2),
  unlessStopped(3);

  const RestartPolicy(this.tag);
  final int tag;

  static RestartPolicy? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HealthStatus matching the Idris2 ABI tags.
enum HealthStatus {
  starting(0),
  healthy(1),
  unhealthy(2),
  noCheck(3);

  const HealthStatus(this.tag);
  final int tag;

  static HealthStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
