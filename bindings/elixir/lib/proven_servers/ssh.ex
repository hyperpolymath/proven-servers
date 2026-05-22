# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Ssh do
  @moduledoc """
  SSH protocol types for the proven-servers ABI.

  This module delegates to `ProvenServers.SshBastion` which contains
  the full SSH bastion protocol implementation. The separation mirrors
  the Rust binding layout where `ssh.rs` contains all SSH bastion types.

  Mirrors the Idris2 module `SshBastionABI.Types` and its type definitions:

    * `SshMessageType`     -- SSH message types (8 constructors, tags 0-7)
    * `AuthMethod`         -- authentication methods (4 constructors, tags 0-3)
    * `KexMethod`          -- key exchange methods (6 constructors, tags 0-5)
    * `ChannelType`        -- SSH channel types (4 constructors, tags 0-3)
    * `BastionState`       -- bastion connection state machine (6 constructors, tags 0-5)
    * `ChannelState`       -- per-channel state machine (4 constructors, tags 0-3)
    * `DisconnectReason`   -- disconnect reason codes (12 constructors, tags 0-11)
    * `HostKeyAlgorithm`   -- host key algorithms (4 constructors, tags 0-3)
    * `CipherAlgorithm`    -- symmetric cipher algorithms (6 constructors, tags 0-5)
    * `ChannelOpenFailure` -- channel open failure reasons (4 constructors, tags 0-3)

  All tag values match the Idris2 ABI definitions exactly.
  """

  # Re-export all types from SshBastion
  @type message_type :: ProvenServers.SshBastion.message_type()
  @type auth_method :: ProvenServers.SshBastion.auth_method()
  @type kex_method :: ProvenServers.SshBastion.kex_method()
  @type channel_type :: ProvenServers.SshBastion.channel_type()
  @type bastion_state :: ProvenServers.SshBastion.bastion_state()
  @type channel_state :: ProvenServers.SshBastion.channel_state()
  @type disconnect_reason :: ProvenServers.SshBastion.disconnect_reason()
  @type host_key_algorithm :: ProvenServers.SshBastion.host_key_algorithm()
  @type cipher_algorithm :: ProvenServers.SshBastion.cipher_algorithm()
  @type channel_open_failure :: ProvenServers.SshBastion.channel_open_failure()

  # ---------------------------------------------------------------------------
  # Constants
  # ---------------------------------------------------------------------------

  @doc "Standard SSH port (22, RFC 4253)."
  @spec ssh_port() :: non_neg_integer()
  defdelegate ssh_port(), to: ProvenServers.SshBastion

  # ---------------------------------------------------------------------------
  # SshMessageType delegates
  # ---------------------------------------------------------------------------

  @doc "Decode a message type from a C-ABI tag value."
  @spec message_type_from_tag(non_neg_integer()) :: {:ok, message_type()} | :error
  defdelegate message_type_from_tag(tag), to: ProvenServers.SshBastion

  @doc "Encode a message type to the C-ABI tag value."
  @spec message_type_to_tag(message_type()) :: non_neg_integer()
  defdelegate message_type_to_tag(mt), to: ProvenServers.SshBastion

  @doc "Human-readable message type name."
  @spec message_type_name(message_type()) :: String.t()
  defdelegate message_type_name(mt), to: ProvenServers.SshBastion

  # ---------------------------------------------------------------------------
  # AuthMethod delegates
  # ---------------------------------------------------------------------------

  @doc "Decode an auth method from a C-ABI tag value."
  @spec auth_method_from_tag(non_neg_integer()) :: {:ok, auth_method()} | :error
  defdelegate auth_method_from_tag(tag), to: ProvenServers.SshBastion

  @doc "Encode an auth method to the C-ABI tag value."
  @spec auth_method_to_tag(auth_method()) :: non_neg_integer()
  defdelegate auth_method_to_tag(method), to: ProvenServers.SshBastion

  @doc "Whether this method is considered secure for production use."
  @spec auth_method_secure?(auth_method()) :: boolean()
  defdelegate auth_method_secure?(method), to: ProvenServers.SshBastion

  # ---------------------------------------------------------------------------
  # KexMethod delegates
  # ---------------------------------------------------------------------------

  @doc "Decode a key exchange method from a C-ABI tag value."
  @spec kex_method_from_tag(non_neg_integer()) :: {:ok, kex_method()} | :error
  defdelegate kex_method_from_tag(tag), to: ProvenServers.SshBastion

  @doc "Encode a key exchange method to the C-ABI tag value."
  @spec kex_method_to_tag(kex_method()) :: non_neg_integer()
  defdelegate kex_method_to_tag(method), to: ProvenServers.SshBastion

  @doc "Whether this key exchange method uses elliptic curve cryptography."
  @spec kex_method_ecc?(kex_method()) :: boolean()
  defdelegate kex_method_ecc?(method), to: ProvenServers.SshBastion

  # ---------------------------------------------------------------------------
  # ChannelType delegates
  # ---------------------------------------------------------------------------

  @doc "Decode a channel type from a C-ABI tag value."
  @spec channel_type_from_tag(non_neg_integer()) :: {:ok, channel_type()} | :error
  defdelegate channel_type_from_tag(tag), to: ProvenServers.SshBastion

  @doc "Encode a channel type to the C-ABI tag value."
  @spec channel_type_to_tag(channel_type()) :: non_neg_integer()
  defdelegate channel_type_to_tag(ct), to: ProvenServers.SshBastion

  @doc "Whether this channel type involves TCP/IP forwarding."
  @spec channel_type_forwarding?(channel_type()) :: boolean()
  defdelegate channel_type_forwarding?(ct), to: ProvenServers.SshBastion

  # ---------------------------------------------------------------------------
  # BastionState delegates
  # ---------------------------------------------------------------------------

  @doc "Decode a bastion state from a C-ABI tag value."
  @spec bastion_state_from_tag(non_neg_integer()) :: {:ok, bastion_state()} | :error
  defdelegate bastion_state_from_tag(tag), to: ProvenServers.SshBastion

  @doc "Encode a bastion state to the C-ABI tag value."
  @spec bastion_state_to_tag(bastion_state()) :: non_neg_integer()
  defdelegate bastion_state_to_tag(state), to: ProvenServers.SshBastion

  @doc "Validate whether a bastion state transition is allowed."
  @spec bastion_can_transition?(bastion_state(), bastion_state()) :: boolean()
  defdelegate bastion_can_transition?(from, to), to: ProvenServers.SshBastion

  # ---------------------------------------------------------------------------
  # ChannelState delegates
  # ---------------------------------------------------------------------------

  @doc "Decode a channel state from a C-ABI tag value."
  @spec channel_state_from_tag(non_neg_integer()) :: {:ok, channel_state()} | :error
  defdelegate channel_state_from_tag(tag), to: ProvenServers.SshBastion

  @doc "Encode a channel state to the C-ABI tag value."
  @spec channel_state_to_tag(channel_state()) :: non_neg_integer()
  defdelegate channel_state_to_tag(state), to: ProvenServers.SshBastion

  @doc "Validate whether a channel state transition is allowed."
  @spec channel_can_transition?(channel_state(), channel_state()) :: boolean()
  defdelegate channel_can_transition?(from, to), to: ProvenServers.SshBastion

  # ---------------------------------------------------------------------------
  # DisconnectReason delegates
  # ---------------------------------------------------------------------------

  @doc "Decode a disconnect reason from a C-ABI tag value."
  @spec disconnect_reason_from_tag(non_neg_integer()) :: {:ok, disconnect_reason()} | :error
  defdelegate disconnect_reason_from_tag(tag), to: ProvenServers.SshBastion

  @doc "Encode a disconnect reason to the C-ABI tag value."
  @spec disconnect_reason_to_tag(disconnect_reason()) :: non_neg_integer()
  defdelegate disconnect_reason_to_tag(reason), to: ProvenServers.SshBastion

  @doc "Whether this disconnect reason indicates a security issue."
  @spec disconnect_reason_security_related?(disconnect_reason()) :: boolean()
  defdelegate disconnect_reason_security_related?(reason), to: ProvenServers.SshBastion

  # ---------------------------------------------------------------------------
  # HostKeyAlgorithm delegates
  # ---------------------------------------------------------------------------

  @doc "Decode a host key algorithm from a C-ABI tag value."
  @spec host_key_algorithm_from_tag(non_neg_integer()) :: {:ok, host_key_algorithm()} | :error
  defdelegate host_key_algorithm_from_tag(tag), to: ProvenServers.SshBastion

  @doc "Encode a host key algorithm to the C-ABI tag value."
  @spec host_key_algorithm_to_tag(host_key_algorithm()) :: non_neg_integer()
  defdelegate host_key_algorithm_to_tag(alg), to: ProvenServers.SshBastion

  @doc "Algorithm name string."
  @spec host_key_algorithm_name(host_key_algorithm()) :: String.t()
  defdelegate host_key_algorithm_name(alg), to: ProvenServers.SshBastion

  @doc "Whether this algorithm uses elliptic curve cryptography."
  @spec host_key_algorithm_ecc?(host_key_algorithm()) :: boolean()
  defdelegate host_key_algorithm_ecc?(alg), to: ProvenServers.SshBastion

  # ---------------------------------------------------------------------------
  # CipherAlgorithm delegates
  # ---------------------------------------------------------------------------

  @doc "Decode a cipher algorithm from a C-ABI tag value."
  @spec cipher_algorithm_from_tag(non_neg_integer()) :: {:ok, cipher_algorithm()} | :error
  defdelegate cipher_algorithm_from_tag(tag), to: ProvenServers.SshBastion

  @doc "Encode a cipher algorithm to the C-ABI tag value."
  @spec cipher_algorithm_to_tag(cipher_algorithm()) :: non_neg_integer()
  defdelegate cipher_algorithm_to_tag(alg), to: ProvenServers.SshBastion

  @doc "Cipher algorithm name string."
  @spec cipher_algorithm_name(cipher_algorithm()) :: String.t()
  defdelegate cipher_algorithm_name(alg), to: ProvenServers.SshBastion

  @doc "Whether this cipher provides authenticated encryption (AEAD)."
  @spec cipher_algorithm_aead?(cipher_algorithm()) :: boolean()
  defdelegate cipher_algorithm_aead?(alg), to: ProvenServers.SshBastion

  @doc "The key size in bits for this cipher."
  @spec cipher_algorithm_key_bits(cipher_algorithm()) :: non_neg_integer()
  defdelegate cipher_algorithm_key_bits(alg), to: ProvenServers.SshBastion

  # ---------------------------------------------------------------------------
  # ChannelOpenFailure delegates
  # ---------------------------------------------------------------------------

  @doc "Decode a channel open failure reason from a C-ABI tag value."
  @spec channel_open_failure_from_tag(non_neg_integer()) :: {:ok, channel_open_failure()} | :error
  defdelegate channel_open_failure_from_tag(tag), to: ProvenServers.SshBastion

  @doc "Encode a channel open failure reason to the C-ABI tag value."
  @spec channel_open_failure_to_tag(channel_open_failure()) :: non_neg_integer()
  defdelegate channel_open_failure_to_tag(reason), to: ProvenServers.SshBastion
end
