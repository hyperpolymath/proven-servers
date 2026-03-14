-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

-- | Entry point for proven-firewall. Prints version info and demonstrates types.
module Main

import Firewall

%default total

covering
main : IO ()
main = do
  putStrLn "proven-firewall v0.2.0 -- Formally verified packet filtering"
  putStrLn "Powered by proven (Idris 2 formal verification)"
  putStrLn ""
  putStrLn "Actions:"
  putStrLn $ "  " ++ show Accept ++ ", " ++ show Drop ++ ", " ++ show Reject
            ++ ", " ++ show Log ++ ", " ++ show Redirect
            ++ ", " ++ show DNAT ++ ", " ++ show SNAT ++ ", " ++ show Masquerade
  putStrLn "Protocols:"
  putStrLn $ "  " ++ show TCP ++ ", " ++ show UDP ++ ", " ++ show ICMP
            ++ ", " ++ show ICMPv6 ++ ", " ++ show GRE ++ ", " ++ show ESP
            ++ ", " ++ show AH ++ ", " ++ show Any
  putStrLn "Chain Types:"
  putStrLn $ "  " ++ show Input ++ ", " ++ show Output ++ ", " ++ show Forward
            ++ ", " ++ show PreRouting ++ ", " ++ show PostRouting
  putStrLn "Match Criteria:"
  putStrLn $ "  " ++ show SourceIP ++ ", " ++ show DestIP
            ++ ", " ++ show SourcePort ++ ", " ++ show DestPort
            ++ ", " ++ show Mark
  putStrLn "Connection States:"
  putStrLn $ "  " ++ show New ++ ", " ++ show Established
            ++ ", " ++ show Related ++ ", " ++ show Invalid
  putStrLn ""
  putStrLn $ "Max rules: " ++ show maxRules
