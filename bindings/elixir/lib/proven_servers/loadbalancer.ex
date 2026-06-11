# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Loadbalancer do
  @moduledoc """
  Load Balancer types for the proven-servers ABI.
  
  Formally verified load balancer types.
  Mirrors the Idris2 module `LoadbalancerABI.Types`.
  
  - `Algorithm` -- Load balancing algorithms.
  - `HealthCheckType` -- Backend health check types.
  - `BackendState` -- Backend server states.
  - `SessionPersistence` -- Session persistence strategies.
  - `LbProtocol` -- Load balancer protocols.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # Algorithm (tags 0-5)
  # ===========================================================================

  @typedoc """
  Algorithm types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type algorithm ::
          :round_robin
          | :least_connections
          | :ip_hash
          | :random
          | :weighted_round_robin
          | :least_response_time

  @algorithm_tags %{
    round_robin: 0,
    least_connections: 1,
    ip_hash: 2,
    random: 3,
    weighted_round_robin: 4,
    least_response_time: 5,
  }

  @tag_to_algorithm Map.new(@algorithm_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Algorithm` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Loadbalancer.algorithm_from_tag(0)
      {:ok, :round_robin}
  """
  @spec algorithm_from_tag(non_neg_integer()) :: {:ok, algorithm()} | :error
  def algorithm_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_algorithm, tag)}
  end

  def algorithm_from_tag(_tag), do: :error

  @doc """
  Encode a `Algorithm` to the C-ABI tag value.
  """
  @spec algorithm_to_tag(algorithm()) :: non_neg_integer()
  def algorithm_to_tag(val) when is_map_key(@algorithm_tags, val) do
    Map.fetch!(@algorithm_tags, val)
  end

  @doc """
  All `Algorithm` variants in tag order.
  """
  @spec all_algorithms() :: [algorithm()]
  def all_algorithms do
    [
      :round_robin, :least_connections, :ip_hash, :random, :weighted_round_robin,
      :least_response_time
    ]
  end

  # ===========================================================================
  # HealthCheckType (tags 0-3)
  # ===========================================================================

  @typedoc """
  HealthCheckType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type health_check_type :: :http | :tcp | :grpc | :script

  @health_check_type_tags %{
    http: 0,
    tcp: 1,
    grpc: 2,
    script: 3,
  }

  @tag_to_health_check_type Map.new(@health_check_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HealthCheckType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Loadbalancer.health_check_type_from_tag(0)
      {:ok, :http}
  """
  @spec health_check_type_from_tag(non_neg_integer()) :: {:ok, health_check_type()} | :error
  def health_check_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_health_check_type, tag)}
  end

  def health_check_type_from_tag(_tag), do: :error

  @doc """
  Encode a `HealthCheckType` to the C-ABI tag value.
  """
  @spec health_check_type_to_tag(health_check_type()) :: non_neg_integer()
  def health_check_type_to_tag(val) when is_map_key(@health_check_type_tags, val) do
    Map.fetch!(@health_check_type_tags, val)
  end

  @doc """
  All `HealthCheckType` variants in tag order.
  """
  @spec all_health_check_types() :: [health_check_type()]
  def all_health_check_types, do: [:http, :tcp, :grpc, :script]

  # ===========================================================================
  # BackendState (tags 0-3)
  # ===========================================================================

  @typedoc """
  BackendState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type backend_state :: :healthy | :unhealthy | :draining | :disabled

  @backend_state_tags %{
    healthy: 0,
    unhealthy: 1,
    draining: 2,
    disabled: 3,
  }

  @tag_to_backend_state Map.new(@backend_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `BackendState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Loadbalancer.backend_state_from_tag(0)
      {:ok, :healthy}
  """
  @spec backend_state_from_tag(non_neg_integer()) :: {:ok, backend_state()} | :error
  def backend_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_backend_state, tag)}
  end

  def backend_state_from_tag(_tag), do: :error

  @doc """
  Encode a `BackendState` to the C-ABI tag value.
  """
  @spec backend_state_to_tag(backend_state()) :: non_neg_integer()
  def backend_state_to_tag(val) when is_map_key(@backend_state_tags, val) do
    Map.fetch!(@backend_state_tags, val)
  end

  @doc """
  All `BackendState` variants in tag order.
  """
  @spec all_backend_states() :: [backend_state()]
  def all_backend_states, do: [:healthy, :unhealthy, :draining, :disabled]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this backend can receive new connections.
  """
  @spec can_receive_traffic?(backend_state()) :: boolean()
  def can_receive_traffic?(val) when val in [:healthy], do: true
  def can_receive_traffic?(_val), do: false

  # ===========================================================================
  # SessionPersistence (tags 0-3)
  # ===========================================================================

  @typedoc """
  SessionPersistence types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_persistence :: :none | :cookie | :source_ip | :header

  @session_persistence_tags %{
    none: 0,
    cookie: 1,
    source_ip: 2,
    header: 3,
  }

  @tag_to_session_persistence Map.new(@session_persistence_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionPersistence` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Loadbalancer.session_persistence_from_tag(0)
      {:ok, :none}
  """
  @spec session_persistence_from_tag(non_neg_integer()) :: {:ok, session_persistence()} | :error
  def session_persistence_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_session_persistence, tag)}
  end

  def session_persistence_from_tag(_tag), do: :error

  @doc """
  Encode a `SessionPersistence` to the C-ABI tag value.
  """
  @spec session_persistence_to_tag(session_persistence()) :: non_neg_integer()
  def session_persistence_to_tag(val) when is_map_key(@session_persistence_tags, val) do
    Map.fetch!(@session_persistence_tags, val)
  end

  @doc """
  All `SessionPersistence` variants in tag order.
  """
  @spec all_session_persistences() :: [session_persistence()]
  def all_session_persistences, do: [:none, :cookie, :source_ip, :header]

  # ===========================================================================
  # LbProtocol (tags 0-4)
  # ===========================================================================

  @typedoc """
  LbProtocol types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type lb_protocol :: :http | :https | :tcp | :udp | :grpc

  @lb_protocol_tags %{
    http: 0,
    https: 1,
    tcp: 2,
    udp: 3,
    grpc: 4,
  }

  @tag_to_lb_protocol Map.new(@lb_protocol_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `LbProtocol` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Loadbalancer.lb_protocol_from_tag(0)
      {:ok, :http}
  """
  @spec lb_protocol_from_tag(non_neg_integer()) :: {:ok, lb_protocol()} | :error
  def lb_protocol_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_lb_protocol, tag)}
  end

  def lb_protocol_from_tag(_tag), do: :error

  @doc """
  Encode a `LbProtocol` to the C-ABI tag value.
  """
  @spec lb_protocol_to_tag(lb_protocol()) :: non_neg_integer()
  def lb_protocol_to_tag(val) when is_map_key(@lb_protocol_tags, val) do
    Map.fetch!(@lb_protocol_tags, val)
  end

  @doc """
  All `LbProtocol` variants in tag order.
  """
  @spec all_lb_protocols() :: [lb_protocol()]
  def all_lb_protocols, do: [:http, :https, :tcp, :udp, :grpc]

end
