defmodule Porkbun.Types.ForwardTypeTest do
  use ExUnit.Case
  doctest Porkbun.Types.ForwardType

  alias Porkbun.Types.ForwardType

  describe "type/0" do
    test "returns :string" do
      assert ForwardType.type() == :string
    end
  end

  describe "cast/1" do
    test "casts valid atom values" do
      assert {:ok, :temporary} = ForwardType.cast(:temporary)
      assert {:ok, :permanent} = ForwardType.cast(:permanent)
    end

    test "casts valid string values" do
      assert {:ok, :temporary} = ForwardType.cast("temporary")
      assert {:ok, :permanent} = ForwardType.cast("permanent")
    end

    test "rejects invalid values" do
      invalid_values = [:invalid, "invalid", nil, 123, [], %{}, true, false]

      for value <- invalid_values do
        assert {:error, [message: "must be either 'temporary' or 'permanent'"]} =
                 ForwardType.cast(value)
      end
    end
  end

  describe "load/1" do
    test "loads valid string values to atoms" do
      assert {:ok, :temporary} = ForwardType.load("temporary")
      assert {:ok, :permanent} = ForwardType.load("permanent")
    end

    test "rejects invalid string values" do
      invalid_values = ["invalid", "", nil, 123, :temporary]

      for value <- invalid_values do
        assert :error = ForwardType.load(value)
      end
    end
  end

  describe "dump/1" do
    test "dumps valid atom values to strings" do
      assert {:ok, "temporary"} = ForwardType.dump(:temporary)
      assert {:ok, "permanent"} = ForwardType.dump(:permanent)
    end

    test "rejects invalid atom values" do
      invalid_values = [:invalid, "temporary", nil, 123, []]

      for value <- invalid_values do
        assert :error = ForwardType.dump(value)
      end
    end
  end

  describe "embed_as/1" do
    test "returns :self for any format" do
      assert ForwardType.embed_as(:json) == :self
      assert ForwardType.embed_as(:anything) == :self
    end
  end

  describe "equal?/2" do
    test "returns true for equal values" do
      assert ForwardType.equal?(:temporary, :temporary) == true
      assert ForwardType.equal?(:permanent, :permanent) == true
    end

    test "returns false for different values" do
      assert ForwardType.equal?(:temporary, :permanent) == false
      assert ForwardType.equal?(:permanent, :temporary) == false
    end

    test "handles different types" do
      assert ForwardType.equal?(:temporary, "temporary") == false
      assert ForwardType.equal?(nil, :temporary) == false
    end
  end

  describe "valid_types/0" do
    test "returns the list of valid types" do
      expected = [:temporary, :permanent]
      assert ForwardType.valid_types() == expected
    end
  end

  describe "valid?/1" do
    test "returns true for valid atom values" do
      assert ForwardType.valid?(:temporary) == true
      assert ForwardType.valid?(:permanent) == true
    end

    test "returns true for valid string values" do
      assert ForwardType.valid?("temporary") == true
      assert ForwardType.valid?("permanent") == true
    end

    test "returns false for invalid values" do
      invalid_values = [:invalid, "invalid", nil, 123, [], %{}, true, false, ""]

      for value <- invalid_values do
        assert ForwardType.valid?(value) == false
      end
    end
  end

  describe "integration with Ecto.Type behaviour" do
    test "implements all required callbacks" do
      behaviours = ForwardType.__info__(:attributes)[:behaviour] || []
      assert Ecto.Type in behaviours
    end

    test "cast -> dump -> load round trip" do
      original = :temporary

      assert {:ok, casted} = ForwardType.cast(original)
      assert {:ok, dumped} = ForwardType.dump(casted)
      assert {:ok, loaded} = ForwardType.load(dumped)

      assert loaded == original
    end

    test "string cast -> dump -> load round trip" do
      original_string = "permanent"
      expected_atom = :permanent

      assert {:ok, casted} = ForwardType.cast(original_string)
      assert casted == expected_atom
      assert {:ok, dumped} = ForwardType.dump(casted)
      assert dumped == original_string
      assert {:ok, loaded} = ForwardType.load(dumped)

      assert loaded == expected_atom
    end
  end
end
