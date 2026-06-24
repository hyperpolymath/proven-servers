-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- TelnetABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into telnet_abi_gen.zig for the comptime guard.
--
-- INSECURE PROTOCOL -- for legacy interoperability only.

module TelnetABI.Emit

import Telnet.Types
import TelnetABI.Types
import TelnetABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "CMD" "SE"                (commandToTag SE)
  , line "CMD" "NOP"               (commandToTag NOP)
  , line "CMD" "DATA_MARK"         (commandToTag DataMark)
  , line "CMD" "BRK"               (commandToTag Break)
  , line "CMD" "INTERRUPT_PROCESS" (commandToTag InterruptProcess)
  , line "CMD" "ABORT_OUTPUT"      (commandToTag AbortOutput)
  , line "CMD" "ARE_YOU_THERE"     (commandToTag AreYouThere)
  , line "CMD" "ERASE_CHAR"        (commandToTag EraseChar)
  , line "CMD" "ERASE_LINE"        (commandToTag EraseLine)
  , line "CMD" "GO_AHEAD"          (commandToTag GoAhead)
  , line "CMD" "SB"                (commandToTag SB)
  , line "CMD" "WILL"              (commandToTag Will)
  , line "CMD" "WONT"              (commandToTag Wont)
  , line "CMD" "DO_"               (commandToTag Do)
  , line "CMD" "DONT"              (commandToTag Dont)
  , line "CMD" "IAC"               (commandToTag IAC)
  , line "OPT" "ECHO"                (optionToTag Echo)
  , line "OPT" "SUPPRESS_GO_AHEAD"   (optionToTag SuppressGoAhead)
  , line "OPT" "STATUS"              (optionToTag Status)
  , line "OPT" "TIMING_MARK"         (optionToTag TimingMark)
  , line "OPT" "TERMINAL_TYPE"       (optionToTag TerminalType)
  , line "OPT" "WINDOW_SIZE"         (optionToTag WindowSize)
  , line "OPT" "TERMINAL_SPEED"      (optionToTag TerminalSpeed)
  , line "OPT" "REMOTE_FLOW_CONTROL" (optionToTag RemoteFlowControl)
  , line "OPT" "LINEMODE"            (optionToTag Linemode)
  , line "OPT" "ENVIRONMENT"         (optionToTag Environment)
  , line "NEG" "INACTIVE"  (negotiationStateToTag Inactive)
  , line "NEG" "WILL_SENT" (negotiationStateToTag WillSent)
  , line "NEG" "DO_SENT"   (negotiationStateToTag DoSent)
  , line "NEG" "ACTIVE"    (negotiationStateToTag Active)
  , line "SESSION" "IDLE"        (sessionStateToTag SSIdle)
  , line "SESSION" "NEGOTIATING" (sessionStateToTag SSNegotiating)
  , line "SESSION" "ACTIVE"      (sessionStateToTag SSActive)
  , line "SESSION" "SUBNEG"      (sessionStateToTag SSSubneg)
  , line "SESSION" "CLOSING"     (sessionStateToTag SSClosing)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
