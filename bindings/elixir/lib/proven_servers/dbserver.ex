# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Dbserver do
  @moduledoc """
  Database server types for the proven-servers ABI.
  
  Formally verified database protocol types.
  Mirrors the Idris2 module `DbserverABI.Types`.
  
  - `QueryType` -- Database query types (SQL DML/DDL).
  - `DataType` -- Database column/value data types.
  - `IsolationLevel` -- Transaction isolation levels (ANSI SQL).
  - `ErrorCode` -- Database error codes.
  - `JoinType` -- SQL JOIN types.
  - `SessionState` -- Database session lifecycle states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard PostgreSQL port."
  @spec dbserver_port() :: non_neg_integer()
  def dbserver_port, do: 5432

  # ===========================================================================
  # QueryType (tags 0-11)
  # ===========================================================================

  @typedoc """
  QueryType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type query_type ::
          :select
          | :insert
          | :update
          | :delete
          | :create_table
          | :drop_table
          | :alter_table
          | :create_index
          | :drop_index
          | :begin
          | :commit
          | :rollback

  @query_type_tags %{
    select: 0,
    insert: 1,
    update: 2,
    delete: 3,
    create_table: 4,
    drop_table: 5,
    alter_table: 6,
    create_index: 7,
    drop_index: 8,
    begin: 9,
    commit: 10,
    rollback: 11,
  }

  @tag_to_query_type Map.new(@query_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `QueryType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..11, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dbserver.query_type_from_tag(0)
      {:ok, :select}
  """
  @spec query_type_from_tag(non_neg_integer()) :: {:ok, query_type()} | :error
  def query_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 11 do
    {:ok, Map.fetch!(@tag_to_query_type, tag)}
  end

  def query_type_from_tag(_tag), do: :error

  @doc """
  Encode a `QueryType` to the C-ABI tag value.
  """
  @spec query_type_to_tag(query_type()) :: non_neg_integer()
  def query_type_to_tag(val) when is_map_key(@query_type_tags, val) do
    Map.fetch!(@query_type_tags, val)
  end

  @doc """
  All `QueryType` variants in tag order.
  """
  @spec all_query_types() :: [query_type()]
  def all_query_types do
    [
      :select, :insert, :update, :delete, :create_table, :drop_table,
      :alter_table, :create_index, :drop_index, :begin, :commit, :rollback,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this is a DDL (schema modification) query.
  """
  @spec is_ddl?(query_type()) :: boolean()
  def is_ddl?(val) when val in [:create_table, :drop_table, :alter_table, :create_index, :drop_index], do: true
  def is_ddl?(_val), do: false

  @doc """
  Whether this is a transaction control statement.
  """
  @spec is_transaction_control?(query_type()) :: boolean()
  def is_transaction_control?(val) when val in [:begin, :commit, :rollback], do: true
  def is_transaction_control?(_val), do: false

  # ===========================================================================
  # DataType (tags 0-8)
  # ===========================================================================

  @typedoc """
  DataType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type data_type ::
          :integer
          | :float
          | :text
          | :blob
          | :boolean
          | :timestamp
          | :uuid
          | :json
          | :null

  @data_type_tags %{
    integer: 0,
    float: 1,
    text: 2,
    blob: 3,
    boolean: 4,
    timestamp: 5,
    uuid: 6,
    json: 7,
    null: 8,
  }

  @tag_to_data_type Map.new(@data_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DataType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dbserver.data_type_from_tag(0)
      {:ok, :integer}
  """
  @spec data_type_from_tag(non_neg_integer()) :: {:ok, data_type()} | :error
  def data_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_data_type, tag)}
  end

  def data_type_from_tag(_tag), do: :error

  @doc """
  Encode a `DataType` to the C-ABI tag value.
  """
  @spec data_type_to_tag(data_type()) :: non_neg_integer()
  def data_type_to_tag(val) when is_map_key(@data_type_tags, val) do
    Map.fetch!(@data_type_tags, val)
  end

  @doc """
  All `DataType` variants in tag order.
  """
  @spec all_data_types() :: [data_type()]
  def all_data_types do
    [
      :integer, :float, :text, :blob, :boolean, :timestamp, :uuid, :json,
      :null
    ]
  end

  # ===========================================================================
  # IsolationLevel (tags 0-3)
  # ===========================================================================

  @typedoc """
  IsolationLevel types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type isolation_level :: :read_uncommitted | :read_committed | :repeatable_read | :serializable

  @isolation_level_tags %{
    read_uncommitted: 0,
    read_committed: 1,
    repeatable_read: 2,
    serializable: 3,
  }

  @tag_to_isolation_level Map.new(@isolation_level_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `IsolationLevel` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dbserver.isolation_level_from_tag(0)
      {:ok, :read_uncommitted}
  """
  @spec isolation_level_from_tag(non_neg_integer()) :: {:ok, isolation_level()} | :error
  def isolation_level_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_isolation_level, tag)}
  end

  def isolation_level_from_tag(_tag), do: :error

  @doc """
  Encode a `IsolationLevel` to the C-ABI tag value.
  """
  @spec isolation_level_to_tag(isolation_level()) :: non_neg_integer()
  def isolation_level_to_tag(val) when is_map_key(@isolation_level_tags, val) do
    Map.fetch!(@isolation_level_tags, val)
  end

  @doc """
  All `IsolationLevel` variants in tag order.
  """
  @spec all_isolation_levels() :: [isolation_level()]
  def all_isolation_levels, do: [:read_uncommitted, :read_committed, :repeatable_read, :serializable]

  # ===========================================================================
  # ErrorCode (tags 0-9)
  # ===========================================================================

  @typedoc """
  ErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_code ::
          :syntax_error
          | :table_not_found
          | :column_not_found
          | :duplicate_key
          | :constraint_violation
          | :type_mismatch
          | :deadlock_detected
          | :transaction_aborted
          | :disk_full
          | :connection_lost

  @error_code_tags %{
    syntax_error: 0,
    table_not_found: 1,
    column_not_found: 2,
    duplicate_key: 3,
    constraint_violation: 4,
    type_mismatch: 5,
    deadlock_detected: 6,
    transaction_aborted: 7,
    disk_full: 8,
    connection_lost: 9,
  }

  @tag_to_error_code Map.new(@error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..9, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dbserver.error_code_from_tag(0)
      {:ok, :syntax_error}
  """
  @spec error_code_from_tag(non_neg_integer()) :: {:ok, error_code()} | :error
  def error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 9 do
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
      :syntax_error, :table_not_found, :column_not_found, :duplicate_key,
      :constraint_violation, :type_mismatch, :deadlock_detected, :transaction_aborted,
      :disk_full, :connection_lost
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this error is potentially recoverable.
  """
  @spec is_recoverable?(error_code()) :: boolean()
  def is_recoverable?(val) when val in [:deadlock_detected, :transaction_aborted, :connection_lost], do: true
  def is_recoverable?(_val), do: false

  # ===========================================================================
  # JoinType (tags 0-4)
  # ===========================================================================

  @typedoc """
  JoinType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type join_type :: :inner | :left_outer | :right_outer | :full_outer | :cross

  @join_type_tags %{
    inner: 0,
    left_outer: 1,
    right_outer: 2,
    full_outer: 3,
    cross: 4,
  }

  @tag_to_join_type Map.new(@join_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `JoinType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dbserver.join_type_from_tag(0)
      {:ok, :inner}
  """
  @spec join_type_from_tag(non_neg_integer()) :: {:ok, join_type()} | :error
  def join_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_join_type, tag)}
  end

  def join_type_from_tag(_tag), do: :error

  @doc """
  Encode a `JoinType` to the C-ABI tag value.
  """
  @spec join_type_to_tag(join_type()) :: non_neg_integer()
  def join_type_to_tag(val) when is_map_key(@join_type_tags, val) do
    Map.fetch!(@join_type_tags, val)
  end

  @doc """
  All `JoinType` variants in tag order.
  """
  @spec all_join_types() :: [join_type()]
  def all_join_types, do: [:inner, :left_outer, :right_outer, :full_outer, :cross]

  # ===========================================================================
  # SessionState (tags 0-5)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state ::
          :idle
          | :connected
          | :transaction
          | :executing
          | :finalising
          | :disconnecting

  @session_state_tags %{
    idle: 0,
    connected: 1,
    transaction: 2,
    executing: 3,
    finalising: 4,
    disconnecting: 5,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dbserver.session_state_from_tag(0)
      {:ok, :idle}
  """
  @spec session_state_from_tag(non_neg_integer()) :: {:ok, session_state()} | :error
  def session_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
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
  def all_session_states do
    [
      :idle, :connected, :transaction, :executing, :finalising, :disconnecting,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether queries can be executed in this state.
  """
  @spec can_query?(session_state()) :: boolean()
  def can_query?(val) when val in [:connected, :transaction], do: true
  def can_query?(_val), do: false

end
