# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Git do
  @moduledoc """
  Git Server types for the proven-servers ABI.
  
  Formally verified Git smart protocol types.
  Mirrors the Idris2 module `GitABI.Types`.
  
  - `Command` -- Git protocol commands.
  - `PacketType` -- Git protocol packet types.
  - `RefType` -- Git reference types.
  - `Capability` -- Git protocol capabilities.
  - `HookResult` -- Git hook results.
  - `ServerState` -- Git server states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard Git daemon port."
  @spec git_port() :: non_neg_integer()
  def git_port, do: 9418

  # ===========================================================================
  # Command (tags 0-2)
  # ===========================================================================

  @typedoc """
  Command types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type command :: :upload_pack | :receive_pack | :upload_archive

  @command_tags %{
    upload_pack: 0,
    receive_pack: 1,
    upload_archive: 2,
  }

  @tag_to_command Map.new(@command_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Command` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Git.command_from_tag(0)
      {:ok, :upload_pack}
  """
  @spec command_from_tag(non_neg_integer()) :: {:ok, command()} | :error
  def command_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
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
  def all_commands, do: [:upload_pack, :receive_pack, :upload_archive]

  # ===========================================================================
  # PacketType (tags 0-7)
  # ===========================================================================

  @typedoc """
  PacketType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type packet_type ::
          :flush
          | :delimiter
          | :response_end
          | :data
          | :pkt_error
          | :sideband_data
          | :sideband_progress
          | :sideband_error

  @packet_type_tags %{
    flush: 0,
    delimiter: 1,
    response_end: 2,
    data: 3,
    pkt_error: 4,
    sideband_data: 5,
    sideband_progress: 6,
    sideband_error: 7,
  }

  @tag_to_packet_type Map.new(@packet_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PacketType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Git.packet_type_from_tag(0)
      {:ok, :flush}
  """
  @spec packet_type_from_tag(non_neg_integer()) :: {:ok, packet_type()} | :error
  def packet_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_packet_type, tag)}
  end

  def packet_type_from_tag(_tag), do: :error

  @doc """
  Encode a `PacketType` to the C-ABI tag value.
  """
  @spec packet_type_to_tag(packet_type()) :: non_neg_integer()
  def packet_type_to_tag(val) when is_map_key(@packet_type_tags, val) do
    Map.fetch!(@packet_type_tags, val)
  end

  @doc """
  All `PacketType` variants in tag order.
  """
  @spec all_packet_types() :: [packet_type()]
  def all_packet_types do
    [
      :flush, :delimiter, :response_end, :data, :pkt_error, :sideband_data,
      :sideband_progress, :sideband_error
    ]
  end

  # ===========================================================================
  # RefType (tags 0-4)
  # ===========================================================================

  @typedoc """
  RefType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ref_type :: :branch | :tag | :head | :remote | :git_note

  @ref_type_tags %{
    branch: 0,
    tag: 1,
    head: 2,
    remote: 3,
    git_note: 4,
  }

  @tag_to_ref_type Map.new(@ref_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RefType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Git.ref_type_from_tag(0)
      {:ok, :branch}
  """
  @spec ref_type_from_tag(non_neg_integer()) :: {:ok, ref_type()} | :error
  def ref_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_ref_type, tag)}
  end

  def ref_type_from_tag(_tag), do: :error

  @doc """
  Encode a `RefType` to the C-ABI tag value.
  """
  @spec ref_type_to_tag(ref_type()) :: non_neg_integer()
  def ref_type_to_tag(val) when is_map_key(@ref_type_tags, val) do
    Map.fetch!(@ref_type_tags, val)
  end

  @doc """
  All `RefType` variants in tag order.
  """
  @spec all_ref_types() :: [ref_type()]
  def all_ref_types, do: [:branch, :tag, :head, :remote, :git_note]

  # ===========================================================================
  # Capability (tags 0-8)
  # ===========================================================================

  @typedoc """
  Capability types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type capability ::
          :multi_ack
          | :thin_pack
          | :side_band64k
          | :ofs_delta
          | :shallow
          | :deepen_since
          | :deepen_not
          | :filter_spec
          | :object_format

  @capability_tags %{
    multi_ack: 0,
    thin_pack: 1,
    side_band64k: 2,
    ofs_delta: 3,
    shallow: 4,
    deepen_since: 5,
    deepen_not: 6,
    filter_spec: 7,
    object_format: 8,
  }

  @tag_to_capability Map.new(@capability_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Capability` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Git.capability_from_tag(0)
      {:ok, :multi_ack}
  """
  @spec capability_from_tag(non_neg_integer()) :: {:ok, capability()} | :error
  def capability_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_capability, tag)}
  end

  def capability_from_tag(_tag), do: :error

  @doc """
  Encode a `Capability` to the C-ABI tag value.
  """
  @spec capability_to_tag(capability()) :: non_neg_integer()
  def capability_to_tag(val) when is_map_key(@capability_tags, val) do
    Map.fetch!(@capability_tags, val)
  end

  @doc """
  All `Capability` variants in tag order.
  """
  @spec all_capabilitys() :: [capability()]
  def all_capabilitys do
    [
      :multi_ack, :thin_pack, :side_band64k, :ofs_delta, :shallow, :deepen_since,
      :deepen_not, :filter_spec, :object_format
    ]
  end

  # ===========================================================================
  # HookResult (tags 0-1)
  # ===========================================================================

  @typedoc """
  HookResult types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type hook_result :: :accept | :reject

  @hook_result_tags %{
    accept: 0,
    reject: 1,
  }

  @tag_to_hook_result Map.new(@hook_result_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HookResult` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Git.hook_result_from_tag(0)
      {:ok, :accept}
  """
  @spec hook_result_from_tag(non_neg_integer()) :: {:ok, hook_result()} | :error
  def hook_result_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_hook_result, tag)}
  end

  def hook_result_from_tag(_tag), do: :error

  @doc """
  Encode a `HookResult` to the C-ABI tag value.
  """
  @spec hook_result_to_tag(hook_result()) :: non_neg_integer()
  def hook_result_to_tag(val) when is_map_key(@hook_result_tags, val) do
    Map.fetch!(@hook_result_tags, val)
  end

  @doc """
  All `HookResult` variants in tag order.
  """
  @spec all_hook_results() :: [hook_result()]
  def all_hook_results, do: [:accept, :reject]

  # ===========================================================================
  # ServerState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ServerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type server_state :: :idle | :discovery | :negotiating | :transfer | :shutdown

  @server_state_tags %{
    idle: 0,
    discovery: 1,
    negotiating: 2,
    transfer: 3,
    shutdown: 4,
  }

  @tag_to_server_state Map.new(@server_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Git.server_state_from_tag(0)
      {:ok, :idle}
  """
  @spec server_state_from_tag(non_neg_integer()) :: {:ok, server_state()} | :error
  def server_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_server_state, tag)}
  end

  def server_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ServerState` to the C-ABI tag value.
  """
  @spec server_state_to_tag(server_state()) :: non_neg_integer()
  def server_state_to_tag(val) when is_map_key(@server_state_tags, val) do
    Map.fetch!(@server_state_tags, val)
  end

  @doc """
  All `ServerState` variants in tag order.
  """
  @spec all_server_states() :: [server_state()]
  def all_server_states, do: [:idle, :discovery, :negotiating, :transfer, :shutdown]

end
