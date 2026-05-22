# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Virt do
  @moduledoc """
  Virtualization types for the proven-servers ABI.
  
  Formally verified virtualization/hypervisor types.
  Mirrors the Idris2 module `VirtABI.Types`.
  
  - `VmState` -- VM lifecycle states.
  - `VirtOperation` -- VM operations.
  - `DiskFormat` -- Virtual disk formats.
  - `NetworkType` -- VM network types.
  - `BootDevice` -- VM boot devices.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # VmState (tags 0-7)
  # ===========================================================================

  @typedoc """
  VmState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type vm_state ::
          :creating
          | :running
          | :paused
          | :suspended
          | :shutting_down
          | :stopped
          | :crashed
          | :migrating

  @vm_state_tags %{
    creating: 0,
    running: 1,
    paused: 2,
    suspended: 3,
    shutting_down: 4,
    stopped: 5,
    crashed: 6,
    migrating: 7,
  }

  @tag_to_vm_state Map.new(@vm_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `VmState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Virt.vm_state_from_tag(0)
      {:ok, :creating}
  """
  @spec vm_state_from_tag(non_neg_integer()) :: {:ok, vm_state()} | :error
  def vm_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_vm_state, tag)}
  end

  def vm_state_from_tag(_tag), do: :error

  @doc """
  Encode a `VmState` to the C-ABI tag value.
  """
  @spec vm_state_to_tag(vm_state()) :: non_neg_integer()
  def vm_state_to_tag(val) when is_map_key(@vm_state_tags, val) do
    Map.fetch!(@vm_state_tags, val)
  end

  @doc """
  All `VmState` variants in tag order.
  """
  @spec all_vm_states() :: [vm_state()]
  def all_vm_states do
    [
      :creating, :running, :paused, :suspended, :shutting_down, :stopped,
      :crashed, :migrating
    ]
  end

  # ===========================================================================
  # VirtOperation (tags 0-10)
  # ===========================================================================

  @typedoc """
  VirtOperation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type virt_operation ::
          :create
          | :start
          | :stop
          | :restart
          | :pause
          | :resume
          | :suspend
          | :migrate
          | :snapshot
          | :clone
          | :delete

  @virt_operation_tags %{
    create: 0,
    start: 1,
    stop: 2,
    restart: 3,
    pause: 4,
    resume: 5,
    suspend: 6,
    migrate: 7,
    snapshot: 8,
    clone: 9,
    delete: 10,
  }

  @tag_to_virt_operation Map.new(@virt_operation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `VirtOperation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..10, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Virt.virt_operation_from_tag(0)
      {:ok, :create}
  """
  @spec virt_operation_from_tag(non_neg_integer()) :: {:ok, virt_operation()} | :error
  def virt_operation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 10 do
    {:ok, Map.fetch!(@tag_to_virt_operation, tag)}
  end

  def virt_operation_from_tag(_tag), do: :error

  @doc """
  Encode a `VirtOperation` to the C-ABI tag value.
  """
  @spec virt_operation_to_tag(virt_operation()) :: non_neg_integer()
  def virt_operation_to_tag(val) when is_map_key(@virt_operation_tags, val) do
    Map.fetch!(@virt_operation_tags, val)
  end

  @doc """
  All `VirtOperation` variants in tag order.
  """
  @spec all_virt_operations() :: [virt_operation()]
  def all_virt_operations do
    [
      :create, :start, :stop, :restart, :pause, :resume, :suspend, :migrate,
      :snapshot, :clone, :delete
    ]
  end

  # ===========================================================================
  # DiskFormat (tags 0-4)
  # ===========================================================================

  @typedoc """
  DiskFormat types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type disk_format :: :raw | :qcow2 | :vdi | :vmdk | :vhd

  @disk_format_tags %{
    raw: 0,
    qcow2: 1,
    vdi: 2,
    vmdk: 3,
    vhd: 4,
  }

  @tag_to_disk_format Map.new(@disk_format_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DiskFormat` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Virt.disk_format_from_tag(0)
      {:ok, :raw}
  """
  @spec disk_format_from_tag(non_neg_integer()) :: {:ok, disk_format()} | :error
  def disk_format_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_disk_format, tag)}
  end

  def disk_format_from_tag(_tag), do: :error

  @doc """
  Encode a `DiskFormat` to the C-ABI tag value.
  """
  @spec disk_format_to_tag(disk_format()) :: non_neg_integer()
  def disk_format_to_tag(val) when is_map_key(@disk_format_tags, val) do
    Map.fetch!(@disk_format_tags, val)
  end

  @doc """
  All `DiskFormat` variants in tag order.
  """
  @spec all_disk_formats() :: [disk_format()]
  def all_disk_formats, do: [:raw, :qcow2, :vdi, :vmdk, :vhd]

  # ===========================================================================
  # NetworkType (tags 0-3)
  # ===========================================================================

  @typedoc """
  NetworkType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type network_type :: :nat | :bridged | :internal | :host_only

  @network_type_tags %{
    nat: 0,
    bridged: 1,
    internal: 2,
    host_only: 3,
  }

  @tag_to_network_type Map.new(@network_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NetworkType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Virt.network_type_from_tag(0)
      {:ok, :nat}
  """
  @spec network_type_from_tag(non_neg_integer()) :: {:ok, network_type()} | :error
  def network_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_network_type, tag)}
  end

  def network_type_from_tag(_tag), do: :error

  @doc """
  Encode a `NetworkType` to the C-ABI tag value.
  """
  @spec network_type_to_tag(network_type()) :: non_neg_integer()
  def network_type_to_tag(val) when is_map_key(@network_type_tags, val) do
    Map.fetch!(@network_type_tags, val)
  end

  @doc """
  All `NetworkType` variants in tag order.
  """
  @spec all_network_types() :: [network_type()]
  def all_network_types, do: [:nat, :bridged, :internal, :host_only]

  # ===========================================================================
  # BootDevice (tags 0-3)
  # ===========================================================================

  @typedoc """
  BootDevice types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type boot_device :: :hard_disk | :cdrom | :network | :usb

  @boot_device_tags %{
    hard_disk: 0,
    cdrom: 1,
    network: 2,
    usb: 3,
  }

  @tag_to_boot_device Map.new(@boot_device_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `BootDevice` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Virt.boot_device_from_tag(0)
      {:ok, :hard_disk}
  """
  @spec boot_device_from_tag(non_neg_integer()) :: {:ok, boot_device()} | :error
  def boot_device_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_boot_device, tag)}
  end

  def boot_device_from_tag(_tag), do: :error

  @doc """
  Encode a `BootDevice` to the C-ABI tag value.
  """
  @spec boot_device_to_tag(boot_device()) :: non_neg_integer()
  def boot_device_to_tag(val) when is_map_key(@boot_device_tags, val) do
    Map.fetch!(@boot_device_tags, val)
  end

  @doc """
  All `BootDevice` variants in tag order.
  """
  @spec all_boot_devices() :: [boot_device()]
  def all_boot_devices, do: [:hard_disk, :cdrom, :network, :usb]

end
