-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | GraphQL protocol bindings for proven-servers.
--
-- Wraps the C-ABI functions from
-- @protocols\/proven-graphql\/ffi\/zig\/src\/graphql.zig@.
-- Provides Haskell ADTs for GraphQL request phases and operation types.

{-# LANGUAGE ForeignFunctionInterface #-}

module ProvenServers.Graphql
  ( -- * ADTs matching Idris2 ABI
    GraphqlPhase(..)
  , OperationType(..)
    -- * Context lifecycle
  , abiVersion
  , create
  , destroy
    -- * State queries
  , phase
  , operationType
  , errorCategory
  , queryDepth
  , complexity
  , fieldsResolved
    -- * Request operations
  , advance
  , abort
  , setQueryDepth
  , setComplexity
  , resolveField
    -- * Subscription operations
  , subCreate
  , subPhase
  , subAdvance
  , subEmitEvent
  , subAbort
  , subEventCount
    -- * Introspection
  , introspectionQuery
    -- * Stateless checks
  , canTransition
  , checkDepth
  , checkComplexity
  ) where

import Data.Word (Word8, Word16, Word32)
import Foreign.C.Types (CInt(..))
import ProvenServers.Error (ProvenError, fromSlot, fromStatus)

-- ---------------------------------------------------------------------------
-- ADTs matching Idris2 ABI enums
-- ---------------------------------------------------------------------------

-- | GraphQL request lifecycle phases.
data GraphqlPhase
  = GqlReceived  -- ^ Request received, not yet parsed.
  | GqlParsed    -- ^ Query parsed and validated.
  | GqlExecuting -- ^ Execution in progress.
  | GqlComplete  -- ^ Execution complete, response ready.
  | GqlError     -- ^ Error occurred.
  deriving (Show, Eq, Ord, Enum, Bounded)

gqlPhaseToTag :: GraphqlPhase -> Word8
gqlPhaseToTag = fromIntegral . fromEnum

gqlPhaseFromTag :: Word8 -> Maybe GraphqlPhase
gqlPhaseFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: GraphqlPhase)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | GraphQL operation types.
data OperationType
  = OpQuery        -- ^ Query operation.
  | OpMutation     -- ^ Mutation operation.
  | OpSubscription -- ^ Subscription operation.
  deriving (Show, Eq, Ord, Enum, Bounded)

opTypeToTag :: OperationType -> Word8
opTypeToTag = fromIntegral . fromEnum

-- ---------------------------------------------------------------------------
-- Foreign imports
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "graphql_abi_version"      c_graphql_abi_version      :: IO Word32
foreign import ccall unsafe "graphql_create"           c_graphql_create           :: Word8 -> IO CInt
foreign import ccall unsafe "graphql_destroy"          c_graphql_destroy          :: CInt -> IO ()
foreign import ccall unsafe "graphql_phase"            c_graphql_phase            :: CInt -> IO Word8
foreign import ccall unsafe "graphql_operation_type"   c_graphql_operation_type   :: CInt -> IO Word8
foreign import ccall unsafe "graphql_error_category"   c_graphql_error_category   :: CInt -> IO Word8
foreign import ccall unsafe "graphql_advance"          c_graphql_advance          :: CInt -> IO Word8
foreign import ccall unsafe "graphql_abort"            c_graphql_abort            :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "graphql_set_query_depth"  c_graphql_set_query_depth  :: CInt -> Word16 -> IO Word8
foreign import ccall unsafe "graphql_query_depth"      c_graphql_query_depth      :: CInt -> IO Word16
foreign import ccall unsafe "graphql_set_complexity"   c_graphql_set_complexity   :: CInt -> Word16 -> IO Word8
foreign import ccall unsafe "graphql_complexity"       c_graphql_complexity       :: CInt -> IO Word16
foreign import ccall unsafe "graphql_resolve_field"    c_graphql_resolve_field    :: CInt -> Word8 -> Word8 -> IO Word8
foreign import ccall unsafe "graphql_fields_resolved"  c_graphql_fields_resolved  :: CInt -> IO Word16
foreign import ccall unsafe "graphql_can_transition"   c_graphql_can_transition   :: Word8 -> Word8 -> IO Word8
foreign import ccall unsafe "graphql_sub_create"       c_graphql_sub_create       :: CInt -> IO CInt
foreign import ccall unsafe "graphql_sub_phase"        c_graphql_sub_phase        :: CInt -> IO Word8
foreign import ccall unsafe "graphql_sub_advance"      c_graphql_sub_advance      :: CInt -> IO Word8
foreign import ccall unsafe "graphql_sub_emit_event"   c_graphql_sub_emit_event   :: CInt -> IO Word8
foreign import ccall unsafe "graphql_sub_abort"        c_graphql_sub_abort        :: CInt -> IO Word8
foreign import ccall unsafe "graphql_sub_event_count"  c_graphql_sub_event_count  :: CInt -> IO Word32
foreign import ccall unsafe "graphql_introspection_query" c_graphql_introspection_query :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "graphql_check_depth"      c_graphql_check_depth      :: Word16 -> Word16 -> IO Word8
foreign import ccall unsafe "graphql_check_complexity" c_graphql_check_complexity :: Word16 -> Word16 -> IO Word8

