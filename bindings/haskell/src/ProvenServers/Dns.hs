-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DNS protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Dns
  (
    dnsPort
  , maxUdpSize
  , maxTcpSize
  , maxLabelLength
  , maxNameLength
  , ednsUdpSize
  , RecordType(..)
  , recordTypeToTag
  , recordTypeFromTag
  , isAddress
  , isInfrastructure
  , mnemonic
  , ResponseCode(..)
  , responseCodeToTag
  , responseCodeFromTag
  , isSuccess
  , isNxdomain
  ) where

import Data.Word (Word16, Word8)

-- | /// Matches `dnsPort` in `DNS`.
dnsPort :: Word16
dnsPort = 53

-- | /// Matches `maxUdpSize` in `DNS`.
maxUdpSize :: usize
maxUdpSize = 512

-- | /// Matches `maxTcpSize` in `DNS`.
maxTcpSize :: usize
maxTcpSize = 65535

-- | /// Matches `maxLabelLength` in `DNS`.
maxLabelLength :: usize
maxLabelLength = 63

-- | /// Matches `maxNameLength` in `DNS`.
maxNameLength :: usize
maxNameLength = 253

-- | /// Matches `ednsUdpSize` in `DNS`.
ednsUdpSize :: usize
ednsUdpSize = 4096

-- ---------------------------------------------------------------------------
-- RecordType
-- ---------------------------------------------------------------------------

-- | Matches `ednsUdpSize` in `DNS`.
--
-- Tags 0-33 (9 constructors).
data RecordType
  = A  -- ^ A record: IPv4 address (RFC 1035).
  | Aaaa  -- ^ AAAA record: IPv6 address (RFC 3596).
  | Cname  -- ^ CNAME record: canonical name alias (RFC 1035).
  | Mx  -- ^ MX record: mail exchange (RFC 1035).
  | Ns  -- ^ NS record: authoritative name server (RFC 1035).
  | Txt  -- ^ TXT record: text strings (RFC 1035).
  | Soa  -- ^ SOA record: start of authority (RFC 1035).
  | Srv  -- ^ SRV record: service locator (RFC 2782).
  | Ptr  -- ^ PTR record: pointer / reverse lookup (RFC 1035).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RecordType' to its ABI tag value.
recordTypeToTag :: RecordType -> Word8
recordTypeToTag = fromIntegral . fromEnum

-- | Decode a 'RecordType' from its ABI tag value.
recordTypeFromTag :: Word8 -> Maybe RecordType
recordTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RecordType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this record type holds an address (A or AAAA).
isAddress :: RecordType -> Bool
isAddress A = True
isAddress Aaaa = True
isAddress _ = False

-- | Whether this is an infrastructure record (NS, SOA).
isInfrastructure :: RecordType -> Bool
isInfrastructure Ns = True
isInfrastructure Soa = True
isInfrastructure _ = False

-- | Mnemonic name (e.g. "A", "AAAA", "CNAME").
mnemonic :: RecordType -> String
mnemonic A = "A"
mnemonic Aaaa = "AAAA"
mnemonic Cname = "CNAME"
mnemonic Mx = "MX"
mnemonic Ns = "NS"
mnemonic Txt = "TXT"
mnemonic Soa = "SOA"
mnemonic Srv = "SRV"
mnemonic Ptr = "PTR"

-- ---------------------------------------------------------------------------
-- ResponseCode
-- ---------------------------------------------------------------------------

-- | DNS response codes (RCODE, RFC 1035 Section 4.1.1).
--
-- Tags 0-5 (6 constructors).
data ResponseCode
  = NoError  -- ^ No error condition (0).
  | FormatError  -- ^ Format error: the server was unable to interpret the query (1).
  | ServerFailure  -- ^ Server failure: internal problem (2).
  | NameError  -- ^ Name error: the domain name does not exist (NXDOMAIN) (3).
  | NotImplemented  -- ^ Not implemented: the server does not support the query type (4).
  | Refused  -- ^ Refused: the server refuses to perform the operation (5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponseCode' to its ABI tag value.
responseCodeToTag :: ResponseCode -> Word8
responseCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ResponseCode' from its ABI tag value.
responseCodeFromTag :: Word8 -> Maybe ResponseCode
responseCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponseCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this response indicates success.
isSuccess :: ResponseCode -> Bool
isSuccess NoError = True
isSuccess _ = False

-- | Whether this response indicates the domain does not exist.
isNxdomain :: ResponseCode -> Bool
isNxdomain NameError = True
isNxdomain _ = False
