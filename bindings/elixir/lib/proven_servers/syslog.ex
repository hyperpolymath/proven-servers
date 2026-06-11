# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Syslog do
  @moduledoc """
  Syslog protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `SyslogABI.Types` and its type definitions:
  - `Severity`   — syslog severity levels (8 constructors, tags 0-7)
  - `Facility`   — syslog facility codes (24 constructors, tags 0-23)
  - `Transport`  — syslog transport mechanisms (3 constructors, tags 0-2)
  
  Severity and facility values match RFC 5424 numeric codes.
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard syslog UDP port (RFC 5426)."
  @spec syslog_udp_port() :: non_neg_integer()
  def syslog_udp_port, do: 514

  @doc "Standard syslog TCP port (RFC 6587)."
  @spec syslog_tcp_port() :: non_neg_integer()
  def syslog_tcp_port, do: 514

  @doc "Syslog over TLS port (RFC 5425)."
  @spec syslog_tls_port() :: non_neg_integer()
  def syslog_tls_port, do: 6514

  # ===========================================================================
  # Severity (tags 0-7)
  # ===========================================================================

  @typedoc """
  Severity types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type severity ::
          :emergency
          | :alert
          | :critical
          | :error
          | :warning
          | :notice
          | :informational
          | :debug

  @severity_tags %{
    emergency: 0,
    alert: 1,
    critical: 2,
    error: 3,
    warning: 4,
    notice: 5,
    informational: 6,
    debug: 7,
  }

  @tag_to_severity Map.new(@severity_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Severity` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Syslog.severity_from_tag(0)
      {:ok, :emergency}
  """
  @spec severity_from_tag(non_neg_integer()) :: {:ok, severity()} | :error
  def severity_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_severity, tag)}
  end

  def severity_from_tag(_tag), do: :error

  @doc """
  Encode a `Severity` to the C-ABI tag value.
  """
  @spec severity_to_tag(severity()) :: non_neg_integer()
  def severity_to_tag(val) when is_map_key(@severity_tags, val) do
    Map.fetch!(@severity_tags, val)
  end

  @doc """
  All `Severity` variants in tag order.
  """
  @spec all_severitys() :: [severity()]
  def all_severitys do
    [
      :emergency, :alert, :critical, :error, :warning, :notice, :informational,
      :debug
    ]
  end

  # ===========================================================================
  # Facility (tags 0-23)
  # ===========================================================================

  @typedoc """
  Facility types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type facility ::
          :kern
          | :user
          | :mail
          | :daemon
          | :auth
          | :syslog
          | :lpr
          | :news
          | :uucp
          | :cron
          | :auth_priv
          | :ftp
          | :ntp
          | :audit
          | :alert
          | :clock
          | :local0
          | :local1
          | :local2
          | :local3
          | :local4
          | :local5
          | :local6
          | :local7

  @facility_tags %{
    kern: 0,
    user: 1,
    mail: 2,
    daemon: 3,
    auth: 4,
    syslog: 5,
    lpr: 6,
    news: 7,
    uucp: 8,
    cron: 9,
    auth_priv: 10,
    ftp: 11,
    ntp: 12,
    audit: 13,
    alert: 14,
    clock: 15,
    local0: 16,
    local1: 17,
    local2: 18,
    local3: 19,
    local4: 20,
    local5: 21,
    local6: 22,
    local7: 23,
  }

  @tag_to_facility Map.new(@facility_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Facility` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..23, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Syslog.facility_from_tag(0)
      {:ok, :kern}
  """
  @spec facility_from_tag(non_neg_integer()) :: {:ok, facility()} | :error
  def facility_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 23 do
    {:ok, Map.fetch!(@tag_to_facility, tag)}
  end

  def facility_from_tag(_tag), do: :error

  @doc """
  Encode a `Facility` to the C-ABI tag value.
  """
  @spec facility_to_tag(facility()) :: non_neg_integer()
  def facility_to_tag(val) when is_map_key(@facility_tags, val) do
    Map.fetch!(@facility_tags, val)
  end

  @doc """
  All `Facility` variants in tag order.
  """
  @spec all_facilitys() :: [facility()]
  def all_facilitys do
    [
      :kern, :user, :mail, :daemon, :auth, :syslog, :lpr, :news, :uucp,
      :cron, :auth_priv, :ftp, :ntp, :audit, :alert, :clock, :local0,
      :local1, :local2, :local3, :local4, :local5, :local6, :local7,
    ]
  end

  @doc """
  Decode from an ABI tag value (RFC 5424 facility code).

  Encode to the ABI tag value (RFC 5424 facility code).

  Whether this is a local-use facility (Local0-Local7).
        (self as u8) >= 16

  Whether this is a security-related facility.
  """
  @spec is_security?(facility()) :: boolean()
  def is_security?(val) when val in [:auth, :auth_priv, :audit], do: true
  def is_security?(_val), do: false

  # ===========================================================================
  # Transport (tags 0-2)
  # ===========================================================================

  @typedoc """
  Transport types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type transport :: :udp514 | :tcp514 | :tls6514

  @transport_tags %{
    udp514: 0,
    tcp514: 1,
    tls6514: 2,
  }

  @tag_to_transport Map.new(@transport_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Transport` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Syslog.transport_from_tag(0)
      {:ok, :udp514}
  """
  @spec transport_from_tag(non_neg_integer()) :: {:ok, transport()} | :error
  def transport_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
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
  def all_transports, do: [:udp514, :tcp514, :tls6514]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The port number used by this transport.
        match self {

  Whether this transport provides encryption.
  """
  @spec is_encrypted?(transport()) :: boolean()
  def is_encrypted?(val) when val in [:tls6514], do: true
  def is_encrypted?(_val), do: false

  @doc """
  Whether this transport provides reliable delivery.
  """
  @spec is_reliable?(transport()) :: boolean()
  def is_reliable?(val) when val in [:tcp514, :tls6514], do: true
  def is_reliable?(_val), do: false

end
