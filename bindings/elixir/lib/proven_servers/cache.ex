# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Cache do
  @moduledoc """
  Cache protocol types for the proven-servers ABI.
  
  Covers Redis-compatible and Memcached-compatible cache server types.
  Mirrors the Idris2 module `CacheABI.Types` and its type definitions:
  - `Command`         — cache commands (13 constructors, tags 0-12)
  - `EvictionPolicy`  — eviction strategies (5 constructors, tags 0-4)
  - `DataType`        — stored value types (5 constructors, tags 0-4)
  - `ErrorCode`       — cache error codes (6 constructors, tags 0-5)
  - `ReplicationMode` — replication topology roles (4 constructors, tags 0-3)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard Redis port."
  @spec redis_port() :: non_neg_integer()
  def redis_port, do: 6379

  @doc "Standard Memcached port."
  @spec memcached_port() :: non_neg_integer()
  def memcached_port, do: 11211

  # ===========================================================================
  # Command (tags 0-12)
  # ===========================================================================

  @typedoc """
  Command types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type command ::
          :get
          | :set
          | :delete
          | :exists
          | :expire
          | :ttl
          | :keys
          | :flush
          | :incr
          | :decr
          | :append
          | :prepend
          | :cas

  @command_tags %{
    get: 0,
    set: 1,
    delete: 2,
    exists: 3,
    expire: 4,
    ttl: 5,
    keys: 6,
    flush: 7,
    incr: 8,
    decr: 9,
    append: 10,
    prepend: 11,
    cas: 12,
  }

  @tag_to_command Map.new(@command_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Command` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..12, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Cache.command_from_tag(0)
      {:ok, :get}
  """
  @spec command_from_tag(non_neg_integer()) :: {:ok, command()} | :error
  def command_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 12 do
    {:ok, Map.fetch!(@tag_to_command, tag)}
  end

  def command_from_tag(_tag), do: :error

  @doc """
  Encode a `Command` to the C-ABI tag value.
  """
  @spec command_to_tag(command()) :: non_neg_integer()
  def command_to_tag(val) when is_map_key(@command_tags, val) do
    Map.fetch!(@command_tags, val)
  end

  @doc """
  All `Command` variants in tag order.
  """
  @spec all_commands() :: [command()]
  def all_commands do
    [
      :get, :set, :delete, :exists, :expire, :ttl, :keys, :flush, :incr,
      :decr, :append, :prepend, :cas
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this command modifies stored data.
  """
  @spec is_write?(command()) :: boolean()
  def is_write?(val) when val in [:get, :exists, :ttl, :keys], do: false
  def is_write?(_val), do: true

  @doc """
  Whether this command is read-only.
  """
  @spec is_read?(command()) :: boolean()
  def is_read?(val) when val in [:get, :exists, :ttl, :keys], do: true
  def is_read?(_val), do: false

  # ===========================================================================
  # EvictionPolicy (tags 0-4)
  # ===========================================================================

  @typedoc """
  EvictionPolicy types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type eviction_policy :: :lru | :lfu | :random | :evict_ttl | :no_eviction

  @eviction_policy_tags %{
    lru: 0,
    lfu: 1,
    random: 2,
    evict_ttl: 3,
    no_eviction: 4,
  }

  @tag_to_eviction_policy Map.new(@eviction_policy_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `EvictionPolicy` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Cache.eviction_policy_from_tag(0)
      {:ok, :lru}
  """
  @spec eviction_policy_from_tag(non_neg_integer()) :: {:ok, eviction_policy()} | :error
  def eviction_policy_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_eviction_policy, tag)}
  end

  def eviction_policy_from_tag(_tag), do: :error

  @doc """
  Encode a `EvictionPolicy` to the C-ABI tag value.
  """
  @spec eviction_policy_to_tag(eviction_policy()) :: non_neg_integer()
  def eviction_policy_to_tag(val) when is_map_key(@eviction_policy_tags, val) do
    Map.fetch!(@eviction_policy_tags, val)
  end

  @doc """
  All `EvictionPolicy` variants in tag order.
  """
  @spec all_eviction_policys() :: [eviction_policy()]
  def all_eviction_policys, do: [:lru, :lfu, :random, :evict_ttl, :no_eviction]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this policy can cause data loss under memory pressure.
  """
  @spec may_evict?(eviction_policy()) :: boolean()
  def may_evict?(val) when val in [:no_eviction], do: false
  def may_evict?(_val), do: true

  # ===========================================================================
  # DataType (tags 0-4)
  # ===========================================================================

  @typedoc """
  DataType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type data_type :: :string_val | :int_val | :list_val | :set_val | :hash_val

  @data_type_tags %{
    string_val: 0,
    int_val: 1,
    list_val: 2,
    set_val: 3,
    hash_val: 4,
  }

  @tag_to_data_type Map.new(@data_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DataType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Cache.data_type_from_tag(0)
      {:ok, :string_val}
  """
  @spec data_type_from_tag(non_neg_integer()) :: {:ok, data_type()} | :error
  def data_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
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
  def all_data_types, do: [:string_val, :int_val, :list_val, :set_val, :hash_val]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this type is a collection (list, set, or hash).
  """
  @spec is_collection?(data_type()) :: boolean()
  def is_collection?(val) when val in [:list_val, :set_val, :hash_val], do: true
  def is_collection?(_val), do: false

  @doc """
  Whether this type is a scalar (string or integer).
  """
  @spec is_scalar?(data_type()) :: boolean()
  def is_scalar?(val) when val in [:string_val, :int_val], do: true
  def is_scalar?(_val), do: false

  # ===========================================================================
  # ErrorCode (tags 0-5)
  # ===========================================================================

  @typedoc """
  ErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_code ::
          :not_found
          | :type_mismatch
          | :out_of_memory
          | :key_too_long
          | :value_too_large
          | :cas_conflict

  @error_code_tags %{
    not_found: 0,
    type_mismatch: 1,
    out_of_memory: 2,
    key_too_long: 3,
    value_too_large: 4,
    cas_conflict: 5,
  }

  @tag_to_error_code Map.new(@error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Cache.error_code_from_tag(0)
      {:ok, :not_found}
  """
  @spec error_code_from_tag(non_neg_integer()) :: {:ok, error_code()} | :error
  def error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
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
      :not_found, :type_mismatch, :out_of_memory, :key_too_long, :value_too_large,
      :cas_conflict
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this error is transient (may succeed on retry).
  """
  @spec is_transient?(error_code()) :: boolean()
  def is_transient?(val) when val in [:out_of_memory, :cas_conflict], do: true
  def is_transient?(_val), do: false

  @doc """
  Whether this error indicates a client programming error.
  """
  @spec is_client_error?(error_code()) :: boolean()
  def is_client_error?(val) when val in [:type_mismatch, :key_too_long, :value_too_large], do: true
  def is_client_error?(_val), do: false

  # ===========================================================================
  # ReplicationMode (tags 0-3)
  # ===========================================================================

  @typedoc """
  ReplicationMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type replication_mode :: :none | :primary | :replica | :sentinel

  @replication_mode_tags %{
    none: 0,
    primary: 1,
    replica: 2,
    sentinel: 3,
  }

  @tag_to_replication_mode Map.new(@replication_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ReplicationMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Cache.replication_mode_from_tag(0)
      {:ok, :none}
  """
  @spec replication_mode_from_tag(non_neg_integer()) :: {:ok, replication_mode()} | :error
  def replication_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_replication_mode, tag)}
  end

  def replication_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `ReplicationMode` to the C-ABI tag value.
  """
  @spec replication_mode_to_tag(replication_mode()) :: non_neg_integer()
  def replication_mode_to_tag(val) when is_map_key(@replication_mode_tags, val) do
    Map.fetch!(@replication_mode_tags, val)
  end

  @doc """
  All `ReplicationMode` variants in tag order.
  """
  @spec all_replication_modes() :: [replication_mode()]
  def all_replication_modes, do: [:none, :primary, :replica, :sentinel]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this node accepts write operations.
  """
  @spec accepts_writes?(replication_mode()) :: boolean()
  def accepts_writes?(val) when val in [:none, :primary], do: true
  def accepts_writes?(_val), do: false

  @doc """
  Whether this is a data-serving node (not sentinel).
  """
  @spec serves_data?(replication_mode()) :: boolean()
  def serves_data?(val) when val in [:sentinel], do: false
  def serves_data?(_val), do: true

end
