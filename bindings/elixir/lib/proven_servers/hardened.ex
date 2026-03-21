# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Hardened do
  @moduledoc """
  Hardened Server types for the proven-servers ABI.
  
  Formally verified hardened server types.
  Mirrors the Idris2 module `HardenedABI.Types`.
  
  - `HardeningLevel` -- System hardening levels.
  - `SecurityControl` -- Security controls.
  - `ComplianceStandard` -- Security compliance standards.
  - `AuditEvent` -- Audit event types.
  - `HardenedHealthStatus` -- Hardened system health.
  - `ServerState` -- Hardened server states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # HardeningLevel (tags 0-3)
  # ===========================================================================

  @typedoc """
  HardeningLevel types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type hardening_level :: :minimal | :standard | :high | :maximum

  @hardening_level_tags %{
    minimal: 0,
    standard: 1,
    high: 2,
    maximum: 3,
  }

  @tag_to_hardening_level Map.new(@hardening_level_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HardeningLevel` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Hardened.hardening_level_from_tag(0)
      {:ok, :minimal}
  """
  @spec hardening_level_from_tag(non_neg_integer()) :: {:ok, hardening_level()} | :error
  def hardening_level_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_hardening_level, tag)}
  end

  def hardening_level_from_tag(_tag), do: :error

  @doc """
  Encode a `HardeningLevel` to the C-ABI tag value.
  """
  @spec hardening_level_to_tag(hardening_level()) :: non_neg_integer()
  def hardening_level_to_tag(val) when is_map_key(@hardening_level_tags, val) do
    Map.fetch!(@hardening_level_tags, val)
  end

  @doc """
  All `HardeningLevel` variants in tag order.
  """
  @spec all_hardening_levels() :: [hardening_level()]
  def all_hardening_levels, do: [:minimal, :standard, :high, :maximum]

  # ===========================================================================
  # SecurityControl (tags 0-6)
  # ===========================================================================

  @typedoc """
  SecurityControl types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type security_control ::
          :aslr
          | :dep
          | :stack_canary
          | :cfi
          | :sandboxing
          | :secure_boot
          | :audit_log

  @security_control_tags %{
    aslr: 0,
    dep: 1,
    stack_canary: 2,
    cfi: 3,
    sandboxing: 4,
    secure_boot: 5,
    audit_log: 6,
  }

  @tag_to_security_control Map.new(@security_control_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SecurityControl` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Hardened.security_control_from_tag(0)
      {:ok, :aslr}
  """
  @spec security_control_from_tag(non_neg_integer()) :: {:ok, security_control()} | :error
  def security_control_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_security_control, tag)}
  end

  def security_control_from_tag(_tag), do: :error

  @doc """
  Encode a `SecurityControl` to the C-ABI tag value.
  """
  @spec security_control_to_tag(security_control()) :: non_neg_integer()
  def security_control_to_tag(val) when is_map_key(@security_control_tags, val) do
    Map.fetch!(@security_control_tags, val)
  end

  @doc """
  All `SecurityControl` variants in tag order.
  """
  @spec all_security_controls() :: [security_control()]
  def all_security_controls do
    [
      :aslr, :dep, :stack_canary, :cfi, :sandboxing, :secure_boot, :audit_log,
    ]
  end

  # ===========================================================================
  # ComplianceStandard (tags 0-4)
  # ===========================================================================

  @typedoc """
  ComplianceStandard types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type compliance_standard :: :cis | :stig | :nist80053 | :pci_dss | :fips140

  @compliance_standard_tags %{
    cis: 0,
    stig: 1,
    nist80053: 2,
    pci_dss: 3,
    fips140: 4,
  }

  @tag_to_compliance_standard Map.new(@compliance_standard_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ComplianceStandard` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Hardened.compliance_standard_from_tag(0)
      {:ok, :cis}
  """
  @spec compliance_standard_from_tag(non_neg_integer()) :: {:ok, compliance_standard()} | :error
  def compliance_standard_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_compliance_standard, tag)}
  end

  def compliance_standard_from_tag(_tag), do: :error

  @doc """
  Encode a `ComplianceStandard` to the C-ABI tag value.
  """
  @spec compliance_standard_to_tag(compliance_standard()) :: non_neg_integer()
  def compliance_standard_to_tag(val) when is_map_key(@compliance_standard_tags, val) do
    Map.fetch!(@compliance_standard_tags, val)
  end

  @doc """
  All `ComplianceStandard` variants in tag order.
  """
  @spec all_compliance_standards() :: [compliance_standard()]
  def all_compliance_standards, do: [:cis, :stig, :nist80053, :pci_dss, :fips140]

  # ===========================================================================
  # AuditEvent (tags 0-5)
  # ===========================================================================

  @typedoc """
  AuditEvent types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type audit_event ::
          :process_start
          | :file_access
          | :network_conn
          | :privilege_escalation
          | :config_change
          | :auth_attempt

  @audit_event_tags %{
    process_start: 0,
    file_access: 1,
    network_conn: 2,
    privilege_escalation: 3,
    config_change: 4,
    auth_attempt: 5,
  }

  @tag_to_audit_event Map.new(@audit_event_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `AuditEvent` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Hardened.audit_event_from_tag(0)
      {:ok, :process_start}
  """
  @spec audit_event_from_tag(non_neg_integer()) :: {:ok, audit_event()} | :error
  def audit_event_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_audit_event, tag)}
  end

  def audit_event_from_tag(_tag), do: :error

  @doc """
  Encode a `AuditEvent` to the C-ABI tag value.
  """
  @spec audit_event_to_tag(audit_event()) :: non_neg_integer()
  def audit_event_to_tag(val) when is_map_key(@audit_event_tags, val) do
    Map.fetch!(@audit_event_tags, val)
  end

  @doc """
  All `AuditEvent` variants in tag order.
  """
  @spec all_audit_events() :: [audit_event()]
  def all_audit_events do
    [
      :process_start, :file_access, :network_conn, :privilege_escalation,
      :config_change, :auth_attempt
    ]
  end

  # ===========================================================================
  # HardenedHealthStatus (tags 0-3)
  # ===========================================================================

  @typedoc """
  HardenedHealthStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type hardened_health_status :: :healthy | :degraded | :compromised | :unresponsive

  @hardened_health_status_tags %{
    healthy: 0,
    degraded: 1,
    compromised: 2,
    unresponsive: 3,
  }

  @tag_to_hardened_health_status Map.new(@hardened_health_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HardenedHealthStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Hardened.hardened_health_status_from_tag(0)
      {:ok, :healthy}
  """
  @spec hardened_health_status_from_tag(non_neg_integer()) :: {:ok, hardened_health_status()} | :error
  def hardened_health_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_hardened_health_status, tag)}
  end

  def hardened_health_status_from_tag(_tag), do: :error

  @doc """
  Encode a `HardenedHealthStatus` to the C-ABI tag value.
  """
  @spec hardened_health_status_to_tag(hardened_health_status()) :: non_neg_integer()
  def hardened_health_status_to_tag(val) when is_map_key(@hardened_health_status_tags, val) do
    Map.fetch!(@hardened_health_status_tags, val)
  end

  @doc """
  All `HardenedHealthStatus` variants in tag order.
  """
  @spec all_hardened_health_statuss() :: [hardened_health_status()]
  def all_hardened_health_statuss, do: [:healthy, :degraded, :compromised, :unresponsive]

  # ===========================================================================
  # ServerState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ServerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type server_state :: :idle | :hardening | :active | :auditing | :shutdown

  @server_state_tags %{
    idle: 0,
    hardening: 1,
    active: 2,
    auditing: 3,
    shutdown: 4,
  }

  @tag_to_server_state Map.new(@server_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Hardened.server_state_from_tag(0)
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
  def all_server_states, do: [:idle, :hardening, :active, :auditing, :shutdown]

end
