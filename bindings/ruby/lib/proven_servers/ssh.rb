# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# SSH protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # SSH protocol types for proven-servers.
  module Ssh
    # SshMessageType matching the Idris2 ABI tags.
    module SshMessageType
      KEXINIT = 0
      NEWKEYS = 1
      SERVICE_REQUEST = 2
      USERAUTH_REQUEST = 3
      SSH_MESSAGE_TYPE_CHANNEL_OPEN = 4
      CHANNEL_DATA = 5
      CHANNEL_CLOSE = 6
      DISCONNECT = 7
    end

    # AuthMethod matching the Idris2 ABI tags.
    module AuthMethod
      PUBLICKEY = 0
      PASSWORD = 1
      KEYBOARD_INTERACTIVE = 2
      AUTH_NONE = 3
    end

    # KexMethod matching the Idris2 ABI tags.
    module KexMethod
      DIFFIE_HELLMAN_GROUP14_SHA256 = 0
      CURVE25519_SHA256 = 1
      DIFFIE_HELLMAN_GROUP16_SHA512 = 2
      DIFFIE_HELLMAN_GROUP18_SHA512 = 3
      ECDH_SHA2_NISTP256 = 4
      ECDH_SHA2_NISTP384 = 5
    end

    # ChannelType matching the Idris2 ABI tags.
    module ChannelType
      SESSION = 0
      DIRECT_TCPIP = 1
      FORWARDED_TCPIP = 2
      X11 = 3
    end

    # BastionState matching the Idris2 ABI tags.
    module BastionState
      CONNECTED = 0
      KEY_EXCHANGED = 1
      AUTHENTICATED = 2
      BASTION_STATE_CHANNEL_OPEN = 3
      ACTIVE = 4
      BASTION_STATE_CLOSED = 5
    end

    # ChannelState matching the Idris2 ABI tags.
    module ChannelState
      OPENING = 0
      OPEN = 1
      CLOSING = 2
      CHANNEL_STATE_CLOSED = 3
    end

    # DisconnectReason matching the Idris2 ABI tags.
    module DisconnectReason
      HOST_NOT_ALLOWED = 0
      PROTOCOL_ERROR = 1
      KEY_EXCHANGE_FAILED = 2
      HOST_AUTH_FAILED = 3
      MAC_ERROR = 4
      SERVICE_NOT_AVAILABLE = 5
      VERSION_NOT_SUPPORTED = 6
      HOST_KEY_NOT_VERIFIABLE = 7
      CONNECTION_LOST = 8
      BY_APPLICATION = 9
      TOO_MANY_CONNECTIONS = 10
      AUTH_CANCELLED = 11
    end

    # HostKeyAlgorithm matching the Idris2 ABI tags.
    module HostKeyAlgorithm
      SSH_ED25519 = 0
      RSA_SHA2256 = 1
      RSA_SHA2512 = 2
      ECDSA_NISTP256 = 3
    end

    # CipherAlgorithm matching the Idris2 ABI tags.
    module CipherAlgorithm
      CHACHA20_POLY1305 = 0
      AES256_GCM = 1
      AES128_GCM = 2
      AES256_CTR = 3
      AES192_CTR = 4
      AES128_CTR = 5
    end

    # ChannelOpenFailure matching the Idris2 ABI tags.
    module ChannelOpenFailure
      ADMIN_PROHIBITED = 0
      CONNECT_FAILED = 1
      UNKNOWN_CHANNEL_TYPE = 2
      RESOURCE_SHORTAGE = 3
    end

  end
end
