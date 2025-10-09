defmodule Porkbun.Types.AlgorithmTest do
  use ExUnit.Case
  doctest Porkbun.Types.Algorithm

  alias Porkbun.Types.Algorithm

  describe "type/0" do
    test "returns :string" do
      assert Algorithm.type() == :string
    end
  end

  describe "cast/1" do
    test "casts valid algorithm strings" do
      valid_algorithms = ["3", "5", "6", "7", "8", "10", "12", "13", "14", "15", "16"]

      for algorithm <- valid_algorithms do
        assert {:ok, ^algorithm} = Algorithm.cast(algorithm)
      end
    end

    test "casts valid algorithm integers" do
      valid_integers = [3, 5, 6, 7, 8, 10, 12, 13, 14, 15, 16]

      for algorithm <- valid_integers do
        expected = Integer.to_string(algorithm)
        assert {:ok, ^expected} = Algorithm.cast(algorithm)
      end
    end

    test "rejects invalid algorithm strings" do
      invalid_algorithms = ["0", "1", "2", "4", "9", "11", "99", "abc", ""]

      for algorithm <- invalid_algorithms do
        assert {:error, [message: "must be a valid DNSSEC algorithm"]} = Algorithm.cast(algorithm)
      end
    end

    test "rejects invalid algorithm integers" do
      invalid_integers = [0, 1, 2, 4, 9, 11, 99, -1]

      for algorithm <- invalid_integers do
        assert {:error, [message: "must be a valid DNSSEC algorithm"]} = Algorithm.cast(algorithm)
      end
    end

    test "rejects non-string, non-integer values" do
      invalid_values = [nil, :atom, [], %{}, 1.5, true, false]

      for value <- invalid_values do
        assert {:error, [message: "must be a valid DNSSEC algorithm"]} = Algorithm.cast(value)
      end
    end
  end

  describe "load/1" do
    test "loads valid binary values" do
      algorithms = ["3", "5", "13", "8"]

      for algorithm <- algorithms do
        assert {:ok, ^algorithm} = Algorithm.load(algorithm)
      end
    end

    test "rejects non-binary values" do
      invalid_values = [nil, 123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = Algorithm.load(value)
      end
    end
  end

  describe "dump/1" do
    test "dumps valid binary values" do
      algorithms = ["3", "5", "13", "8"]

      for algorithm <- algorithms do
        assert {:ok, ^algorithm} = Algorithm.dump(algorithm)
      end
    end

    test "rejects non-binary values" do
      invalid_values = [nil, 123, :atom, [], %{}]

      for value <- invalid_values do
        assert :error = Algorithm.dump(value)
      end
    end
  end

  describe "embed_as/1" do
    test "returns :self for any format" do
      assert Algorithm.embed_as(:json) == :self
      assert Algorithm.embed_as(:anything) == :self
    end
  end

  describe "equal?/2" do
    test "returns true for equal values" do
      assert Algorithm.equal?("13", "13") == true
      assert Algorithm.equal?("8", "8") == true
    end

    test "returns false for different values" do
      assert Algorithm.equal?("13", "8") == false
      assert Algorithm.equal?("5", "7") == false
    end

    test "handles different types" do
      assert Algorithm.equal?("13", 13) == false
      assert Algorithm.equal?(nil, "13") == false
    end
  end

  describe "valid?/1" do
    test "returns true for valid algorithm strings" do
      valid_algorithms = ["3", "5", "6", "7", "8", "10", "12", "13", "14", "15", "16"]

      for algorithm <- valid_algorithms do
        assert Algorithm.valid?(algorithm) == true
      end
    end

    test "returns false for invalid algorithm strings" do
      invalid_algorithms = ["0", "1", "2", "4", "9", "11", "99", "abc", ""]

      for algorithm <- invalid_algorithms do
        assert Algorithm.valid?(algorithm) == false
      end
    end

    test "returns false for non-string values" do
      invalid_values = [nil, 13, :atom, [], %{}, 1.5]

      for value <- invalid_values do
        assert Algorithm.valid?(value) == false
      end
    end
  end

  describe "valid_algorithms/0" do
    test "returns the list of valid algorithms" do
      expected = ["3", "5", "6", "7", "8", "10", "12", "13", "14", "15", "16"]
      assert Algorithm.valid_algorithms() == expected
    end

    test "returned list contains expected common algorithms" do
      algorithms = Algorithm.valid_algorithms()

      # Common algorithms that should be supported
      # RSA/SHA-256
      assert "8" in algorithms
      # ECDSA Curve P-256 with SHA-256
      assert "13" in algorithms
      # ECDSA Curve P-384 with SHA-384
      assert "14" in algorithms
      # Ed25519
      assert "15" in algorithms
      # Ed448
      assert "16" in algorithms
    end
  end

  describe "integration with Ecto.Type behaviour" do
    test "implements all required callbacks" do
      # Verify the module implements the Ecto.Type behaviour
      behaviours = Algorithm.__info__(:attributes)[:behaviour] || []
      assert Ecto.Type in behaviours
    end

    test "cast -> dump -> load round trip" do
      original = "13"

      assert {:ok, casted} = Algorithm.cast(original)
      assert {:ok, dumped} = Algorithm.dump(casted)
      assert {:ok, loaded} = Algorithm.load(dumped)

      assert loaded == original
    end
  end
end
