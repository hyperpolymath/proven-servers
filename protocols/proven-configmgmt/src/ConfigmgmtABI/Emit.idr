-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ConfigmgmtABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into configmgmt_abi_gen.zig for the comptime guard.

module ConfigmgmtABI.Emit

import Configmgmt.Types
import ConfigmgmtABI.Types
import ConfigmgmtABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "RT" "FILE"     (resourceTypeToTag File)
  , line "RT" "PACKAGE"  (resourceTypeToTag Package)
  , line "RT" "SERVICE"  (resourceTypeToTag Service)
  , line "RT" "USER"     (resourceTypeToTag User)
  , line "RT" "GROUP"    (resourceTypeToTag Group)
  , line "RT" "CRON"     (resourceTypeToTag Cron)
  , line "RT" "MOUNT"    (resourceTypeToTag Mount)
  , line "RT" "FIREWALL" (resourceTypeToTag Firewall)
  , line "RT" "REGISTRY" (resourceTypeToTag Registry)
  , line "RS" "PRESENT"  (resourceStateToTag Present)
  , line "RS" "ABSENT"   (resourceStateToTag Absent)
  , line "RS" "RUNNING"  (resourceStateToTag Running)
  , line "RS" "STOPPED"  (resourceStateToTag Stopped)
  , line "RS" "ENABLED"  (resourceStateToTag Enabled)
  , line "RS" "DISABLED" (resourceStateToTag Disabled)
  , line "ACT" "CREATE"  (changeActionToTag Create)
  , line "ACT" "MODIFY"  (changeActionToTag Modify)
  , line "ACT" "DELETE"  (changeActionToTag Delete)
  , line "ACT" "RESTART" (changeActionToTag Restart)
  , line "ACT" "RELOAD"  (changeActionToTag Reload)
  , line "ACT" "SKIP"    (changeActionToTag Skip)
  , line "DS" "IN_SYNC"   (driftStatusToTag InSync)
  , line "DS" "DRIFTED"   (driftStatusToTag Drifted)
  , line "DS" "UNKNOWN"   (driftStatusToTag DUnknown)
  , line "DS" "UNMANAGED" (driftStatusToTag Unmanaged)
  , line "AM" "ENFORCE" (applyModeToTag Enforce)
  , line "AM" "DRY_RUN" (applyModeToTag DryRun)
  , line "AM" "AUDIT"   (applyModeToTag Audit)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
