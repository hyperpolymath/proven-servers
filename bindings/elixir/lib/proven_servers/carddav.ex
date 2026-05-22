# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Carddav do
  @moduledoc """
  CardDAV types for the proven-servers ABI.
  
  Formally verified CardDAV types (RFC 6352).
  Mirrors the Idris2 module `CarddavABI.Types`.
  
  - `PropertyType` -- vCard property types.
  - `CardMethod` -- CardDAV methods.
  - `VCardVersion` -- vCard versions.
  - `CardError` -- CardDAV error codes.
  - `ServerState` -- CardDAV server lifecycle states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard CardDAV HTTPS port."
  @spec carddav_port() :: non_neg_integer()
  def carddav_port, do: 443

  # ===========================================================================
  # PropertyType (tags 0-8)
  # ===========================================================================

  @typedoc """
  PropertyType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type property_type :: :fn_name | :n | :email | :tel | :adr | :org | :photo | :url | :note

  @property_type_tags %{
    fn_name: 0,
    n: 1,
    email: 2,
    tel: 3,
    adr: 4,
    org: 5,
    photo: 6,
    url: 7,
    note: 8,
  }

  @tag_to_property_type Map.new(@property_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PropertyType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Carddav.property_type_from_tag(0)
      {:ok, :fn_name}
  """
  @spec property_type_from_tag(non_neg_integer()) :: {:ok, property_type()} | :error
  def property_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_property_type, tag)}
  end

  def property_type_from_tag(_tag), do: :error

  @doc """
  Encode a `PropertyType` to the C-ABI tag value.
  """
  @spec property_type_to_tag(property_type()) :: non_neg_integer()
  def property_type_to_tag(val) when is_map_key(@property_type_tags, val) do
    Map.fetch!(@property_type_tags, val)
  end

  @doc """
  All `PropertyType` variants in tag order.
  """
  @spec all_property_types() :: [property_type()]
  def all_property_types, do: [:fn_name, :n, :email, :tel, :adr, :org, :photo, :url, :note]

  # ===========================================================================
  # CardMethod (tags 0-6)
  # ===========================================================================

  @typedoc """
  CardMethod types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type card_method :: :get | :put | :delete | :propfind | :proppatch | :report | :mkcol

  @card_method_tags %{
    get: 0,
    put: 1,
    delete: 2,
    propfind: 3,
    proppatch: 4,
    report: 5,
    mkcol: 6,
  }

  @tag_to_card_method Map.new(@card_method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CardMethod` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Carddav.card_method_from_tag(0)
      {:ok, :get}
  """
  @spec card_method_from_tag(non_neg_integer()) :: {:ok, card_method()} | :error
  def card_method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_card_method, tag)}
  end

  def card_method_from_tag(_tag), do: :error

  @doc """
  Encode a `CardMethod` to the C-ABI tag value.
  """
  @spec card_method_to_tag(card_method()) :: non_neg_integer()
  def card_method_to_tag(val) when is_map_key(@card_method_tags, val) do
    Map.fetch!(@card_method_tags, val)
  end

  @doc """
  All `CardMethod` variants in tag order.
  """
  @spec all_card_methods() :: [card_method()]
  def all_card_methods, do: [:get, :put, :delete, :propfind, :proppatch, :report, :mkcol]

  # ===========================================================================
  # VCardVersion (tags 0-1)
  # ===========================================================================

  @typedoc """
  VCardVersion types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type v_card_version :: :vcard3 | :vcard4

  @v_card_version_tags %{
    vcard3: 0,
    vcard4: 1,
  }

  @tag_to_v_card_version Map.new(@v_card_version_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `VCardVersion` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Carddav.v_card_version_from_tag(0)
      {:ok, :vcard3}
  """
  @spec v_card_version_from_tag(non_neg_integer()) :: {:ok, v_card_version()} | :error
  def v_card_version_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_v_card_version, tag)}
  end

  def v_card_version_from_tag(_tag), do: :error

  @doc """
  Encode a `VCardVersion` to the C-ABI tag value.
  """
  @spec v_card_version_to_tag(v_card_version()) :: non_neg_integer()
  def v_card_version_to_tag(val) when is_map_key(@v_card_version_tags, val) do
    Map.fetch!(@v_card_version_tags, val)
  end

  @doc """
  All `VCardVersion` variants in tag order.
  """
  @spec all_v_card_versions() :: [v_card_version()]
  def all_v_card_versions, do: [:vcard3, :vcard4]

  # ===========================================================================
  # CardError (tags 0-5)
  # ===========================================================================

  @typedoc """
  CardError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type card_error ::
          :valid_address_data
          | :no_resource_type
          | :max_resource_size
          | :uid_conflict
          | :supported_address_data
          | :precondition_failed

  @card_error_tags %{
    valid_address_data: 0,
    no_resource_type: 1,
    max_resource_size: 2,
    uid_conflict: 3,
    supported_address_data: 4,
    precondition_failed: 5,
  }

  @tag_to_card_error Map.new(@card_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CardError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Carddav.card_error_from_tag(0)
      {:ok, :valid_address_data}
  """
  @spec card_error_from_tag(non_neg_integer()) :: {:ok, card_error()} | :error
  def card_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_card_error, tag)}
  end

  def card_error_from_tag(_tag), do: :error

  @doc """
  Encode a `CardError` to the C-ABI tag value.
  """
  @spec card_error_to_tag(card_error()) :: non_neg_integer()
  def card_error_to_tag(val) when is_map_key(@card_error_tags, val) do
    Map.fetch!(@card_error_tags, val)
  end

  @doc """
  All `CardError` variants in tag order.
  """
  @spec all_card_errors() :: [card_error()]
  def all_card_errors do
    [
      :valid_address_data, :no_resource_type, :max_resource_size, :uid_conflict,
      :supported_address_data, :precondition_failed
    ]
  end

  # ===========================================================================
  # ServerState (tags 0-3)
  # ===========================================================================

  @typedoc """
  ServerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type server_state :: :idle | :bound | :serving | :shutdown

  @server_state_tags %{
    idle: 0,
    bound: 1,
    serving: 2,
    shutdown: 3,
  }

  @tag_to_server_state Map.new(@server_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Carddav.server_state_from_tag(0)
      {:ok, :idle}
  """
  @spec server_state_from_tag(non_neg_integer()) :: {:ok, server_state()} | :error
  def server_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_server_state, tag)}
  end

  def server_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ServerState` to the C-ABI tag value.
  """
  @spec server_state_to_tag(server_state()) :: non_neg_integer()
  def server_state_to_tag(val) when is_map_key(@server_state_tags, val) do
    Map.fetch!(@server_state_tags, val)
  end

  @doc """
  All `ServerState` variants in tag order.
  """
  @spec all_server_states() :: [server_state()]
  def all_server_states, do: [:idle, :bound, :serving, :shutdown]

end
