<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Log Collector protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** LogLevel matching the Idris2 ABI tags. */
enum LogLevel: int
{
    case Trace = 0;
    case Debug = 1;
    case Info = 2;
    case Warn = 3;
    case Err = 4;
    case Fatal = 5;
}

/** InputFormat matching the Idris2 ABI tags. */
enum InputFormat: int
{
    case Json = 0;
    case Logfmt = 1;
    case Syslog = 2;
    case Cef = 3;
    case Gelf = 4;
    case Raw = 5;
}

/** OutputTarget matching the Idris2 ABI tags. */
enum OutputTarget: int
{
    case File = 0;
    case Elasticsearch = 1;
    case S3 = 2;
    case Kafka = 3;
    case Stdout = 4;
}

/** FilterOp matching the Idris2 ABI tags. */
enum FilterOp: int
{
    case Include = 0;
    case Exclude = 1;
    case Transform = 2;
    case Redact = 3;
    case Sample = 4;
}

/** PipelineStage matching the Idris2 ABI tags. */
enum PipelineStage: int
{
    case Input = 0;
    case Parse = 1;
    case Filter = 2;
    case PipelineTransform = 3;
    case Output = 4;
}
