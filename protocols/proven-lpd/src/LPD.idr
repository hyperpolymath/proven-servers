-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- =========================================================================
-- LEGACY PROTOCOL WARNING — READ THIS BEFORE USING THIS SKELETON
-- =========================================================================
--
-- LPD (RFC 1179) is a LEGACY protocol with NO built-in security:
--
--   - No encryption — print data is transmitted in cleartext
--   - No authentication — anyone on the network can submit print jobs
--   - No integrity — print data can be modified in transit
--   - No access control beyond source-port checking (ports 721-731)
--
-- LPD has been SUPERSEDED by IPP (Internet Printing Protocol, RFC 8011)
-- which supports TLS, authentication, and access control.
--
-- This skeleton exists ONLY for:
--   1. Legacy printers and print servers that speak only LPD
--      (hardware that cannot be upgraded to IPP/CUPS)
--   2. Building a secure print gateway in front of such hardware
--      (accept IPP/TLS from clients, forward LPD to legacy printer
--       on an isolated network segment)
--   3. Educational/research purposes
--
-- If you are building a new print system, use IPP (compose proven-httpd
-- with print-specific types). This skeleton is for keeping old hardware
-- working — not for building new insecure print infrastructure.
--
-- Recommended architecture for legacy LPD printers:
--
--   [Client] --IPP/TLS--> [Print Gateway] --LPD--> [Legacy Printer]
--                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                         Secure boundary. The LPD hop is on an
--                         isolated network segment only.
--
-- =========================================================================
--
-- Architecture:
--   - Command: 5 LPD commands as a closed sum type with byte codes
--   - Job: Print job records with validated IDs (000-999) and status tracking
--   - Queue: Bounded FIFO queue with capacity enforcement and CRUD operations
--   - Protocol: State machine (Idle -> ReceivingControlFile -> ReceivingDataFile)
--   - Spool: Spool directory management with RFC 1179 file naming conventions
--
-- This module defines core LPD constants and re-exports all submodules.

||| Top-level module for proven-lpd.
|||
||| **LEGACY PROTOCOL** — See security warning above.
||| Use IPP (RFC 8011) for all new print systems.
||| This skeleton is for legacy printer interoperability only.
module LPD

import public LPD.Command
import public LPD.Job
import public LPD.Queue
import public LPD.Protocol
import public LPD.Spool

||| Standard LPD port (RFC 1179 Section 1).
public export
lpdPort : Bits16
lpdPort = 515

||| Maximum print job size in bytes (100 MiB default).
public export
maxJobSize : Nat
maxJobSize = 104857600

||| Maximum number of jobs in a single queue.
public export
maxQueueDepth : Nat
maxQueueDepth = 100

||| Default spool directory base path.
public export
defaultSpoolPath : String
defaultSpoolPath = "/var/spool/lpd"

||| Server identification string for proven-lpd.
public export
serverIdent : String
serverIdent = "proven-lpd/0.1.0"

||| Security notice string. Implementations SHOULD display this on startup.
public export
securityNotice : String
securityNotice = "WARNING: LPD is a legacy protocol with no encryption or authentication. Use IPP (RFC 8011) for new print systems."
