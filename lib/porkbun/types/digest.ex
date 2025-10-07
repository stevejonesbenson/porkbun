defmodule Porkbun.Types.Digest do
  @moduledoc """
  Ecto type for DNSSEC digest.

  Digest must be a valid hexadecimal string.
  """

  @behaviour Ecto.Type

  @type t :: binary()

  @impl Ecto.Type
  def type, do: :string

  @impl Ecto.Type
  def cast(value) when is_binary(value) and value != "" do
    if valid?(value) do
      {:ok, String.upcase(value)}
    else
      {:error, [message: "must be a valid hexadecimal digest"]}
    end
  end

  def cast(_), do: {:error, [message: "must be a non-empty hexadecimal string"]}

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
  Validates that the digest is a valid hexadecimal string.

  ## Examples

      iex> Porkbun.Types.Digest.valid?("15E445BD08128BDC213E25F1C8227DF4CB35186CAC701C1C335B2C406D5530DC")
      true

      iex> Porkbun.Types.Digest.valid?("abcdef123456")
      true

      iex> Porkbun.Types.Digest.valid?("xyz123")
      false

      iex> Porkbun.Types.Digest.valid?("")
      false
  """
  def valid?(digest) when is_binary(digest) and digest != "" do
    String.match?(digest, ~r/^[A-Fa-f0-9]+$/)
  end

  def valid?(_), do: false
end
