# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Graphdb do
  @moduledoc """
  Graph Database types for the proven-servers ABI.
  
  Formally verified graph database types.
  Mirrors the Idris2 module `GraphdbABI.Types`.
  
  - `ElementType` -- Graph element types.
  - `QueryLanguage` -- Graph query languages.
  - `TraversalStrategy` -- Graph traversal strategies.
  - `Consistency` -- Consistency levels.
  - `ErrorCode` -- Graph database error codes.
  - `SessionState` -- Graph database session states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard Bolt protocol port."
  @spec graphdb_port() :: non_neg_integer()
  def graphdb_port, do: 7687

  # ===========================================================================
  # ElementType (tags 0-4)
  # ===========================================================================

  @typedoc """
  ElementType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type element_type :: :node | :edge | :property | :label | :index

  @element_type_tags %{
    node: 0,
    edge: 1,
    property: 2,
    label: 3,
    index: 4,
  }

  @tag_to_element_type Map.new(@element_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ElementType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Graphdb.element_type_from_tag(0)
      {:ok, :node}
  """
  @spec element_type_from_tag(non_neg_integer()) :: {:ok, element_type()} | :error
  def element_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_element_type, tag)}
  end

  def element_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ElementType` to the C-ABI tag value.
  """
  @spec element_type_to_tag(element_type()) :: non_neg_integer()
  def element_type_to_tag(val) when is_map_key(@element_type_tags, val) do
    Map.fetch!(@element_type_tags, val)
  end

  @doc """
  All `ElementType` variants in tag order.
  """
  @spec all_element_types() :: [element_type()]
  def all_element_types, do: [:node, :edge, :property, :label, :index]

  # ===========================================================================
  # QueryLanguage (tags 0-3)
  # ===========================================================================

  @typedoc """
  QueryLanguage types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type query_language :: :cypher | :gremlin | :sparql | :graph_ql

  @query_language_tags %{
    cypher: 0,
    gremlin: 1,
    sparql: 2,
    graph_ql: 3,
  }

  @tag_to_query_language Map.new(@query_language_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `QueryLanguage` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Graphdb.query_language_from_tag(0)
      {:ok, :cypher}
  """
  @spec query_language_from_tag(non_neg_integer()) :: {:ok, query_language()} | :error
  def query_language_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_query_language, tag)}
  end

  def query_language_from_tag(_tag), do: :error

  @doc """
  Encode a `QueryLanguage` to the C-ABI tag value.
  """
  @spec query_language_to_tag(query_language()) :: non_neg_integer()
  def query_language_to_tag(val) when is_map_key(@query_language_tags, val) do
    Map.fetch!(@query_language_tags, val)
  end

  @doc """
  All `QueryLanguage` variants in tag order.
  """
  @spec all_query_languages() :: [query_language()]
  def all_query_languages, do: [:cypher, :gremlin, :sparql, :graph_ql]

  # ===========================================================================
  # TraversalStrategy (tags 0-4)
  # ===========================================================================

  @typedoc """
  TraversalStrategy types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type traversal_strategy :: :bfs | :dfs | :dijkstra | :a_star | :random

  @traversal_strategy_tags %{
    bfs: 0,
    dfs: 1,
    dijkstra: 2,
    a_star: 3,
    random: 4,
  }

  @tag_to_traversal_strategy Map.new(@traversal_strategy_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TraversalStrategy` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Graphdb.traversal_strategy_from_tag(0)
      {:ok, :bfs}
  """
  @spec traversal_strategy_from_tag(non_neg_integer()) :: {:ok, traversal_strategy()} | :error
  def traversal_strategy_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_traversal_strategy, tag)}
  end

  def traversal_strategy_from_tag(_tag), do: :error

  @doc """
  Encode a `TraversalStrategy` to the C-ABI tag value.
  """
  @spec traversal_strategy_to_tag(traversal_strategy()) :: non_neg_integer()
  def traversal_strategy_to_tag(val) when is_map_key(@traversal_strategy_tags, val) do
    Map.fetch!(@traversal_strategy_tags, val)
  end

  @doc """
  All `TraversalStrategy` variants in tag order.
  """
  @spec all_traversal_strategys() :: [traversal_strategy()]
  def all_traversal_strategys, do: [:bfs, :dfs, :dijkstra, :a_star, :random]

  # ===========================================================================
  # Consistency (tags 0-3)
  # ===========================================================================

  @typedoc """
  Consistency types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type consistency :: :strong | :eventual | :session | :causal

  @consistency_tags %{
    strong: 0,
    eventual: 1,
    session: 2,
    causal: 3,
  }

  @tag_to_consistency Map.new(@consistency_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Consistency` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Graphdb.consistency_from_tag(0)
      {:ok, :strong}
  """
  @spec consistency_from_tag(non_neg_integer()) :: {:ok, consistency()} | :error
  def consistency_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_consistency, tag)}
  end

  def consistency_from_tag(_tag), do: :error

  @doc """
  Encode a `Consistency` to the C-ABI tag value.
  """
  @spec consistency_to_tag(consistency()) :: non_neg_integer()
  def consistency_to_tag(val) when is_map_key(@consistency_tags, val) do
    Map.fetch!(@consistency_tags, val)
  end

  @doc """
  All `Consistency` variants in tag order.
  """
  @spec all_consistencys() :: [consistency()]
  def all_consistencys, do: [:strong, :eventual, :session, :causal]

  # ===========================================================================
  # ErrorCode (tags 0-6)
  # ===========================================================================

  @typedoc """
  ErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_code ::
          :syntax_error
          | :node_not_found
          | :edge_not_found
          | :constraint_violation
          | :index_exists
          | :transaction_conflict
          | :out_of_memory

  @error_code_tags %{
    syntax_error: 0,
    node_not_found: 1,
    edge_not_found: 2,
    constraint_violation: 3,
    index_exists: 4,
    transaction_conflict: 5,
    out_of_memory: 6,
  }

  @tag_to_error_code Map.new(@error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Graphdb.error_code_from_tag(0)
      {:ok, :syntax_error}
  """
  @spec error_code_from_tag(non_neg_integer()) :: {:ok, error_code()} | :error
  def error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_error_code, tag)}
  end

  def error_code_from_tag(_tag), do: :error

  @doc """
  Encode a `ErrorCode` to the C-ABI tag value.
  """
  @spec error_code_to_tag(error_code()) :: non_neg_integer()
  def error_code_to_tag(val) when is_map_key(@error_code_tags, val) do
    Map.fetch!(@error_code_tags, val)
  end

  @doc """
  All `ErrorCode` variants in tag order.
  """
  @spec all_error_codes() :: [error_code()]
  def all_error_codes do
    [
      :syntax_error, :node_not_found, :edge_not_found, :constraint_violation,
      :index_exists, :transaction_conflict, :out_of_memory
    ]
  end

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :connected | :querying | :traversing | :disconnecting

  @session_state_tags %{
    idle: 0,
    connected: 1,
    querying: 2,
    traversing: 3,
    disconnecting: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Graphdb.session_state_from_tag(0)
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
  def all_session_states, do: [:idle, :connected, :querying, :traversing, :disconnecting]

end
