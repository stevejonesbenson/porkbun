defmodule Porkbun.Types.KeyTag do
  @moduledoc """
  Ecto type for DNSSEC key tag.

  Key tags are 16-bit integers (0-65535) used to identify DNSSEC keys.
  """

  @behaviour Ecto.Type

  @type t :: binary()

  @impl Ecto.Type
  def type, do: :string

  @impl Ecto.Type
  def cast(value) when is_binary(value) do
    if valid?(value) do
      {:ok, value}
    else
      {:error, [message: "must be a valid key tag (0-65535)"]}
    end
  end

  def cast(value) when is_integer(value) and value >= 0 and value <= 65_535 do
    {:ok, Integer.to_string(value)}
  end

  def cast(_), do: {:error, [message: "must be a valid key tag"]}

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
  Validates that the key tag is valid.

  ## Examples

      iex> Porkbun.Types.KeyTag.valid?("12345")
      true

      iex> Porkbun.Types.KeyTag.valid?("65535")
      true

      iex> Porkbun.Types.KeyTag.valid?("65536")
      false

      iex> Porkbun.Types.KeyTag.valid?("abc")
      false
  """
  def valid?(key_tag) when is_binary(key_tag) do
    case Integer.parse(key_tag) do
      {int_val, ""} when int_val >= 0 and int_val <= 65_535 -> true
      _ -> false
    end
  end

  def valid?(_), do: false
end
