-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| Entry point for proven-quic: identification + a live demo that exercises
||| the stream-access rules, the connection state machine, and the
||| frame-in-packet table.
module Main

import Quic

%default total

yn : Bool -> String
yn True  = "yes"
yn False = "no"

connStep : ConnState -> ConnState -> String
connStep a b = show a ++ " -> " ++ show b ++ ": " ++
  case validateConnTransition a b of
    Just _  => "legal"
    Nothing => "rejected"

covering
main : IO ()
main = do
  putStrLn "proven-quic — QUIC transport core (RFC 9000)"
  putStrLn $ "  Version:      0x" ++ show version1 ++ " (QUIC v1)"
  putStrLn $ "  Default port: " ++ show defaultPort
  putStrLn $ "  Max varint:   " ++ show maxVarint
  putStrLn ""
  putStrLn "Stream access rules (RFC 9000 2.1/3):"
  putStrLn $ "  client send on server-uni?  " ++ yn (canSend Client ServerUni)
  putStrLn $ "  client recv on server-uni?  " ++ yn (canReceive Client ServerUni)
  putStrLn $ "  client send on client-bidi? " ++ yn (canSend Client ClientBidi)
  putStrLn ""
  putStrLn "Connection state machine:"
  putStrLn $ "  " ++ connStep CInitial CHandshaking
  putStrLn $ "  " ++ connStep CConnected CClosing
  putStrLn $ "  " ++ connStep CClosed CConnected
  putStrLn ""
  putStrLn "Frame-in-packet table (RFC 9000 12.4):"
  putStrLn $ "  STREAM in Initial?        " ++ yn (frameAllowedIn StreamFrame PInitial)
  putStrLn $ "  STREAM in 1-RTT?          " ++ yn (frameAllowedIn StreamFrame POneRtt)
  putStrLn $ "  HANDSHAKE_DONE in Initial?" ++ yn (frameAllowedIn HandshakeDone PInitial)
  putStrLn $ "  CRYPTO in Initial?        " ++ yn (frameAllowedIn Crypto PInitial)
