# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Auth protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Auth protocol types for proven-servers.
  module Authserver
    # AuthMethod matching the Idris2 ABI tags.
    module AuthMethod
      PASSWORD = 0
      CERTIFICATE = 1
      O_AUTH2 = 2
      SAML = 3
      FIDO2 = 4
      KERBEROS = 5
      LDAP = 6
      RADIUS = 7
    end

    # TokenType matching the Idris2 ABI tags.
    module TokenType
      ACCESS = 0
      REFRESH = 1
      ID = 2
      API = 3
    end

    # AuthResult matching the Idris2 ABI tags.
    module AuthResult
      SUCCESS = 0
      INVALID_CREDENTIALS = 1
      ACCOUNT_LOCKED = 2
      ACCOUNT_EXPIRED = 3
      MFA_REQUIRED = 4
      IP_BLOCKED = 5
    end

    # MfaMethod matching the Idris2 ABI tags.
    module MfaMethod
      TOTP = 0
      SMS = 1
      PUSH = 2
      FIDO2_MFA = 3
      EMAIL = 4
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      ACTIVE = 0
      EXPIRED = 1
      REVOKED = 2
      LOCKED = 3
    end

  end
end
