<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SPARQL protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** SparqlQueryType matching the Idris2 ABI tags. */
enum SparqlQueryType: int
{
    case Select = 0;
    case Construct = 1;
    case Ask = 2;
    case Describe = 3;
}

/** UpdateType matching the Idris2 ABI tags. */
enum UpdateType: int
{
    case Insert = 0;
    case Delete = 1;
    case Load = 2;
    case Clear = 3;
    case Create = 4;
    case Drop = 5;
}

/** ResultFormat matching the Idris2 ABI tags. */
enum ResultFormat: int
{
    case Xml = 0;
    case Json = 1;
    case Csv = 2;
    case Tsv = 3;
}

/** SparqlErrorType matching the Idris2 ABI tags. */
enum SparqlErrorType: int
{
    case ParseError = 0;
    case QueryTimeout = 1;
    case ResultsTooLarge = 2;
    case UnknownGraph = 3;
    case AccessDenied = 4;
}
