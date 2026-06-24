-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- BFDABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into bfd_abi_gen.zig for the comptime guard.

module BFDABI.Emit

import BFD.Types
import BFDABI.Types
import BFDABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "STATE" "ADMIN_DOWN" (stateToTag AdminDown)
  , line "STATE" "DOWN"       (stateToTag Down)
  , line "STATE" "INIT"       (stateToTag Init)
  , line "STATE" "UP"         (stateToTag Up)
  , line "DIAG" "NO_DIAGNOSTIC"                  (diagnosticToTag NoDiagnostic)
  , line "DIAG" "CONTROL_DETECTION_TIME_EXPIRED" (diagnosticToTag ControlDetectionTimeExpired)
  , line "DIAG" "ECHO_FUNCTION_FAILED"           (diagnosticToTag EchoFunctionFailed)
  , line "DIAG" "NEIGHBOR_SIGNALED_SESSION_DOWN" (diagnosticToTag NeighborSignaledSessionDown)
  , line "DIAG" "FORWARDING_PLANE_RESET"         (diagnosticToTag ForwardingPlaneReset)
  , line "DIAG" "PATH_DOWN"                      (diagnosticToTag PathDown)
  , line "DIAG" "CONCATENATED_PATH_DOWN"         (diagnosticToTag ConcatenatedPathDown)
  , line "DIAG" "ADMINISTRATIVELY_DOWN"          (diagnosticToTag AdministrativelyDown)
  , line "DIAG" "REVERSE_CONCATENATED_PATH_DOWN" (diagnosticToTag ReverseConcatenatedPathDown)
  , line "MODE" "ASYNC_MODE"  (sessionModeToTag AsyncMode)
  , line "MODE" "DEMAND_MODE" (sessionModeToTag DemandMode)
  , line "SESSION" "IDLE"        (sessionStateToTag SSIdle)
  , line "SESSION" "SS_DOWN"     (sessionStateToTag SSDown)
  , line "SESSION" "NEGOTIATING" (sessionStateToTag SSNegotiating)
  , line "SESSION" "ESTABLISHED" (sessionStateToTag SSEstablished)
  , line "SESSION" "TEARDOWN"    (sessionStateToTag SSTeardown)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
