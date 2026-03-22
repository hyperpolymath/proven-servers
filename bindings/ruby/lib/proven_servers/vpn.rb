# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# VPN protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # VPN protocol types for proven-servers.
  module Vpn
    # TunnelType matching the Idris2 ABI tags.
    module TunnelType
      IPSEC = 0
      WIREGUARD = 1
      OPENVPN = 2
      L2TP = 3
    end

    # TunnelPhase matching the Idris2 ABI tags.
    module TunnelPhase
      IDLE = 0
      PHASE1_INIT = 1
      PHASE1_AUTH = 2
      PHASE1_DONE = 3
      PHASE2_NEGOTIATING = 4
      ESTABLISHED = 5
      TUNNEL_PHASE_EXPIRED = 6
    end

    # EncryptionAlgorithm matching the Idris2 ABI tags.
    module EncryptionAlgorithm
      AES128_CBC = 0
      AES256_CBC = 1
      AES128_GCM = 2
      AES256_GCM = 3
      CHACHA20_POLY1305 = 4
      NULL_CIPHER = 5
    end

    # IntegrityAlgorithm matching the Idris2 ABI tags.
    module IntegrityAlgorithm
      HMAC_SHA1 = 0
      HMAC_SHA256 = 1
      HMAC_SHA384 = 2
      HMAC_SHA512 = 3
      NO_INTEGRITY = 4
    end

    # DhGroup matching the Idris2 ABI tags.
    module DhGroup
      DH14 = 0
      ECP256 = 1
      ECP384 = 2
      CURVE25519 = 3
    end

    # SaLifecycle matching the Idris2 ABI tags.
    module SaLifecycle
      NONE = 0
      ACTIVE = 1
      REKEYING = 2
      SA_LIFECYCLE_EXPIRED = 3
      DELETED = 4
    end

    # IkeVersion matching the Idris2 ABI tags.
    module IkeVersion
      V1 = 0
      V2 = 1
    end

    # VpnError matching the Idris2 ABI tags.
    module VpnError
      AUTHENTICATION_FAILED = 0
      NO_PROPOSAL_CHOSEN = 1
      LIFETIME_EXPIRED = 2
      INVALID_SPI = 3
      REPLAY_DETECTED = 4
      NEGOTIATION_TIMEOUT = 5
    end

  end
end
