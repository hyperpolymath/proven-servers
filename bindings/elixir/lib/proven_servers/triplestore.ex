# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Triplestore do
  @moduledoc """
  Triple Store types for the proven-servers ABI.
  
  Formally verified RDF triple store types.
  Mirrors the Idris2 module `TriplestoreABI.Types`.
  
  - `Statement` -- RDF statement types.
  - `IndexOrder` -- Triple index orderings.
  - `StorageBackend` -- Triple store storage backends.
  - `ImportFormat` -- RDF import formats.
  - `TransactionIsolation` -- Triple store transaction isolation.
  - `StoreState` -- Triple store states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # Statement (tags 0-1)
  # ===========================================================================

  @typedoc """
  Statement types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type statement :: :triple | :quad

  @statement_tags %{
    triple: 0,
    quad: 1,
  }

  @tag_to_statement Map.new(@statement_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Statement` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Triplestore.statement_from_tag(0)
      {:ok, :triple}
  """
  @spec statement_from_tag(non_neg_integer()) :: {:ok, statement()} | :error
  def statement_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_statement, tag)}
  end

  def statement_from_tag(_tag), do: :error

  @doc """
  Encode a `Statement` to the C-ABI tag value.
  """
  @spec statement_to_tag(statement()) :: non_neg_integer()
  def statement_to_tag(val) when is_map_key(@statement_tags, val) do
    Map.fetch!(@statement_tags, val)
  end

  @doc """
  All `Statement` variants in tag order.
  """
  @spec all_statements() :: [statement()]
  def all_statements, do: [:triple, :quad]

  # ===========================================================================
  # IndexOrder (tags 0-5)
  # ===========================================================================

  @typedoc """
  IndexOrder types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type index_order :: :spo | :pos | :osp | :gspo | :gpos | :gosp

  @index_order_tags %{
    spo: 0,
    pos: 1,
    osp: 2,
    gspo: 3,
    gpos: 4,
    gosp: 5,
  }

  @tag_to_index_order Map.new(@index_order_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `IndexOrder` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Triplestore.index_order_from_tag(0)
      {:ok, :spo}
  """
  @spec index_order_from_tag(non_neg_integer()) :: {:ok, index_order()} | :error
  def index_order_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_index_order, tag)}
  end

  def index_order_from_tag(_tag), do: :error

  @doc """
  Encode a `IndexOrder` to the C-ABI tag value.
  """
  @spec index_order_to_tag(index_order()) :: non_neg_integer()
  def index_order_to_tag(val) when is_map_key(@index_order_tags, val) do
    Map.fetch!(@index_order_tags, val)
  end

  @doc """
  All `IndexOrder` variants in tag order.
  """
  @spec all_index_orders() :: [index_order()]
  def all_index_orders, do: [:spo, :pos, :osp, :gspo, :gpos, :gosp]

  # ===========================================================================
  # StorageBackend (tags 0-3)
  # ===========================================================================

  @typedoc """
  StorageBackend types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type storage_backend :: :in_memory | :b_tree | :lsm | :persistent

  @storage_backend_tags %{
    in_memory: 0,
    b_tree: 1,
    lsm: 2,
    persistent: 3,
  }

  @tag_to_storage_backend Map.new(@storage_backend_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `StorageBackend` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Triplestore.storage_backend_from_tag(0)
      {:ok, :in_memory}
  """
  @spec storage_backend_from_tag(non_neg_integer()) :: {:ok, storage_backend()} | :error
  def storage_backend_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_storage_backend, tag)}
  end

  def storage_backend_from_tag(_tag), do: :error

  @doc """
  Encode a `StorageBackend` to the C-ABI tag value.
  """
  @spec storage_backend_to_tag(storage_backend()) :: non_neg_integer()
  def storage_backend_to_tag(val) when is_map_key(@storage_backend_tags, val) do
    Map.fetch!(@storage_backend_tags, val)
  end

  @doc """
  All `StorageBackend` variants in tag order.
  """
  @spec all_storage_backends() :: [storage_backend()]
  def all_storage_backends, do: [:in_memory, :b_tree, :lsm, :persistent]

  # ===========================================================================
  # ImportFormat (tags 0-5)
  # ===========================================================================

  @typedoc """
  ImportFormat types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type import_format :: :n_triples | :turtle | :rdf_xml | :json_ld | :n_quads | :trig

  @import_format_tags %{
    n_triples: 0,
    turtle: 1,
    rdf_xml: 2,
    json_ld: 3,
    n_quads: 4,
    trig: 5,
  }

  @tag_to_import_format Map.new(@import_format_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ImportFormat` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Triplestore.import_format_from_tag(0)
      {:ok, :n_triples}
  """
  @spec import_format_from_tag(non_neg_integer()) :: {:ok, import_format()} | :error
  def import_format_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_import_format, tag)}
  end

  def import_format_from_tag(_tag), do: :error

  @doc """
  Encode a `ImportFormat` to the C-ABI tag value.
  """
  @spec import_format_to_tag(import_format()) :: non_neg_integer()
  def import_format_to_tag(val) when is_map_key(@import_format_tags, val) do
    Map.fetch!(@import_format_tags, val)
  end

  @doc """
  All `ImportFormat` variants in tag order.
  """
  @spec all_import_formats() :: [import_format()]
  def all_import_formats, do: [:n_triples, :turtle, :rdf_xml, :json_ld, :n_quads, :trig]

  # ===========================================================================
  # TransactionIsolation (tags 0-2)
  # ===========================================================================

  @typedoc """
  TransactionIsolation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type transaction_isolation :: :read_committed | :serializable | :snapshot

  @transaction_isolation_tags %{
    read_committed: 0,
    serializable: 1,
    snapshot: 2,
  }

  @tag_to_transaction_isolation Map.new(@transaction_isolation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TransactionIsolation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Triplestore.transaction_isolation_from_tag(0)
      {:ok, :read_committed}
  """
  @spec transaction_isolation_from_tag(non_neg_integer()) :: {:ok, transaction_isolation()} | :error
  def transaction_isolation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_transaction_isolation, tag)}
  end

  def transaction_isolation_from_tag(_tag), do: :error

  @doc """
  Encode a `TransactionIsolation` to the C-ABI tag value.
  """
  @spec transaction_isolation_to_tag(transaction_isolation()) :: non_neg_integer()
  def transaction_isolation_to_tag(val) when is_map_key(@transaction_isolation_tags, val) do
    Map.fetch!(@transaction_isolation_tags, val)
  end

  @doc """
  All `TransactionIsolation` variants in tag order.
  """
  @spec all_transaction_isolations() :: [transaction_isolation()]
  def all_transaction_isolations, do: [:read_committed, :serializable, :snapshot]

  # ===========================================================================
  # StoreState (tags 0-4)
  # ===========================================================================

  @typedoc """
  StoreState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type store_state :: :idle | :ready | :in_transaction | :importing | :closing

  @store_state_tags %{
    idle: 0,
    ready: 1,
    in_transaction: 2,
    importing: 3,
    closing: 4,
  }

  @tag_to_store_state Map.new(@store_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `StoreState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Triplestore.store_state_from_tag(0)
      {:ok, :idle}
  """
  @spec store_state_from_tag(non_neg_integer()) :: {:ok, store_state()} | :error
  def store_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_store_state, tag)}
  end

  def store_state_from_tag(_tag), do: :error

  @doc """
  Encode a `StoreState` to the C-ABI tag value.
  """
  @spec store_state_to_tag(store_state()) :: non_neg_integer()
  def store_state_to_tag(val) when is_map_key(@store_state_tags, val) do
    Map.fetch!(@store_state_tags, val)
  end

  @doc """
  All `StoreState` variants in tag order.
  """
  @spec all_store_states() :: [store_state()]
  def all_store_states, do: [:idle, :ready, :in_transaction, :importing, :closing]

end
