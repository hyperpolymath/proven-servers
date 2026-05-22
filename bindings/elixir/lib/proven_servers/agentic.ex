# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Agentic do
  @moduledoc """
  Agentic AI types for the proven-servers ABI.
  
  Formally verified agentic AI orchestration types.
  Mirrors the Idris2 module `AgenticABI.Types`.
  
  - `AgentState` -- AI agent lifecycle states.
  - `ToolCall` -- Agent tool call types.
  - `PlanStep` -- Agent plan step types.
  - `Coordination` -- Multi-agent coordination modes.
  - `SafetyCheck` -- Agent safety check results.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # AgentState (tags 0-6)
  # ===========================================================================

  @typedoc """
  AgentState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type agent_state ::
          :idle
          | :planning
          | :acting
          | :observing
          | :reflecting
          | :blocked
          | :terminated

  @agent_state_tags %{
    idle: 0,
    planning: 1,
    acting: 2,
    observing: 3,
    reflecting: 4,
    blocked: 5,
    terminated: 6,
  }

  @tag_to_agent_state Map.new(@agent_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AgentState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Agentic.agent_state_from_tag(0)
      {:ok, :idle}
  """
  @spec agent_state_from_tag(non_neg_integer()) :: {:ok, agent_state()} | :error
  def agent_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_agent_state, tag)}
  end

  def agent_state_from_tag(_tag), do: :error

  @doc """
  Encode a `AgentState` to the C-ABI tag value.
  """
  @spec agent_state_to_tag(agent_state()) :: non_neg_integer()
  def agent_state_to_tag(val) when is_map_key(@agent_state_tags, val) do
    Map.fetch!(@agent_state_tags, val)
  end

  @doc """
  All `AgentState` variants in tag order.
  """
  @spec all_agent_states() :: [agent_state()]
  def all_agent_states do
    [
      :idle, :planning, :acting, :observing, :reflecting, :blocked, :terminated,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the agent is actively working.
  """
  @spec is_active?(agent_state()) :: boolean()
  def is_active?(val) when val in [:planning, :acting, :observing, :reflecting], do: true
  def is_active?(_val), do: false

  # ===========================================================================
  # ToolCall (tags 0-5)
  # ===========================================================================

  @typedoc """
  ToolCall types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type tool_call :: :execute | :query | :transform | :communicate | :delegate | :escalate

  @tool_call_tags %{
    execute: 0,
    query: 1,
    transform: 2,
    communicate: 3,
    delegate: 4,
    escalate: 5,
  }

  @tag_to_tool_call Map.new(@tool_call_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ToolCall` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Agentic.tool_call_from_tag(0)
      {:ok, :execute}
  """
  @spec tool_call_from_tag(non_neg_integer()) :: {:ok, tool_call()} | :error
  def tool_call_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_tool_call, tag)}
  end

  def tool_call_from_tag(_tag), do: :error

  @doc """
  Encode a `ToolCall` to the C-ABI tag value.
  """
  @spec tool_call_to_tag(tool_call()) :: non_neg_integer()
  def tool_call_to_tag(val) when is_map_key(@tool_call_tags, val) do
    Map.fetch!(@tool_call_tags, val)
  end

  @doc """
  All `ToolCall` variants in tag order.
  """
  @spec all_tool_calls() :: [tool_call()]
  def all_tool_calls, do: [:execute, :query, :transform, :communicate, :delegate, :escalate]

  # ===========================================================================
  # PlanStep (tags 0-6)
  # ===========================================================================

  @typedoc """
  PlanStep types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type plan_step ::
          :action
          | :condition
          | :loop
          | :branch
          | :parallel
          | :checkpoint
          | :rollback

  @plan_step_tags %{
    action: 0,
    condition: 1,
    loop: 2,
    branch: 3,
    parallel: 4,
    checkpoint: 5,
    rollback: 6,
  }

  @tag_to_plan_step Map.new(@plan_step_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PlanStep` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Agentic.plan_step_from_tag(0)
      {:ok, :action}
  """
  @spec plan_step_from_tag(non_neg_integer()) :: {:ok, plan_step()} | :error
  def plan_step_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_plan_step, tag)}
  end

  def plan_step_from_tag(_tag), do: :error

  @doc """
  Encode a `PlanStep` to the C-ABI tag value.
  """
  @spec plan_step_to_tag(plan_step()) :: non_neg_integer()
  def plan_step_to_tag(val) when is_map_key(@plan_step_tags, val) do
    Map.fetch!(@plan_step_tags, val)
  end

  @doc """
  All `PlanStep` variants in tag order.
  """
  @spec all_plan_steps() :: [plan_step()]
  def all_plan_steps, do: [:action, :condition, :loop, :branch, :parallel, :checkpoint, :rollback]

  # ===========================================================================
  # Coordination (tags 0-5)
  # ===========================================================================

  @typedoc """
  Coordination types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type coordination ::
          :solo
          | :collaborative
          | :competitive
          | :hierarchical
          | :swarm
          | :consensus

  @coordination_tags %{
    solo: 0,
    collaborative: 1,
    competitive: 2,
    hierarchical: 3,
    swarm: 4,
    consensus: 5,
  }

  @tag_to_coordination Map.new(@coordination_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Coordination` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Agentic.coordination_from_tag(0)
      {:ok, :solo}
  """
  @spec coordination_from_tag(non_neg_integer()) :: {:ok, coordination()} | :error
  def coordination_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_coordination, tag)}
  end

  def coordination_from_tag(_tag), do: :error

  @doc """
  Encode a `Coordination` to the C-ABI tag value.
  """
  @spec coordination_to_tag(coordination()) :: non_neg_integer()
  def coordination_to_tag(val) when is_map_key(@coordination_tags, val) do
    Map.fetch!(@coordination_tags, val)
  end

  @doc """
  All `Coordination` variants in tag order.
  """
  @spec all_coordinations() :: [coordination()]
  def all_coordinations, do: [:solo, :collaborative, :competitive, :hierarchical, :swarm, :consensus]

  # ===========================================================================
  # SafetyCheck (tags 0-5)
  # ===========================================================================

  @typedoc """
  SafetyCheck types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type safety_check ::
          :approved
          | :denied
          | :escalated
          | :timeout
          | :sandboxed
          | :human_required

  @safety_check_tags %{
    approved: 0,
    denied: 1,
    escalated: 2,
    timeout: 3,
    sandboxed: 4,
    human_required: 5,
  }

  @tag_to_safety_check Map.new(@safety_check_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SafetyCheck` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Agentic.safety_check_from_tag(0)
      {:ok, :approved}
  """
  @spec safety_check_from_tag(non_neg_integer()) :: {:ok, safety_check()} | :error
  def safety_check_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_safety_check, tag)}
  end

  def safety_check_from_tag(_tag), do: :error

  @doc """
  Encode a `SafetyCheck` to the C-ABI tag value.
  """
  @spec safety_check_to_tag(safety_check()) :: non_neg_integer()
  def safety_check_to_tag(val) when is_map_key(@safety_check_tags, val) do
    Map.fetch!(@safety_check_tags, val)
  end

  @doc """
  All `SafetyCheck` variants in tag order.
  """
  @spec all_safety_checks() :: [safety_check()]
  def all_safety_checks, do: [:approved, :denied, :escalated, :timeout, :sandboxed, :human_required]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the action is approved to proceed.
  """
  @spec is_safe?(safety_check()) :: boolean()
  def is_safe?(val) when val in [:approved, :sandboxed], do: true
  def is_safe?(_val), do: false

end
