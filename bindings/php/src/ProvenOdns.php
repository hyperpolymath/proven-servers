<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ODNS protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Role matching the Idris2 ABI tags. */
enum Role: int
{
    case Client = 0;
    case Proxy = 1;
    case Target = 2;
}

/** OdnsMessageType matching the Idris2 ABI tags. */
enum OdnsMessageType: int
{
    case Query = 0;
    case Response = 1;
}

/** OdnsErrorReason matching the Idris2 ABI tags. */
enum OdnsErrorReason: int
{
    case ProxyError = 0;
    case TargetError = 1;
    case DecryptionFailed = 2;
    case InvalidConfig = 3;
    case PayloadTooLarge = 4;
}

/** EncapsulationFormat matching the Idris2 ABI tags. */
enum EncapsulationFormat: int
{
    case Hpke = 0;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case KeyExchange = 1;
    case Ready = 2;
    case Processing = 3;
    case Closing = 4;
}
