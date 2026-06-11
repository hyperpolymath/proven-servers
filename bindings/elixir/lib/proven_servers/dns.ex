# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Dns do
  @moduledoc """
  DNS protocol types for the proven-servers ABI.

  Mirrors the Idris2 module `DNS` and its submodules:

    * `DNS` — core constants (ports, size limits)
    * `DNS.RecordType` — DNS record types
    * `DNS.Name` — domain name validation

  All constants match the values in the Idris2 `DNS` module, which
  are derived from RFC 1035, RFC 6891, and related RFCs.

  ## Domain Validation

  The `validate_domain_name/1` function enforces RFC 1035 length
  constraints: no label exceeds 63 bytes and the total name does
  not exceed 253 bytes.
  """

  # ===========================================================================
  # DNS Constants (DNS module)
  # ===========================================================================

  # Standard DNS port (RFC 1035).
  @dns_port 53

  # Maximum UDP message size without EDNS (RFC 1035 Section 4.2.1).
  @max_udp_size 512

  # Maximum TCP message size (RFC 1035 Section 4.2.2).
  @max_tcp_size 65_535

  # Maximum label length in bytes (RFC 1035 Section 2.3.4).
  @max_label_length 63

  # Maximum total domain name length including dots (RFC 1035).
  @max_name_length 253

  # EDNS(0) default UDP payload size (RFC 6891).
  @edns_udp_size 4096

  @doc "Standard DNS port (53). Matches `dnsPort` in `DNS`."
  @spec dns_port() :: non_neg_integer()
  def dns_port, do: @dns_port

  @doc "Maximum UDP message size without EDNS (512 bytes). Matches `maxUdpSize` in `DNS`."
  @spec max_udp_size() :: non_neg_integer()
  def max_udp_size, do: @max_udp_size

  @doc "Maximum TCP message size (65535 bytes). Matches `maxTcpSize` in `DNS`."
  @spec max_tcp_size() :: non_neg_integer()
  def max_tcp_size, do: @max_tcp_size

  @doc "Maximum label length (63 bytes). Matches `maxLabelLength` in `DNS`."
  @spec max_label_length() :: non_neg_integer()
  def max_label_length, do: @max_label_length

  @doc "Maximum domain name length (253 bytes). Matches `maxNameLength` in `DNS`."
  @spec max_name_length() :: non_neg_integer()
  def max_name_length, do: @max_name_length

  @doc "EDNS(0) default UDP payload size (4096 bytes). Matches `ednsUdpSize` in `DNS`."
  @spec edns_udp_size() :: non_neg_integer()
  def edns_udp_size, do: @edns_udp_size

  # ===========================================================================
  # DNS Record Type
  # ===========================================================================

  @typedoc """
  DNS resource record types.

  Covers the 9 record types defined in the proven-dns `RecordType` module.
  Values are the standard DNS type codes from IANA.
  """
  @type record_type :: :a | :aaaa | :cname | :mx | :ns | :txt | :soa | :srv | :ptr

  @record_type_codes %{
    a: 1,
    ns: 2,
    cname: 5,
    soa: 6,
    ptr: 12,
    mx: 15,
    txt: 16,
    aaaa: 28,
    srv: 33
  }

  @code_to_record_type Map.new(@record_type_codes, fn {k, v} -> {v, k} end)

  @record_type_mnemonics %{
    a: "A",
    aaaa: "AAAA",
    cname: "CNAME",
    mx: "MX",
    ns: "NS",
    txt: "TXT",
    soa: "SOA",
    srv: "SRV",
    ptr: "PTR"
  }

  @doc """
  Decode from a DNS type code (IANA registered value).

  ## Examples

      iex> ProvenServers.Dns.record_type_from_code(1)
      {:ok, :a}

      iex> ProvenServers.Dns.record_type_from_code(28)
      {:ok, :aaaa}

      iex> ProvenServers.Dns.record_type_from_code(0)
      :error
  """
  @spec record_type_from_code(non_neg_integer()) :: {:ok, record_type()} | :error
  def record_type_from_code(code) when is_integer(code) do
    case Map.fetch(@code_to_record_type, code) do
      {:ok, _rt} = result -> result
      :error -> :error
    end
  end

  @doc """
  Convert to the DNS type code (IANA registered value).

  ## Examples

      iex> ProvenServers.Dns.record_type_to_code(:a)
      1

      iex> ProvenServers.Dns.record_type_to_code(:aaaa)
      28
  """
  @spec record_type_to_code(record_type()) :: non_neg_integer()
  def record_type_to_code(rt) when is_map_key(@record_type_codes, rt) do
    Map.fetch!(@record_type_codes, rt)
  end

  @doc """
  Mnemonic name (e.g. "A", "AAAA", "CNAME").

  ## Examples

      iex> ProvenServers.Dns.record_type_mnemonic(:aaaa)
      "AAAA"
  """
  @spec record_type_mnemonic(record_type()) :: String.t()
  def record_type_mnemonic(rt) when is_map_key(@record_type_mnemonics, rt) do
    Map.fetch!(@record_type_mnemonics, rt)
  end

  @doc """
  Whether this record type holds an address (A or AAAA).

  ## Examples

      iex> ProvenServers.Dns.record_type_address?(:a)
      true

      iex> ProvenServers.Dns.record_type_address?(:cname)
      false
  """
  @spec record_type_address?(record_type()) :: boolean()
  def record_type_address?(rt) when rt in [:a, :aaaa], do: true
  def record_type_address?(_rt), do: false

  @doc """
  Whether this is an infrastructure record (NS, SOA).
  """
  @spec record_type_infrastructure?(record_type()) :: boolean()
  def record_type_infrastructure?(rt) when rt in [:ns, :soa], do: true
  def record_type_infrastructure?(_rt), do: false

  @doc """
  All supported record types in IANA type code order.
  """
  @spec all_record_types() :: [record_type()]
  def all_record_types, do: [:a, :ns, :cname, :soa, :ptr, :mx, :txt, :aaaa, :srv]

  # ===========================================================================
  # DNS Response Code
  # ===========================================================================

  @typedoc """
  DNS response codes (RCODE, RFC 1035 Section 4.1.1).
  """
  @type response_code ::
          :no_error | :format_error | :server_failure | :name_error | :not_implemented | :refused

  @response_code_rcodes %{
    no_error: 0,
    format_error: 1,
    server_failure: 2,
    name_error: 3,
    not_implemented: 4,
    refused: 5
  }

  @rcode_to_response Map.new(@response_code_rcodes, fn {k, v} -> {v, k} end)

  @response_code_names %{
    no_error: "NOERROR",
    format_error: "FORMERR",
    server_failure: "SERVFAIL",
    name_error: "NXDOMAIN",
    not_implemented: "NOTIMP",
    refused: "REFUSED"
  }

  @doc """
  Decode from a 4-bit RCODE value.

  ## Examples

      iex> ProvenServers.Dns.response_code_from_rcode(0)
      {:ok, :no_error}

      iex> ProvenServers.Dns.response_code_from_rcode(3)
      {:ok, :name_error}

      iex> ProvenServers.Dns.response_code_from_rcode(99)
      :error
  """
  @spec response_code_from_rcode(non_neg_integer()) :: {:ok, response_code()} | :error
  def response_code_from_rcode(code) when is_integer(code) and code >= 0 and code <= 5 do
    {:ok, Map.fetch!(@rcode_to_response, code)}
  end

  def response_code_from_rcode(_code), do: :error

  @doc """
  Convert to the RCODE value.
  """
  @spec response_code_to_rcode(response_code()) :: non_neg_integer()
  def response_code_to_rcode(rc) when is_map_key(@response_code_rcodes, rc) do
    Map.fetch!(@response_code_rcodes, rc)
  end

  @doc """
  DNS mnemonic name (e.g. "NOERROR", "NXDOMAIN").

  ## Examples

      iex> ProvenServers.Dns.response_code_name(:name_error)
      "NXDOMAIN"
  """
  @spec response_code_name(response_code()) :: String.t()
  def response_code_name(rc) when is_map_key(@response_code_names, rc) do
    Map.fetch!(@response_code_names, rc)
  end

  @doc """
  Whether this response indicates success.
  """
  @spec response_code_success?(response_code()) :: boolean()
  def response_code_success?(:no_error), do: true
  def response_code_success?(_rc), do: false

  @doc """
  Whether this response indicates the domain does not exist (NXDOMAIN).
  """
  @spec response_code_nxdomain?(response_code()) :: boolean()
  def response_code_nxdomain?(:name_error), do: true
  def response_code_nxdomain?(_rc), do: false

  # ===========================================================================
  # Domain Name Validation
  # ===========================================================================

  @typedoc """
  Errors that can occur during domain name validation.
  """
  @type name_error ::
          {:label_too_long, String.t(), non_neg_integer()}
          | {:name_too_long, String.t(), non_neg_integer()}
          | :empty_name
          | :empty_label

  @doc """
  Validate a domain name against RFC 1035 length constraints.

  Checks that no label exceeds `max_label_length/0` bytes and that
  the total name does not exceed `max_name_length/0` bytes.
  Mirrors the validation logic in the Idris2 `DNS.Name` module.

  ## Examples

      iex> ProvenServers.Dns.validate_domain_name("example.com")
      :ok

      iex> ProvenServers.Dns.validate_domain_name("")
      {:error, :empty_name}

      iex> ProvenServers.Dns.validate_domain_name("example..com")
      {:error, :empty_label}
  """
  @spec validate_domain_name(String.t()) :: :ok | {:error, name_error()}
  def validate_domain_name(""), do: {:error, :empty_name}

  def validate_domain_name(name) when is_binary(name) do
    cond do
      byte_size(name) > @max_name_length ->
        {:error, {:name_too_long, name, byte_size(name)}}

      true ->
        name
        |> String.split(".")
        |> validate_labels()
    end
  end

  @doc false
  @spec validate_labels([String.t()]) :: :ok | {:error, name_error()}
  defp validate_labels([]), do: :ok

  defp validate_labels(["" | _rest]), do: {:error, :empty_label}

  defp validate_labels([label | rest]) do
    if byte_size(label) > @max_label_length do
      {:error, {:label_too_long, label, byte_size(label)}}
    else
      validate_labels(rest)
    end
  end
end
