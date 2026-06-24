-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- AppserverABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into appserver_abi_gen.zig for the comptime guard.

module AppserverABI.Emit

import Appserver.Types
import AppserverABI.Types
import AppserverABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "REQ" "HTTP"      (requestTypeToTag HTTP)
  , line "REQ" "WEBSOCKET" (requestTypeToTag WebSocket)
  , line "REQ" "GRPC"      (requestTypeToTag GRPC)
  , line "REQ" "GRAPHQL"   (requestTypeToTag GraphQL)
  , line "LIFECYCLE" "INITIALIZING" (lifecycleStateToTag Initializing)
  , line "LIFECYCLE" "STARTING"     (lifecycleStateToTag Starting)
  , line "LIFECYCLE" "RUNNING"      (lifecycleStateToTag Running)
  , line "LIFECYCLE" "DRAINING"     (lifecycleStateToTag Draining)
  , line "LIFECYCLE" "STOPPING"     (lifecycleStateToTag Stopping)
  , line "LIFECYCLE" "STOPPED"      (lifecycleStateToTag Stopped)
  , line "HEALTH" "LIVENESS"  (healthCheckToTag Liveness)
  , line "HEALTH" "READINESS" (healthCheckToTag Readiness)
  , line "HEALTH" "STARTUP"   (healthCheckToTag Startup)
  , line "DEPLOY" "ROLLING_UPDATE" (deployStrategyToTag RollingUpdate)
  , line "DEPLOY" "BLUE_GREEN"     (deployStrategyToTag BlueGreen)
  , line "DEPLOY" "CANARY"         (deployStrategyToTag Canary)
  , line "DEPLOY" "RECREATE"       (deployStrategyToTag Recreate)
  , line "ERR" "CLIENT_ERROR" (errorCategoryToTag ClientError)
  , line "ERR" "SERVER_ERROR" (errorCategoryToTag ServerError)
  , line "ERR" "TIMEOUT"      (errorCategoryToTag Timeout)
  , line "ERR" "CIRCUIT_OPEN" (errorCategoryToTag CircuitOpen)
  , line "ERR" "RATE_LIMITED" (errorCategoryToTag RateLimited)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
