defmodule Porkbun.Types.LocationTest do
  use ExUnit.Case
  doctest Porkbun.Types.Location

  alias Porkbun.Types.Location

  describe "type/0" do
    test "returns :string" do
      assert Location.type() == :string
    end
  end

  describe "cast/1" do
    test "casts valid HTTP URLs" do
      valid_http_urls = [
        "http://example.com",
        "http://www.example.com",
        "http://example.com/path",
        "http://example.com/path?query=value",
        "http://example.com:8080",
        "http://subdomain.example.com/path/to/resource"
      ]

      for url <- valid_http_urls do
        assert {:ok, ^url} = Location.cast(url)
      end
    end

    test "casts valid HTTPS URLs" do
      valid_https_urls = [
        "https://example.com",
        "https://www.example.com",
        "https://example.com/path",
        "https://example.com/path?query=value",
        "https://example.com:443",
        "https://secure.example.com/api/v1"
      ]

      for url <- valid_https_urls do
        assert {:ok, ^url} = Location.cast(url)
      end
    end

    test "rejects URLs with invalid schemes" do
      invalid_scheme_urls = [
        "ftp://example.com",
        "mailto:user@example.com",
        "file:///path/to/file",
        "ldap://server.example.com",
        "example.com",
        "www.example.com"
      ]

      for url <- invalid_scheme_urls do
        assert {:error, [message: "must be a valid URL (http:// or https://)"]} =
                 Location.cast(url)
      end
    end

    test "rejects malformed URLs" do
      invalid_urls = [
        "http://",
        "https://",
        "http:///path",
        "not-a-url",
        "",
        "http:/example.com",
        "https:/example.com"
      ]

      for url <- invalid_urls do
        assert {:error, [message: "must be a valid URL (http:// or https://)"]} =
                 Location.cast(url)
      end
    end

    test "rejects non-string values" do
      invalid_values = [nil, 123, :atom, [], %{}, true, false]

      for value <- invalid_values do
        assert {:error, [message: "must be a valid URL string"]} = Location.cast(value)
      end
    end
  end

  describe "load/1" do
    test "loads valid binary URL values" do
      urls = [
        "https://example.com",
        "http://www.example.com/path",
        "https://api.example.com:8443/v1"
      ]

      for url <- urls do
        assert {:ok, ^url} = Location.load(url)
      end
    end

    test "rejects non-binary values" do
      invalid_values = [nil, 123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = Location.load(value)
      end
    end
  end

  describe "dump/1" do
    test "dumps valid binary URL values" do
      urls = [
        "https://example.com",
        "http://www.example.com/path",
        "https://api.example.com:8443/v1"
      ]

      for url <- urls do
        assert {:ok, ^url} = Location.dump(url)
      end
    end

    test "rejects non-binary values" do
      invalid_values = [nil, 123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = Location.dump(value)
      end
    end
  end

  describe "embed_as/1" do
    test "returns :self for any format" do
      assert Location.embed_as(:json) == :self
      assert Location.embed_as(:anything) == :self
    end
  end

  describe "equal?/2" do
    test "returns true for equal URLs" do
      assert Location.equal?("https://example.com", "https://example.com") == true
      assert Location.equal?("http://test.com/path", "http://test.com/path") == true
    end

    test "returns false for different URLs" do
      assert Location.equal?("https://example.com", "http://example.com") == false
      assert Location.equal?("https://example.com/path1", "https://example.com/path2") == false
    end

    test "handles different types" do
      assert Location.equal?("https://example.com", 123) == false
      assert Location.equal?(nil, "https://example.com") == false
    end
  end

  describe "valid?/1" do
    test "returns true for valid HTTP URLs" do
      valid_urls = [
        "http://example.com",
        "http://www.example.com/path",
        "http://example.com:8080/api"
      ]

      for url <- valid_urls do
        assert Location.valid?(url) == true
      end
    end

    test "returns true for valid HTTPS URLs" do
      valid_urls = [
        "https://example.com",
        "https://secure.example.com/path",
        "https://api.example.com:443/v1"
      ]

      for url <- valid_urls do
        assert Location.valid?(url) == true
      end
    end

    test "returns false for invalid URLs" do
      invalid_values = [
        "ftp://example.com",
        "not-a-url",
        "example.com",
        "",
        nil,
        123,
        :atom,
        "http://",
        "https://"
      ]

      for value <- invalid_values do
        assert Location.valid?(value) == false
      end
    end
  end

  describe "URL parsing edge cases" do
    test "validates URLs with ports" do
      assert Location.valid?("http://example.com:80") == true
      assert Location.valid?("https://example.com:443") == true
      assert Location.valid?("http://example.com:8080") == true
    end

    test "validates URLs with paths and query parameters" do
      assert Location.valid?("https://example.com/path/to/resource") == true
      assert Location.valid?("https://example.com/path?query=value&other=param") == true
      assert Location.valid?("https://example.com/path#fragment") == true
    end

    test "validates URLs with subdomains" do
      assert Location.valid?("https://api.example.com") == true
      assert Location.valid?("https://sub.domain.example.com") == true
      assert Location.valid?("https://deep.nested.sub.example.com") == true
    end

    test "validates international domain names" do
      assert Location.valid?("https://example.co.uk") == true
      assert Location.valid?("https://example.com.au") == true
    end

    test "rejects URLs missing host" do
      assert Location.valid?("http:///path") == false
      assert Location.valid?("https:///path") == false
    end
  end

  describe "integration with Ecto.Type behaviour" do
    test "implements all required callbacks" do
      behaviours = Location.__info__(:attributes)[:behaviour] || []
      assert Ecto.Type in behaviours
    end

    test "cast -> dump -> load round trip" do
      original = "https://example.com/path"

      assert {:ok, casted} = Location.cast(original)
      assert {:ok, dumped} = Location.dump(casted)
      assert {:ok, loaded} = Location.load(dumped)

      assert loaded == original
    end
  end
end
