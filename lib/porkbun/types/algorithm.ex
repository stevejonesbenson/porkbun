defmodule Porkbun.Types.Algorithm do
  @moduledoc """
  Ecto type for DNSSEC algorithm.

  Valid DNSSEC algorithms as defined in RFC specifications.
  """

  @behaviour Ecto.Type

  @type t :: binary()

  # Common DNSSEC algorithms
  @valid_algorithms ["3", "5", "6", "7", "8", "10", "12", "13", "14", "15", "16"]

  @impl Ecto.Type
  def type, do: :string

  @impl Ecto.Type
  def cast(value) when is_binary(value) do
    if valid?(value) do
      {:ok, value}
    else
      {:error, [message: "must be a valid DNSSEC algorithm"]}
    end
  end

  def cast(value) when is_integer(value) do
    cast(Integer.to_string(value))
  end

  def cast(_), do: {:error, [message: "must be a valid DNSSEC algorithm"]}

  @impl Ecto.Type
  def load(value) when is_binary(value), do: {:ok, value}
  def load(_), do: :error

  @impl Ecto.Type
  def dump(value) when is_binary(value), do: {:ok, value}
  def dump(_), do: :error

  @impl Ecto.Type
  def embed_as(_format), do: :self

  @impl Ecto.Type
  def equal?(val1, val2), do: val1 == val2

  @doc """
  Validates that the algorithm is valid.

  ## Examples

      iex> Porkbun.Types.Algorithm.valid?("13")
      true

      iex> Porkbun.Types.Algorithm.valid?("8")
      true

      iex> Porkbun.Types.Algorithm.valid?("99")
      false
  """
  def valid?(algorithm) when is_binary(algorithm) do
    algorithm in @valid_algorithms
  end

  def valid?(_), do: false

  @doc """
  Returns the list of valid algorithms.
  """
  def valid_algorithms, do: @valid_algorithms
end
