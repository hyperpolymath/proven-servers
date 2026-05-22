# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Sandbox do
  @moduledoc """
  Sandbox types for the proven-servers ABI.
  
  Formally verified sandbox/isolation types.
  Mirrors the Idris2 module `SandboxABI.Types`.
  
  - `ExecutionPolicy` -- Sandbox execution policies.
  - `ResourceLimit` -- Sandbox resource limits.
  - `SandboxState` -- Sandbox lifecycle states.
  - `ExitReason` -- Sandbox exit reasons.
  - `SyscallPolicy` -- System call filter policies.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # ExecutionPolicy (tags 0-4)
  # ===========================================================================

  @typedoc """
  ExecutionPolicy types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type execution_policy :: :unrestricted | :read_only | :network_denied | :isolated | :ephemeral

  @execution_policy_tags %{
    unrestricted: 0,
    read_only: 1,
    network_denied: 2,
    isolated: 3,
    ephemeral: 4,
  }

  @tag_to_execution_policy Map.new(@execution_policy_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ExecutionPolicy` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sandbox.execution_policy_from_tag(0)
      {:ok, :unrestricted}
  """
  @spec execution_policy_from_tag(non_neg_integer()) :: {:ok, execution_policy()} | :error
  def execution_policy_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_execution_policy, tag)}
  end

  def execution_policy_from_tag(_tag), do: :error

  @doc """
  Encode a `ExecutionPolicy` to the C-ABI tag value.
  """
  @spec execution_policy_to_tag(execution_policy()) :: non_neg_integer()
  def execution_policy_to_tag(val) when is_map_key(@execution_policy_tags, val) do
    Map.fetch!(@execution_policy_tags, val)
  end

  @doc """
  All `ExecutionPolicy` variants in tag order.
  """
  @spec all_execution_policys() :: [execution_policy()]
  def all_execution_policys, do: [:unrestricted, :read_only, :network_denied, :isolated, :ephemeral]

  # ===========================================================================
  # ResourceLimit (tags 0-5)
  # ===========================================================================

  @typedoc """
  ResourceLimit types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type resource_limit ::
          :cpu_time
          | :memory
          | :disk_io
          | :network_io
          | :file_descriptors
          | :processes

  @resource_limit_tags %{
    cpu_time: 0,
    memory: 1,
    disk_io: 2,
    network_io: 3,
    file_descriptors: 4,
    processes: 5,
  }

  @tag_to_resource_limit Map.new(@resource_limit_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResourceLimit` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sandbox.resource_limit_from_tag(0)
      {:ok, :cpu_time}
  """
  @spec resource_limit_from_tag(non_neg_integer()) :: {:ok, resource_limit()} | :error
  def resource_limit_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_resource_limit, tag)}
  end

  def resource_limit_from_tag(_tag), do: :error

  @doc """
  Encode a `ResourceLimit` to the C-ABI tag value.
  """
  @spec resource_limit_to_tag(resource_limit()) :: non_neg_integer()
  def resource_limit_to_tag(val) when is_map_key(@resource_limit_tags, val) do
    Map.fetch!(@resource_limit_tags, val)
  end

  @doc """
  All `ResourceLimit` variants in tag order.
  """
  @spec all_resource_limits() :: [resource_limit()]
  def all_resource_limits do
    [
      :cpu_time, :memory, :disk_io, :network_io, :file_descriptors, :processes,
    ]
  end

  # ===========================================================================
  # SandboxState (tags 0-5)
  # ===========================================================================

  @typedoc """
  SandboxState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type sandbox_state :: :creating | :ready | :running | :suspended | :terminated | :destroyed

  @sandbox_state_tags %{
    creating: 0,
    ready: 1,
    running: 2,
    suspended: 3,
    terminated: 4,
    destroyed: 5,
  }

  @tag_to_sandbox_state Map.new(@sandbox_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SandboxState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sandbox.sandbox_state_from_tag(0)
      {:ok, :creating}
  """
  @spec sandbox_state_from_tag(non_neg_integer()) :: {:ok, sandbox_state()} | :error
  def sandbox_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_sandbox_state, tag)}
  end

  def sandbox_state_from_tag(_tag), do: :error

  @doc """
  Encode a `SandboxState` to the C-ABI tag value.
  """
  @spec sandbox_state_to_tag(sandbox_state()) :: non_neg_integer()
  def sandbox_state_to_tag(val) when is_map_key(@sandbox_state_tags, val) do
    Map.fetch!(@sandbox_state_tags, val)
  end

  @doc """
  All `SandboxState` variants in tag order.
  """
  @spec all_sandbox_states() :: [sandbox_state()]
  def all_sandbox_states, do: [:creating, :ready, :running, :suspended, :terminated, :destroyed]

  # ===========================================================================
  # ExitReason (tags 0-5)
  # ===========================================================================

  @typedoc """
  ExitReason types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type exit_reason ::
          :normal
          | :timeout
          | :memory_exceeded
          | :policy_violation
          | :killed
          | :error

  @exit_reason_tags %{
    normal: 0,
    timeout: 1,
    memory_exceeded: 2,
    policy_violation: 3,
    killed: 4,
    error: 5,
  }

  @tag_to_exit_reason Map.new(@exit_reason_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ExitReason` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sandbox.exit_reason_from_tag(0)
      {:ok, :normal}
  """
  @spec exit_reason_from_tag(non_neg_integer()) :: {:ok, exit_reason()} | :error
  def exit_reason_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_exit_reason, tag)}
  end

  def exit_reason_from_tag(_tag), do: :error

  @doc """
  Encode a `ExitReason` to the C-ABI tag value.
  """
  @spec exit_reason_to_tag(exit_reason()) :: non_neg_integer()
  def exit_reason_to_tag(val) when is_map_key(@exit_reason_tags, val) do
    Map.fetch!(@exit_reason_tags, val)
  end

  @doc """
  All `ExitReason` variants in tag order.
  """
  @spec all_exit_reasons() :: [exit_reason()]
  def all_exit_reasons do
    [
      :normal, :timeout, :memory_exceeded, :policy_violation, :killed,
      :error
    ]
  end

  # ===========================================================================
  # SyscallPolicy (tags 0-3)
  # ===========================================================================

  @typedoc """
  SyscallPolicy types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type syscall_policy :: :allow | :deny | :log | :trap

  @syscall_policy_tags %{
    allow: 0,
    deny: 1,
    log: 2,
    trap: 3,
  }

  @tag_to_syscall_policy Map.new(@syscall_policy_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SyscallPolicy` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sandbox.syscall_policy_from_tag(0)
      {:ok, :allow}
  """
  @spec syscall_policy_from_tag(non_neg_integer()) :: {:ok, syscall_policy()} | :error
  def syscall_policy_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_syscall_policy, tag)}
  end

  def syscall_policy_from_tag(_tag), do: :error

  @doc """
  Encode a `SyscallPolicy` to the C-ABI tag value.
  """
  @spec syscall_policy_to_tag(syscall_policy()) :: non_neg_integer()
  def syscall_policy_to_tag(val) when is_map_key(@syscall_policy_tags, val) do
    Map.fetch!(@syscall_policy_tags, val)
  end

  @doc """
  All `SyscallPolicy` variants in tag order.
  """
  @spec all_syscall_policys() :: [syscall_policy()]
  def all_syscall_policys, do: [:allow, :deny, :log, :trap]

end
