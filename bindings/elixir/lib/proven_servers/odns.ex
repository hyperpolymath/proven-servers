# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Odns do
  @moduledoc """
  ODNS types for the proven-servers ABI.
  
  Formally verified Oblivious DNS (ODNS) types.
  Mirrors the Idris2 module `OdnsABI.Types`.
  
  - `Role` -- ODNS participant roles.
  - `OdnsMessageType` -- ODNS message types.
  - `OdnsErrorReason` -- ODNS error reasons.
  - `EncapsulationFormat` -- ODNS encapsulation formats.
  - `SessionState` -- ODNS session states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # Role (tags 0-2)
  # ===========================================================================

  @typedoc """
  Role types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type role :: :client | :proxy | :target

  @role_tags %{
    client: 0,
    proxy: 1,
    target: 2,
  }

  @tag_to_role Map.new(@role_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Role` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Odns.role_from_tag(0)
      {:ok, :client}
  """
  @spec role_from_tag(non_neg_integer()) :: {:ok, role()} | :error
  def role_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_role, tag)}
  end

  def role_from_tag(_tag), do: :error

  @doc """
  Encode a `Role` to the C-ABI tag value.
  """
  @spec role_to_tag(role()) :: non_neg_integer()
  def role_to_tag(val) when is_map_key(@role_tags, val) do
    Map.fetch!(@role_tags, val)
  end

  @doc """
  All `Role` variants in tag order.
  """
  @spec all_roles() :: [role()]
  def all_roles, do: [:client, :proxy, :target]

  # ===========================================================================
  # OdnsMessageType (tags 0-1)
  # ===========================================================================

  @typedoc """
  OdnsMessageType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type odns_message_type :: :query | :response

  @odns_message_type_tags %{
    query: 0,
    response: 1,
  }

  @tag_to_odns_message_type Map.new(@odns_message_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `OdnsMessageType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Odns.odns_message_type_from_tag(0)
      {:ok, :query}
  """
  @spec odns_message_type_from_tag(non_neg_integer()) :: {:ok, odns_message_type()} | :error
  def odns_message_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_odns_message_type, tag)}
  end

  def odns_message_type_from_tag(_tag), do: :error

  @doc """
  Encode a `OdnsMessageType` to the C-ABI tag value.
  """
  @spec odns_message_type_to_tag(odns_message_type()) :: non_neg_integer()
  def odns_message_type_to_tag(val) when is_map_key(@odns_message_type_tags, val) do
    Map.fetch!(@odns_message_type_tags, val)
  end

  @doc """
  All `OdnsMessageType` variants in tag order.
  """
  @spec all_odns_message_types() :: [odns_message_type()]
  def all_odns_message_types, do: [:query, :response]

  # ===========================================================================
  # OdnsErrorReason (tags 0-4)
  # ===========================================================================

  @typedoc """
  OdnsErrorReason types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type odns_error_reason ::
          :proxy_error
          | :target_error
          | :decryption_failed
          | :invalid_config
          | :payload_too_large

  @odns_error_reason_tags %{
    proxy_error: 0,
    target_error: 1,
    decryption_failed: 2,
    invalid_config: 3,
    payload_too_large: 4,
  }

  @tag_to_odns_error_reason Map.new(@odns_error_reason_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `OdnsErrorReason` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Odns.odns_error_reason_from_tag(0)
      {:ok, :proxy_error}
  """
  @spec odns_error_reason_from_tag(non_neg_integer()) :: {:ok, odns_error_reason()} | :error
  def odns_error_reason_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_odns_error_reason, tag)}
  end

  def odns_error_reason_from_tag(_tag), do: :error

  @doc """
  Encode a `OdnsErrorReason` to the C-ABI tag value.
  """
  @spec odns_error_reason_to_tag(odns_error_reason()) :: non_neg_integer()
  def odns_error_reason_to_tag(val) when is_map_key(@odns_error_reason_tags, val) do
    Map.fetch!(@odns_error_reason_tags, val)
  end

  @doc """
  All `OdnsErrorReason` variants in tag order.
  """
  @spec all_odns_error_reasons() :: [odns_error_reason()]
  def all_odns_error_reasons do
    [
      :proxy_error, :target_error, :decryption_failed, :invalid_config,
      :payload_too_large
    ]
  end

  # ===========================================================================
  # EncapsulationFormat (tags 0-0)
  # ===========================================================================

  @typedoc """
  EncapsulationFormat types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type encapsulation_format :: :hpke

  @encapsulation_format_tags %{
    hpke: 0,
  }

  @tag_to_encapsulation_format Map.new(@encapsulation_format_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `EncapsulationFormat` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..0, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Odns.encapsulation_format_from_tag(0)
      {:ok, :hpke}
  """
  @spec encapsulation_format_from_tag(non_neg_integer()) :: {:ok, encapsulation_format()} | :error
  def encapsulation_format_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 0 do
    {:ok, Map.fetch!(@tag_to_encapsulation_format, tag)}
  end

  def encapsulation_format_from_tag(_tag), do: :error

  @doc """
  Encode a `EncapsulationFormat` to the C-ABI tag value.
  """
  @spec encapsulation_format_to_tag(encapsulation_format()) :: non_neg_integer()
  def encapsulation_format_to_tag(val) when is_map_key(@encapsulation_format_tags, val) do
    Map.fetch!(@encapsulation_format_tags, val)
  end

  @doc """
  All `EncapsulationFormat` variants in tag order.
  """
  @spec all_encapsulation_formats() :: [encapsulation_format()]
  def all_encapsulation_formats, do: [:hpke]

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :key_exchange | :ready | :processing | :closing

  @session_state_tags %{
    idle: 0,
    key_exchange: 1,
    ready: 2,
    processing: 3,
    closing: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Odns.session_state_from_tag(0)
      {:ok, :idle}
  """
  @spec session_state_from_tag(non_neg_integer()) :: {:ok, session_state()} | :error
  def session_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_session_state, tag)}
  end

  def session_state_from_tag(_tag), do: :error

  @doc """
  Encode a `SessionState` to the C-ABI tag value.
  """
  @spec session_state_to_tag(session_state()) :: non_neg_integer()
  def session_state_to_tag(val) when is_map_key(@session_state_tags, val) do
    Map.fetch!(@session_state_tags, val)
  end

  @doc """
  All `SessionState` variants in tag order.
  """
  @spec all_session_states() :: [session_state()]
  def all_session_states, do: [:idle, :key_exchange, :ready, :processing, :closing]

end
