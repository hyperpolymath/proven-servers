# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Ntp do
  @moduledoc """
  NTP protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `NtpABI.Types` and its type definitions:
  - `LeapIndicator`       — leap second indicator (4 constructors, tags 0-3)
  - `NtpMode`             — NTP association modes (8 constructors, tags 0-7)
  - `ExchangeState`       — NTP request/response state machine (4 constructors, tags 0-3)
  - `ClockDisciplineState` — clock discipline algorithm states (5 constructors, tags 0-4)
  - `KissCode`            — Kiss-o'-Death codes (4 constructors, tags 0-3)
  - `NtpError`            — NTP error codes (6 constructors, tags 0-5)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard NTP port (RFC 5905)."
  @spec ntp_port() :: non_neg_integer()
  def ntp_port, do: 123

  @doc "Offset from Unix epoch (1 January 1970) in seconds."
  @spec ntp_epoch_offset() :: non_neg_integer()
  def ntp_epoch_offset, do: 2208988800

  # ===========================================================================
  # LeapIndicator (tags 0-3)
  # ===========================================================================

  @typedoc """
  LeapIndicator types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type leap_indicator :: :no_warning | :last_minute61 | :last_minute59 | :unsynchronised

  @leap_indicator_tags %{
    no_warning: 0,
    last_minute61: 1,
    last_minute59: 2,
    unsynchronised: 3,
  }

  @tag_to_leap_indicator Map.new(@leap_indicator_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `LeapIndicator` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ntp.leap_indicator_from_tag(0)
      {:ok, :no_warning}
  """
  @spec leap_indicator_from_tag(non_neg_integer()) :: {:ok, leap_indicator()} | :error
  def leap_indicator_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_leap_indicator, tag)}
  end

  def leap_indicator_from_tag(_tag), do: :error

  @doc """
  Encode a `LeapIndicator` to the C-ABI tag value.
  """
  @spec leap_indicator_to_tag(leap_indicator()) :: non_neg_integer()
  def leap_indicator_to_tag(val) when is_map_key(@leap_indicator_tags, val) do
    Map.fetch!(@leap_indicator_tags, val)
  end

  @doc """
  All `LeapIndicator` variants in tag order.
  """
  @spec all_leap_indicators() :: [leap_indicator()]
  def all_leap_indicators, do: [:no_warning, :last_minute61, :last_minute59, :unsynchronised]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the clock is considered synchronised.
  """
  @spec is_synchronised?(leap_indicator()) :: boolean()
  def is_synchronised?(val) when val in [:unsynchronised], do: false
  def is_synchronised?(_val), do: true

  @doc """
  Whether a leap second adjustment is pending.
  """
  @spec has_leap_second?(leap_indicator()) :: boolean()
  def has_leap_second?(val) when val in [:last_minute61, :last_minute59], do: true
  def has_leap_second?(_val), do: false

  # ===========================================================================
  # NtpMode (tags 0-7)
  # ===========================================================================

  @typedoc """
  NtpMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ntp_mode ::
          :reserved
          | :symmetric_active
          | :symmetric_passive
          | :client
          | :server
          | :broadcast
          | :control_message
          | :private

  @ntp_mode_tags %{
    reserved: 0,
    symmetric_active: 1,
    symmetric_passive: 2,
    client: 3,
    server: 4,
    broadcast: 5,
    control_message: 6,
    private: 7,
  }

  @tag_to_ntp_mode Map.new(@ntp_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NtpMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ntp.ntp_mode_from_tag(0)
      {:ok, :reserved}
  """
  @spec ntp_mode_from_tag(non_neg_integer()) :: {:ok, ntp_mode()} | :error
  def ntp_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_ntp_mode, tag)}
  end

  def ntp_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `NtpMode` to the C-ABI tag value.
  """
  @spec ntp_mode_to_tag(ntp_mode()) :: non_neg_integer()
  def ntp_mode_to_tag(val) when is_map_key(@ntp_mode_tags, val) do
    Map.fetch!(@ntp_mode_tags, val)
  end

  @doc """
  All `NtpMode` variants in tag order.
  """
  @spec all_ntp_modes() :: [ntp_mode()]
  def all_ntp_modes do
    [
      :reserved, :symmetric_active, :symmetric_passive, :client, :server,
      :broadcast, :control_message, :private
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this mode is used for time synchronisation
  (as opposed to control or reserved).
  """
  @spec is_time_sync?(ntp_mode()) :: boolean()
  def is_time_sync?(val) when val in [:symmetric_active, :symmetric_passive, :client, :server, :broadcast], do: true
  def is_time_sync?(_val), do: false

  # ===========================================================================
  # ExchangeState (tags 0-3)
  # ===========================================================================

  @typedoc """
  ExchangeState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type exchange_state :: :idle | :request_received | :timestamp_calculated | :response_sent

  @exchange_state_tags %{
    idle: 0,
    request_received: 1,
    timestamp_calculated: 2,
    response_sent: 3,
  }

  @tag_to_exchange_state Map.new(@exchange_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ExchangeState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ntp.exchange_state_from_tag(0)
      {:ok, :idle}
  """
  @spec exchange_state_from_tag(non_neg_integer()) :: {:ok, exchange_state()} | :error
  def exchange_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_exchange_state, tag)}
  end

  def exchange_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ExchangeState` to the C-ABI tag value.
  """
  @spec exchange_state_to_tag(exchange_state()) :: non_neg_integer()
  def exchange_state_to_tag(val) when is_map_key(@exchange_state_tags, val) do
    Map.fetch!(@exchange_state_tags, val)
  end

  @doc """
  All `ExchangeState` variants in tag order.
  """
  @spec all_exchange_states() :: [exchange_state()]
  def all_exchange_states, do: [:idle, :request_received, :timestamp_calculated, :response_sent]

  @doc """
  Validate whether a `ExchangeState` state transition is allowed.

  Mirrors the formally verified transitions from the Idris2 source.
  """
  @spec validate_exchange_state_transition(exchange_state(), exchange_state()) :: boolean()
  def validate_exchange_state_transition(:idle, :request_received), do: true
  def validate_exchange_state_transition(:request_received, :timestamp_calculated), do: true
  def validate_exchange_state_transition(:timestamp_calculated, :response_sent), do: true
  def validate_exchange_state_transition(:response_sent, :idle), do: true
  def validate_exchange_state_transition(_from, _to), do: false

  # ===========================================================================
  # ClockDisciplineState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ClockDisciplineState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type clock_discipline_state :: :unset | :spike | :freq | :sync | :panic

  @clock_discipline_state_tags %{
    unset: 0,
    spike: 1,
    freq: 2,
    sync: 3,
    panic: 4,
  }

  @tag_to_clock_discipline_state Map.new(@clock_discipline_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ClockDisciplineState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ntp.clock_discipline_state_from_tag(0)
      {:ok, :unset}
  """
  @spec clock_discipline_state_from_tag(non_neg_integer()) :: {:ok, clock_discipline_state()} | :error
  def clock_discipline_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_clock_discipline_state, tag)}
  end

  def clock_discipline_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ClockDisciplineState` to the C-ABI tag value.
  """
  @spec clock_discipline_state_to_tag(clock_discipline_state()) :: non_neg_integer()
  def clock_discipline_state_to_tag(val) when is_map_key(@clock_discipline_state_tags, val) do
    Map.fetch!(@clock_discipline_state_tags, val)
  end

  @doc """
  All `ClockDisciplineState` variants in tag order.
  """
  @spec all_clock_discipline_states() :: [clock_discipline_state()]
  def all_clock_discipline_states, do: [:unset, :spike, :freq, :sync, :panic]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the clock is in a healthy state.
  """
  @spec is_healthy?(clock_discipline_state()) :: boolean()
  def is_healthy?(val) when val in [:freq, :sync], do: true
  def is_healthy?(_val), do: false

  @doc """
  Whether the clock requires operator intervention.
  """
  @spec needs_intervention?(clock_discipline_state()) :: boolean()
  def needs_intervention?(val) when val in [:panic], do: true
  def needs_intervention?(_val), do: false

  # ===========================================================================
  # KissCode (tags 0-3)
  # ===========================================================================

  @typedoc """
  KissCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type kiss_code :: :deny | :rstr | :rate | :other

  @kiss_code_tags %{
    deny: 0,
    rstr: 1,
    rate: 2,
    other: 3,
  }

  @tag_to_kiss_code Map.new(@kiss_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `KissCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ntp.kiss_code_from_tag(0)
      {:ok, :deny}
  """
  @spec kiss_code_from_tag(non_neg_integer()) :: {:ok, kiss_code()} | :error
  def kiss_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_kiss_code, tag)}
  end

  def kiss_code_from_tag(_tag), do: :error

  @doc """
  Encode a `KissCode` to the C-ABI tag value.
  """
  @spec kiss_code_to_tag(kiss_code()) :: non_neg_integer()
  def kiss_code_to_tag(val) when is_map_key(@kiss_code_tags, val) do
    Map.fetch!(@kiss_code_tags, val)
  end

  @doc """
  All `KissCode` variants in tag order.
  """
  @spec all_kiss_codes() :: [kiss_code()]
  def all_kiss_codes, do: [:deny, :rstr, :rate, :other]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The 4-character ASCII kiss code string.
        match self {

  Whether the client should stop querying this server.
  """
  @spec should_stop?(kiss_code()) :: boolean()
  def should_stop?(val) when val in [:deny, :rstr], do: true
  def should_stop?(_val), do: false

  # ===========================================================================
  # NtpError (tags 0-5)
  # ===========================================================================

  @typedoc """
  NtpError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ntp_error ::
          :ok
          | :invalid_slot
          | :not_active
          | :invalid_packet
          | :kiss_of_death
          | :stratum_too_high

  @ntp_error_tags %{
    ok: 0,
    invalid_slot: 1,
    not_active: 2,
    invalid_packet: 3,
    kiss_of_death: 4,
    stratum_too_high: 5,
  }

  @tag_to_ntp_error Map.new(@ntp_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NtpError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ntp.ntp_error_from_tag(0)
      {:ok, :ok}
  """
  @spec ntp_error_from_tag(non_neg_integer()) :: {:ok, ntp_error()} | :error
  def ntp_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_ntp_error, tag)}
  end

  def ntp_error_from_tag(_tag), do: :error

  @doc """
  Encode a `NtpError` to the C-ABI tag value.
  """
  @spec ntp_error_to_tag(ntp_error()) :: non_neg_integer()
  def ntp_error_to_tag(val) when is_map_key(@ntp_error_tags, val) do
    Map.fetch!(@ntp_error_tags, val)
  end

  @doc """
  All `NtpError` variants in tag order.
  """
  @spec all_ntp_errors() :: [ntp_error()]
  def all_ntp_errors do
    [
      :ok, :invalid_slot, :not_active, :invalid_packet, :kiss_of_death,
      :stratum_too_high
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this represents a successful outcome.
  """
  @spec is_ok?(ntp_error()) :: boolean()
  def is_ok?(val) when val in [:ok], do: true
  def is_ok?(_val), do: false

  @doc """
  Whether this error indicates a problem with the remote server.
  """
  @spec is_remote_error?(ntp_error()) :: boolean()
  def is_remote_error?(val) when val in [:kiss_of_death, :stratum_too_high], do: true
  def is_remote_error?(_val), do: false

end
