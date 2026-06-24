-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- IMAPABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into imap_abi_gen.zig for the comptime guard.

module IMAPABI.Emit

import IMAP.Types
import IMAPABI.Types
import IMAPABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "COMMAND" "LOGIN"      (commandToTag Login)
  , line "COMMAND" "LOGOUT"     (commandToTag Logout)
  , line "COMMAND" "SELECT"     (commandToTag Select)
  , line "COMMAND" "EXAMINE"    (commandToTag Examine)
  , line "COMMAND" "CREATE"     (commandToTag Create)
  , line "COMMAND" "DELETE"     (commandToTag Delete)
  , line "COMMAND" "RENAME"     (commandToTag Rename)
  , line "COMMAND" "LIST"       (commandToTag List)
  , line "COMMAND" "FETCH"      (commandToTag Fetch)
  , line "COMMAND" "STORE"      (commandToTag Store)
  , line "COMMAND" "SEARCH"     (commandToTag Search)
  , line "COMMAND" "COPY"       (commandToTag Copy)
  , line "COMMAND" "NOOP"       (commandToTag Noop)
  , line "COMMAND" "CAPABILITY" (commandToTag Capability)
  , line "STATE" "NOT_AUTHENTICATED" (stateToTag NotAuthenticated)
  , line "STATE" "AUTHENTICATED"     (stateToTag Authenticated)
  , line "STATE" "SELECTED"          (stateToTag Selected)
  , line "STATE" "LOGOUT_STATE"      (stateToTag LogoutState)
  , line "FLAG" "SEEN"     (flagToTag Seen)
  , line "FLAG" "ANSWERED" (flagToTag Answered)
  , line "FLAG" "FLAGGED"  (flagToTag Flagged)
  , line "FLAG" "DELETED"  (flagToTag Deleted)
  , line "FLAG" "DRAFT"    (flagToTag Draft)
  , line "FLAG" "RECENT"   (flagToTag Recent)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
