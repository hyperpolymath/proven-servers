# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.DnsTest do
  use ExUnit.Case, async: true
  doctest ProvenServers.Dns

  alias ProvenServers.Dns

  describe "record type roundtrip" do
    test "all record types roundtrip" do
      for rt <- Dns.all_record_types() do
        code = Dns.record_type_to_code(rt)
        assert {:ok, ^rt} = Dns.record_type_from_code(code)
      end
    end

    test "unknown type codes rejected" do
      assert Dns.record_type_from_code(0) == :error
      assert Dns.record_type_from_code(255) == :error
    end
  end

  describe "record type classification" do
    test "address types" do
      assert Dns.record_type_address?(:a)
      assert Dns.record_type_address?(:aaaa)
      refute Dns.record_type_address?(:cname)
    end

    test "infrastructure types" do
      assert Dns.record_type_infrastructure?(:ns)
      assert Dns.record_type_infrastructure?(:soa)
      refute Dns.record_type_infrastructure?(:mx)
    end
  end

  describe "response code roundtrip" do
    test "all codes 0..5 roundtrip" do
      for code <- 0..5 do
        {:ok, rc} = Dns.response_code_from_rcode(code)
        assert Dns.response_code_to_rcode(rc) == code
      end
    end

    test "invalid code rejected" do
      assert Dns.response_code_from_rcode(6) == :error
    end
  end

  describe "response code classification" do
    test "success" do
      assert Dns.response_code_success?(:no_error)
      refute Dns.response_code_success?(:name_error)
    end

    test "nxdomain" do
      assert Dns.response_code_nxdomain?(:name_error)
      refute Dns.response_code_nxdomain?(:no_error)
    end
  end

  describe "domain name validation" do
    test "valid names" do
      assert Dns.validate_domain_name("example.com") == :ok
      assert Dns.validate_domain_name("sub.example.com") == :ok
      assert Dns.validate_domain_name("a") == :ok
    end

    test "empty name" do
      assert Dns.validate_domain_name("") == {:error, :empty_name}
    end

    test "label too long" do
      long_label = String.duplicate("a", 64)
      name = "#{long_label}.com"
      assert {:error, {:label_too_long, ^long_label, 64}} = Dns.validate_domain_name(name)
    end

    test "name too long" do
      label = String.duplicate("a", 63)
      name = "#{label}.#{label}.#{label}.#{label}.x"
      assert byte_size(name) > 253
      assert {:error, {:name_too_long, ^name, _len}} = Dns.validate_domain_name(name)
    end

    test "empty label" do
      assert Dns.validate_domain_name("example..com") == {:error, :empty_label}
    end
  end

  describe "constants match Idris2" do
    test "all constants are correct" do
      assert Dns.dns_port() == 53
      assert Dns.max_udp_size() == 512
      assert Dns.max_tcp_size() == 65535
      assert Dns.max_label_length() == 63
      assert Dns.max_name_length() == 253
      assert Dns.edns_udp_size() == 4096
    end
  end
end
