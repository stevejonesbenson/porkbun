defmodule Porkbun.Types.YesNoTest do
  use ExUnit.Case
  doctest Porkbun.Types.YesNo

  alias Porkbun.Types.YesNo

  describe "type/0" do
    test "returns :string" do
      assert YesNo.type() == :string
    end
  end

  describe "cast/1" do
    test "casts boolean values" do
      assert {:ok, true} = YesNo.cast(true)
      assert {:ok, false} = YesNo.cast(false)
    end

    test "casts yes/no strings to booleans" do
      assert {:ok, true} = YesNo.cast("yes")
      assert {:ok, false} = YesNo.cast("no")
    end

    test "rejects invalid string values" do
      invalid_strings = ["true", "false", "YES", "NO", "y", "n", "1", "0", "", "maybe"]

      for value <- invalid_strings do
        assert {:error, [message: "must be true, false, 'yes', or 'no'"]} = YesNo.cast(value)
      end
    end

    test "rejects non-boolean, non-string values" do
      invalid_values = [nil, 1, 0, :yes, :no, [], %{}, :atom]

      for value <- invalid_values do
        assert {:error, [message: "must be true, false, 'yes', or 'no'"]} = YesNo.cast(value)
      end
    end
  end

  describe "load/1" do
    test "loads yes string to true" do
      assert {:ok, true} = YesNo.load("yes")
    end

    test "loads no string to false" do
      assert {:ok, false} = YesNo.load("no")
    end

    test "rejects invalid string values" do
      invalid_strings = ["true", "false", "YES", "NO", "y", "n", "1", "0", "", "maybe"]

      for value <- invalid_strings do
        assert :error = YesNo.load(value)
      end
    end

    test "rejects non-string values" do
      invalid_values = [nil, true, false, 123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = YesNo.load(value)
      end
    end
  end

  describe "dump/1" do
    test "dumps true to yes string" do
      assert {:ok, "yes"} = YesNo.dump(true)
    end

    test "dumps false to no string" do
      assert {:ok, "no"} = YesNo.dump(false)
    end

    test "rejects non-boolean values" do
      invalid_values = [nil, "yes", "no", 1, 0, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = YesNo.dump(value)
      end
    end
  end

  describe "embed_as/1" do
    test "returns :self for any format" do
      assert YesNo.embed_as(:json) == :self
      assert YesNo.embed_as(:anything) == :self
    end
  end

  describe "equal?/2" do
    test "returns true for equal boolean values" do
      assert YesNo.equal?(true, true) == true
      assert YesNo.equal?(false, false) == true
    end

    test "returns false for different boolean values" do
      assert YesNo.equal?(true, false) == false
      assert YesNo.equal?(false, true) == false
    end

    test "handles different types" do
      assert YesNo.equal?(true, "yes") == false
      assert YesNo.equal?(false, "no") == false
      assert YesNo.equal?(nil, true) == false
      assert YesNo.equal?(true, nil) == false
    end
  end

  describe "valid?/1" do
    test "returns true for boolean values" do
      assert YesNo.valid?(true) == true
      assert YesNo.valid?(false) == true
    end

    test "returns true for yes/no strings" do
      assert YesNo.valid?("yes") == true
      assert YesNo.valid?("no") == true
    end

    test "returns false for invalid string values" do
      invalid_strings = ["true", "false", "YES", "NO", "y", "n", "1", "0", "", "maybe"]

      for value <- invalid_strings do
        assert YesNo.valid?(value) == false
      end
    end

    test "returns false for non-boolean, non-string values" do
      invalid_values = [nil, 1, 0, :yes, :no, [], %{}, :atom]

      for value <- invalid_values do
        assert YesNo.valid?(value) == false
      end
    end
  end

  describe "API consistency" do
    test "cast and valid return consistent results for valid values" do
      valid_values = [true, false, "yes", "no"]

      for value <- valid_values do
        assert YesNo.valid?(value) == true
        assert {:ok, _result} = YesNo.cast(value)
      end
    end

    test "cast and valid return consistent results for invalid values" do
      invalid_values = ["true", "false", "YES", "NO", nil, 1, 0, :atom]

      for value <- invalid_values do
        assert YesNo.valid?(value) == false
        assert {:error, _message} = YesNo.cast(value)
      end
    end
  end

  describe "integration with Ecto.Type behaviour" do
    test "implements all required callbacks" do
      behaviours = YesNo.__info__(:attributes)[:behaviour] || []
      assert Ecto.Type in behaviours
    end

    test "cast -> dump -> load round trip with true" do
      original = true

      assert {:ok, casted} = YesNo.cast(original)
      assert casted == true
      assert {:ok, dumped} = YesNo.dump(casted)
      assert dumped == "yes"
      assert {:ok, loaded} = YesNo.load(dumped)

      assert loaded == original
    end

    test "cast -> dump -> load round trip with false" do
      original = false

      assert {:ok, casted} = YesNo.cast(original)
      assert casted == false
      assert {:ok, dumped} = YesNo.dump(casted)
      assert dumped == "no"
      assert {:ok, loaded} = YesNo.load(dumped)

      assert loaded == original
    end

    test "string cast -> dump -> load round trip with yes" do
      original_string = "yes"
      expected_boolean = true
      expected_dump = "yes"

      assert {:ok, casted} = YesNo.cast(original_string)
      assert casted == expected_boolean
      assert {:ok, dumped} = YesNo.dump(casted)
      assert dumped == expected_dump
      assert {:ok, loaded} = YesNo.load(dumped)

      assert loaded == expected_boolean
    end

    test "string cast -> dump -> load round trip with no" do
      original_string = "no"
      expected_boolean = false
      expected_dump = "no"

      assert {:ok, casted} = YesNo.cast(original_string)
      assert casted == expected_boolean
      assert {:ok, dumped} = YesNo.dump(casted)
      assert dumped == expected_dump
      assert {:ok, loaded} = YesNo.load(dumped)

      assert loaded == expected_boolean
    end
  end

  describe "edge cases and error handling" do
    test "handles case sensitivity strictly" do
      # Only lowercase "yes" and "no" should work
      assert YesNo.valid?("yes") == true
      assert YesNo.valid?("no") == true
      assert YesNo.valid?("YES") == false
      assert YesNo.valid?("NO") == false
      assert YesNo.valid?("Yes") == false
      assert YesNo.valid?("No") == false
    end

    test "handles whitespace strictly" do
      # No whitespace should be allowed
      assert YesNo.valid?(" yes") == false
      assert YesNo.valid?("yes ") == false
      assert YesNo.valid?(" yes ") == false
      assert YesNo.valid?(" no") == false
      assert YesNo.valid?("no ") == false
      assert YesNo.valid?(" no ") == false
    end

    test "rejects common boolean representations" do
      # Common boolean representations that should be rejected
      common_booleans = ["true", "false", "TRUE", "FALSE", "1", "0", "t", "f", "T", "F"]

      for value <- common_booleans do
        assert YesNo.valid?(value) == false
        assert {:error, _} = YesNo.cast(value)
      end
    end
  end
end
