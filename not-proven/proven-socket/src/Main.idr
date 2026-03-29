-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-socket.
-- Prints the primitive name and shows all type constructors.

module Main

import Socket

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-socket type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-socket — Typed socket operations"
  putStrLn ""
  showConstructors "SocketDomain"
    [ show IPv4, show IPv6, show Unix ]
  showConstructors "SocketType"
    [ show Stream, show Datagram, show SeqPacket, show Raw ]
  showConstructors "SocketState"
    [ show Unbound, show Bound, show Listening
    , show Connected, show Closed, show Error ]
  showConstructors "SocketOp"
    [ show Bind, show Listen, show Accept, show Connect
    , show Send, show Recv, show Close, show Shutdown ]
  showConstructors "ShutdownMode"
    [ show Read, show Write, show Both ]
  showConstructors "SocketError"
    [ show AddressInUse, show ConnectionRefused, show ConnectionReset
    , show TimedOut, show HostUnreachable, show NetworkUnreachable
    , show PermissionDenied, show InvalidAddress
    , show AlreadyConnected, show NotConnected ]
  putStrLn ""
  putStrLn $ "  defaultBacklog  = " ++ show defaultBacklog
  putStrLn $ "  maxConnections  = " ++ show maxConnections