-- ---------------------------------------------------------------------------
-- Safe wrappers
-- ---------------------------------------------------------------------------

-- | Return the ABI version.
abiVersion :: IO Word32
abiVersion = c_graphql_abi_version

-- | Create a new GraphQL request context.
-- @opType@: 0 = Query, 1 = Mutation, 2 = Subscription.
create :: OperationType -> IO (Either ProvenError CInt)
create opType = fromSlot . fromIntegral <$> c_graphql_create (opTypeToTag opType)

-- | Destroy a GraphQL context.
destroy :: CInt -> IO ()
destroy = c_graphql_destroy

-- | Get the current request phase.
phase :: CInt -> IO (Maybe GraphqlPhase)
phase slot = gqlPhaseFromTag <$> c_graphql_phase slot

-- | Get the operation type tag.
operationType :: CInt -> IO Word8
operationType = c_graphql_operation_type

-- | Get the error category tag (255 = no error).
errorCategory :: CInt -> IO Word8
errorCategory = c_graphql_error_category

-- | Advance to the next lifecycle phase.
advance :: CInt -> IO (Either ProvenError ())
advance slot = fromStatus <$> c_graphql_advance slot

-- | Abort the request with an error category.
abort :: CInt -> Word8 -> IO (Either ProvenError ())
abort slot errCat = fromStatus <$> c_graphql_abort slot errCat

-- | Set the query nesting depth (for depth limiting).
setQueryDepth :: CInt -> Word16 -> IO (Either ProvenError ())
setQueryDepth slot depth = fromStatus <$> c_graphql_set_query_depth slot depth

-- | Get the current query depth.
queryDepth :: CInt -> IO Word16
queryDepth = c_graphql_query_depth

-- | Set the query complexity score.
setComplexity :: CInt -> Word16 -> IO (Either ProvenError ())
setComplexity slot score = fromStatus <$> c_graphql_set_complexity slot score

-- | Get the current complexity score.
complexity :: CInt -> IO Word16
complexity = c_graphql_complexity

-- | Record a field resolution with type and scalar kind.
resolveField :: CInt -> Word8 -> Word8 -> IO (Either ProvenError ())
resolveField slot typeKind scalarKind = fromStatus <$> c_graphql_resolve_field slot typeKind scalarKind

-- | Get the number of fields resolved so far.
fieldsResolved :: CInt -> IO Word16
fieldsResolved = c_graphql_fields_resolved

-- | Stateless query: check whether a request phase transition is valid.
canTransition :: GraphqlPhase -> GraphqlPhase -> IO Bool
canTransition from to =
  (== 1) <$> c_graphql_can_transition (gqlPhaseToTag from) (gqlPhaseToTag to)

-- | Create a subscription from a context in subscription operation type.
subCreate :: CInt -> IO (Either ProvenError CInt)
subCreate slot = fromSlot . fromIntegral <$> c_graphql_sub_create slot

-- | Get the subscription phase tag.
subPhase :: CInt -> IO Word8
subPhase = c_graphql_sub_phase

-- | Advance the subscription lifecycle.
subAdvance :: CInt -> IO (Either ProvenError ())
subAdvance slot = fromStatus <$> c_graphql_sub_advance slot

-- | Emit a subscription event.
subEmitEvent :: CInt -> IO (Either ProvenError ())
subEmitEvent slot = fromStatus <$> c_graphql_sub_emit_event slot

-- | Abort a subscription.
subAbort :: CInt -> IO (Either ProvenError ())
subAbort slot = fromStatus <$> c_graphql_sub_abort slot

-- | Get the subscription event count.
subEventCount :: CInt -> IO Word32
subEventCount = c_graphql_sub_event_count

-- | Run an introspection query on a specific field.
introspectionQuery :: CInt -> Word8 -> IO (Either ProvenError ())
introspectionQuery slot introField = fromStatus <$> c_graphql_introspection_query slot introField

-- | Stateless: check if a query depth is within limits.
checkDepth :: Word16 -> Word16 -> IO Bool
checkDepth depth maxDepth = (== 1) <$> c_graphql_check_depth depth maxDepth

-- | Stateless: check if a complexity score is within limits.
checkComplexity :: Word16 -> Word16 -> IO Bool
checkComplexity score maxComplexity = (== 1) <$> c_graphql_check_complexity score maxComplexity
