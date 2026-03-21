# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Appserver do
  @moduledoc """
  Application Server types for the proven-servers ABI.
  
  Formally verified application server types.
  Mirrors the Idris2 module `AppserverABI.Types`.
  
  - `RequestType` -- Request protocol types.
  - `LifecycleState` -- Application lifecycle states.
  - `HealthCheck` -- Health check types.
  - `DeployStrategy` -- Deployment strategies.
  - `ErrorCategory` -- Application error categories.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard application server port."
  @spec app_port() :: non_neg_integer()
  def app_port, do: 8080

  # ===========================================================================
  # RequestType (tags 0-3)
  # ===========================================================================

  @typedoc """
  RequestType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type request_type :: :http | :web_socket | :grpc | :graph_ql

  @request_type_tags %{
    http: 0,
    web_socket: 1,
    grpc: 2,
    graph_ql: 3,
  }

  @tag_to_request_type Map.new(@request_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RequestType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Appserver.request_type_from_tag(0)
      {:ok, :http}
  """
  @spec request_type_from_tag(non_neg_integer()) :: {:ok, request_type()} | :error
  def request_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_request_type, tag)}
  end

  def request_type_from_tag(_tag), do: :error

  @doc """
  Encode a `RequestType` to the C-ABI tag value.
  """
  @spec request_type_to_tag(request_type()) :: non_neg_integer()
  def request_type_to_tag(val) when is_map_key(@request_type_tags, val) do
    Map.fetch!(@request_type_tags, val)
  end

  @doc """
  All `RequestType` variants in tag order.
  """
  @spec all_request_types() :: [request_type()]
  def all_request_types, do: [:http, :web_socket, :grpc, :graph_ql]

  # ===========================================================================
  # LifecycleState (tags 0-5)
  # ===========================================================================

  @typedoc """
  LifecycleState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type lifecycle_state ::
          :initializing
          | :starting
          | :running
          | :draining
          | :stopping
          | :stopped

  @lifecycle_state_tags %{
    initializing: 0,
    starting: 1,
    running: 2,
    draining: 3,
    stopping: 4,
    stopped: 5,
  }

  @tag_to_lifecycle_state Map.new(@lifecycle_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `LifecycleState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Appserver.lifecycle_state_from_tag(0)
      {:ok, :initializing}
  """
  @spec lifecycle_state_from_tag(non_neg_integer()) :: {:ok, lifecycle_state()} | :error
  def lifecycle_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_lifecycle_state, tag)}
  end

  def lifecycle_state_from_tag(_tag), do: :error

  @doc """
  Encode a `LifecycleState` to the C-ABI tag value.
  """
  @spec lifecycle_state_to_tag(lifecycle_state()) :: non_neg_integer()
  def lifecycle_state_to_tag(val) when is_map_key(@lifecycle_state_tags, val) do
    Map.fetch!(@lifecycle_state_tags, val)
  end

  @doc """
  All `LifecycleState` variants in tag order.
  """
  @spec all_lifecycle_states() :: [lifecycle_state()]
  def all_lifecycle_states, do: [:initializing, :starting, :running, :draining, :stopping, :stopped]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the server is ready to handle requests.
  """
  @spec is_ready?(lifecycle_state()) :: boolean()
  def is_ready?(val) when val in [:running], do: true
  def is_ready?(_val), do: false

  # ===========================================================================
  # HealthCheck (tags 0-2)
  # ===========================================================================

  @typedoc """
  HealthCheck types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type health_check :: :liveness | :readiness | :startup

  @health_check_tags %{
    liveness: 0,
    readiness: 1,
    startup: 2,
  }

  @tag_to_health_check Map.new(@health_check_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HealthCheck` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Appserver.health_check_from_tag(0)
      {:ok, :liveness}
  """
  @spec health_check_from_tag(non_neg_integer()) :: {:ok, health_check()} | :error
  def health_check_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_health_check, tag)}
  end

  def health_check_from_tag(_tag), do: :error

  @doc """
  Encode a `HealthCheck` to the C-ABI tag value.
  """
  @spec health_check_to_tag(health_check()) :: non_neg_integer()
  def health_check_to_tag(val) when is_map_key(@health_check_tags, val) do
    Map.fetch!(@health_check_tags, val)
  end

  @doc """
  All `HealthCheck` variants in tag order.
  """
  @spec all_health_checks() :: [health_check()]
  def all_health_checks, do: [:liveness, :readiness, :startup]

  # ===========================================================================
  # DeployStrategy (tags 0-3)
  # ===========================================================================

  @typedoc """
  DeployStrategy types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type deploy_strategy :: :rolling_update | :blue_green | :canary | :recreate

  @deploy_strategy_tags %{
    rolling_update: 0,
    blue_green: 1,
    canary: 2,
    recreate: 3,
  }

  @tag_to_deploy_strategy Map.new(@deploy_strategy_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DeployStrategy` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Appserver.deploy_strategy_from_tag(0)
      {:ok, :rolling_update}
  """
  @spec deploy_strategy_from_tag(non_neg_integer()) :: {:ok, deploy_strategy()} | :error
  def deploy_strategy_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_deploy_strategy, tag)}
  end

  def deploy_strategy_from_tag(_tag), do: :error

  @doc """
  Encode a `DeployStrategy` to the C-ABI tag value.
  """
  @spec deploy_strategy_to_tag(deploy_strategy()) :: non_neg_integer()
  def deploy_strategy_to_tag(val) when is_map_key(@deploy_strategy_tags, val) do
    Map.fetch!(@deploy_strategy_tags, val)
  end

  @doc """
  All `DeployStrategy` variants in tag order.
  """
  @spec all_deploy_strategys() :: [deploy_strategy()]
  def all_deploy_strategys, do: [:rolling_update, :blue_green, :canary, :recreate]

  # ===========================================================================
  # ErrorCategory (tags 0-4)
  # ===========================================================================

  @typedoc """
  ErrorCategory types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_category ::
          :client_error
          | :server_error
          | :timeout
          | :circuit_open
          | :rate_limited

  @error_category_tags %{
    client_error: 0,
    server_error: 1,
    timeout: 2,
    circuit_open: 3,
    rate_limited: 4,
  }

  @tag_to_error_category Map.new(@error_category_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorCategory` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Appserver.error_category_from_tag(0)
      {:ok, :client_error}
  """
  @spec error_category_from_tag(non_neg_integer()) :: {:ok, error_category()} | :error
  def error_category_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_error_category, tag)}
  end

  def error_category_from_tag(_tag), do: :error

  @doc """
  Encode a `ErrorCategory` to the C-ABI tag value.
  """
  @spec error_category_to_tag(error_category()) :: non_neg_integer()
  def error_category_to_tag(val) when is_map_key(@error_category_tags, val) do
    Map.fetch!(@error_category_tags, val)
  end

  @doc """
  All `ErrorCategory` variants in tag order.
  """
  @spec all_error_categorys() :: [error_category()]
  def all_error_categorys, do: [:client_error, :server_error, :timeout, :circuit_open, :rate_limited]

end
