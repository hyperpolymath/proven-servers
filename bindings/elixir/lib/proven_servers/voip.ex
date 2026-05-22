# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Voip do
  @moduledoc """
  VoIP (Voice over IP / SIP) types for the proven-servers ABI.
  
  Mirrors the Idris2 module `VoIPABI.Types` and its type definitions:
  - `Method`       — SIP request methods (13 constructors, tags 0-12)
  - `ResponseCode` — SIP response codes (17 constructors, tags 0-16)
  - `DialogState`  — SIP dialog lifecycle (3 constructors, tags 0-2)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard SIP port (RFC 3261)."
  @spec sip_port() :: non_neg_integer()
  def sip_port, do: 5060

  @doc "Standard SIP over TLS (SIPS) port (RFC 3261)."
  @spec sips_port() :: non_neg_integer()
  def sips_port, do: 5061

  # ===========================================================================
  # Method (tags 0-12)
  # ===========================================================================

  @typedoc """
  Method types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type method ::
          :invite
          | :ack
          | :bye
          | :cancel
          | :register
          | :options
          | :info
          | :update
          | :subscribe
          | :notify
          | :refer
          | :message
          | :prack

  @method_tags %{
    invite: 0,
    ack: 1,
    bye: 2,
    cancel: 3,
    register: 4,
    options: 5,
    info: 6,
    update: 7,
    subscribe: 8,
    notify: 9,
    refer: 10,
    message: 11,
    prack: 12,
  }

  @tag_to_method Map.new(@method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Method` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..12, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Voip.method_from_tag(0)
      {:ok, :invite}
  """
  @spec method_from_tag(non_neg_integer()) :: {:ok, method()} | :error
  def method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 12 do
    {:ok, Map.fetch!(@tag_to_method, tag)}
  end

  def method_from_tag(_tag), do: :error

  @doc """
  Encode a `Method` to the C-ABI tag value.
  """
  @spec method_to_tag(method()) :: non_neg_integer()
  def method_to_tag(val) when is_map_key(@method_tags, val) do
    Map.fetch!(@method_tags, val)
  end

  @doc """
  All `Method` variants in tag order.
  """
  @spec all_methods() :: [method()]
  def all_methods do
    [
      :invite, :ack, :bye, :cancel, :register, :options, :info, :update,
      :subscribe, :notify, :refer, :message, :prack
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The SIP method name string.
        match self {

  Whether this method creates or modifies a dialog.
  """
  @spec is_dialog_creating?(method()) :: boolean()
  def is_dialog_creating?(val) when val in [:invite, :subscribe], do: true
  def is_dialog_creating?(_val), do: false

  @doc """
  Whether this method is related to session management.
  """
  @spec is_session_related?(method()) :: boolean()
  def is_session_related?(val) when val in [:invite, :ack, :bye, :cancel, :update, :prack], do: true
  def is_session_related?(_val), do: false

  @doc """
  Whether this method is related to event notification.
  """
  @spec is_event_related?(method()) :: boolean()
  def is_event_related?(val) when val in [:subscribe, :notify], do: true
  def is_event_related?(_val), do: false

  # ===========================================================================
  # ResponseCode (tags 0-16)
  # ===========================================================================

  @typedoc """
  ResponseCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type response_code ::
          :trying
          | :ringing
          | :session_progress
          | :ok
          | :multiple_choices
          | :moved_permanently
          | :moved_temporarily
          | :bad_request
          | :unauthorized
          | :forbidden
          | :not_found
          | :method_not_allowed
          | :request_timeout
          | :busy_here
          | :decline
          | :server_internal_error
          | :service_unavailable

  @response_code_tags %{
    trying: 0,
    ringing: 1,
    session_progress: 2,
    ok: 3,
    multiple_choices: 4,
    moved_permanently: 5,
    moved_temporarily: 6,
    bad_request: 7,
    unauthorized: 8,
    forbidden: 9,
    not_found: 10,
    method_not_allowed: 11,
    request_timeout: 12,
    busy_here: 13,
    decline: 14,
    server_internal_error: 15,
    service_unavailable: 16,
  }

  @tag_to_response_code Map.new(@response_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResponseCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..16, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Voip.response_code_from_tag(0)
      {:ok, :trying}
  """
  @spec response_code_from_tag(non_neg_integer()) :: {:ok, response_code()} | :error
  def response_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 16 do
    {:ok, Map.fetch!(@tag_to_response_code, tag)}
  end

  def response_code_from_tag(_tag), do: :error

  @doc """
  Encode a `ResponseCode` to the C-ABI tag value.
  """
  @spec response_code_to_tag(response_code()) :: non_neg_integer()
  def response_code_to_tag(val) when is_map_key(@response_code_tags, val) do
    Map.fetch!(@response_code_tags, val)
  end

  @doc """
  All `ResponseCode` variants in tag order.
  """
  @spec all_response_codes() :: [response_code()]
  def all_response_codes do
    [
      :trying, :ringing, :session_progress, :ok, :multiple_choices, :moved_permanently,
      :moved_temporarily, :bad_request, :unauthorized, :forbidden, :not_found,
      :method_not_allowed, :request_timeout, :busy_here, :decline, :server_internal_error,
      :service_unavailable
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this is a provisional (1xx) response.
  """
  @spec is_provisional?(response_code()) :: boolean()
  def is_provisional?(val) when val in [:trying, :ringing, :session_progress], do: true
  def is_provisional?(_val), do: false

  @doc """
  Whether this is a success (2xx) response.
  """
  @spec is_success?(response_code()) :: boolean()
  def is_success?(val) when val in [:ok], do: true
  def is_success?(_val), do: false

  @doc """
  Whether this is a redirection (3xx) response.
  """
  @spec is_redirect?(response_code()) :: boolean()
  def is_redirect?(val) when val in [:multiple_choices, :moved_permanently, :moved_temporarily], do: true
  def is_redirect?(_val), do: false

  @doc """
  Whether this is a client error (4xx) response.
  """
  @spec is_client_error?(response_code()) :: boolean()
  def is_client_error?(val) when val in [:bad_request, :unauthorized, :forbidden, :not_found, :method_not_allowed, :request_timeout, :busy_here], do: true
  def is_client_error?(_val), do: false

  @doc """
  Whether this is a server error (5xx) response.
  """
  @spec is_server_error?(response_code()) :: boolean()
  def is_server_error?(val) when val in [:server_internal_error, :service_unavailable], do: true
  def is_server_error?(_val), do: false

  @doc """
  Whether this is a global failure (6xx) response.
  """
  @spec is_global_failure?(response_code()) :: boolean()
  def is_global_failure?(val) when val in [:decline], do: true
  def is_global_failure?(_val), do: false

  # ===========================================================================
  # DialogState (tags 0-2)
  # ===========================================================================

  @typedoc """
  DialogState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type dialog_state :: :early | :confirmed | :terminated

  @dialog_state_tags %{
    early: 0,
    confirmed: 1,
    terminated: 2,
  }

  @tag_to_dialog_state Map.new(@dialog_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DialogState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Voip.dialog_state_from_tag(0)
      {:ok, :early}
  """
  @spec dialog_state_from_tag(non_neg_integer()) :: {:ok, dialog_state()} | :error
  def dialog_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_dialog_state, tag)}
  end

  def dialog_state_from_tag(_tag), do: :error

  @doc """
  Encode a `DialogState` to the C-ABI tag value.
  """
  @spec dialog_state_to_tag(dialog_state()) :: non_neg_integer()
  def dialog_state_to_tag(val) when is_map_key(@dialog_state_tags, val) do
    Map.fetch!(@dialog_state_tags, val)
  end

  @doc """
  All `DialogState` variants in tag order.
  """
  @spec all_dialog_states() :: [dialog_state()]
  def all_dialog_states, do: [:early, :confirmed, :terminated]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether media can flow in this state.
  """
  @spec can_carry_media?(dialog_state()) :: boolean()
  def can_carry_media?(val) when val in [:early, :confirmed], do: true
  def can_carry_media?(_val), do: false

  @doc """
  Whether the dialog is active (not terminated).
  """
  @spec is_active?(dialog_state()) :: boolean()
  def is_active?(val) when val in [:terminated], do: false
  def is_active?(_val), do: true

end
