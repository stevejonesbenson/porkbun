defmodule Porkbun.Types.PrioTest do
  use ExUnit.Case
  doctest Porkbun.Types.Prio

  alias Porkbun.Types.Prio

  describe "type/0" do
    test "returns :integer" do
      assert Prio.type() == :integer
    end
  end

  describe "cast/1" do
    test "casts valid non-negative integers" do
      valid_integers = [0, 1, 10, 100, 65_535]

      for value <- valid_integers do
        assert {:ok, ^value} = Prio.cast(value)
      end
    end

    test "casts nil to nil" do
      assert {:ok, nil} = Prio.cast(nil)
    end

    test "casts valid string integers" do
      valid_strings = [
        {"0", 0},
        {"1", 1},
        {"10", 10},
        {"100", 100},
        {"65535", 65_535}
      ]

      for {string_val, expected} <- valid_strings do
        assert {:ok, ^expected} = Prio.cast(string_val)
      end
    end

    test "rejects negative integers" do
      negative_values = [-1, -10, -100]

      for value <- negative_values do
        assert {:error, _} = Prio.cast(value)
      end
    end

    test "rejects negative string integers" do
      negative_strings = ["-1", "-10", "-100"]

      for value <- negative_strings do
        assert {:error, _} = Prio.cast(value)
      end
    end

    test "rejects invalid string values" do
      invalid_strings = ["not_a_number", "10.5", "abc", "", "10a", "a10"]

      for value <- invalid_strings do
        assert {:error, _} = Prio.cast(value)
      end
    end

    test "rejects non-integer, non-string, non-nil values" do
      invalid_values = [10.5, :atom, [], %{}, true, false]

      for value <- invalid_values do
        assert {:error, _} = Prio.cast(value)
      end
    end
  end

  describe "load/1" do
    test "loads valid non-negative integers" do
      valid_integers = [0, 1, 10, 100, 65_535]

      for value <- valid_integers do
        assert {:ok, ^value} = Prio.load(value)
      end
    end

    test "loads nil as nil" do
      assert {:ok, nil} = Prio.load(nil)
    end

    test "rejects negative integers" do
      negative_values = [-1, -10, -100]

      for value <- negative_values do
        assert :error = Prio.load(value)
      end
    end

    test "rejects non-integer, non-nil values" do
      invalid_values = ["10", 10.5, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = Prio.load(value)
      end
    end
  end

  describe "dump/1" do
    test "dumps valid non-negative integers" do
      valid_integers = [0, 1, 10, 100, 65_535]

      for value <- valid_integers do
        assert {:ok, ^value} = Prio.dump(value)
      end
    end

    test "dumps nil as nil" do
      assert {:ok, nil} = Prio.dump(nil)
    end

    test "rejects negative integers" do
      negative_values = [-1, -10, -100]

      for value <- negative_values do
        assert :error = Prio.dump(value)
      end
    end

    test "rejects non-integer, non-nil values" do
      invalid_values = ["10", 10.5, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = Prio.dump(value)
      end
    end
  end

  describe "embed_as/1" do
    test "returns :self for any format" do
      assert Prio.embed_as(:json) == :self
      assert Prio.embed_as(:anything) == :self
    end
  end

  describe "equal?/2" do
    test "returns true for equal integers" do
      assert Prio.equal?(10, 10) == true
      assert Prio.equal?(0, 0) == true
      assert Prio.equal?(nil, nil) == true
    end

    test "returns false for different integers" do
      assert Prio.equal?(10, 20) == false
      assert Prio.equal?(0, 1) == false
    end

    test "handles different types" do
      assert Prio.equal?(10, "10") == false
      assert Prio.equal?(nil, 0) == false
      assert Prio.equal?(10, nil) == false
    end
  end

  describe "valid?/1" do
    test "returns true for valid non-negative integers" do
      valid_values = [0, 1, 10, 100, 65_535]

      for value <- valid_values do
        assert Prio.valid?(value) == true
      end
    end

    test "returns true for nil" do
      assert Prio.valid?(nil) == true
    end

    test "returns false for negative integers" do
      negative_values = [-1, -10, -100]

      for value <- negative_values do
        assert Prio.valid?(value) == false
      end
    end

    test "returns false for non-integer, non-nil values" do
      invalid_values = ["10", 10.5, :atom, [], %{}, true, false, ""]

      for value <- invalid_values do
        assert Prio.valid?(value) == false
      end
    end
  end

  describe "required_for_type?/1" do
    test "returns true for record types that require priority" do
      required_types = [:mx, :srv, :https, :svcb]

      for type <- required_types do
        assert Prio.required_for_type?(type) == true
      end
    end

    test "returns false for record types that don't require priority" do
      non_required_types = [:a, :aaaa, :cname, :alias, :txt, :ns, :caa, :tlsa]

      for type <- non_required_types do
        assert Prio.required_for_type?(type) == false
      end
    end

    test "returns false for unknown record types" do
      unknown_types = [:unknown, :custom, :other]

      for type <- unknown_types do
        assert Prio.required_for_type?(type) == false
      end
    end
  end

  describe "priority validation boundaries" do
    test "accepts zero priority" do
      assert {:ok, 0} = Prio.cast(0)
      assert Prio.valid?(0) == true
    end

    test "accepts large valid priorities" do
      large_values = [32_767, 65_535, 100_000]

      for value <- large_values do
        assert {:ok, ^value} = Prio.cast(value)
        assert Prio.valid?(value) == true
      end
    end

    test "handles string conversion edge cases" do
      assert {:ok, 0} = Prio.cast("0")
      assert {:ok, 65_535} = Prio.cast("65535")
      assert {:error, _} = Prio.cast("00")
      assert {:error, _} = Prio.cast(" 10 ")
    end
  end

  describe "integration with Ecto.Type behaviour" do
    test "implements all required callbacks" do
      behaviours = Prio.__info__(:attributes)[:behaviour] || []
      assert Ecto.Type in behaviours
    end

    test "cast -> dump -> load round trip with integer" do
      original = 10

      assert {:ok, casted} = Prio.cast(original)
      assert {:ok, dumped} = Prio.dump(casted)
      assert {:ok, loaded} = Prio.load(dumped)

      assert loaded == original
    end

    test "cast -> dump -> load round trip with nil" do
      original = nil

      assert {:ok, casted} = Prio.cast(original)
      assert {:ok, dumped} = Prio.dump(casted)
      assert {:ok, loaded} = Prio.load(dumped)

      assert loaded == original
    end

    test "string cast -> dump -> load round trip" do
      original_string = "20"
      expected_integer = 20

      assert {:ok, casted} = Prio.cast(original_string)
      assert casted == expected_integer
      assert {:ok, dumped} = Prio.dump(casted)
      assert dumped == expected_integer
      assert {:ok, loaded} = Prio.load(dumped)

      assert loaded == expected_integer
    end
  end
end
