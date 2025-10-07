defmodule Porkbun.Types.DigestType do
  @moduledoc """
  Ecto type for DNSSEC digest type.

  Valid digest types: SHA-1 = 1, SHA-256 = 2, GOST = 3, SHA-384 = 4
  """

  @behaviour Ecto.Type

  @type t :: binary()

  # Valid digest types
  @valid_types ["1", "2", "3", "4"]

  @impl Ecto.Type
  def type, do: :string

  @impl Ecto.Type
  def cast(value) when is_binary(value) do
    if valid?(value) do
      {:ok, value}
    else
      {:error, [message: "must be a valid digest type (1-4)"]}
    end
  end

  def cast(value) when is_integer(value) do
    cast(Integer.to_string(value))
  end

  def cast(_), do: {:error, [message: "must be a valid digest type"]}

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
  Validates that the digest type is valid.

  ## Examples

      iex> Porkbun.Types.DigestType.valid?("2")
      true

      iex> Porkbun.Types.DigestType.valid?("1")
      true

      iex> Porkbun.Types.DigestType.valid?("5")
      false
  """
  def valid?(digest_type) when is_binary(digest_type) do
    digest_type in @valid_types
  end

  def valid?(_), do: false

  @doc """
  Returns the list of valid digest types.
  """
  def valid_types, do: @valid_types
end
