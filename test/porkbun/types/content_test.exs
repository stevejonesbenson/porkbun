defmodule Porkbun.Types.ContentTest do
  use ExUnit.Case
  doctest Porkbun.Types.Content

  alias Porkbun.Types.Content

  describe "type/0" do
    test "returns :string" do
      assert Content.type() == :string
    end
  end

  describe "cast/1" do
    test "casts valid non-empty strings" do
      valid_strings = ["192.168.1.1", "example.com", "mail.example.com", "test content"]

      for content <- valid_strings do
        assert {:ok, ^content} = Content.cast(content)
      end
    end

    test "rejects empty strings" do
      assert {:error, [message: "must be a non-empty string"]} = Content.cast("")
    end

    test "rejects non-string values" do
      invalid_values = [nil, 123, :atom, [], %{}, true, false]

      for value <- invalid_values do
        assert {:error, [message: "must be a non-empty string"]} = Content.cast(value)
      end
    end
  end

  describe "load/1" do
    test "loads valid binary values" do
      content_values = ["192.168.1.1", "example.com", "test content"]

      for content <- content_values do
        assert {:ok, ^content} = Content.load(content)
      end
    end

    test "rejects non-binary values" do
      invalid_values = [nil, 123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = Content.load(value)
      end
    end
  end

  describe "dump/1" do
    test "dumps valid binary values" do
      content_values = ["192.168.1.1", "example.com", "test content"]

      for content <- content_values do
        assert {:ok, ^content} = Content.dump(content)
      end
    end

    test "rejects non-binary values" do
      invalid_values = [nil, 123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = Content.dump(value)
      end
    end
  end

  describe "embed_as/1" do
    test "returns :self for any format" do
      assert Content.embed_as(:json) == :self
      assert Content.embed_as(:anything) == :self
    end
  end

  describe "equal?/2" do
    test "returns true for equal values" do
      assert Content.equal?("test", "test") == true
      assert Content.equal?("192.168.1.1", "192.168.1.1") == true
    end

    test "returns false for different values" do
      assert Content.equal?("test1", "test2") == false
      assert Content.equal?("192.168.1.1", "192.168.1.2") == false
    end

    test "handles different types" do
      assert Content.equal?("test", 123) == false
      assert Content.equal?(nil, "test") == false
    end
  end

  describe "valid_for_type?/2 - A records" do
    test "validates IPv4 addresses" do
      assert Content.valid_for_type?("192.168.1.1", :a) == true
      assert Content.valid_for_type?("8.8.8.8", :a) == true
      assert Content.valid_for_type?("0.0.0.0", :a) == true
      assert Content.valid_for_type?("255.255.255.255", :a) == true
    end

    test "rejects invalid IPv4 addresses" do
      assert Content.valid_for_type?("256.1.1.1", :a) == false
      assert Content.valid_for_type?("192.168.1", :a) == false
      assert Content.valid_for_type?("not.an.ip", :a) == false
      assert Content.valid_for_type?("::1", :a) == false
    end
  end

  describe "valid_for_type?/2 - AAAA records" do
    test "validates IPv6 addresses" do
      assert Content.valid_for_type?("::1", :aaaa) == true
      assert Content.valid_for_type?("2001:db8::1", :aaaa) == true
      assert Content.valid_for_type?("fe80::1%lo0", :aaaa) == true
      assert Content.valid_for_type?("2001:0db8:85a3:0000:0000:8a2e:0370:7334", :aaaa) == true
    end

    test "rejects invalid IPv6 addresses" do
      assert Content.valid_for_type?("192.168.1.1", :aaaa) == false
      assert Content.valid_for_type?("not:an:ipv6", :aaaa) == false
      assert Content.valid_for_type?("gggg::1", :aaaa) == false
    end
  end

  describe "valid_for_type?/2 - CNAME records" do
    test "validates domain names" do
      assert Content.valid_for_type?("example.com", :cname) == true
      assert Content.valid_for_type?("sub.example.com", :cname) == true
    end

    test "rejects invalid domain names" do
      assert Content.valid_for_type?("invalid domain", :cname) == false
      assert Content.valid_for_type?("", :cname) == false
    end
  end

  describe "valid_for_type?/2 - ALIAS records" do
    test "validates domain names" do
      assert Content.valid_for_type?("example.com", :alias) == true
      assert Content.valid_for_type?("cdn.example.com", :alias) == true
    end
  end

  describe "valid_for_type?/2 - MX records" do
    test "validates mail server names" do
      assert Content.valid_for_type?("mail.example.com", :mx) == true
      assert Content.valid_for_type?("mx1.example.com", :mx) == true
    end
  end

  describe "valid_for_type?/2 - NS records" do
    test "validates name server names" do
      assert Content.valid_for_type?("ns1.example.com", :ns) == true
      assert Content.valid_for_type?("dns.example.com", :ns) == true
    end
  end

  describe "valid_for_type?/2 - SRV records" do
    test "validates SRV format (weight port target)" do
      assert Content.valid_for_type?("10 80 server.example.com", :srv) == true
      assert Content.valid_for_type?("0 443 secure.example.com", :srv) == true
      assert Content.valid_for_type?("65535 65535 test.example.com", :srv) == true
    end

    test "rejects invalid SRV format" do
      assert Content.valid_for_type?("invalid", :srv) == false
      assert Content.valid_for_type?("10 80", :srv) == false
      assert Content.valid_for_type?("not_number 80 server.example.com", :srv) == false
      assert Content.valid_for_type?("10 not_number server.example.com", :srv) == false
      assert Content.valid_for_type?("10 80 invalid domain", :srv) == false
      assert Content.valid_for_type?("-1 80 server.example.com", :srv) == false
      assert Content.valid_for_type?("10 65536 server.example.com", :srv) == false
    end
  end

  describe "valid_for_type?/2 - CAA records" do
    test "validates CAA format (flags tag value)" do
      assert Content.valid_for_type?("0 issue letsencrypt.org", :caa) == true
      assert Content.valid_for_type?("0 issuewild ;", :caa) == true
      assert Content.valid_for_type?("128 iodef mailto:admin@example.com", :caa) == true
      assert Content.valid_for_type?("255 issue example.com", :caa) == true
    end

    test "rejects invalid CAA format" do
      assert Content.valid_for_type?("invalid", :caa) == false
      assert Content.valid_for_type?("0 issue", :caa) == false
      assert Content.valid_for_type?("not_number issue value", :caa) == false
      assert Content.valid_for_type?("256 issue value", :caa) == false
      assert Content.valid_for_type?("0 invalid_tag value", :caa) == false
      assert Content.valid_for_type?("0 issue ", :caa) == false
    end
  end

  describe "valid_for_type?/2 - TLSA records" do
    test "validates TLSA format (cert_usage selector matching_type cert_data)" do
      assert Content.valid_for_type?("3 1 1 1234567890ABCDEF", :tlsa) == true
      assert Content.valid_for_type?("0 0 0 abcdef123456", :tlsa) == true
      assert Content.valid_for_type?("2 1 2 FEDCBA0987654321", :tlsa) == true
    end

    test "rejects invalid TLSA format" do
      assert Content.valid_for_type?("invalid", :tlsa) == false
      assert Content.valid_for_type?("3 1 1", :tlsa) == false
      assert Content.valid_for_type?("not_number 1 1 1234", :tlsa) == false
      assert Content.valid_for_type?("4 1 1 1234", :tlsa) == false
      assert Content.valid_for_type?("3 2 1 1234", :tlsa) == false
      assert Content.valid_for_type?("3 1 3 1234", :tlsa) == false
      assert Content.valid_for_type?("3 1 1 xyz123", :tlsa) == false
      assert Content.valid_for_type?("3 1 1 ", :tlsa) == false
    end
  end

  describe "valid_for_type?/2 - HTTPS/SVCB records" do
    test "validates HTTPS format" do
      assert Content.valid_for_type?(".", :https) == true
      assert Content.valid_for_type?("svc.example.com", :https) == true
      assert Content.valid_for_type?("svc.example.com port=443", :https) == true
    end

    test "validates SVCB format" do
      assert Content.valid_for_type?(".", :svcb) == true
      assert Content.valid_for_type?("service.example.com", :svcb) == true
      assert Content.valid_for_type?("service.example.com alpn=h2", :svcb) == true
    end

    test "rejects invalid HTTPS/SVCB format" do
      assert Content.valid_for_type?("", :https) == false
      assert Content.valid_for_type?("", :svcb) == false
      assert Content.valid_for_type?("invalid domain", :https) == false
      assert Content.valid_for_type?("invalid domain", :svcb) == false
    end
  end

  describe "valid_for_type?/2 - other types" do
    test "accepts any non-empty string for TXT records" do
      assert Content.valid_for_type?("v=spf1 include:_spf.google.com ~all", :txt) == true
      assert Content.valid_for_type?("any text content", :txt) == true
      assert Content.valid_for_type?("", :txt) == false
    end

    test "accepts any non-empty string for unknown types" do
      assert Content.valid_for_type?("some content", :unknown) == true
      assert Content.valid_for_type?("", :unknown) == false
    end

    test "rejects non-binary content" do
      assert Content.valid_for_type?(123, :a) == false
      assert Content.valid_for_type?(nil, :mx) == false
      assert Content.valid_for_type?(:atom, :cname) == false
    end
  end

  describe "integration with Ecto.Type behaviour" do
    test "implements all required callbacks" do
      behaviours = Content.__info__(:attributes)[:behaviour] || []
      assert Ecto.Type in behaviours
    end

    test "cast -> dump -> load round trip" do
      original = "test content"

      assert {:ok, casted} = Content.cast(original)
      assert {:ok, dumped} = Content.dump(casted)
      assert {:ok, loaded} = Content.load(dumped)

      assert loaded == original
    end
  end
end
