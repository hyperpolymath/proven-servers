# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

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

  @doc """
  Validate whether a bastion state transition is allowed.

  ## Examples

      iex> ProvenServers.SshBastion.bastion_can_transition?(:connected, :key_exchanged)
      true

      iex> ProvenServers.SshBastion.bastion_can_transition?(:connected, :active)
      false
  """
  @spec bastion_can_transition?(bastion_state(), bastion_state()) :: boolean()
  def bastion_can_transition?(:connected, :key_exchanged), do: true
  def bastion_can_transition?(:key_exchanged, :authenticated), do: true
  def bastion_can_transition?(:authenticated, :channel_open), do: true
  def bastion_can_transition?(:channel_open, :active), do: true
  def bastion_can_transition?(_, :closed), do: true
  def bastion_can_transition?(_, _), do: false

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

  @doc "Validate whether a channel state transition is allowed."
  @spec channel_can_transition?(channel_state(), channel_state()) :: boolean()
  def channel_can_transition?(:opening, :open), do: true
  def channel_can_transition?(:opening, :channel_closed), do: true
  def channel_can_transition?(:open, :closing), do: true
  def channel_can_transition?(:closing, :channel_closed), do: true
  def channel_can_transition?(_, _), do: false

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
end
