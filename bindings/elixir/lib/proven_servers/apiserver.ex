# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Apiserver do
  @moduledoc """
  API Server types for the proven-servers ABI.
  
  Formally verified API gateway/server types.
  Mirrors the Idris2 module `ApiserverABI.Types`.
  
  - `AuthScheme` -- API authentication schemes.
  - `RateLimitStrategy` -- API rate limiting strategies.
  - `ApiVersion` -- API version identifiers.
  - `ResponseFormat` -- API response formats.
  - `GatewayError` -- API gateway error codes.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard API server port."
  @spec api_port() :: non_neg_integer()
  def api_port, do: 8080

  # ===========================================================================
  # AuthScheme (tags 0-5)
  # ===========================================================================

  @typedoc """
  AuthScheme types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type auth_scheme :: :api_key | :bearer | :basic | :o_auth2 | :hmac | :mtls

  @auth_scheme_tags %{
    api_key: 0,
    bearer: 1,
    basic: 2,
    o_auth2: 3,
    hmac: 4,
    mtls: 5,
  }

  @tag_to_auth_scheme Map.new(@auth_scheme_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuthScheme` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Apiserver.auth_scheme_from_tag(0)
      {:ok, :api_key}
  """
  @spec auth_scheme_from_tag(non_neg_integer()) :: {:ok, auth_scheme()} | :error
  def auth_scheme_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_auth_scheme, tag)}
  end

  def auth_scheme_from_tag(_tag), do: :error

  @doc """
  Encode a `AuthScheme` to the C-ABI tag value.
  """
  @spec auth_scheme_to_tag(auth_scheme()) :: non_neg_integer()
  def auth_scheme_to_tag(val) when is_map_key(@auth_scheme_tags, val) do
    Map.fetch!(@auth_scheme_tags, val)
  end

  @doc """
  All `AuthScheme` variants in tag order.
  """
  @spec all_auth_schemes() :: [auth_scheme()]
  def all_auth_schemes, do: [:api_key, :bearer, :basic, :o_auth2, :hmac, :mtls]

  # ===========================================================================
  # RateLimitStrategy (tags 0-3)
  # ===========================================================================

  @typedoc """
  RateLimitStrategy types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type rate_limit_strategy :: :fixed_window | :sliding_window | :token_bucket | :leaky_bucket

  @rate_limit_strategy_tags %{
    fixed_window: 0,
    sliding_window: 1,
    token_bucket: 2,
    leaky_bucket: 3,
  }

  @tag_to_rate_limit_strategy Map.new(@rate_limit_strategy_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RateLimitStrategy` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Apiserver.rate_limit_strategy_from_tag(0)
      {:ok, :fixed_window}
  """
  @spec rate_limit_strategy_from_tag(non_neg_integer()) :: {:ok, rate_limit_strategy()} | :error
  def rate_limit_strategy_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_rate_limit_strategy, tag)}
  end

  def rate_limit_strategy_from_tag(_tag), do: :error

  @doc """
  Encode a `RateLimitStrategy` to the C-ABI tag value.
  """
  @spec rate_limit_strategy_to_tag(rate_limit_strategy()) :: non_neg_integer()
  def rate_limit_strategy_to_tag(val) when is_map_key(@rate_limit_strategy_tags, val) do
    Map.fetch!(@rate_limit_strategy_tags, val)
  end

  @doc """
  All `RateLimitStrategy` variants in tag order.
  """
  @spec all_rate_limit_strategys() :: [rate_limit_strategy()]
  def all_rate_limit_strategys, do: [:fixed_window, :sliding_window, :token_bucket, :leaky_bucket]

  # ===========================================================================
  # ApiVersion (tags 0-4)
  # ===========================================================================

  @typedoc """
  ApiVersion types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type api_version :: :v1 | :v2 | :v3 | :latest | :deprecated

  @api_version_tags %{
    v1: 0,
    v2: 1,
    v3: 2,
    latest: 3,
    deprecated: 4,
  }

  @tag_to_api_version Map.new(@api_version_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ApiVersion` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Apiserver.api_version_from_tag(0)
      {:ok, :v1}
  """
  @spec api_version_from_tag(non_neg_integer()) :: {:ok, api_version()} | :error
  def api_version_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_api_version, tag)}
  end

  def api_version_from_tag(_tag), do: :error

  @doc """
  Encode a `ApiVersion` to the C-ABI tag value.
  """
  @spec api_version_to_tag(api_version()) :: non_neg_integer()
  def api_version_to_tag(val) when is_map_key(@api_version_tags, val) do
    Map.fetch!(@api_version_tags, val)
  end

  @doc """
  All `ApiVersion` variants in tag order.
  """
  @spec all_api_versions() :: [api_version()]
  def all_api_versions, do: [:v1, :v2, :v3, :latest, :deprecated]

  # ===========================================================================
  # ResponseFormat (tags 0-3)
  # ===========================================================================

  @typedoc """
  ResponseFormat types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type response_format :: :json | :xml | :protobuf | :message_pack

  @response_format_tags %{
    json: 0,
    xml: 1,
    protobuf: 2,
    message_pack: 3,
  }

  @tag_to_response_format Map.new(@response_format_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResponseFormat` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Apiserver.response_format_from_tag(0)
      {:ok, :json}
  """
  @spec response_format_from_tag(non_neg_integer()) :: {:ok, response_format()} | :error
  def response_format_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_response_format, tag)}
  end

  def response_format_from_tag(_tag), do: :error

  @doc """
  Encode a `ResponseFormat` to the C-ABI tag value.
  """
  @spec response_format_to_tag(response_format()) :: non_neg_integer()
  def response_format_to_tag(val) when is_map_key(@response_format_tags, val) do
    Map.fetch!(@response_format_tags, val)
  end

  @doc """
  All `ResponseFormat` variants in tag order.
  """
  @spec all_response_formats() :: [response_format()]
  def all_response_formats, do: [:json, :xml, :protobuf, :message_pack]

  # ===========================================================================
  # GatewayError (tags 0-5)
  # ===========================================================================

  @typedoc """
  GatewayError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type gateway_error ::
          :unauthorized
          | :rate_limited
          | :not_found
          | :bad_request
          | :service_unavailable
          | :circuit_open

  @gateway_error_tags %{
    unauthorized: 0,
    rate_limited: 1,
    not_found: 2,
    bad_request: 3,
    service_unavailable: 4,
    circuit_open: 5,
  }

  @tag_to_gateway_error Map.new(@gateway_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `GatewayError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Apiserver.gateway_error_from_tag(0)
      {:ok, :unauthorized}
  """
  @spec gateway_error_from_tag(non_neg_integer()) :: {:ok, gateway_error()} | :error
  def gateway_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_gateway_error, tag)}
  end

  def gateway_error_from_tag(_tag), do: :error

  @doc """
  Encode a `GatewayError` to the C-ABI tag value.
  """
  @spec gateway_error_to_tag(gateway_error()) :: non_neg_integer()
  def gateway_error_to_tag(val) when is_map_key(@gateway_error_tags, val) do
    Map.fetch!(@gateway_error_tags, val)
  end

  @doc """
  All `GatewayError` variants in tag order.
  """
  @spec all_gateway_errors() :: [gateway_error()]
  def all_gateway_errors do
    [
      :unauthorized, :rate_limited, :not_found, :bad_request, :service_unavailable,
      :circuit_open
    ]
  end

end
