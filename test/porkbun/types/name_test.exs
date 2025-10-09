defmodule Porkbun.Types.NameTest do
  use ExUnit.Case
  doctest Porkbun.Types.Name

  alias Porkbun.Types.Name

  describe "type/0" do
    test "returns :string" do
      assert Name.type() == :string
    end
  end

  describe "cast/1" do
    test "casts valid subdomain names" do
      valid_names = [
        "www",
        "api",
        "mail",
        "subdomain",
        "test123",
        "my-subdomain",
        "a",
        "long-subdomain-name-with-many-characters"
      ]

      for name <- valid_names do
        assert {:ok, ^name} = Name.cast(name)
      end
    end

    test "casts nil to nil" do
      assert {:ok, nil} = Name.cast(nil)
    end

    test "casts empty string to nil" do
      assert {:ok, nil} = Name.cast("")
    end

    test "casts wildcard to wildcard" do
      assert {:ok, "*"} = Name.cast("*")
    end

    test "rejects names with dots" do
      invalid_names = [
        "sub.domain",
        "www.example.com",
        "api.v1",
        "test.sub.domain"
      ]

      for name <- invalid_names do
        assert {:error, [message: "must be a valid subdomain name"]} = Name.cast(name)
      end
    end

    test "rejects names that are too long" do
      long_name = String.duplicate("a", 64)
      assert {:error, [message: "must be a valid subdomain name"]} = Name.cast(long_name)
    end

    test "rejects names with invalid characters" do
      invalid_names = [
        "sub_domain",
        "subdomain!",
        "sub domain",
        "subdomain@",
        "subdomain#",
        "-subdomain",
        "subdomain-",
        "--invalid"
      ]

      for name <- invalid_names do
        assert {:error, [message: "must be a valid subdomain name"]} = Name.cast(name)
      end
    end

    test "rejects non-string, non-nil values" do
      invalid_values = [123, :atom, [], %{}, true, false]

      for value <- invalid_values do
        assert {:error, [message: "must be a string"]} = Name.cast(value)
      end
    end
  end

  describe "load/1" do
    test "loads valid binary names" do
      names = ["www", "api", "subdomain"]

      for name <- names do
        assert {:ok, ^name} = Name.load(name)
      end
    end

    test "loads empty string as nil" do
      assert {:ok, nil} = Name.load("")
    end

    test "loads nil as nil" do
      assert {:ok, nil} = Name.load(nil)
    end

    test "rejects non-binary, non-nil values" do
      invalid_values = [123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = Name.load(value)
      end
    end
  end

  describe "dump/1" do
    test "dumps valid binary names" do
      names = ["www", "api", "subdomain"]

      for name <- names do
        assert {:ok, ^name} = Name.dump(name)
      end
    end

    test "dumps nil as empty string" do
      assert {:ok, ""} = Name.dump(nil)
    end

    test "rejects non-binary, non-nil values" do
      invalid_values = [123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = Name.dump(value)
      end
    end
  end

  describe "embed_as/1" do
    test "returns :self for any format" do
      assert Name.embed_as(:json) == :self
      assert Name.embed_as(:anything) == :self
    end
  end

  describe "equal?/2" do
    test "returns true for equal names" do
      assert Name.equal?("www", "www") == true
      assert Name.equal?("api", "api") == true
    end

    test "returns true for empty string and nil" do
      assert Name.equal?("", nil) == true
      assert Name.equal?(nil, "") == true
    end

    test "returns true for nil and nil" do
      assert Name.equal?(nil, nil) == true
    end

    test "returns false for different names" do
      assert Name.equal?("www", "api") == false
      assert Name.equal?("subdomain", "other") == false
    end

    test "handles mixed types" do
      assert Name.equal?("www", 123) == false
      assert Name.equal?(123, "www") == false
    end
  end

  describe "valid?/1" do
    test "returns true for nil" do
      assert Name.valid?(nil) == true
    end

    test "returns true for empty string" do
      assert Name.valid?("") == true
    end

    test "returns true for wildcard" do
      assert Name.valid?("*") == true
    end

    test "returns true for valid subdomain names" do
      valid_names = [
        "www",
        "api",
        "mail",
        "subdomain",
        "test123",
        "my-subdomain",
        "a",
        "x-y-z"
      ]

      for name <- valid_names do
        assert Name.valid?(name) == true
      end
    end

    test "returns false for names with dots" do
      invalid_names = [
        "sub.domain",
        "www.example.com",
        "api.v1"
      ]

      for name <- invalid_names do
        assert Name.valid?(name) == false
      end
    end

    test "returns false for names that are too long" do
      long_name = String.duplicate("a", 64)
      assert Name.valid?(long_name) == false
    end

    test "returns false for names with invalid characters" do
      invalid_names = [
        "sub_domain",
        "subdomain!",
        "sub domain",
        "-subdomain",
        "subdomain-"
      ]

      for name <- invalid_names do
        assert Name.valid?(name) == false
      end
    end

    test "returns false for non-string, non-nil values" do
      invalid_values = [123, :atom, [], %{}, true, false]

      for value <- invalid_values do
        assert Name.valid?(value) == false
      end
    end
  end

  describe "subdomain validation rules" do
    test "allows single character names" do
      assert Name.valid?("a") == true
      assert Name.valid?("z") == true
      assert Name.valid?("1") == true
      assert Name.valid?("9") == true
    end

    test "allows names starting and ending with alphanumeric" do
      assert Name.valid?("a1") == true
      assert Name.valid?("1a") == true
      assert Name.valid?("test1") == true
      assert Name.valid?("1test") == true
    end

    test "allows hyphens in the middle" do
      assert Name.valid?("sub-domain") == true
      assert Name.valid?("api-v1") == true
      assert Name.valid?("test-123") == true
      assert Name.valid?("a-b-c-d") == true
    end

    test "rejects names starting with hyphen" do
      assert Name.valid?("-subdomain") == false
      assert Name.valid?("-test") == false
    end

    test "rejects names ending with hyphen" do
      assert Name.valid?("subdomain-") == false
      assert Name.valid?("test-") == false
    end

    test "validates maximum length (63 characters)" do
      valid_63_chars = String.duplicate("a", 63)
      invalid_64_chars = String.duplicate("a", 64)

      assert Name.valid?(valid_63_chars) == true
      assert Name.valid?(invalid_64_chars) == false
    end
  end

  describe "integration with Ecto.Type behaviour" do
    test "implements all required callbacks" do
      behaviours = Name.__info__(:attributes)[:behaviour] || []
      assert Ecto.Type in behaviours
    end

    test "cast -> dump -> load round trip with valid name" do
      original = "www"

      assert {:ok, casted} = Name.cast(original)
      assert {:ok, dumped} = Name.dump(casted)
      assert {:ok, loaded} = Name.load(dumped)

      assert loaded == original
    end

    test "cast -> dump -> load round trip with nil" do
      original = nil

      assert {:ok, casted} = Name.cast(original)
      assert {:ok, dumped} = Name.dump(casted)
      assert {:ok, loaded} = Name.load(dumped)

      assert loaded == original
    end

    test "cast -> dump -> load round trip with empty string" do
      original = ""

      assert {:ok, casted} = Name.cast(original)
      assert casted == nil
      assert {:ok, dumped} = Name.dump(casted)
      assert dumped == ""
      assert {:ok, loaded} = Name.load(dumped)

      assert loaded == nil
    end
  end
end
