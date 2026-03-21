-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DNS protocol bindings for proven-servers.
--
-- Wraps the C-ABI functions from @protocols\/proven-dns\/ffi\/zig\/src\/dns.zig@.
-- Provides Haskell ADTs for DNS lifecycle states, DNSSEC states, and
-- signing algorithms, plus safe wrapper functions.

{-# LANGUAGE ForeignFunctionInterface #-}

module ProvenServers.Dns
  ( -- * ADTs matching Idris2 ABI
    DnsState(..)
  , DnssecState(..)
  , DnssecAlgorithm(..)
    -- * Context lifecycle
  , abiVersion
  , createContext
  , destroyContext
    -- * State queries
  , getState
  , getDnssecState
  , getRcode
  , answerCount
  , authorityCount
  , additionalCount
    -- * Query operations
  , parseQuery
  , beginLookup
  , beginResponse
    -- * Record management
  , addAnswer
  , addAuthority
  , addAdditional
  , setRcode
    -- * Response building
  , buildResponse
    -- * DNSSEC
  , enableDnssec
  , loadDnssecKey
  , signResponse
  , validateDnssec
    -- * Transition queries
  , canTransition
  , canDnssecTransition
  ) where

import Data.Word (Word8, Word16, Word32)
import Foreign.C.Types (CInt(..))
import Foreign.Ptr (Ptr)
import ProvenServers.Error (ProvenError, fromSlot, fromStatus)

-- ---------------------------------------------------------------------------
-- ADTs matching Idris2 ABI enums
-- ---------------------------------------------------------------------------

-- | DNS query lifecycle states matching @DnsState@ in dns.zig.
data DnsState
  = DnsIdle             -- ^ Waiting for a query.
  | DnsQueryReceived    -- ^ Query received and parsed.
  | DnsLookup           -- ^ Performing DNS lookup.
  | DnsResponseBuilding -- ^ Building response message.
  | DnsSent             -- ^ Response sent (terminal).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a DNS state to its ABI tag.
dnsStateToTag :: DnsState -> Word8
dnsStateToTag = fromIntegral . fromEnum

-- | Decode a DNS state from its ABI tag.
dnsStateFromTag :: Word8 -> Maybe DnsState
dnsStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DnsState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | DNSSEC lifecycle states matching @DnssecState@ in dns.zig.
data DnssecState
  = DnssecDisabled  -- ^ DNSSEC disabled.
  | DnssecEnabled   -- ^ DNSSEC enabled, no key loaded.
  | DnssecKeyLoaded -- ^ DNSSEC key loaded.
  | DnssecValidated -- ^ Response validated / signed.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a DNSSEC state to its ABI tag.
dnssecStateToTag :: DnssecState -> Word8
dnssecStateToTag = fromIntegral . fromEnum

-- | Decode a DNSSEC state from its ABI tag.
dnssecStateFromTag :: Word8 -> Maybe DnssecState
dnssecStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DnssecState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | DNSSEC signing algorithms matching @DnssecAlgorithm@ in dns.zig.
data DnssecAlgorithm
  = RsaSha256       -- ^ RSA/SHA-256.
  | RsaSha512       -- ^ RSA/SHA-512.
  | EcdsaP256Sha256 -- ^ ECDSA P-256/SHA-256.
  | EcdsaP384Sha384 -- ^ ECDSA P-384/SHA-384.
  | Ed25519         -- ^ Ed25519.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert an algorithm to its ABI tag.
algorithmToTag :: DnssecAlgorithm -> Word8
algorithmToTag = fromIntegral . fromEnum

-- ---------------------------------------------------------------------------
-- Foreign imports
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "dns_abi_version"
  c_dns_abi_version :: IO Word32

foreign import ccall unsafe "dns_create_context"
  c_dns_create_context :: IO CInt

foreign import ccall unsafe "dns_destroy_context"
  c_dns_destroy_context :: CInt -> IO ()

foreign import ccall unsafe "dns_state"
  c_dns_state :: CInt -> IO Word8

foreign import ccall unsafe "dns_dnssec_state"
  c_dns_dnssec_state :: CInt -> IO Word8

foreign import ccall unsafe "dns_rcode"
  c_dns_rcode :: CInt -> IO Word8

foreign import ccall unsafe "dns_answer_count"
  c_dns_answer_count :: CInt -> IO Word16

foreign import ccall unsafe "dns_authority_count"
  c_dns_authority_count :: CInt -> IO Word16

foreign import ccall unsafe "dns_additional_count"
  c_dns_additional_count :: CInt -> IO Word16

foreign import ccall unsafe "dns_parse_query"
  c_dns_parse_query :: CInt -> Ptr Word8 -> Word16 -> IO Word8

foreign import ccall unsafe "dns_begin_lookup"
  c_dns_begin_lookup :: CInt -> IO Word8

foreign import ccall unsafe "dns_begin_response"
  c_dns_begin_response :: CInt -> IO Word8

foreign import ccall unsafe "dns_add_answer"
  c_dns_add_answer :: CInt -> Word8 -> Word8 -> Word32 -> Ptr Word8 -> Word16 -> IO Word8

foreign import ccall unsafe "dns_add_authority"
  c_dns_add_authority :: CInt -> Word8 -> Word8 -> Word32 -> Ptr Word8 -> Word16 -> IO Word8

foreign import ccall unsafe "dns_add_additional"
  c_dns_add_additional :: CInt -> Word8 -> Word8 -> Word32 -> Ptr Word8 -> Word16 -> IO Word8

foreign import ccall unsafe "dns_set_rcode"
  c_dns_set_rcode :: CInt -> Word8 -> IO Word8

foreign import ccall unsafe "dns_build_response"
  c_dns_build_response :: CInt -> Ptr Word8 -> Ptr Word16 -> IO Word8

foreign import ccall unsafe "dns_enable_dnssec"
  c_dns_enable_dnssec :: CInt -> IO Word8

foreign import ccall unsafe "dns_load_dnssec_key"
  c_dns_load_dnssec_key :: CInt -> Word8 -> IO Word8

foreign import ccall unsafe "dns_sign_response"
  c_dns_sign_response :: CInt -> IO Word8

foreign import ccall unsafe "dns_validate_dnssec"
  c_dns_validate_dnssec :: CInt -> IO Word8

foreign import ccall unsafe "dns_can_transition"
  c_dns_can_transition :: Word8 -> Word8 -> IO Word8

foreign import ccall unsafe "dns_can_dnssec_transition"
  c_dns_can_dnssec_transition :: Word8 -> Word8 -> IO Word8

-- ---------------------------------------------------------------------------
-- Safe wrappers
-- ---------------------------------------------------------------------------

-- | Return the ABI version of the linked DNS library.
abiVersion :: IO Word32
abiVersion = c_dns_abi_version

-- | Create a new DNS context in the Idle state.
createContext :: IO (Either ProvenError CInt)
createContext = do
  slot <- c_dns_create_context
  pure (fromSlot (fromIntegral slot))

-- | Destroy a DNS context, releasing its slot.
destroyContext :: CInt -> IO ()
destroyContext = c_dns_destroy_context

-- | Get the current lifecycle state.
getState :: CInt -> IO (Maybe DnsState)
getState slot = dnsStateFromTag <$> c_dns_state slot

-- | Get the current DNSSEC state.
getDnssecState :: CInt -> IO (Maybe DnssecState)
getDnssecState slot = dnssecStateFromTag <$> c_dns_dnssec_state slot

-- | Get the response code tag.
getRcode :: CInt -> IO Word8
getRcode = c_dns_rcode

-- | Get the number of answer records.
answerCount :: CInt -> IO Word16
answerCount = c_dns_answer_count

-- | Get the number of authority records.
authorityCount :: CInt -> IO Word16
authorityCount = c_dns_authority_count

-- | Get the number of additional records.
additionalCount :: CInt -> IO Word16
additionalCount = c_dns_additional_count

-- | Parse a DNS query from raw bytes. Transitions Idle -> QueryReceived.
parseQuery :: CInt -> Ptr Word8 -> Word16 -> IO (Either ProvenError ())
parseQuery slot buf len = fromStatus <$> c_dns_parse_query slot buf len

-- | Begin DNS lookup. Transitions QueryReceived -> Lookup.
beginLookup :: CInt -> IO (Either ProvenError ())
beginLookup slot = fromStatus <$> c_dns_begin_lookup slot

-- | Begin building the response. Transitions Lookup -> ResponseBuilding.
beginResponse :: CInt -> IO (Either ProvenError ())
beginResponse slot = fromStatus <$> c_dns_begin_response slot

-- | Add a resource record to the answer section.
addAnswer :: CInt -> Word8 -> Word8 -> Word32 -> Ptr Word8 -> Word16 -> IO (Either ProvenError ())
addAnswer slot rtype rclass ttl rdata rdlen =
  fromStatus <$> c_dns_add_answer slot rtype rclass ttl rdata rdlen

-- | Add a resource record to the authority section.
addAuthority :: CInt -> Word8 -> Word8 -> Word32 -> Ptr Word8 -> Word16 -> IO (Either ProvenError ())
addAuthority slot rtype rclass ttl rdata rdlen =
  fromStatus <$> c_dns_add_authority slot rtype rclass ttl rdata rdlen

-- | Add a resource record to the additional section.
addAdditional :: CInt -> Word8 -> Word8 -> Word32 -> Ptr Word8 -> Word16 -> IO (Either ProvenError ())
addAdditional slot rtype rclass ttl rdata rdlen =
  fromStatus <$> c_dns_add_additional slot rtype rclass ttl rdata rdlen

-- | Set the response code. Only valid in ResponseBuilding state.
setRcode :: CInt -> Word8 -> IO (Either ProvenError ())
setRcode slot rcode = fromStatus <$> c_dns_set_rcode slot rcode

-- | Build the DNS response message. Transitions ResponseBuilding -> Sent.
buildResponse :: CInt -> Ptr Word8 -> Ptr Word16 -> IO (Either ProvenError ())
buildResponse slot out outLen = fromStatus <$> c_dns_build_response slot out outLen

-- | Enable DNSSEC. Transitions Disabled -> Enabled.
enableDnssec :: CInt -> IO (Either ProvenError ())
enableDnssec slot = fromStatus <$> c_dns_enable_dnssec slot

-- | Load a DNSSEC signing key. Transitions Enabled -> KeyLoaded.
loadDnssecKey :: CInt -> DnssecAlgorithm -> IO (Either ProvenError ())
loadDnssecKey slot algo = fromStatus <$> c_dns_load_dnssec_key slot (algorithmToTag algo)

-- | Sign the response (DNSSEC). Transitions KeyLoaded -> Validated.
signResponse :: CInt -> IO (Either ProvenError ())
signResponse slot = fromStatus <$> c_dns_sign_response slot

-- | Check DNSSEC validation result. Returns @True@ if validated.
validateDnssec :: CInt -> IO Bool
validateDnssec slot = (== 0) <$> c_dns_validate_dnssec slot

-- | Stateless query: check whether a DNS lifecycle transition is valid.
canTransition :: DnsState -> DnsState -> IO Bool
canTransition from to =
  (== 1) <$> c_dns_can_transition (dnsStateToTag from) (dnsStateToTag to)

-- | Stateless query: check whether a DNSSEC state transition is valid.
canDnssecTransition :: DnssecState -> DnssecState -> IO Bool
canDnssecTransition from to =
  (== 1) <$> c_dns_can_dnssec_transition (dnssecStateToTag from) (dnssecStateToTag to)
