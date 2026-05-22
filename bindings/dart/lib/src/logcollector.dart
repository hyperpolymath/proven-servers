// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Log Collector protocol types for proven-servers.

/// LogLevel matching the Idris2 ABI tags.
enum LogLevel {
  trace(0),
  debug(1),
  info(2),
  warn(3),
  err(4),
  fatal(5);

  const LogLevel(this.tag);
  final int tag;

  static LogLevel? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// InputFormat matching the Idris2 ABI tags.
enum InputFormat {
  json(0),
  logfmt(1),
  syslog(2),
  cef(3),
  gelf(4),
  raw(5);

  const InputFormat(this.tag);
  final int tag;

  static InputFormat? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// OutputTarget matching the Idris2 ABI tags.
enum OutputTarget {
  file(0),
  elasticsearch(1),
  s3(2),
  kafka(3),
  stdout(4);

  const OutputTarget(this.tag);
  final int tag;

  static OutputTarget? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// FilterOp matching the Idris2 ABI tags.
enum FilterOp {
  include(0),
  exclude(1),
  transform(2),
  redact(3),
  sample(4);

  const FilterOp(this.tag);
  final int tag;

  static FilterOp? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PipelineStage matching the Idris2 ABI tags.
enum PipelineStage {
  input(0),
  parse(1),
  filter(2),
  pipelineTransform(3),
  output(4);

  const PipelineStage(this.tag);
  final int tag;

  static PipelineStage? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
