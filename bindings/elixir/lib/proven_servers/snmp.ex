# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Snmp do
  @moduledoc """
  SNMP protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `SNMPABI.Types` and its type definitions:
  - `Version`     — SNMP protocol versions (3 constructors, tags 0-2)
  - `PduType`     — SNMP PDU types (7 constructors, tags 0-6)
  - `ErrorStatus` — SNMP error status codes (16 constructors, tags 0-15)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard SNMP agent port (RFC 3411)."
  @spec snmp_port() :: non_neg_integer()
  def snmp_port, do: 161

  @doc "Standard SNMP trap port (RFC 3411)."
  @spec snmp_trap_port() :: non_neg_integer()
  def snmp_trap_port, do: 162

  # ===========================================================================
  # Version (tags 0-2)
  # ===========================================================================

  @typedoc """
  Version types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type version :: :v1 | :v2c | :v3

  @version_tags %{
    v1: 0,
    v2c: 1,
    v3: 2,
  }

  @tag_to_version Map.new(@version_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Version` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Snmp.version_from_tag(0)
      {:ok, :v1}
  """
  @spec version_from_tag(non_neg_integer()) :: {:ok, version()} | :error
  def version_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_version, tag)}
  end

  def version_from_tag(_tag), do: :error

  @doc """
  Encode a `Version` to the C-ABI tag value.
  """
  @spec version_to_tag(version()) :: non_neg_integer()
  def version_to_tag(val) when is_map_key(@version_tags, val) do
    Map.fetch!(@version_tags, val)
  end

  @doc """
  All `Version` variants in tag order.
  """
  @spec all_versions() :: [version()]
  def all_versions, do: [:v1, :v2c, :v3]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this version supports the User-based Security Model (USM).
  """
  @spec has_usm?(version()) :: boolean()
  def has_usm?(val) when val in [:v3], do: true
  def has_usm?(_val), do: false

  @doc """
  Whether this version uses community strings for authentication.
  """
  @spec uses_community_strings?(version()) :: boolean()
  def uses_community_strings?(val) when val in [:v1, :v2c], do: true
  def uses_community_strings?(_val), do: false

  @doc """
  Whether this version supports GetBulkRequest.
  """
  @spec supports_get_bulk?(version()) :: boolean()
  def supports_get_bulk?(val) when val in [:v1], do: false
  def supports_get_bulk?(_val), do: true

  # ===========================================================================
  # PduType (tags 0-6)
  # ===========================================================================

  @typedoc """
  PduType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type pdu_type ::
          :get_request
          | :get_next_request
          | :get_response
          | :set_request
          | :get_bulk_request
          | :inform_request
          | :snmp_v2_trap

  @pdu_type_tags %{
    get_request: 0,
    get_next_request: 1,
    get_response: 2,
    set_request: 3,
    get_bulk_request: 4,
    inform_request: 5,
    snmp_v2_trap: 6,
  }

  @tag_to_pdu_type Map.new(@pdu_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PduType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Snmp.pdu_type_from_tag(0)
      {:ok, :get_request}
  """
  @spec pdu_type_from_tag(non_neg_integer()) :: {:ok, pdu_type()} | :error
  def pdu_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_pdu_type, tag)}
  end

  def pdu_type_from_tag(_tag), do: :error

  @doc """
  Encode a `PduType` to the C-ABI tag value.
  """
  @spec pdu_type_to_tag(pdu_type()) :: non_neg_integer()
  def pdu_type_to_tag(val) when is_map_key(@pdu_type_tags, val) do
    Map.fetch!(@pdu_type_tags, val)
  end

  @doc """
  All `PduType` variants in tag order.
  """
  @spec all_pdu_types() :: [pdu_type()]
  def all_pdu_types do
    [
      :get_request, :get_next_request, :get_response, :set_request, :get_bulk_request,
      :inform_request, :snmp_v2_trap
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this PDU is a request from manager to agent.
  """
  @spec is_request?(pdu_type()) :: boolean()
  def is_request?(val) when val in [:get_request, :get_next_request, :set_request, :get_bulk_request], do: true
  def is_request?(_val), do: false

  @doc """
  Whether this PDU is a notification (trap or inform).
  """
  @spec is_notification?(pdu_type()) :: boolean()
  def is_notification?(val) when val in [:inform_request, :snmp_v2_trap], do: true
  def is_notification?(_val), do: false

  @doc """
  Whether this PDU modifies agent state.
  """
  @spec is_write?(pdu_type()) :: boolean()
  def is_write?(val) when val in [:set_request], do: true
  def is_write?(_val), do: false

  # ===========================================================================
  # ErrorStatus (tags 0-15)
  # ===========================================================================

  @typedoc """
  ErrorStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_status ::
          :no_error
          | :too_big
          | :no_such_name
          | :bad_value
          | :read_only
          | :gen_err
          | :no_access
          | :wrong_type
          | :wrong_length
          | :wrong_value
          | :no_creation
          | :inconsistent_value
          | :resource_unavailable
          | :commit_failed
          | :undo_failed
          | :authorization_error

  @error_status_tags %{
    no_error: 0,
    too_big: 1,
    no_such_name: 2,
    bad_value: 3,
    read_only: 4,
    gen_err: 5,
    no_access: 6,
    wrong_type: 7,
    wrong_length: 8,
    wrong_value: 9,
    no_creation: 10,
    inconsistent_value: 11,
    resource_unavailable: 12,
    commit_failed: 13,
    undo_failed: 14,
    authorization_error: 15,
  }

  @tag_to_error_status Map.new(@error_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..15, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Snmp.error_status_from_tag(0)
      {:ok, :no_error}
  """
  @spec error_status_from_tag(non_neg_integer()) :: {:ok, error_status()} | :error
  def error_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 15 do
    {:ok, Map.fetch!(@tag_to_error_status, tag)}
  end

  def error_status_from_tag(_tag), do: :error

  @doc """
  Encode a `ErrorStatus` to the C-ABI tag value.
  """
  @spec error_status_to_tag(error_status()) :: non_neg_integer()
  def error_status_to_tag(val) when is_map_key(@error_status_tags, val) do
    Map.fetch!(@error_status_tags, val)
  end

  @doc """
  All `ErrorStatus` variants in tag order.
  """
  @spec all_error_statuss() :: [error_status()]
  def all_error_statuss do
    [
      :no_error, :too_big, :no_such_name, :bad_value, :read_only, :gen_err,
      :no_access, :wrong_type, :wrong_length, :wrong_value, :no_creation,
      :inconsistent_value, :resource_unavailable, :commit_failed, :undo_failed,
      :authorization_error
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this status indicates success.
  """
  @spec is_success?(error_status()) :: boolean()
  def is_success?(val) when val in [:no_error], do: true
  def is_success?(_val), do: false

  @doc """
  Whether this is an SNMPv1-only error code.
  """
  @spec is_v1_only?(error_status()) :: boolean()
  def is_v1_only?(val) when val in [:no_such_name, :bad_value, :read_only], do: true
  def is_v1_only?(_val), do: false

  @doc """
  Whether this error relates to authorisation/access control.
  """
  @spec is_auth_error?(error_status()) :: boolean()
  def is_auth_error?(val) when val in [:no_access, :authorization_error], do: true
  def is_auth_error?(_val), do: false

end
