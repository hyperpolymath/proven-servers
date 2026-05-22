-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | HTTP/1.1+ protocol bindings for proven-servers.
--
-- Wraps the C-ABI functions from @protocols\/proven-httpd\/ffi\/zig\/src\/httpd.zig@.
-- Provides Haskell ADTs matching the Idris2 ABI enums for HTTP methods,
-- status codes, request phases, and versions, plus safe wrapper functions
-- returning @Either ProvenError a@.

{-# LANGUAGE ForeignFunctionInterface #-}

module ProvenServers.Httpd
  ( -- * ADTs matching Idris2 ABI
    Method(..)
  , StatusCode(..)
  , RequestPhase(..)
  , Version(..)
  , ParseResult(..)
    -- * Context lifecycle
  , abiVersion
  , createContext
  , destroyContext
    -- * Request operations
  , parseRequest
  , getMethod
  , getPhase
  , getVersion
    -- * Response operations
  , setStatus
  , sendResponse
    -- * Connection management
  , keepAliveCheck
  , resetContext
  , canTransition
  ) where

import Data.Word (Word8, Word32)
import Foreign.C.Types (CInt(..), CUInt(..))
import ProvenServers.Error (ProvenError(..), fromSlot, fromStatus)

-- ---------------------------------------------------------------------------
-- ADTs matching Idris2 ABI enums
-- ---------------------------------------------------------------------------

-- | HTTP request methods matching @Method@ in httpd.zig.
data Method
  = GET | HEAD | POST | PUT | DELETE | CONNECT | OPTIONS | TRACE | PATCH
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a method to its ABI tag value.
methodToTag :: Method -> Word8
methodToTag = fromIntegral . fromEnum

-- | Decode a method from its ABI tag value.
methodFromTag :: Word8 -> Maybe Method
methodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Method)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | HTTP status code categories matching @StatusCode@ in httpd.zig.
data StatusCode
  = Ok200 | Created201 | NoContent204 | MovedPermanently301
  | Found302 | NotModified304 | BadRequest400 | Unauthorized401
  | Forbidden403 | NotFound404 | MethodNotAllowed405
  | InternalServerError500 | BadGateway502 | ServiceUnavailable503
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a status code to its ABI tag value.
statusCodeToTag :: StatusCode -> Word8
statusCodeToTag = fromIntegral . fromEnum

-- | HTTP request lifecycle phases matching @RequestPhase@ in httpd.zig.
data RequestPhase
  = Idle | Receiving | HeadersParsed | BodyReceiving | Complete | Responding | Sent
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a phase to its ABI tag value.
phaseToTag :: RequestPhase -> Word8
phaseToTag = fromIntegral . fromEnum

-- | Decode a phase from its ABI tag value.
phaseFromTag :: Word8 -> Maybe RequestPhase
phaseFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RequestPhase)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | HTTP protocol versions.
data Version
  = Http10 | Http11
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Decode a version from its ABI tag value.
versionFromTag :: Word8 -> Maybe Version
versionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Version)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Result of feeding raw HTTP data into a context.
data ParseResult
  = ParseComplete   -- ^ Parsing complete, request ready.
  | ParseRejected   -- ^ Malformed request rejected.
  | ParseNeedMore   -- ^ Need more data (headers or body incomplete).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- ---------------------------------------------------------------------------
-- Foreign imports (C-ABI from Zig FFI)
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "http_abi_version"
  c_http_abi_version :: IO Word32

foreign import ccall unsafe "http_create_context"
  c_http_create_context :: IO CInt

foreign import ccall unsafe "http_destroy_context"
  c_http_destroy_context :: CInt -> IO ()

foreign import ccall unsafe "http_parse_request"
  c_http_parse_request :: CInt -> IO Word8

foreign import ccall unsafe "http_get_method"
  c_http_get_method :: CInt -> IO Word8

foreign import ccall unsafe "http_set_status"
  c_http_set_status :: CInt -> Word8 -> IO Word8

foreign import ccall unsafe "http_send_response"
  c_http_send_response :: CInt -> IO Word8

foreign import ccall unsafe "http_keep_alive_check"
  c_http_keep_alive_check :: CInt -> IO Word8

foreign import ccall unsafe "http_get_phase"
  c_http_get_phase :: CInt -> IO Word8

foreign import ccall unsafe "http_get_version"
  c_http_get_version :: CInt -> IO Word8

foreign import ccall unsafe "http_reset_context"
  c_http_reset_context :: CInt -> IO Word8

foreign import ccall unsafe "http_can_transition"
  c_http_can_transition :: Word8 -> Word8 -> IO Word8

-- ---------------------------------------------------------------------------
-- Safe wrappers
-- ---------------------------------------------------------------------------

-- | Return the ABI version of the linked @libproven_httpd@.
abiVersion :: IO Word32
abiVersion = c_http_abi_version

-- | Create a new HTTP context in the Idle phase.
-- Returns the slot handle or 'PoolExhausted' if all 64 slots are in use.
createContext :: IO (Either ProvenError CInt)
createContext = do
  slot <- c_http_create_context
  pure (fromSlot (fromIntegral slot))

-- | Destroy an HTTP context, releasing its slot.
destroyContext :: CInt -> IO ()
destroyContext = c_http_destroy_context

-- | Feed raw HTTP data into a context for parsing.
parseRequest :: CInt -> IO (Either ProvenError ParseResult)
parseRequest slot = do
  result <- c_http_parse_request slot
  pure $ case result of
    0 -> Right ParseComplete
    1 -> Right ParseRejected
    2 -> Right ParseNeedMore
    _ -> Left (UnknownError (fromIntegral result))

-- | Get the HTTP method of the parsed request.
getMethod :: CInt -> IO (Maybe Method)
getMethod slot = do
  tag <- c_http_get_method slot
  pure (methodFromTag tag)

-- | Set the response status code.
setStatus :: CInt -> StatusCode -> IO (Either ProvenError ())
setStatus slot status = do
  result <- c_http_set_status slot (statusCodeToTag status)
  pure (fromStatus result)

-- | Send the response, transitioning Responding -> Sent.
sendResponse :: CInt -> IO (Either ProvenError ())
sendResponse slot = do
  result <- c_http_send_response slot
  pure (fromStatus result)

-- | Check if the connection uses keep-alive.
keepAliveCheck :: CInt -> IO Bool
keepAliveCheck slot = do
  result <- c_http_keep_alive_check slot
  pure (result == 1)

-- | Get the current request processing phase.
getPhase :: CInt -> IO (Maybe RequestPhase)
getPhase slot = do
  tag <- c_http_get_phase slot
  pure (phaseFromTag tag)

-- | Get the HTTP version of the parsed request.
getVersion :: CInt -> IO (Maybe Version)
getVersion slot = do
  tag <- c_http_get_version slot
  pure (versionFromTag tag)

-- | Reset the context for keep-alive reuse (Sent -> Idle).
resetContext :: CInt -> IO (Either ProvenError ())
resetContext slot = do
  result <- c_http_reset_context slot
  pure (fromStatus result)

-- | Stateless query: check whether a lifecycle transition is valid.
canTransition :: RequestPhase -> RequestPhase -> IO Bool
canTransition from to = do
  result <- c_http_can_transition (phaseToTag from) (phaseToTag to)
  pure (result == 1)
