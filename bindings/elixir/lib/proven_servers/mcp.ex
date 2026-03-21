# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Mcp do
  @moduledoc """
  MCP types for the proven-servers ABI.
  
  Formally verified Model Context Protocol types.
  Mirrors the Idris2 module `McpABI.Types`.
  
  - `McpMessageType` -- MCP message types.
  - `Transport` -- MCP transport types.
  - `McpContentType` -- MCP content types.
  - `McpErrorCode` -- MCP error codes.
  - `McpCapability` -- MCP server capabilities.
  - `SessionState` -- MCP session lifecycle states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # McpMessageType (tags 0-13)
  # ===========================================================================

  @typedoc """
  McpMessageType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type mcp_message_type ::
          :initialize
          | :initialized
          | :ping
          | :call_tool
          | :tool_result
          | :list_tools
          | :list_resources
          | :read_resource
          | :list_prompts
          | :get_prompt
          | :subscribe
          | :unsubscribe
          | :notification
          | :cancel

  @mcp_message_type_tags %{
    initialize: 0,
    initialized: 1,
    ping: 2,
    call_tool: 3,
    tool_result: 4,
    list_tools: 5,
    list_resources: 6,
    read_resource: 7,
    list_prompts: 8,
    get_prompt: 9,
    subscribe: 10,
    unsubscribe: 11,
    notification: 12,
    cancel: 13,
  }

  @tag_to_mcp_message_type Map.new(@mcp_message_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `McpMessageType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..13, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Mcp.mcp_message_type_from_tag(0)
      {:ok, :initialize}
  """
  @spec mcp_message_type_from_tag(non_neg_integer()) :: {:ok, mcp_message_type()} | :error
  def mcp_message_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 13 do
    {:ok, Map.fetch!(@tag_to_mcp_message_type, tag)}
  end

  def mcp_message_type_from_tag(_tag), do: :error

  @doc """
  Encode a `McpMessageType` to the C-ABI tag value.
  """
  @spec mcp_message_type_to_tag(mcp_message_type()) :: non_neg_integer()
  def mcp_message_type_to_tag(val) when is_map_key(@mcp_message_type_tags, val) do
    Map.fetch!(@mcp_message_type_tags, val)
  end

  @doc """
  All `McpMessageType` variants in tag order.
  """
  @spec all_mcp_message_types() :: [mcp_message_type()]
  def all_mcp_message_types do
    [
      :initialize, :initialized, :ping, :call_tool, :tool_result, :list_tools,
      :list_resources, :read_resource, :list_prompts, :get_prompt, :subscribe,
      :unsubscribe, :notification, :cancel
    ]
  end

  # ===========================================================================
  # Transport (tags 0-3)
  # ===========================================================================

  @typedoc """
  Transport types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type transport :: :stdio | :sse | :web_socket | :streamable_http

  @transport_tags %{
    stdio: 0,
    sse: 1,
    web_socket: 2,
    streamable_http: 3,
  }

  @tag_to_transport Map.new(@transport_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Transport` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Mcp.transport_from_tag(0)
      {:ok, :stdio}
  """
  @spec transport_from_tag(non_neg_integer()) :: {:ok, transport()} | :error
  def transport_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_transport, tag)}
  end

  def transport_from_tag(_tag), do: :error

  @doc """
  Encode a `Transport` to the C-ABI tag value.
  """
  @spec transport_to_tag(transport()) :: non_neg_integer()
  def transport_to_tag(val) when is_map_key(@transport_tags, val) do
    Map.fetch!(@transport_tags, val)
  end

  @doc """
  All `Transport` variants in tag order.
  """
  @spec all_transports() :: [transport()]
  def all_transports, do: [:stdio, :sse, :web_socket, :streamable_http]

  # ===========================================================================
  # McpContentType (tags 0-3)
  # ===========================================================================

  @typedoc """
  McpContentType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type mcp_content_type :: :text | :image | :resource | :embedding

  @mcp_content_type_tags %{
    text: 0,
    image: 1,
    resource: 2,
    embedding: 3,
  }

  @tag_to_mcp_content_type Map.new(@mcp_content_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `McpContentType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Mcp.mcp_content_type_from_tag(0)
      {:ok, :text}
  """
  @spec mcp_content_type_from_tag(non_neg_integer()) :: {:ok, mcp_content_type()} | :error
  def mcp_content_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_mcp_content_type, tag)}
  end

  def mcp_content_type_from_tag(_tag), do: :error

  @doc """
  Encode a `McpContentType` to the C-ABI tag value.
  """
  @spec mcp_content_type_to_tag(mcp_content_type()) :: non_neg_integer()
  def mcp_content_type_to_tag(val) when is_map_key(@mcp_content_type_tags, val) do
    Map.fetch!(@mcp_content_type_tags, val)
  end

  @doc """
  All `McpContentType` variants in tag order.
  """
  @spec all_mcp_content_types() :: [mcp_content_type()]
  def all_mcp_content_types, do: [:text, :image, :resource, :embedding]

  # ===========================================================================
  # McpErrorCode (tags 0-5)
  # ===========================================================================

  @typedoc """
  McpErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type mcp_error_code ::
          :parse_error
          | :invalid_request
          | :method_not_found
          | :invalid_params
          | :internal_error
          | :timeout

  @mcp_error_code_tags %{
    parse_error: 0,
    invalid_request: 1,
    method_not_found: 2,
    invalid_params: 3,
    internal_error: 4,
    timeout: 5,
  }

  @tag_to_mcp_error_code Map.new(@mcp_error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `McpErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Mcp.mcp_error_code_from_tag(0)
      {:ok, :parse_error}
  """
  @spec mcp_error_code_from_tag(non_neg_integer()) :: {:ok, mcp_error_code()} | :error
  def mcp_error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_mcp_error_code, tag)}
  end

  def mcp_error_code_from_tag(_tag), do: :error

  @doc """
  Encode a `McpErrorCode` to the C-ABI tag value.
  """
  @spec mcp_error_code_to_tag(mcp_error_code()) :: non_neg_integer()
  def mcp_error_code_to_tag(val) when is_map_key(@mcp_error_code_tags, val) do
    Map.fetch!(@mcp_error_code_tags, val)
  end

  @doc """
  All `McpErrorCode` variants in tag order.
  """
  @spec all_mcp_error_codes() :: [mcp_error_code()]
  def all_mcp_error_codes do
    [
      :parse_error, :invalid_request, :method_not_found, :invalid_params,
      :internal_error, :timeout
    ]
  end

  # ===========================================================================
  # McpCapability (tags 0-4)
  # ===========================================================================

  @typedoc """
  McpCapability types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type mcp_capability :: :tools | :resources | :prompts | :logging | :sampling

  @mcp_capability_tags %{
    tools: 0,
    resources: 1,
    prompts: 2,
    logging: 3,
    sampling: 4,
  }

  @tag_to_mcp_capability Map.new(@mcp_capability_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `McpCapability` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Mcp.mcp_capability_from_tag(0)
      {:ok, :tools}
  """
  @spec mcp_capability_from_tag(non_neg_integer()) :: {:ok, mcp_capability()} | :error
  def mcp_capability_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_mcp_capability, tag)}
  end

  def mcp_capability_from_tag(_tag), do: :error

  @doc """
  Encode a `McpCapability` to the C-ABI tag value.
  """
  @spec mcp_capability_to_tag(mcp_capability()) :: non_neg_integer()
  def mcp_capability_to_tag(val) when is_map_key(@mcp_capability_tags, val) do
    Map.fetch!(@mcp_capability_tags, val)
  end

  @doc """
  All `McpCapability` variants in tag order.
  """
  @spec all_mcp_capabilitys() :: [mcp_capability()]
  def all_mcp_capabilitys, do: [:tools, :resources, :prompts, :logging, :sampling]

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :connecting | :ready | :processing | :disconnecting

  @session_state_tags %{
    idle: 0,
    connecting: 1,
    ready: 2,
    processing: 3,
    disconnecting: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Mcp.session_state_from_tag(0)
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
  def all_session_states, do: [:idle, :connecting, :ready, :processing, :disconnecting]

end
