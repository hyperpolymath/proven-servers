# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.SshBastion do
  @moduledoc """
  SSH bastion protocol types for the proven-servers ABI.

  Mirrors the Idris2 modules:

    * `SSH.Transport` -- key exchange and cipher algorithms
    * `SSH.Auth` -- authentication methods
    * `SSH.Channel` -- channel types and states
    * `SSH.Session` -- session lifecycle states
    * `SSHABI.Layout` -- C-ABI tag values for all types
    * `SSHABI.Transitions` -- session and channel state machines

  ## Bastion State Machine

      Connected -> KeyExchanged -> Authenticated -> ChannelOpen -> Active -> Closed
      (Can close from any state)
  """

  @doc "Standard SSH port (22, RFC 4253)."
  @spec ssh_port() :: non_neg_integer()
  def ssh_port, do: 22

  # ===========================================================================
  # SshMessageType (tags 0-7)
  # ===========================================================================

  @typedoc "SSH message types relevant to bastion operation."
  @type message_type ::
          :kexinit | :newkeys | :service_request | :userauth_request
          | :channel_open | :channel_data | :channel_close | :disconnect

  @message_type_tags %{
    kexinit: 0, newkeys: 1, service_request: 2, userauth_request: 3,
    channel_open: 4, channel_data: 5, channel_close: 6, disconnect: 7
  }
  @tag_to_message_type Map.new(@message_type_tags, fn {k, v} -> {v, k} end)

  @message_type_names %{
    kexinit: "SSH_MSG_KEXINIT", newkeys: "SSH_MSG_NEWKEYS",
    service_request: "SSH_MSG_SERVICE_REQUEST", userauth_request: "SSH_MSG_USERAUTH_REQUEST",
    channel_open: "SSH_MSG_CHANNEL_OPEN", channel_data: "SSH_MSG_CHANNEL_DATA",
    channel_close: "SSH_MSG_CHANNEL_CLOSE", disconnect: "SSH_MSG_DISCONNECT"
  }

  @doc "Decode from a C-ABI tag value."
  @spec message_type_from_tag(non_neg_integer()) :: {:ok, message_type()} | :error
  def message_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_message_type, tag)}
  end
  def message_type_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec message_type_to_tag(message_type()) :: non_neg_integer()
  def message_type_to_tag(mt) when is_map_key(@message_type_tags, mt) do
    Map.fetch!(@message_type_tags, mt)
  end

  @doc "Human-readable message type name."
  @spec message_type_name(message_type()) :: String.t()
  def message_type_name(mt) when is_map_key(@message_type_names, mt) do
    Map.fetch!(@message_type_names, mt)
  end

  # ===========================================================================
  # AuthMethod (tags 0-3)
  # ===========================================================================

  @typedoc "SSH authentication methods (RFC 4252)."
  @type auth_method :: :publickey | :password | :keyboard_interactive | :none

  @auth_method_tags %{publickey: 0, password: 1, keyboard_interactive: 2, none: 3}
  @tag_to_auth_method Map.new(@auth_method_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec auth_method_from_tag(non_neg_integer()) :: {:ok, auth_method()} | :error
  def auth_method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_auth_method, tag)}
  end
  def auth_method_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec auth_method_to_tag(auth_method()) :: non_neg_integer()
  def auth_method_to_tag(method) when is_map_key(@auth_method_tags, method) do
    Map.fetch!(@auth_method_tags, method)
  end

  @doc "Whether this method is considered secure for production use."
  @spec auth_method_secure?(auth_method()) :: boolean()
  def auth_method_secure?(method) when method in [:publickey, :keyboard_interactive], do: true
  def auth_method_secure?(_method), do: false

  # ===========================================================================
  # KexMethod (tags 0-5)
  # ===========================================================================

  @typedoc "SSH key exchange methods."
  @type kex_method ::
          :dh_group14_sha256 | :curve25519_sha256 | :dh_group16_sha512
          | :dh_group18_sha512 | :ecdh_sha2_nistp256 | :ecdh_sha2_nistp384

  @kex_method_tags %{
    dh_group14_sha256: 0, curve25519_sha256: 1, dh_group16_sha512: 2,
    dh_group18_sha512: 3, ecdh_sha2_nistp256: 4, ecdh_sha2_nistp384: 5
  }
  @tag_to_kex_method Map.new(@kex_method_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec kex_method_from_tag(non_neg_integer()) :: {:ok, kex_method()} | :error
  def kex_method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_kex_method, tag)}
  end
  def kex_method_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec kex_method_to_tag(kex_method()) :: non_neg_integer()
  def kex_method_to_tag(method) when is_map_key(@kex_method_tags, method) do
    Map.fetch!(@kex_method_tags, method)
  end

  @doc "Whether this key exchange method uses elliptic curve cryptography."
  @spec kex_method_ecc?(kex_method()) :: boolean()
  def kex_method_ecc?(m) when m in [:curve25519_sha256, :ecdh_sha2_nistp256, :ecdh_sha2_nistp384], do: true
  def kex_method_ecc?(_m), do: false

  # ===========================================================================
  # ChannelType (tags 0-3)
  # ===========================================================================

  @typedoc "SSH channel types."
  @type channel_type :: :session | :direct_tcpip | :forwarded_tcpip | :x11

  @channel_type_tags %{session: 0, direct_tcpip: 1, forwarded_tcpip: 2, x11: 3}
  @tag_to_channel_type Map.new(@channel_type_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec channel_type_from_tag(non_neg_integer()) :: {:ok, channel_type()} | :error
  def channel_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_channel_type, tag)}
  end
  def channel_type_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec channel_type_to_tag(channel_type()) :: non_neg_integer()
  def channel_type_to_tag(ct) when is_map_key(@channel_type_tags, ct) do
    Map.fetch!(@channel_type_tags, ct)
  end

  @doc "Whether this channel type involves TCP/IP forwarding."
  @spec channel_type_forwarding?(channel_type()) :: boolean()
  def channel_type_forwarding?(ct) when ct in [:direct_tcpip, :forwarded_tcpip], do: true
  def channel_type_forwarding?(_ct), do: false

  # ===========================================================================
  # BastionState (tags 0-5)
  # ===========================================================================

  @typedoc "SSH bastion connection state machine."
  @type bastion_state ::
          :connected | :key_exchanged | :authenticated | :channel_open | :active | :closed

  @bastion_state_tags %{
    connected: 0, key_exchanged: 1, authenticated: 2,
    channel_open: 3, active: 4, closed: 5
  }
  @tag_to_bastion_state Map.new(@bastion_state_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec bastion_state_from_tag(non_neg_integer()) :: {:ok, bastion_state()} | :error
  def bastion_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_bastion_state, tag)}
  end
  def bastion_state_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec bastion_state_to_tag(bastion_state()) :: non_neg_integer()
  def bastion_state_to_tag(state) when is_map_key(@bastion_state_tags, state) do
    Map.fetch!(@bastion_state_tags, state)
  end

  # bastion_can_transition? removed: unproven reimplementation. The verified check lives in the
  # Idris2/Zig core; calling it needs FFI wiring not yet present in this binding.
  # Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

  # ===========================================================================
  # ChannelState (tags 0-3)
  # ===========================================================================

  @typedoc "SSH channel state machine."
  @type channel_state :: :opening | :open | :closing | :channel_closed

  @channel_state_tags %{opening: 0, open: 1, closing: 2, channel_closed: 3}
  @tag_to_channel_state Map.new(@channel_state_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec channel_state_from_tag(non_neg_integer()) :: {:ok, channel_state()} | :error
  def channel_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_channel_state, tag)}
  end
  def channel_state_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec channel_state_to_tag(channel_state()) :: non_neg_integer()
  def channel_state_to_tag(state) when is_map_key(@channel_state_tags, state) do
    Map.fetch!(@channel_state_tags, state)
  end

  # channel_can_transition? removed: unproven reimplementation. The verified check lives in the
  # Idris2/Zig core; calling it needs FFI wiring not yet present in this binding.
  # Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

  # ===========================================================================
  # DisconnectReason (tags 0-11)
  # ===========================================================================

  @typedoc "SSH disconnect reason codes."
  @type disconnect_reason ::
          :host_not_allowed | :protocol_error | :key_exchange_failed
          | :host_auth_failed | :mac_error | :service_not_available
          | :version_not_supported | :host_key_not_verifiable
          | :connection_lost | :by_application | :too_many_connections
          | :auth_cancelled

  @disconnect_reason_tags %{
    host_not_allowed: 0, protocol_error: 1, key_exchange_failed: 2,
    host_auth_failed: 3, mac_error: 4, service_not_available: 5,
    version_not_supported: 6, host_key_not_verifiable: 7,
    connection_lost: 8, by_application: 9, too_many_connections: 10,
    auth_cancelled: 11
  }
  @tag_to_disconnect_reason Map.new(@disconnect_reason_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec disconnect_reason_from_tag(non_neg_integer()) :: {:ok, disconnect_reason()} | :error
  def disconnect_reason_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 11 do
    {:ok, Map.fetch!(@tag_to_disconnect_reason, tag)}
  end
  def disconnect_reason_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec disconnect_reason_to_tag(disconnect_reason()) :: non_neg_integer()
  def disconnect_reason_to_tag(reason) when is_map_key(@disconnect_reason_tags, reason) do
    Map.fetch!(@disconnect_reason_tags, reason)
  end

  @doc "Whether this disconnect reason indicates a security issue."
  @spec disconnect_reason_security_related?(disconnect_reason()) :: boolean()
  def disconnect_reason_security_related?(r)
      when r in [:host_not_allowed, :host_auth_failed, :mac_error, :host_key_not_verifiable, :auth_cancelled],
      do: true
  def disconnect_reason_security_related?(_r), do: false

  # ===========================================================================
  # HostKeyAlgorithm (tags 0-3)
  # ===========================================================================

  @typedoc "SSH host key algorithms."
  @type host_key_algorithm :: :ssh_ed25519 | :rsa_sha2_256 | :rsa_sha2_512 | :ecdsa_nistp256

  @host_key_algorithm_tags %{ssh_ed25519: 0, rsa_sha2_256: 1, rsa_sha2_512: 2, ecdsa_nistp256: 3}
  @tag_to_host_key_algorithm Map.new(@host_key_algorithm_tags, fn {k, v} -> {v, k} end)

  @host_key_algorithm_names %{
    ssh_ed25519: "ssh-ed25519", rsa_sha2_256: "rsa-sha2-256",
    rsa_sha2_512: "rsa-sha2-512", ecdsa_nistp256: "ecdsa-sha2-nistp256"
  }

  @doc "Decode from a C-ABI tag value."
  @spec host_key_algorithm_from_tag(non_neg_integer()) :: {:ok, host_key_algorithm()} | :error
  def host_key_algorithm_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_host_key_algorithm, tag)}
  end
  def host_key_algorithm_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec host_key_algorithm_to_tag(host_key_algorithm()) :: non_neg_integer()
  def host_key_algorithm_to_tag(alg) when is_map_key(@host_key_algorithm_tags, alg) do
    Map.fetch!(@host_key_algorithm_tags, alg)
  end

  @doc "Algorithm name string."
  @spec host_key_algorithm_name(host_key_algorithm()) :: String.t()
  def host_key_algorithm_name(alg) when is_map_key(@host_key_algorithm_names, alg) do
    Map.fetch!(@host_key_algorithm_names, alg)
  end

  @doc "Whether this algorithm uses elliptic curve cryptography."
  @spec host_key_algorithm_ecc?(host_key_algorithm()) :: boolean()
  def host_key_algorithm_ecc?(alg) when alg in [:ssh_ed25519, :ecdsa_nistp256], do: true
  def host_key_algorithm_ecc?(_alg), do: false

  # ===========================================================================
  # CipherAlgorithm (tags 0-5)
  # ===========================================================================

  @typedoc "SSH symmetric cipher algorithms."
  @type cipher_algorithm ::
          :chacha20_poly1305 | :aes256_gcm | :aes128_gcm
          | :aes256_ctr | :aes192_ctr | :aes128_ctr

  @cipher_algorithm_tags %{
    chacha20_poly1305: 0, aes256_gcm: 1, aes128_gcm: 2,
    aes256_ctr: 3, aes192_ctr: 4, aes128_ctr: 5
  }

  @tag_to_cipher_algorithm Map.new(@cipher_algorithm_tags, fn {k, v} -> {v, k} end)

  @cipher_algorithm_names %{
    chacha20_poly1305: "chacha20-poly1305@openssh.com",
    aes256_gcm: "aes256-gcm@openssh.com",
    aes128_gcm: "aes128-gcm@openssh.com",
    aes256_ctr: "aes256-ctr",
    aes192_ctr: "aes192-ctr",
    aes128_ctr: "aes128-ctr"
  }

  @doc "Decode from a C-ABI tag value."
  @spec cipher_algorithm_from_tag(non_neg_integer()) :: {:ok, cipher_algorithm()} | :error
  def cipher_algorithm_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_cipher_algorithm, tag)}
  end
  def cipher_algorithm_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec cipher_algorithm_to_tag(cipher_algorithm()) :: non_neg_integer()
  def cipher_algorithm_to_tag(alg) when is_map_key(@cipher_algorithm_tags, alg) do
    Map.fetch!(@cipher_algorithm_tags, alg)
  end

  @doc "Cipher algorithm name string."
  @spec cipher_algorithm_name(cipher_algorithm()) :: String.t()
  def cipher_algorithm_name(alg) when is_map_key(@cipher_algorithm_names, alg) do
    Map.fetch!(@cipher_algorithm_names, alg)
  end

  @doc "Whether this cipher provides authenticated encryption (AEAD)."
  @spec cipher_algorithm_aead?(cipher_algorithm()) :: boolean()
  def cipher_algorithm_aead?(alg) when alg in [:chacha20_poly1305, :aes256_gcm, :aes128_gcm], do: true
  def cipher_algorithm_aead?(_alg), do: false

  @doc "The key size in bits for this cipher."
  @spec cipher_algorithm_key_bits(cipher_algorithm()) :: non_neg_integer()
  def cipher_algorithm_key_bits(:chacha20_poly1305), do: 256
  def cipher_algorithm_key_bits(:aes256_gcm), do: 256
  def cipher_algorithm_key_bits(:aes256_ctr), do: 256
  def cipher_algorithm_key_bits(:aes192_ctr), do: 192
  def cipher_algorithm_key_bits(:aes128_gcm), do: 128
  def cipher_algorithm_key_bits(:aes128_ctr), do: 128

  # ===========================================================================
  # ChannelOpenFailure (tags 0-3)
  # ===========================================================================

  @typedoc "Reasons an SSH channel open request can be rejected."
  @type channel_open_failure :: :admin_prohibited | :connect_failed | :unknown_channel_type | :resource_shortage

  @channel_open_failure_tags %{
    admin_prohibited: 0, connect_failed: 1, unknown_channel_type: 2, resource_shortage: 3
  }

  @tag_to_channel_open_failure Map.new(@channel_open_failure_tags, fn {k, v} -> {v, k} end)

  @doc "Decode from a C-ABI tag value."
  @spec channel_open_failure_from_tag(non_neg_integer()) :: {:ok, channel_open_failure()} | :error
  def channel_open_failure_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_channel_open_failure, tag)}
  end
  def channel_open_failure_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec channel_open_failure_to_tag(channel_open_failure()) :: non_neg_integer()
  def channel_open_failure_to_tag(reason) when is_map_key(@channel_open_failure_tags, reason) do
    Map.fetch!(@channel_open_failure_tags, reason)
  end
end
