-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- MonitorABI.Types: C-ABI-compatible numeric representations of Monitor types.
--
-- Maps every constructor of the core Monitor sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/monitor.h) and the
-- Zig FFI enums (ffi/zig/src/monitor.zig) exactly.
--
-- Types covered:
--   CheckType    (11 constructors, tags 0-10)
--   Status       (5 constructors, tags 0-4)
--   AlertChannel (5 constructors, tags 0-4)
--   Severity     (4 constructors, tags 0-3)
--   CheckState   (6 constructors, tags 0-5)

module MonitorABI.Types

import Monitor.Types

%default total

---------------------------------------------------------------------------
-- CheckType (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
checkTypeToTag : CheckType -> Bits8
checkTypeToTag HTTP        = 0
checkTypeToTag TCP         = 1
checkTypeToTag UDP         = 2
checkTypeToTag ICMP        = 3
checkTypeToTag DNS         = 4
checkTypeToTag Certificate = 5
checkTypeToTag Disk        = 6
checkTypeToTag CPU         = 7
checkTypeToTag Memory      = 8
checkTypeToTag Process     = 9
checkTypeToTag Custom      = 10

public export
tagToCheckType : Bits8 -> Maybe CheckType
tagToCheckType 0  = Just HTTP
tagToCheckType 1  = Just TCP
tagToCheckType 2  = Just UDP
tagToCheckType 3  = Just ICMP
tagToCheckType 4  = Just DNS
tagToCheckType 5  = Just Certificate
tagToCheckType 6  = Just Disk
tagToCheckType 7  = Just CPU
tagToCheckType 8  = Just Memory
tagToCheckType 9  = Just Process
tagToCheckType 10 = Just Custom
tagToCheckType _  = Nothing

public export
checkTypeRoundtrip : (c : CheckType) -> tagToCheckType (checkTypeToTag c) = Just c
checkTypeRoundtrip HTTP        = Refl
checkTypeRoundtrip TCP         = Refl
checkTypeRoundtrip UDP         = Refl
checkTypeRoundtrip ICMP        = Refl
checkTypeRoundtrip DNS         = Refl
checkTypeRoundtrip Certificate = Refl
checkTypeRoundtrip Disk        = Refl
checkTypeRoundtrip CPU         = Refl
checkTypeRoundtrip Memory      = Refl
checkTypeRoundtrip Process     = Refl
checkTypeRoundtrip Custom      = Refl

---------------------------------------------------------------------------
-- Status (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
statusToTag : Status -> Bits8
statusToTag Up          = 0
statusToTag Down        = 1
statusToTag Degraded    = 2
statusToTag Unknown     = 3
statusToTag Maintenance = 4

public export
tagToStatus : Bits8 -> Maybe Status
tagToStatus 0 = Just Up
tagToStatus 1 = Just Down
tagToStatus 2 = Just Degraded
tagToStatus 3 = Just Unknown
tagToStatus 4 = Just Maintenance
tagToStatus _ = Nothing

public export
statusRoundtrip : (s : Status) -> tagToStatus (statusToTag s) = Just s
statusRoundtrip Up          = Refl
statusRoundtrip Down        = Refl
statusRoundtrip Degraded    = Refl
statusRoundtrip Unknown     = Refl
statusRoundtrip Maintenance = Refl

---------------------------------------------------------------------------
-- AlertChannel (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
alertChannelToTag : AlertChannel -> Bits8
alertChannelToTag Email     = 0
alertChannelToTag SMS       = 1
alertChannelToTag Webhook   = 2
alertChannelToTag Slack     = 3
alertChannelToTag PagerDuty = 4

public export
tagToAlertChannel : Bits8 -> Maybe AlertChannel
tagToAlertChannel 0 = Just Email
tagToAlertChannel 1 = Just SMS
tagToAlertChannel 2 = Just Webhook
tagToAlertChannel 3 = Just Slack
tagToAlertChannel 4 = Just PagerDuty
tagToAlertChannel _ = Nothing

public export
alertChannelRoundtrip : (a : AlertChannel) -> tagToAlertChannel (alertChannelToTag a) = Just a
alertChannelRoundtrip Email     = Refl
alertChannelRoundtrip SMS       = Refl
alertChannelRoundtrip Webhook   = Refl
alertChannelRoundtrip Slack     = Refl
alertChannelRoundtrip PagerDuty = Refl

---------------------------------------------------------------------------
-- Severity (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
severityToTag : Severity -> Bits8
severityToTag Info     = 0
severityToTag Warning  = 1
severityToTag Error    = 2
severityToTag Critical = 3

public export
tagToSeverity : Bits8 -> Maybe Severity
tagToSeverity 0 = Just Info
tagToSeverity 1 = Just Warning
tagToSeverity 2 = Just Error
tagToSeverity 3 = Just Critical
tagToSeverity _ = Nothing

public export
severityRoundtrip : (s : Severity) -> tagToSeverity (severityToTag s) = Just s
severityRoundtrip Info     = Refl
severityRoundtrip Warning  = Refl
severityRoundtrip Error    = Refl
severityRoundtrip Critical = Refl

---------------------------------------------------------------------------
-- CheckState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
checkStateToTag : CheckState -> Bits8
checkStateToTag Pending = 0
checkStateToTag Running = 1
checkStateToTag Passed  = 2
checkStateToTag Failed  = 3
checkStateToTag Timeout = 4
checkStateToTag CSError = 5

public export
tagToCheckState : Bits8 -> Maybe CheckState
tagToCheckState 0 = Just Pending
tagToCheckState 1 = Just Running
tagToCheckState 2 = Just Passed
tagToCheckState 3 = Just Failed
tagToCheckState 4 = Just Timeout
tagToCheckState 5 = Just CSError
tagToCheckState _ = Nothing

public export
checkStateRoundtrip : (s : CheckState) -> tagToCheckState (checkStateToTag s) = Just s
checkStateRoundtrip Pending = Refl
checkStateRoundtrip Running = Refl
checkStateRoundtrip Passed  = Refl
checkStateRoundtrip Failed  = Refl
checkStateRoundtrip Timeout = Refl
checkStateRoundtrip CSError = Refl

---------------------------------------------------------------------------
-- MonitorState: Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| Monitor server lifecycle states used by the FFI layer.
public export
data MonitorState : Type where
  ||| Not started; initial state.
  MSIdle       : MonitorState
  ||| Configured but not yet running checks.
  MSConfigured : MonitorState
  ||| Actively running scheduled checks.
  MSRunning    : MonitorState
  ||| Temporarily paused (no checks dispatched).
  MSPaused     : MonitorState
  ||| Alert firing in progress.
  MSAlerting   : MonitorState
  ||| Shutting down.
  MSShutdown   : MonitorState

public export
Eq MonitorState where
  MSIdle       == MSIdle       = True
  MSConfigured == MSConfigured = True
  MSRunning    == MSRunning    = True
  MSPaused     == MSPaused     = True
  MSAlerting   == MSAlerting   = True
  MSShutdown   == MSShutdown   = True
  _            == _            = False

public export
Show MonitorState where
  show MSIdle       = "Idle"
  show MSConfigured = "Configured"
  show MSRunning    = "Running"
  show MSPaused     = "Paused"
  show MSAlerting   = "Alerting"
  show MSShutdown   = "Shutdown"

public export
monitorStateToTag : MonitorState -> Bits8
monitorStateToTag MSIdle       = 0
monitorStateToTag MSConfigured = 1
monitorStateToTag MSRunning    = 2
monitorStateToTag MSPaused     = 3
monitorStateToTag MSAlerting   = 4
monitorStateToTag MSShutdown   = 5

public export
tagToMonitorState : Bits8 -> Maybe MonitorState
tagToMonitorState 0 = Just MSIdle
tagToMonitorState 1 = Just MSConfigured
tagToMonitorState 2 = Just MSRunning
tagToMonitorState 3 = Just MSPaused
tagToMonitorState 4 = Just MSAlerting
tagToMonitorState 5 = Just MSShutdown
tagToMonitorState _ = Nothing

public export
monitorStateRoundtrip : (s : MonitorState) -> tagToMonitorState (monitorStateToTag s) = Just s
monitorStateRoundtrip MSIdle       = Refl
monitorStateRoundtrip MSConfigured = Refl
monitorStateRoundtrip MSRunning    = Refl
monitorStateRoundtrip MSPaused     = Refl
monitorStateRoundtrip MSAlerting   = Refl
monitorStateRoundtrip MSShutdown   = Refl
