-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| Entry point for proven-http3: identification + a live demo that walks a
||| legal request-frame sequence and shows the frame-vs-stream rules.
module Main

import Http3

%default total

yn : Bool -> String
yn True  = "yes"
yn False = "no"

reqStep : ReqState -> ReqState -> String
reqStep a b = show a ++ " -> " ++ show b ++ ": " ++
  case validateReqTransition a b of
    Just _  => "legal"
    Nothing => "rejected"

covering
main : IO ()
main = do
  putStrLn "proven-http3 — HTTP/3 structural core (RFC 9114)"
  putStrLn $ "  ALPN:         " ++ alpn
  putStrLn $ "  Default port: " ++ show defaultPort
  putStrLn ""
  putStrLn "Request-stream frame sequence (RFC 9114 4.1):"
  putStrLn $ "  " ++ reqStep RInit RReqHeaders   -- HEADERS
  putStrLn $ "  " ++ reqStep RReqHeaders RData    -- DATA
  putStrLn $ "  " ++ reqStep RData RTrailers      -- trailing HEADERS
  putStrLn $ "  " ++ reqStep RTrailers RDone      -- end of stream
  putStrLn $ "  " ++ reqStep RInit RData          -- DATA before HEADERS (illegal)
  putStrLn ""
  putStrLn "Frame-vs-stream rules (RFC 9114 7.2):"
  putStrLn $ "  SETTINGS on control stream? " ++ yn (allowedOnControl Settings)
  putStrLn $ "  SETTINGS on request stream? " ++ yn (allowedOnRequest Settings)
  putStrLn $ "  DATA on control stream?     " ++ yn (allowedOnControl Data)
  putStrLn $ "  DATA on request stream?     " ++ yn (allowedOnRequest Data)
  putStrLn ""
  putStrLn "Frame wire codes (RFC 9114 7.2):"
  putStrLn $ "  HEADERS code = " ++ show (frameWireCode Headers)
  putStrLn $ "  SETTINGS code = " ++ show (frameWireCode Settings)
  putStrLn $ "  MAX_PUSH_ID code = " ++ show (frameWireCode MaxPushId)
