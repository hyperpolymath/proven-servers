-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- SMBABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into smb_abi_gen.zig for the comptime guard.

module SMBABI.Emit

import SMB.Types
import SMBABI.Types
import SMBABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "COMMAND" "NEGOTIATE"        (commandToTag Negotiate)
  , line "COMMAND" "SESSION_SETUP"    (commandToTag SessionSetup)
  , line "COMMAND" "LOGOFF"           (commandToTag Logoff)
  , line "COMMAND" "TREE_CONNECT"     (commandToTag TreeConnect)
  , line "COMMAND" "TREE_DISCONNECT"  (commandToTag TreeDisconnect)
  , line "COMMAND" "CREATE"           (commandToTag Create)
  , line "COMMAND" "CLOSE"            (commandToTag Close)
  , line "COMMAND" "READ"             (commandToTag Read)
  , line "COMMAND" "WRITE"            (commandToTag Write)
  , line "COMMAND" "LOCK"             (commandToTag Lock)
  , line "COMMAND" "IOCTL"            (commandToTag Ioctl)
  , line "COMMAND" "CANCEL"           (commandToTag Cancel)
  , line "COMMAND" "QUERY_DIRECTORY"  (commandToTag QueryDirectory)
  , line "COMMAND" "CHANGE_NOTIFY"    (commandToTag ChangeNotify)
  , line "COMMAND" "QUERY_INFO"       (commandToTag QueryInfo)
  , line "COMMAND" "SET_INFO"         (commandToTag SetInfo)
  , line "DIALECT" "SMB2_0_2" (dialectToTag SMB2_0_2)
  , line "DIALECT" "SMB2_1"   (dialectToTag SMB2_1)
  , line "DIALECT" "SMB3_0"   (dialectToTag SMB3_0)
  , line "DIALECT" "SMB3_0_2" (dialectToTag SMB3_0_2)
  , line "DIALECT" "SMB3_1_1" (dialectToTag SMB3_1_1)
  , line "SHARE" "DISK"  (shareTypeToTag Disk)
  , line "SHARE" "PIPE"  (shareTypeToTag Pipe)
  , line "SHARE" "PRINT" (shareTypeToTag Print)
  , line "SESSION" "IDLE"          (sessionStateToTag SSIdle)
  , line "SESSION" "NEGOTIATED"    (sessionStateToTag SSNegotiated)
  , line "SESSION" "AUTHENTICATED" (sessionStateToTag SSAuthenticated)
  , line "SESSION" "TREE_CONNECTED" (sessionStateToTag SSTreeConnected)
  , line "SESSION" "FILE_OPEN"     (sessionStateToTag SSFileOpen)
  , line "SESSION" "DISCONNECTING" (sessionStateToTag SSDisconnecting)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
