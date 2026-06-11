# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Firewall do
  @moduledoc """
  Firewall protocol types for the proven-servers ABI.

  Mirrors the Idris2 modules:

    * `Firewall.Types` -- actions, protocols, chain types, match criteria,
      connection states
    * `FirewallABI.Layout` -- C-ABI tag values for all types
    * `FirewallABI.Transitions` -- rule evaluation state machine
  """

  # ===========================================================================
  # Action (FirewallABI.Layout.Action, tags 0-7)
  # ===========================================================================

  @typedoc "Firewall rule actions applied to matching packets."
  @type action :: :accept | :drop | :reject | :log | :redirect | :dnat | :snat | :masquerade

  @action_tags %{
    accept: 0, drop: 1, reject: 2, log: 3,
    redirect: 4, dnat: 5, snat: 6, masquerade: 7
  }
  @tag_to_action Map.new(@action_tags, fn {k, v} -> {v, k} end)

  @action_strings %{
    accept: "ACCEPT", drop: "DROP", reject: "REJECT", log: "LOG",
    redirect: "REDIRECT", dnat: "DNAT", snat: "SNAT", masquerade: "MASQUERADE"
  }

  @doc "Decode from a C-ABI tag value."
  @spec action_from_tag(non_neg_integer()) :: {:ok, action()} | :error
  def action_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_action, tag)}
  end
  def action_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec action_to_tag(action()) :: non_neg_integer()
  def action_to_tag(action) when is_map_key(@action_tags, action) do
    Map.fetch!(@action_tags, action)
  end

  @doc """
  iptables/nftables action string.

  ## Examples

      iex> ProvenServers.Firewall.action_to_string(:accept)
      "ACCEPT"
  """
  @spec action_to_string(action()) :: String.t()
  def action_to_string(action) when is_map_key(@action_strings, action) do
    Map.fetch!(@action_strings, action)
  end

  @doc "Whether this action terminates rule processing (LOG does not terminate)."
  @spec action_terminating?(action()) :: boolean()
  def action_terminating?(:log), do: false
  def action_terminating?(_action), do: true

  @doc "Whether this action performs network address translation."
  @spec action_nat?(action()) :: boolean()
  def action_nat?(a) when a in [:dnat, :snat, :masquerade, :redirect], do: true
  def action_nat?(_a), do: false

  # ===========================================================================
  # Protocol (FirewallABI.Layout.Protocol, tags 0-7)
  # ===========================================================================

  @typedoc "IP protocols for firewall rule matching."
  @type fw_protocol :: :tcp | :udp | :icmp | :icmpv6 | :gre | :esp | :ah | :any

  @protocol_tags %{tcp: 0, udp: 1, icmp: 2, icmpv6: 3, gre: 4, esp: 5, ah: 6, any: 7}
  @tag_to_protocol Map.new(@protocol_tags, fn {k, v} -> {v, k} end)

  @protocol_strings %{
    tcp: "TCP", udp: "UDP", icmp: "ICMP", icmpv6: "ICMPv6",
    gre: "GRE", esp: "ESP", ah: "AH", any: "ANY"
  }

  @protocol_numbers %{tcp: 6, udp: 17, icmp: 1, icmpv6: 58, gre: 47, esp: 50, ah: 51, any: 0}

  @doc "Decode from a C-ABI tag value."
  @spec protocol_from_tag(non_neg_integer()) :: {:ok, fw_protocol()} | :error
  def protocol_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_protocol, tag)}
  end
  def protocol_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec protocol_to_tag(fw_protocol()) :: non_neg_integer()
  def protocol_to_tag(p) when is_map_key(@protocol_tags, p), do: Map.fetch!(@protocol_tags, p)

  @doc "Protocol name string."
  @spec protocol_to_string(fw_protocol()) :: String.t()
  def protocol_to_string(p) when is_map_key(@protocol_strings, p), do: Map.fetch!(@protocol_strings, p)

  @doc "IANA protocol number."
  @spec protocol_number(fw_protocol()) :: non_neg_integer()
  def protocol_number(p) when is_map_key(@protocol_numbers, p), do: Map.fetch!(@protocol_numbers, p)

  @doc "Whether this protocol supports port-based matching."
  @spec protocol_has_ports?(fw_protocol()) :: boolean()
  def protocol_has_ports?(p) when p in [:tcp, :udp], do: true
  def protocol_has_ports?(_p), do: false

  # ===========================================================================
  # ChainType (FirewallABI.Layout.ChainType, tags 0-4)
  # ===========================================================================

  @typedoc "Netfilter chain types for firewall rule organisation."
  @type chain_type :: :input | :output | :forward | :pre_routing | :post_routing

  @chain_type_tags %{input: 0, output: 1, forward: 2, pre_routing: 3, post_routing: 4}
  @tag_to_chain_type Map.new(@chain_type_tags, fn {k, v} -> {v, k} end)

  @chain_type_strings %{
    input: "INPUT", output: "OUTPUT", forward: "FORWARD",
    pre_routing: "PREROUTING", post_routing: "POSTROUTING"
  }

  @doc "Decode from a C-ABI tag value."
  @spec chain_type_from_tag(non_neg_integer()) :: {:ok, chain_type()} | :error
  def chain_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_chain_type, tag)}
  end
  def chain_type_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec chain_type_to_tag(chain_type()) :: non_neg_integer()
  def chain_type_to_tag(ct) when is_map_key(@chain_type_tags, ct), do: Map.fetch!(@chain_type_tags, ct)

  @doc "Chain name string."
  @spec chain_type_to_string(chain_type()) :: String.t()
  def chain_type_to_string(ct) when is_map_key(@chain_type_strings, ct), do: Map.fetch!(@chain_type_strings, ct)

  @doc "Whether NAT actions are valid in this chain."
  @spec chain_type_supports_nat?(chain_type()) :: boolean()
  def chain_type_supports_nat?(ct) when ct in [:pre_routing, :post_routing], do: true
  def chain_type_supports_nat?(_ct), do: false

  # ===========================================================================
  # RuleMatch (FirewallABI.Layout.RuleMatch, tags 0-7)
  # ===========================================================================

  @typedoc "Match criteria for firewall rules."
  @type rule_match :: :source_ip | :dest_ip | :source_port | :dest_port | :proto | :interface | :state | :mark

  @rule_match_tags %{
    source_ip: 0, dest_ip: 1, source_port: 2, dest_port: 3,
    proto: 4, interface: 5, state: 6, mark: 7
  }
  @tag_to_rule_match Map.new(@rule_match_tags, fn {k, v} -> {v, k} end)

  @rule_match_strings %{
    source_ip: "SourceIP", dest_ip: "DestIP", source_port: "SourcePort",
    dest_port: "DestPort", proto: "Protocol", interface: "Interface",
    state: "State", mark: "Mark"
  }

  @doc "Decode from a C-ABI tag value."
  @spec rule_match_from_tag(non_neg_integer()) :: {:ok, rule_match()} | :error
  def rule_match_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_rule_match, tag)}
  end
  def rule_match_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec rule_match_to_tag(rule_match()) :: non_neg_integer()
  def rule_match_to_tag(rm) when is_map_key(@rule_match_tags, rm), do: Map.fetch!(@rule_match_tags, rm)

  @doc "Match criteria name string."
  @spec rule_match_to_string(rule_match()) :: String.t()
  def rule_match_to_string(rm) when is_map_key(@rule_match_strings, rm), do: Map.fetch!(@rule_match_strings, rm)

  # ===========================================================================
  # ConnState (FirewallABI.Layout.ConnState, tags 0-3)
  # ===========================================================================

  @typedoc "Connection tracking states for stateful firewall inspection."
  @type conn_state :: :new | :established | :related | :invalid

  @conn_state_tags %{new: 0, established: 1, related: 2, invalid: 3}
  @tag_to_conn_state Map.new(@conn_state_tags, fn {k, v} -> {v, k} end)

  @conn_state_strings %{
    new: "NEW", established: "ESTABLISHED", related: "RELATED", invalid: "INVALID"
  }

  @doc "Decode from a C-ABI tag value."
  @spec conn_state_from_tag(non_neg_integer()) :: {:ok, conn_state()} | :error
  def conn_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_conn_state, tag)}
  end
  def conn_state_from_tag(_tag), do: :error

  @doc "Encode to the C-ABI tag value."
  @spec conn_state_to_tag(conn_state()) :: non_neg_integer()
  def conn_state_to_tag(s) when is_map_key(@conn_state_tags, s), do: Map.fetch!(@conn_state_tags, s)

  @doc "Connection state name string."
  @spec conn_state_to_string(conn_state()) :: String.t()
  def conn_state_to_string(s) when is_map_key(@conn_state_strings, s), do: Map.fetch!(@conn_state_strings, s)

  @doc "Whether this state represents an active, valid connection."
  @spec conn_state_active?(conn_state()) :: boolean()
  def conn_state_active?(s) when s in [:established, :related], do: true
  def conn_state_active?(_s), do: false
end
