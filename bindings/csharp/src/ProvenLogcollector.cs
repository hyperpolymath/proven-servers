// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Log Collector protocol types for proven-servers.

namespace Proven;

/// <summary>LogLevel matching the Idris2 ABI tags (0-5).</summary>
public enum LogLevel : byte
{
    Trace = 0,
    Debug = 1,
    Info = 2,
    Warn = 3,
    Err = 4,
    Fatal = 5
}

/// <summary>InputFormat matching the Idris2 ABI tags (0-5).</summary>
public enum InputFormat : byte
{
    Json = 0,
    Logfmt = 1,
    Syslog = 2,
    Cef = 3,
    Gelf = 4,
    Raw = 5
}

/// <summary>OutputTarget matching the Idris2 ABI tags (0-4).</summary>
public enum OutputTarget : byte
{
    File = 0,
    Elasticsearch = 1,
    S3 = 2,
    Kafka = 3,
    Stdout = 4
}

/// <summary>FilterOp matching the Idris2 ABI tags (0-4).</summary>
public enum FilterOp : byte
{
    Include = 0,
    Exclude = 1,
    Transform = 2,
    Redact = 3,
    Sample = 4
}

/// <summary>PipelineStage matching the Idris2 ABI tags (0-4).</summary>
public enum PipelineStage : byte
{
    Input = 0,
    Parse = 1,
    Filter = 2,
    PipelineTransform = 3,
    Output = 4
}
