defmodule Porkbun.Types.IPAddressTest do
  use ExUnit.Case
  doctest Porkbun.Types.IPAddress

  alias Porkbun.Types.IPAddress

  describe "type/0" do
    test "returns :string" do
      assert IPAddress.type() == :string
    end
  end

  describe "cast/1" do
    test "casts valid IPv4 addresses" do
      valid_ipv4 = [
        "192.168.1.1",
        "8.8.8.8",
        "0.0.0.0",
        "255.255.255.255",
        "127.0.0.1",
        "10.0.0.1"
      ]

      for ip <- valid_ipv4 do
        assert {:ok, ^ip} = IPAddress.cast(ip)
      end
    end

    test "casts valid IPv6 addresses" do
      valid_ipv6 = [
        "::1",
        "2001:db8::1",
        "fe80::1%lo0",
        "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
        "2001:db8:85a3::8a2e:370:7334",
        "::",
        "::ffff:192.0.2.1"
      ]

      for ip <- valid_ipv6 do
        assert {:ok, ^ip} = IPAddress.cast(ip)
      end
    end

    test "rejects invalid IP addresses" do
      invalid_ips = [
        "256.1.1.1",
        "192.168.1",
        "not.an.ip",
        "192.168.1.1.1",
        "gggg::1",
        "not:an:ipv6",
        "",
        "192.168.1.-1"
      ]

      for ip <- invalid_ips do
        assert :error = IPAddress.cast(ip)
      end
    end

    test "rejects non-string values" do
      invalid_values = [nil, 123, :atom, [], %{}, true, false]

      for value <- invalid_values do
        assert {:error, [message: "must be a valid IPv4 or IPv6 address"]} =
                 IPAddress.cast(value)
      end
    end
  end

  describe "load/1" do
    test "loads valid binary IP addresses" do
      ip_addresses = ["192.168.1.1", "::1", "8.8.8.8", "2001:db8::1"]

      for ip <- ip_addresses do
        assert {:ok, ^ip} = IPAddress.load(ip)
      end
    end

    test "rejects non-binary values" do
      invalid_values = [nil, 123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = IPAddress.load(value)
      end
    end
  end

  describe "dump/1" do
    test "dumps valid binary IP addresses" do
      ip_addresses = ["192.168.1.1", "::1", "8.8.8.8", "2001:db8::1"]

      for ip <- ip_addresses do
        assert {:ok, ^ip} = IPAddress.dump(ip)
      end
    end

    test "rejects non-binary values" do
      invalid_values = [nil, 123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = IPAddress.dump(value)
      end
    end
  end

  describe "embed_as/1" do
    test "returns :self for any format" do
      assert IPAddress.embed_as(:json) == :self
      assert IPAddress.embed_as(:anything) == :self
    end
  end

  describe "equal?/2" do
    test "returns true for equal IP addresses" do
      assert IPAddress.equal?("192.168.1.1", "192.168.1.1") == true
      assert IPAddress.equal?("::1", "::1") == true
    end

    test "returns false for different IP addresses" do
      assert IPAddress.equal?("192.168.1.1", "192.168.1.2") == false
      assert IPAddress.equal?("::1", "::2") == false
    end

    test "handles different types" do
      assert IPAddress.equal?("192.168.1.1", 123) == false
      assert IPAddress.equal?(nil, "192.168.1.1") == false
    end
  end

  describe "valid?/1" do
    test "returns true for valid IPv4 addresses" do
      valid_ipv4 = [
        "192.168.1.1",
        "8.8.8.8",
        "0.0.0.0",
        "255.255.255.255",
        "127.0.0.1"
      ]

      for ip <- valid_ipv4 do
        assert IPAddress.valid?(ip) == true
      end
    end

    test "returns true for valid IPv6 addresses" do
      valid_ipv6 = [
        "::1",
        "2001:db8::1",
        "fe80::1%lo0",
        "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
        "::"
      ]

      for ip <- valid_ipv6 do
        assert IPAddress.valid?(ip) == true
      end
    end

    test "returns false for invalid addresses" do
      invalid_values = [
        "256.1.1.1",
        "not.an.ip",
        "gggg::1",
        "",
        nil,
        123,
        :atom
      ]

      for value <- invalid_values do
        assert IPAddress.valid?(value) == false
      end
    end
  end

  describe "ipv4?/1" do
    test "returns true for valid IPv4 addresses" do
      valid_ipv4 = [
        "192.168.1.1",
        "8.8.8.8",
        "0.0.0.0",
        "255.255.255.255",
        "127.0.0.1",
        "10.0.0.1"
      ]

      for ip <- valid_ipv4 do
        assert IPAddress.ipv4?(ip) == true
      end
    end

    test "returns false for IPv6 addresses" do
      ipv6_addresses = ["::1", "2001:db8::1", "fe80::1%lo0"]

      for ip <- ipv6_addresses do
        assert IPAddress.ipv4?(ip) == false
      end
    end

    test "returns false for invalid addresses" do
      invalid_addresses = ["256.1.1.1", "not.an.ip", "192.168.1", ""]

      for ip <- invalid_addresses do
        assert IPAddress.ipv4?(ip) == false
      end
    end
  end

  describe "ipv6?/1" do
    test "returns true for valid IPv6 addresses" do
      valid_ipv6 = [
        "::1",
        "2001:db8::1",
        "fe80::1%lo0",
        "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
        "2001:db8:85a3::8a2e:370:7334",
        "::",
        "::ffff:192.0.2.1"
      ]

      for ip <- valid_ipv6 do
        assert IPAddress.ipv6?(ip) == true
      end
    end

    test "returns false for IPv4 addresses" do
      ipv4_addresses = ["192.168.1.1", "8.8.8.8", "127.0.0.1"]

      for ip <- ipv4_addresses do
        assert IPAddress.ipv6?(ip) == false
      end
    end

    test "returns false for invalid addresses" do
      invalid_addresses = ["gggg::1", "not:an:ipv6", "192.168.1", ""]

      for ip <- invalid_addresses do
        assert IPAddress.ipv6?(ip) == false
      end
    end
  end

  describe "integration with Ecto.Type behaviour" do
    test "implements all required callbacks" do
      behaviours = IPAddress.__info__(:attributes)[:behaviour] || []
      assert Ecto.Type in behaviours
    end

    test "cast -> dump -> load round trip for IPv4" do
      original = "192.168.1.1"

      assert {:ok, casted} = IPAddress.cast(original)
      assert {:ok, dumped} = IPAddress.dump(casted)
      assert {:ok, loaded} = IPAddress.load(dumped)

      assert loaded == original
    end

    test "cast -> dump -> load round trip for IPv6" do
      original = "::1"

      assert {:ok, casted} = IPAddress.cast(original)
      assert {:ok, dumped} = IPAddress.dump(casted)
      assert {:ok, loaded} = IPAddress.load(dumped)

      assert loaded == original
    end
  end
end
