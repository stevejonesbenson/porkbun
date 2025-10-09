defmodule Porkbun.Types.TTLTest do
  use ExUnit.Case
  doctest Porkbun.Types.TTL

  alias Porkbun.Types.TTL

  describe "type/0" do
    test "returns :integer" do
      assert TTL.type() == :integer
    end
  end

  describe "cast/1" do
    test "casts valid integers above minimum" do
      valid_integers = [600, 700, 1000, 3600, 86400]

      for value <- valid_integers do
        assert {:ok, ^value} = TTL.cast(value)
      end
    end

    test "casts integers below minimum to minimum" do
      below_minimum = [0, 1, 100, 599]
      minimum = TTL.minimum()

      for value <- below_minimum do
        assert {:ok, ^minimum} = TTL.cast(value)
      end
    end

    test "casts nil to nil" do
      assert {:ok, nil} = TTL.cast(nil)
    end

    test "casts valid string integers" do
      valid_string_cases = [
        {"600", 600},
        {"1000", 1000},
        {"3600", 3600}
      ]

      for {string_val, expected} <- valid_string_cases do
        assert {:ok, ^expected} = TTL.cast(string_val)
      end
    end

    test "casts string integers below minimum to minimum" do
      below_minimum_strings = ["0", "100", "599"]
      minimum = TTL.minimum()

      for value <- below_minimum_strings do
        assert {:ok, ^minimum} = TTL.cast(value)
      end
    end

    test "rejects invalid string values" do
      invalid_strings = ["not_a_number", "600.5", "abc", "", "600a", "a600", " 600 "]

      for value <- invalid_strings do
        assert :error = TTL.cast(value)
      end
    end

    test "rejects non-integer, non-string, non-nil values" do
      invalid_values = [600.5, :atom, [], %{}, true, false]

      for value <- invalid_values do
        assert :error = TTL.cast(value)
      end
    end
  end

  describe "load/1" do
    test "loads valid integers above minimum" do
      valid_integers = [600, 700, 1000, 3600]

      for value <- valid_integers do
        assert {:ok, ^value} = TTL.load(value)
      end
    end

    test "loads integers below minimum to minimum" do
      below_minimum = [0, 1, 100, 599]
      minimum = TTL.minimum()

      for value <- below_minimum do
        assert {:ok, ^minimum} = TTL.load(value)
      end
    end

    test "loads nil as nil" do
      assert {:ok, nil} = TTL.load(nil)
    end

    test "rejects non-integer, non-nil values" do
      invalid_values = ["600", 600.5, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = TTL.load(value)
      end
    end
  end

  describe "dump/1" do
    test "dumps valid integers above minimum" do
      valid_integers = [600, 700, 1000, 3600]

      for value <- valid_integers do
        assert {:ok, ^value} = TTL.dump(value)
      end
    end

    test "dumps integers below minimum to minimum" do
      below_minimum = [0, 1, 100, 599]
      minimum = TTL.minimum()

      for value <- below_minimum do
        assert {:ok, ^minimum} = TTL.dump(value)
      end
    end

    test "dumps nil as default" do
      default = TTL.default()
      assert {:ok, ^default} = TTL.dump(nil)
    end

    test "rejects non-integer, non-nil values" do
      invalid_values = ["600", 600.5, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = TTL.dump(value)
      end
    end
  end

  describe "embed_as/1" do
    test "returns :self for any format" do
      assert TTL.embed_as(:json) == :self
      assert TTL.embed_as(:anything) == :self
    end
  end

  describe "equal?/2" do
    test "returns true for equal integers" do
      assert TTL.equal?(600, 600) == true
      assert TTL.equal?(3600, 3600) == true
      assert TTL.equal?(nil, nil) == true
    end

    test "returns false for different integers" do
      assert TTL.equal?(600, 700) == false
      assert TTL.equal?(3600, 7200) == false
    end

    test "handles different types" do
      assert TTL.equal?(600, "600") == false
      assert TTL.equal?(nil, 600) == false
      assert TTL.equal?(600, nil) == false
    end
  end

  describe "minimum/0" do
    test "returns the minimum TTL value" do
      assert TTL.minimum() == 600
    end
  end

  describe "default/0" do
    test "returns the default TTL value" do
      assert TTL.default() == 600
    end
  end

  describe "valid?/1" do
    test "returns true for valid integers above minimum" do
      valid_values = [600, 700, 1000, 3600, 86400]

      for value <- valid_values do
        assert TTL.valid?(value) == true
      end
    end

    test "returns false for integers below minimum" do
      below_minimum = [0, 1, 100, 599]

      for value <- below_minimum do
        assert TTL.valid?(value) == false
      end
    end

    test "returns true for nil" do
      assert TTL.valid?(nil) == true
    end

    test "returns false for non-integer, non-nil values" do
      invalid_values = ["600", 600.5, :atom, [], %{}, true, false, ""]

      for value <- invalid_values do
        assert TTL.valid?(value) == false
      end
    end
  end

  describe "TTL boundary conditions" do
    test "minimum value boundary" do
      minimum = TTL.minimum()

      # Exactly at minimum should be valid
      assert TTL.valid?(minimum) == true
      assert {:ok, ^minimum} = TTL.cast(minimum)

      # One below minimum should be invalid but cast to minimum
      below_minimum = minimum - 1
      assert TTL.valid?(below_minimum) == false
      assert {:ok, ^minimum} = TTL.cast(below_minimum)
    end

    test "large TTL values" do
      # 1 day, 1 week, 30 days
      large_values = [86400, 604_800, 2_592_000]

      for value <- large_values do
        assert TTL.valid?(value) == true
        assert {:ok, ^value} = TTL.cast(value)
      end
    end

    test "string conversion with minimum enforcement" do
      test_cases = [
        {"0", 600},
        {"300", 600},
        {"600", 600},
        {"700", 700},
        {"3600", 3600}
      ]

      for {string_val, expected} <- test_cases do
        assert {:ok, ^expected} = TTL.cast(string_val)
      end
    end
  end

  describe "integration with Ecto.Type behaviour" do
    test "implements all required callbacks" do
      behaviours = TTL.__info__(:attributes)[:behaviour] || []
      assert Ecto.Type in behaviours
    end

    test "cast -> dump -> load round trip with valid TTL" do
      original = 3600

      assert {:ok, casted} = TTL.cast(original)
      assert {:ok, dumped} = TTL.dump(casted)
      assert {:ok, loaded} = TTL.load(dumped)

      assert loaded == original
    end

    test "cast -> dump -> load round trip with nil" do
      original = nil
      default = TTL.default()

      assert {:ok, casted} = TTL.cast(original)
      assert casted == nil
      assert {:ok, dumped} = TTL.dump(casted)
      assert dumped == default
      assert {:ok, loaded} = TTL.load(dumped)

      assert loaded == default
    end

    test "cast -> dump -> load round trip with below minimum value" do
      original = 300
      minimum = TTL.minimum()

      assert {:ok, casted} = TTL.cast(original)
      assert casted == minimum
      assert {:ok, dumped} = TTL.dump(casted)
      assert dumped == minimum
      assert {:ok, loaded} = TTL.load(dumped)

      assert loaded == minimum
    end

    test "string cast -> dump -> load round trip" do
      original_string = "7200"
      expected_integer = 7200

      assert {:ok, casted} = TTL.cast(original_string)
      assert casted == expected_integer
      assert {:ok, dumped} = TTL.dump(casted)
      assert dumped == expected_integer
      assert {:ok, loaded} = TTL.load(dumped)

      assert loaded == expected_integer
    end
  end
end
