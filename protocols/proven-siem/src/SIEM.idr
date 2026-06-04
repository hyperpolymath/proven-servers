-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- SIEM : Top-level module for the proven-siem server.
-- Re-exports SIEM.Types and defines server constants.

module SIEM

import public SIEM.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Maximum events the SIEM can ingest per second.
public export
maxEventsPerSecond : Nat
maxEventsPerSecond = 10000

||| Default log retention period in days.
public export
retentionDays : Nat
retentionDays = 90
