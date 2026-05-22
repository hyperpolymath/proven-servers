# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Caldav do
  @moduledoc """
  CalDAV types for the proven-servers ABI.
  
  Formally verified CalDAV types (RFC 4791).
  Mirrors the Idris2 module `CaldavABI.Types`.
  
  - `ComponentType` -- iCalendar component types.
  - `CalMethod` -- CalDAV methods.
  - `ScheduleStatus` -- CalDAV scheduling statuses.
  - `CalError` -- CalDAV error codes.
  - `ServerState` -- CalDAV server lifecycle states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard CalDAV HTTPS port."
  @spec caldav_port() :: non_neg_integer()
  def caldav_port, do: 443

  # ===========================================================================
  # ComponentType (tags 0-3)
  # ===========================================================================

  @typedoc """
  ComponentType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type component_type :: :vevent | :vtodo | :vjournal | :vfreebusy

  @component_type_tags %{
    vevent: 0,
    vtodo: 1,
    vjournal: 2,
    vfreebusy: 3,
  }

  @tag_to_component_type Map.new(@component_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ComponentType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Caldav.component_type_from_tag(0)
      {:ok, :vevent}
  """
  @spec component_type_from_tag(non_neg_integer()) :: {:ok, component_type()} | :error
  def component_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_component_type, tag)}
  end

  def component_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ComponentType` to the C-ABI tag value.
  """
  @spec component_type_to_tag(component_type()) :: non_neg_integer()
  def component_type_to_tag(val) when is_map_key(@component_type_tags, val) do
    Map.fetch!(@component_type_tags, val)
  end

  @doc """
  All `ComponentType` variants in tag order.
  """
  @spec all_component_types() :: [component_type()]
  def all_component_types, do: [:vevent, :vtodo, :vjournal, :vfreebusy]

  # ===========================================================================
  # CalMethod (tags 0-6)
  # ===========================================================================

  @typedoc """
  CalMethod types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type cal_method :: :get | :put | :delete | :propfind | :proppatch | :report | :mkcalendar

  @cal_method_tags %{
    get: 0,
    put: 1,
    delete: 2,
    propfind: 3,
    proppatch: 4,
    report: 5,
    mkcalendar: 6,
  }

  @tag_to_cal_method Map.new(@cal_method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CalMethod` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Caldav.cal_method_from_tag(0)
      {:ok, :get}
  """
  @spec cal_method_from_tag(non_neg_integer()) :: {:ok, cal_method()} | :error
  def cal_method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_cal_method, tag)}
  end

  def cal_method_from_tag(_tag), do: :error

  @doc """
  Encode a `CalMethod` to the C-ABI tag value.
  """
  @spec cal_method_to_tag(cal_method()) :: non_neg_integer()
  def cal_method_to_tag(val) when is_map_key(@cal_method_tags, val) do
    Map.fetch!(@cal_method_tags, val)
  end

  @doc """
  All `CalMethod` variants in tag order.
  """
  @spec all_cal_methods() :: [cal_method()]
  def all_cal_methods, do: [:get, :put, :delete, :propfind, :proppatch, :report, :mkcalendar]

  # ===========================================================================
  # ScheduleStatus (tags 0-4)
  # ===========================================================================

  @typedoc """
  ScheduleStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type schedule_status :: :needs_action | :accepted | :declined | :tentative | :delegated

  @schedule_status_tags %{
    needs_action: 0,
    accepted: 1,
    declined: 2,
    tentative: 3,
    delegated: 4,
  }

  @tag_to_schedule_status Map.new(@schedule_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ScheduleStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Caldav.schedule_status_from_tag(0)
      {:ok, :needs_action}
  """
  @spec schedule_status_from_tag(non_neg_integer()) :: {:ok, schedule_status()} | :error
  def schedule_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_schedule_status, tag)}
  end

  def schedule_status_from_tag(_tag), do: :error

  @doc """
  Encode a `ScheduleStatus` to the C-ABI tag value.
  """
  @spec schedule_status_to_tag(schedule_status()) :: non_neg_integer()
  def schedule_status_to_tag(val) when is_map_key(@schedule_status_tags, val) do
    Map.fetch!(@schedule_status_tags, val)
  end

  @doc """
  All `ScheduleStatus` variants in tag order.
  """
  @spec all_schedule_statuss() :: [schedule_status()]
  def all_schedule_statuss, do: [:needs_action, :accepted, :declined, :tentative, :delegated]

  # ===========================================================================
  # CalError (tags 0-5)
  # ===========================================================================

  @typedoc """
  CalError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type cal_error ::
          :valid_calendar_data
          | :no_resource_type_change
          | :supported_component_mismatch
          | :max_resource_size
          | :uid_conflict
          | :precondition_failed

  @cal_error_tags %{
    valid_calendar_data: 0,
    no_resource_type_change: 1,
    supported_component_mismatch: 2,
    max_resource_size: 3,
    uid_conflict: 4,
    precondition_failed: 5,
  }

  @tag_to_cal_error Map.new(@cal_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CalError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Caldav.cal_error_from_tag(0)
      {:ok, :valid_calendar_data}
  """
  @spec cal_error_from_tag(non_neg_integer()) :: {:ok, cal_error()} | :error
  def cal_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_cal_error, tag)}
  end

  def cal_error_from_tag(_tag), do: :error

  @doc """
  Encode a `CalError` to the C-ABI tag value.
  """
  @spec cal_error_to_tag(cal_error()) :: non_neg_integer()
  def cal_error_to_tag(val) when is_map_key(@cal_error_tags, val) do
    Map.fetch!(@cal_error_tags, val)
  end

  @doc """
  All `CalError` variants in tag order.
  """
  @spec all_cal_errors() :: [cal_error()]
  def all_cal_errors do
    [
      :valid_calendar_data, :no_resource_type_change, :supported_component_mismatch,
      :max_resource_size, :uid_conflict, :precondition_failed
    ]
  end

  # ===========================================================================
  # ServerState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ServerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type server_state :: :idle | :bound | :serving | :scheduling | :shutdown

  @server_state_tags %{
    idle: 0,
    bound: 1,
    serving: 2,
    scheduling: 3,
    shutdown: 4,
  }

  @tag_to_server_state Map.new(@server_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Caldav.server_state_from_tag(0)
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
  def all_server_states, do: [:idle, :bound, :serving, :scheduling, :shutdown]

end
