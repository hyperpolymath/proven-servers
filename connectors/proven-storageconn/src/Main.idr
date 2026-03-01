-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-storageconn.
-- Prints the connector name and shows all type constructors.

module Main

import StorageConn

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-storageconn type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-storageconn — Object storage connector interface types"
  putStrLn ""
  showConstructors "StorageOp"
    [ show PutObject, show GetObject, show DeleteObject, show ListObjects
    , show HeadObject, show CopyObject, show CreateBucket, show DeleteBucket ]
  showConstructors "StorageState"
    [ show Disconnected, show Connected, show Uploading
    , show Downloading, show Failed ]
  showConstructors "ObjectStatus"
    [ show Exists, show NotFound, show Archived
    , show Deleted, show Pending ]
  showConstructors "StorageError"
    [ show BucketNotFound, show ObjectNotFound, show AccessDenied
    , show QuotaExceeded, show IntegrityCheckFailed, show UploadIncomplete
    , show PathTraversal, show TLSRequired ]
  showConstructors "IntegrityCheck"
    [ show SHA256, show SHA384, show SHA512, show BLAKE3, show None ]
  putStrLn ""
  putStrLn $ "  maxObjectSize      = " ++ show maxObjectSize
  putStrLn $ "  maxKeyLength       = " ++ show maxKeyLength
  putStrLn $ "  maxBucketNameLength = " ++ show maxBucketNameLength
