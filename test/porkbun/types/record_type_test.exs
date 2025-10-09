defmodule Porkbun.Types.RecordTypeTest do
  use ExUnit.Case
  doctest Porkbun.Types.RecordType

  alias Porkbun.Types.RecordType

  describe "type/0" do
    test "returns :string" do
      assert RecordType.type() == :string
    end
  end

  describe "cast/1" do
    test "casts lowercase atoms to uppercase binaries" do
      lowercase_atoms = [
        :a,
        :aaaa,
        :cname,
        :alias,
        :mx,
        :txt,
        :srv,
        :ns,
        :caa,
        :tlsa,
        :https,
        :svcb
      ]

      expected_binaries = [
        "A",
        "AAAA",
        "CNAME",
        "ALIAS",
        "MX",
        "TXT",
        "SRV",
        "NS",
        "CAA",
        "TLSA",
        "HTTPS",
        "SVCB"
      ]

      for {atom, expected} <- Enum.zip(lowercase_atoms, expected_binaries) do
        assert {:ok, ^expected} = RecordType.cast(atom)
      end
    end

    test "casts uppercase atoms to uppercase binaries" do
      uppercase_atoms = [
        :A,
        :AAAA,
        :CNAME,
        :ALIAS,
        :MX,
        :TXT,
        :SRV,
        :NS,
        :CAA,
        :TLSA,
        :HTTPS,
        :SVCB
      ]

      expected_binaries = [
        "A",
        "AAAA",
        "CNAME",
        "ALIAS",
        "MX",
        "TXT",
        "SRV",
        "NS",
        "CAA",
        "TLSA",
        "HTTPS",
        "SVCB"
      ]

      for {atom, expected} <- Enum.zip(uppercase_atoms, expected_binaries) do
        assert {:ok, ^expected} = RecordType.cast(atom)
      end
    end

    test "casts lowercase binary strings to uppercase" do
      lowercase_strings = [
        "a",
        "aaaa",
        "cname",
        "alias",
        "mx",
        "txt",
        "srv",
        "ns",
        "caa",
        "tlsa",
        "https",
        "svcb"
      ]

      expected_binaries = [
        "A",
        "AAAA",
        "CNAME",
        "ALIAS",
        "MX",
        "TXT",
        "SRV",
        "NS",
        "CAA",
        "TLSA",
        "HTTPS",
        "SVCB"
      ]

      for {string, expected} <- Enum.zip(lowercase_strings, expected_binaries) do
        assert {:ok, ^expected} = RecordType.cast(string)
      end
    end

    test "preserves uppercase binary strings" do
      uppercase_strings = [
        "A",
        "AAAA",
        "CNAME",
        "ALIAS",
        "MX",
        "TXT",
        "SRV",
        "NS",
        "CAA",
        "TLSA",
        "HTTPS",
        "SVCB"
      ]

      for string <- uppercase_strings do
        assert {:ok, ^string} = RecordType.cast(string)
      end
    end

    test "rejects invalid record types" do
      invalid_types = [
        :invalid,
        "INVALID",
        "unknown",
        :ptr,
        "PTR",
        nil,
        123,
        [],
        %{},
        true,
        false
      ]

      for invalid_type <- invalid_types do
        assert {:error,
                [
                  message:
                    "must be one of: A, AAAA, CNAME, ALIAS, MX, TXT, SRV, NS, CAA, TLSA, HTTPS, SVCB"
                ]} =
                 RecordType.cast(invalid_type)
      end
    end
  end

  describe "load/1" do
    test "loads uppercase binary strings" do
      uppercase_strings = [
        "A",
        "AAAA",
        "CNAME",
        "ALIAS",
        "MX",
        "TXT",
        "SRV",
        "NS",
        "CAA",
        "TLSA",
        "HTTPS",
        "SVCB"
      ]

      for string <- uppercase_strings do
        assert {:ok, ^string} = RecordType.load(string)
      end
    end

    test "loads lowercase binary strings to uppercase" do
      test_cases = [
        {"a", "A"},
        {"aaaa", "AAAA"},
        {"cname", "CNAME"},
        {"mx", "MX"},
        {"txt", "TXT"}
      ]

      for {lowercase, expected} <- test_cases do
        assert {:ok, ^expected} = RecordType.load(lowercase)
      end
    end

    test "rejects invalid binary strings" do
      invalid_strings = ["invalid", "unknown", "ptr", ""]

      for string <- invalid_strings do
        assert :error = RecordType.load(string)
      end
    end

    test "rejects non-binary values" do
      invalid_values = [nil, 123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = RecordType.load(value)
      end
    end
  end

  describe "dump/1" do
    test "dumps uppercase binary strings" do
      uppercase_strings = [
        "A",
        "AAAA",
        "CNAME",
        "ALIAS",
        "MX",
        "TXT",
        "SRV",
        "NS",
        "CAA",
        "TLSA",
        "HTTPS",
        "SVCB"
      ]

      for string <- uppercase_strings do
        assert {:ok, ^string} = RecordType.dump(string)
      end
    end

    test "rejects lowercase binary strings" do
      lowercase_strings = ["a", "aaaa", "cname", "mx"]

      for string <- lowercase_strings do
        assert :error = RecordType.dump(string)
      end
    end

    test "rejects invalid values" do
      invalid_values = ["INVALID", nil, 123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = RecordType.dump(value)
      end
    end
  end

  describe "embed_as/1" do
    test "returns :self for any format" do
      assert RecordType.embed_as(:json) == :self
      assert RecordType.embed_as(:anything) == :self
    end
  end

  describe "equal?/2" do
    test "returns true for case-insensitive binary equality" do
      test_cases = [
        {"A", "a"},
        {"AAAA", "aaaa"},
        {"CNAME", "cname"},
        {"MX", "mx"},
        {"A", "A"},
        {"CNAME", "CNAME"}
      ]

      for {val1, val2} <- test_cases do
        assert RecordType.equal?(val1, val2) == true
        assert RecordType.equal?(val2, val1) == true
      end
    end

    test "returns true for atom-binary case-insensitive equality" do
      test_cases = [
        {:a, "A"},
        {:A, "a"},
        {:cname, "CNAME"},
        {:CNAME, "cname"},
        {"A", :a},
        {"a", :A}
      ]

      for {val1, val2} <- test_cases do
        assert RecordType.equal?(val1, val2) == true
        assert RecordType.equal?(val2, val1) == true
      end
    end

    test "returns true for atom-atom case-insensitive equality" do
      test_cases = [
        {:a, :A},
        {:A, :a},
        {:cname, :CNAME},
        {:CNAME, :cname}
      ]

      for {val1, val2} <- test_cases do
        assert RecordType.equal?(val1, val2) == true
        assert RecordType.equal?(val2, val1) == true
      end
    end

    test "returns false for different record types" do
      assert RecordType.equal?("A", "AAAA") == false
      assert RecordType.equal?("CNAME", "MX") == false
      assert RecordType.equal?(:a, :mx) == false
    end

    test "returns false for non-comparable types" do
      assert RecordType.equal?("A", 123) == false
      assert RecordType.equal?(nil, "A") == false
      assert RecordType.equal?([], "CNAME") == false
    end
  end

  describe "types/0" do
    test "returns list of atom-string tuples" do
      types = RecordType.types()

      # Check that it returns the expected format
      assert is_list(types)
      assert length(types) == 12

      # Check some expected entries
      assert {:a, "a"} in types
      assert {:aaaa, "aaaa"} in types
      assert {:cname, "cname"} in types
      assert {:mx, "mx"} in types
    end

    test "all types in list are valid for casting" do
      types = RecordType.types()

      for {atom, _string} <- types do
        assert {:ok, _result} = RecordType.cast(atom)
      end
    end
  end

  describe "case handling edge cases" do
    test "handles mixed case strings" do
      mixed_cases = [
        {"CnAmE", "CNAME"},
        {"aAaA", "AAAA"},
        {"Mx", "MX"},
        # This should fail since TTL is not in our list
        {"tTl", "TTL"}
      ]

      for {input, expected} <- mixed_cases do
        case expected do
          "TTL" ->
            # TTL is not a valid record type in our list
            assert {:error, _} = RecordType.cast(input)

          _ ->
            # These should work
            if input in ["CnAmE", "aAaA", "Mx"] do
              assert {:ok, ^expected} = RecordType.cast(input)
            end
        end
      end
    end

    test "rejects empty string" do
      assert {:error, _} = RecordType.cast("")
    end
  end

  describe "integration with Ecto.Type behaviour" do
    test "implements all required callbacks" do
      behaviours = RecordType.__info__(:attributes)[:behaviour] || []
      assert Ecto.Type in behaviours
    end

    test "cast -> dump -> load round trip with atom" do
      original = :a
      expected_final = "A"

      assert {:ok, casted} = RecordType.cast(original)
      assert casted == expected_final
      assert {:ok, dumped} = RecordType.dump(casted)
      assert dumped == expected_final
      assert {:ok, loaded} = RecordType.load(dumped)

      assert loaded == expected_final
    end

    test "cast -> dump -> load round trip with lowercase string" do
      original = "cname"
      expected_final = "CNAME"

      assert {:ok, casted} = RecordType.cast(original)
      assert casted == expected_final
      assert {:ok, dumped} = RecordType.dump(casted)
      assert dumped == expected_final
      assert {:ok, loaded} = RecordType.load(dumped)

      assert loaded == expected_final
    end

    test "cast -> dump -> load round trip with uppercase string" do
      original = "MX"

      assert {:ok, casted} = RecordType.cast(original)
      assert {:ok, dumped} = RecordType.dump(casted)
      assert {:ok, loaded} = RecordType.load(dumped)

      assert loaded == original
    end
  end
end
