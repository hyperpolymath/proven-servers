# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Metrics do
  @moduledoc """
  Metrics Server types for the proven-servers ABI.
  
  Formally verified metrics/Prometheus types.
  Mirrors the Idris2 module `MetricsABI.Types`.
  
  - `MetricType` -- Metric data types (OpenMetrics).
  - `ScrapeResult` -- Metrics scrape results.
  - `AlertState` -- Alert rule states.
  - `AggregationOp` -- Metrics aggregation operations.
  - `QueryError` -- Metrics query error codes.
  - `CollectorState` -- Metrics collector states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard Prometheus port."
  @spec metrics_port() :: non_neg_integer()
  def metrics_port, do: 9090

  # ===========================================================================
  # MetricType (tags 0-5)
  # ===========================================================================

  @typedoc """
  MetricType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type metric_type :: :counter | :gauge | :histogram | :summary | :info | :state_set

  @metric_type_tags %{
    counter: 0,
    gauge: 1,
    histogram: 2,
    summary: 3,
    info: 4,
    state_set: 5,
  }

  @tag_to_metric_type Map.new(@metric_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MetricType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Metrics.metric_type_from_tag(0)
      {:ok, :counter}
  """
  @spec metric_type_from_tag(non_neg_integer()) :: {:ok, metric_type()} | :error
  def metric_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_metric_type, tag)}
  end

  def metric_type_from_tag(_tag), do: :error

  @doc """
  Encode a `MetricType` to the C-ABI tag value.
  """
  @spec metric_type_to_tag(metric_type()) :: non_neg_integer()
  def metric_type_to_tag(val) when is_map_key(@metric_type_tags, val) do
    Map.fetch!(@metric_type_tags, val)
  end

  @doc """
  All `MetricType` variants in tag order.
  """
  @spec all_metric_types() :: [metric_type()]
  def all_metric_types, do: [:counter, :gauge, :histogram, :summary, :info, :state_set]

  # ===========================================================================
  # ScrapeResult (tags 0-3)
  # ===========================================================================

  @typedoc """
  ScrapeResult types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type scrape_result :: :success | :scrape_timeout | :connection_refused | :invalid_response

  @scrape_result_tags %{
    success: 0,
    scrape_timeout: 1,
    connection_refused: 2,
    invalid_response: 3,
  }

  @tag_to_scrape_result Map.new(@scrape_result_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ScrapeResult` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Metrics.scrape_result_from_tag(0)
      {:ok, :success}
  """
  @spec scrape_result_from_tag(non_neg_integer()) :: {:ok, scrape_result()} | :error
  def scrape_result_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_scrape_result, tag)}
  end

  def scrape_result_from_tag(_tag), do: :error

  @doc """
  Encode a `ScrapeResult` to the C-ABI tag value.
  """
  @spec scrape_result_to_tag(scrape_result()) :: non_neg_integer()
  def scrape_result_to_tag(val) when is_map_key(@scrape_result_tags, val) do
    Map.fetch!(@scrape_result_tags, val)
  end

  @doc """
  All `ScrapeResult` variants in tag order.
  """
  @spec all_scrape_results() :: [scrape_result()]
  def all_scrape_results, do: [:success, :scrape_timeout, :connection_refused, :invalid_response]

  # ===========================================================================
  # AlertState (tags 0-3)
  # ===========================================================================

  @typedoc """
  AlertState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type alert_state :: :inactive | :pending | :firing | :resolved

  @alert_state_tags %{
    inactive: 0,
    pending: 1,
    firing: 2,
    resolved: 3,
  }

  @tag_to_alert_state Map.new(@alert_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AlertState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Metrics.alert_state_from_tag(0)
      {:ok, :inactive}
  """
  @spec alert_state_from_tag(non_neg_integer()) :: {:ok, alert_state()} | :error
  def alert_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_alert_state, tag)}
  end

  def alert_state_from_tag(_tag), do: :error

  @doc """
  Encode a `AlertState` to the C-ABI tag value.
  """
  @spec alert_state_to_tag(alert_state()) :: non_neg_integer()
  def alert_state_to_tag(val) when is_map_key(@alert_state_tags, val) do
    Map.fetch!(@alert_state_tags, val)
  end

  @doc """
  All `AlertState` variants in tag order.
  """
  @spec all_alert_states() :: [alert_state()]
  def all_alert_states, do: [:inactive, :pending, :firing, :resolved]

  # ===========================================================================
  # AggregationOp (tags 0-10)
  # ===========================================================================

  @typedoc """
  AggregationOp types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type aggregation_op ::
          :sum
          | :avg
          | :min
          | :max
          | :count
          | :rate
          | :increase
          | :p50
          | :p90
          | :p95
          | :p99

  @aggregation_op_tags %{
    sum: 0,
    avg: 1,
    min: 2,
    max: 3,
    count: 4,
    rate: 5,
    increase: 6,
    p50: 7,
    p90: 8,
    p95: 9,
    p99: 10,
  }

  @tag_to_aggregation_op Map.new(@aggregation_op_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AggregationOp` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..10, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Metrics.aggregation_op_from_tag(0)
      {:ok, :sum}
  """
  @spec aggregation_op_from_tag(non_neg_integer()) :: {:ok, aggregation_op()} | :error
  def aggregation_op_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
    {:ok, Map.fetch!(@tag_to_aggregation_op, tag)}
  end

  def aggregation_op_from_tag(_tag), do: :error

  @doc """
  Encode a `AggregationOp` to the C-ABI tag value.
  """
  @spec aggregation_op_to_tag(aggregation_op()) :: non_neg_integer()
  def aggregation_op_to_tag(val) when is_map_key(@aggregation_op_tags, val) do
    Map.fetch!(@aggregation_op_tags, val)
  end

  @doc """
  All `AggregationOp` variants in tag order.
  """
  @spec all_aggregation_ops() :: [aggregation_op()]
  def all_aggregation_ops do
    [
      :sum, :avg, :min, :max, :count, :rate, :increase, :p50, :p90, :p95,
      :p99
    ]
  end

  # ===========================================================================
  # QueryError (tags 0-3)
  # ===========================================================================

  @typedoc """
  QueryError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type query_error :: :parse_error | :execution_error | :query_timeout | :too_many_series

  @query_error_tags %{
    parse_error: 0,
    execution_error: 1,
    query_timeout: 2,
    too_many_series: 3,
  }

  @tag_to_query_error Map.new(@query_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `QueryError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Metrics.query_error_from_tag(0)
      {:ok, :parse_error}
  """
  @spec query_error_from_tag(non_neg_integer()) :: {:ok, query_error()} | :error
  def query_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_query_error, tag)}
  end

  def query_error_from_tag(_tag), do: :error

  @doc """
  Encode a `QueryError` to the C-ABI tag value.
  """
  @spec query_error_to_tag(query_error()) :: non_neg_integer()
  def query_error_to_tag(val) when is_map_key(@query_error_tags, val) do
    Map.fetch!(@query_error_tags, val)
  end

  @doc """
  All `QueryError` variants in tag order.
  """
  @spec all_query_errors() :: [query_error()]
  def all_query_errors, do: [:parse_error, :execution_error, :query_timeout, :too_many_series]

  # ===========================================================================
  # CollectorState (tags 0-4)
  # ===========================================================================

  @typedoc """
  CollectorState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type collector_state :: :idle | :configured | :scraping | :alerting | :stopping

  @collector_state_tags %{
    idle: 0,
    configured: 1,
    scraping: 2,
    alerting: 3,
    stopping: 4,
  }

  @tag_to_collector_state Map.new(@collector_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CollectorState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Metrics.collector_state_from_tag(0)
      {:ok, :idle}
  """
  @spec collector_state_from_tag(non_neg_integer()) :: {:ok, collector_state()} | :error
  def collector_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_collector_state, tag)}
  end

  def collector_state_from_tag(_tag), do: :error

  @doc """
  Encode a `CollectorState` to the C-ABI tag value.
  """
  @spec collector_state_to_tag(collector_state()) :: non_neg_integer()
  def collector_state_to_tag(val) when is_map_key(@collector_state_tags, val) do
    Map.fetch!(@collector_state_tags, val)
  end

  @doc """
  All `CollectorState` variants in tag order.
  """
  @spec all_collector_states() :: [collector_state()]
  def all_collector_states, do: [:idle, :configured, :scraping, :alerting, :stopping]

end
