# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Proxy do
  @moduledoc """
  Reverse Proxy types for the proven-servers ABI.
  
  Formally verified HTTP proxy types.
  Mirrors the Idris2 module `ProxyABI.Types`.
  
  - `ProxyMode` -- Proxy operating modes.
  - `HopByHopHeader` -- HTTP hop-by-hop headers (RFC 2616).
  - `CacheDirective` -- HTTP cache directives.
  - `ProxyError` -- Proxy-specific error codes.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard HTTP proxy port."
  @spec proxy_http_port() :: non_neg_integer()
  def proxy_http_port, do: 80

  @doc "Standard HTTPS proxy port."
  @spec proxy_https_port() :: non_neg_integer()
  def proxy_https_port, do: 443

  # ===========================================================================
  # ProxyMode (tags 0-1)
  # ===========================================================================

  @typedoc """
  ProxyMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type proxy_mode :: :forward | :reverse

  @proxy_mode_tags %{
    forward: 0,
    reverse: 1,
  }

  @tag_to_proxy_mode Map.new(@proxy_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ProxyMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Proxy.proxy_mode_from_tag(0)
      {:ok, :forward}
  """
  @spec proxy_mode_from_tag(non_neg_integer()) :: {:ok, proxy_mode()} | :error
  def proxy_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_proxy_mode, tag)}
  end

  def proxy_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `ProxyMode` to the C-ABI tag value.
  """
  @spec proxy_mode_to_tag(proxy_mode()) :: non_neg_integer()
  def proxy_mode_to_tag(val) when is_map_key(@proxy_mode_tags, val) do
    Map.fetch!(@proxy_mode_tags, val)
  end

  @doc """
  All `ProxyMode` variants in tag order.
  """
  @spec all_proxy_modes() :: [proxy_mode()]
  def all_proxy_modes, do: [:forward, :reverse]

  # ===========================================================================
  # HopByHopHeader (tags 0-7)
  # ===========================================================================

  @typedoc """
  HopByHopHeader types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type hop_by_hop_header ::
          :connection
          | :keep_alive
          | :proxy_auth
          | :proxy_authz
          | :te
          | :trailers
          | :transfer_encoding
          | :upgrade

  @hop_by_hop_header_tags %{
    connection: 0,
    keep_alive: 1,
    proxy_auth: 2,
    proxy_authz: 3,
    te: 4,
    trailers: 5,
    transfer_encoding: 6,
    upgrade: 7,
  }

  @tag_to_hop_by_hop_header Map.new(@hop_by_hop_header_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HopByHopHeader` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Proxy.hop_by_hop_header_from_tag(0)
      {:ok, :connection}
  """
  @spec hop_by_hop_header_from_tag(non_neg_integer()) :: {:ok, hop_by_hop_header()} | :error
  def hop_by_hop_header_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_hop_by_hop_header, tag)}
  end

  def hop_by_hop_header_from_tag(_tag), do: :error

  @doc """
  Encode a `HopByHopHeader` to the C-ABI tag value.
  """
  @spec hop_by_hop_header_to_tag(hop_by_hop_header()) :: non_neg_integer()
  def hop_by_hop_header_to_tag(val) when is_map_key(@hop_by_hop_header_tags, val) do
    Map.fetch!(@hop_by_hop_header_tags, val)
  end

  @doc """
  All `HopByHopHeader` variants in tag order.
  """
  @spec all_hop_by_hop_headers() :: [hop_by_hop_header()]
  def all_hop_by_hop_headers do
    [
      :connection, :keep_alive, :proxy_auth, :proxy_authz, :te, :trailers,
      :transfer_encoding, :upgrade
    ]
  end

  # ===========================================================================
  # CacheDirective (tags 0-5)
  # ===========================================================================

  @typedoc """
  CacheDirective types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type cache_directive ::
          :no_cache
          | :no_store
          | :max_age
          | :public
          | :private
          | :must_revalidate

  @cache_directive_tags %{
    no_cache: 0,
    no_store: 1,
    max_age: 2,
    public: 3,
    private: 4,
    must_revalidate: 5,
  }

  @tag_to_cache_directive Map.new(@cache_directive_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CacheDirective` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Proxy.cache_directive_from_tag(0)
      {:ok, :no_cache}
  """
  @spec cache_directive_from_tag(non_neg_integer()) :: {:ok, cache_directive()} | :error
  def cache_directive_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_cache_directive, tag)}
  end

  def cache_directive_from_tag(_tag), do: :error

  @doc """
  Encode a `CacheDirective` to the C-ABI tag value.
  """
  @spec cache_directive_to_tag(cache_directive()) :: non_neg_integer()
  def cache_directive_to_tag(val) when is_map_key(@cache_directive_tags, val) do
    Map.fetch!(@cache_directive_tags, val)
  end

  @doc """
  All `CacheDirective` variants in tag order.
  """
  @spec all_cache_directives() :: [cache_directive()]
  def all_cache_directives, do: [:no_cache, :no_store, :max_age, :public, :private, :must_revalidate]

  # ===========================================================================
  # ProxyError (tags 0-3)
  # ===========================================================================

  @typedoc """
  ProxyError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type proxy_error :: :bad_gateway | :gateway_timeout | :upstream_refused | :upstream_tls

  @proxy_error_tags %{
    bad_gateway: 0,
    gateway_timeout: 1,
    upstream_refused: 2,
    upstream_tls: 3,
  }

  @tag_to_proxy_error Map.new(@proxy_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ProxyError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Proxy.proxy_error_from_tag(0)
      {:ok, :bad_gateway}
  """
  @spec proxy_error_from_tag(non_neg_integer()) :: {:ok, proxy_error()} | :error
  def proxy_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_proxy_error, tag)}
  end

  def proxy_error_from_tag(_tag), do: :error

  @doc """
  Encode a `ProxyError` to the C-ABI tag value.
  """
  @spec proxy_error_to_tag(proxy_error()) :: non_neg_integer()
  def proxy_error_to_tag(val) when is_map_key(@proxy_error_tags, val) do
    Map.fetch!(@proxy_error_tags, val)
  end

  @doc """
  All `ProxyError` variants in tag order.
  """
  @spec all_proxy_errors() :: [proxy_error()]
  def all_proxy_errors, do: [:bad_gateway, :gateway_timeout, :upstream_refused, :upstream_tls]

end
