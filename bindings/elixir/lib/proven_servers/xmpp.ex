# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Xmpp do
  @moduledoc """
  XMPP (Extensible Messaging and Presence Protocol) types for the
  proven-servers ABI.
  
  Mirrors the Idris2 module `XMPPABI.Types` and its type definitions:
  - `StanzaType`   — XMPP stanza types (3 constructors, tags 0-2)
  - `MessageType`  — XMPP message types (5 constructors, tags 0-4)
  - `PresenceType` — XMPP presence show values (5 constructors, tags 0-4)
  - `IqType`       — XMPP IQ stanza types (4 constructors, tags 0-3)
  - `StreamError`  — XMPP stream-level errors (9 constructors, tags 0-8)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard XMPP client-to-server port (RFC 6120)."
  @spec xmpp_client_port() :: non_neg_integer()
  def xmpp_client_port, do: 5222

  @doc "Standard XMPP server-to-server port (RFC 6120)."
  @spec xmpp_server_port() :: non_neg_integer()
  def xmpp_server_port, do: 5269

  @doc "XMPP over TLS (XMPPS) port for direct TLS connections."
  @spec xmpps_port() :: non_neg_integer()
  def xmpps_port, do: 5223

  # ===========================================================================
  # StanzaType (tags 0-2)
  # ===========================================================================

  @typedoc """
  StanzaType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type stanza_type :: :message | :presence | :iq

  @stanza_type_tags %{
    message: 0,
    presence: 1,
    iq: 2,
  }

  @tag_to_stanza_type Map.new(@stanza_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `StanzaType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Xmpp.stanza_type_from_tag(0)
      {:ok, :message}
  """
  @spec stanza_type_from_tag(non_neg_integer()) :: {:ok, stanza_type()} | :error
  def stanza_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_stanza_type, tag)}
  end

  def stanza_type_from_tag(_tag), do: :error

  @doc """
  Encode a `StanzaType` to the C-ABI tag value.
  """
  @spec stanza_type_to_tag(stanza_type()) :: non_neg_integer()
  def stanza_type_to_tag(val) when is_map_key(@stanza_type_tags, val) do
    Map.fetch!(@stanza_type_tags, val)
  end

  @doc """
  All `StanzaType` variants in tag order.
  """
  @spec all_stanza_types() :: [stanza_type()]
  def all_stanza_types, do: [:message, :presence, :iq]

  # ===========================================================================
  # MessageType (tags 0-4)
  # ===========================================================================

  @typedoc """
  MessageType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type message_type :: :chat | :error | :groupchat | :headline | :normal

  @message_type_tags %{
    chat: 0,
    error: 1,
    groupchat: 2,
    headline: 3,
    normal: 4,
  }

  @tag_to_message_type Map.new(@message_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MessageType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Xmpp.message_type_from_tag(0)
      {:ok, :chat}
  """
  @spec message_type_from_tag(non_neg_integer()) :: {:ok, message_type()} | :error
  def message_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_message_type, tag)}
  end

  def message_type_from_tag(_tag), do: :error

  @doc """
  Encode a `MessageType` to the C-ABI tag value.
  """
  @spec message_type_to_tag(message_type()) :: non_neg_integer()
  def message_type_to_tag(val) when is_map_key(@message_type_tags, val) do
    Map.fetch!(@message_type_tags, val)
  end

  @doc """
  All `MessageType` variants in tag order.
  """
  @spec all_message_types() :: [message_type()]
  def all_message_types, do: [:chat, :error, :groupchat, :headline, :normal]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this message type expects a reply.
  """
  @spec expects_reply?(message_type()) :: boolean()
  def expects_reply?(val) when val in [:chat, :normal], do: true
  def expects_reply?(_val), do: false

  @doc """
  Whether this message type is for multi-party communication.
  """
  @spec is_multi_party?(message_type()) :: boolean()
  def is_multi_party?(val) when val in [:groupchat], do: true
  def is_multi_party?(_val), do: false

  # ===========================================================================
  # PresenceType (tags 0-4)
  # ===========================================================================

  @typedoc """
  PresenceType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type presence_type :: :available | :away | :dnd | :xa | :unavailable

  @presence_type_tags %{
    available: 0,
    away: 1,
    dnd: 2,
    xa: 3,
    unavailable: 4,
  }

  @tag_to_presence_type Map.new(@presence_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PresenceType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Xmpp.presence_type_from_tag(0)
      {:ok, :available}
  """
  @spec presence_type_from_tag(non_neg_integer()) :: {:ok, presence_type()} | :error
  def presence_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_presence_type, tag)}
  end

  def presence_type_from_tag(_tag), do: :error

  @doc """
  Encode a `PresenceType` to the C-ABI tag value.
  """
  @spec presence_type_to_tag(presence_type()) :: non_neg_integer()
  def presence_type_to_tag(val) when is_map_key(@presence_type_tags, val) do
    Map.fetch!(@presence_type_tags, val)
  end

  @doc """
  All `PresenceType` variants in tag order.
  """
  @spec all_presence_types() :: [presence_type()]
  def all_presence_types, do: [:available, :away, :dnd, :xa, :unavailable]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the entity is online (any form of availability).
  """
  @spec is_online?(presence_type()) :: boolean()
  def is_online?(val) when val in [:unavailable], do: false
  def is_online?(_val), do: true

  @doc """
  Whether the entity is actively available for communication.
  """
  @spec is_available?(presence_type()) :: boolean()
  def is_available?(val) when val in [:available], do: true
  def is_available?(_val), do: false

  # ===========================================================================
  # IqType (tags 0-3)
  # ===========================================================================

  @typedoc """
  IqType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type iq_type :: :get | :set | :result | :error

  @iq_type_tags %{
    get: 0,
    set: 1,
    result: 2,
    error: 3,
  }

  @tag_to_iq_type Map.new(@iq_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `IqType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Xmpp.iq_type_from_tag(0)
      {:ok, :get}
  """
  @spec iq_type_from_tag(non_neg_integer()) :: {:ok, iq_type()} | :error
  def iq_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_iq_type, tag)}
  end

  def iq_type_from_tag(_tag), do: :error

  @doc """
  Encode a `IqType` to the C-ABI tag value.
  """
  @spec iq_type_to_tag(iq_type()) :: non_neg_integer()
  def iq_type_to_tag(val) when is_map_key(@iq_type_tags, val) do
    Map.fetch!(@iq_type_tags, val)
  end

  @doc """
  All `IqType` variants in tag order.
  """
  @spec all_iq_types() :: [iq_type()]
  def all_iq_types, do: [:get, :set, :result, :error]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this IQ type is a request (requires a response).
  """
  @spec is_request?(iq_type()) :: boolean()
  def is_request?(val) when val in [:get, :set], do: true
  def is_request?(_val), do: false

  @doc """
  Whether this IQ type is a response.
  """
  @spec is_response?(iq_type()) :: boolean()
  def is_response?(val) when val in [:result, :error], do: true
  def is_response?(_val), do: false

  # ===========================================================================
  # StreamError (tags 0-8)
  # ===========================================================================

  @typedoc """
  StreamError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type stream_error ::
          :bad_format
          | :conflict
          | :connection_timeout
          | :host_gone
          | :host_unknown
          | :not_authorized
          | :policy_violation
          | :resource_constraint
          | :system_shutdown

  @stream_error_tags %{
    bad_format: 0,
    conflict: 1,
    connection_timeout: 2,
    host_gone: 3,
    host_unknown: 4,
    not_authorized: 5,
    policy_violation: 6,
    resource_constraint: 7,
    system_shutdown: 8,
  }

  @tag_to_stream_error Map.new(@stream_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `StreamError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Xmpp.stream_error_from_tag(0)
      {:ok, :bad_format}
  """
  @spec stream_error_from_tag(non_neg_integer()) :: {:ok, stream_error()} | :error
  def stream_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_stream_error, tag)}
  end

  def stream_error_from_tag(_tag), do: :error

  @doc """
  Encode a `StreamError` to the C-ABI tag value.
  """
  @spec stream_error_to_tag(stream_error()) :: non_neg_integer()
  def stream_error_to_tag(val) when is_map_key(@stream_error_tags, val) do
    Map.fetch!(@stream_error_tags, val)
  end

  @doc """
  All `StreamError` variants in tag order.
  """
  @spec all_stream_errors() :: [stream_error()]
  def all_stream_errors do
    [
      :bad_format, :conflict, :connection_timeout, :host_gone, :host_unknown,
      :not_authorized, :policy_violation, :resource_constraint, :system_shutdown,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this error is related to security/authorisation.
  """
  @spec is_security_error?(stream_error()) :: boolean()
  def is_security_error?(val) when val in [:not_authorized, :policy_violation], do: true
  def is_security_error?(_val), do: false

  @doc """
  Whether this error is likely transient and the connection can be retried.
  """
  @spec is_retryable?(stream_error()) :: boolean()
  def is_retryable?(val) when val in [:connection_timeout, :resource_constraint, :system_shutdown], do: true
  def is_retryable?(_val), do: false

end
