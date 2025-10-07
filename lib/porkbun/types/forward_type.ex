defmodule Porkbun.Types.ForwardType do
  @moduledoc """
  Ecto type for URL forward type.

  The type of forward. Valid types are: temporary or permanent
  """

  @behaviour Ecto.Type

  @type t :: :temporary | :permanent

  @types [:temporary, :permanent]
  @string_types ["temporary", "permanent"]

  @impl Ecto.Type
  def type, do: :string

  @impl Ecto.Type
  def cast(value) when is_atom(value) and value in @types, do: {:ok, value}

  def cast(value) when is_binary(value) and value in @string_types do
    {:ok, String.to_atom(value)}
  end

  def cast(_), do: {:error, [message: "must be either 'temporary' or 'permanent'"]}

  @impl Ecto.Type
  def load(value) when is_binary(value) and value in @string_types do
    {:ok, String.to_atom(value)}
  end

  def load(_), do: :error

  @impl Ecto.Type
  def dump(value) when is_atom(value) and value in @types do
    {:ok, Atom.to_string(value)}
  end

  def dump(_), do: :error

  @impl Ecto.Type
  def embed_as(_format), do: :self

  @impl Ecto.Type
  def equal?(val1, val2), do: val1 == val2

  @doc """
  Returns valid forward types.
  """
  def valid_types, do: @types

  @doc """
  Validates the forward type.
  """
  def valid?(value) when is_atom(value), do: value in @types
  def valid?(value) when is_binary(value), do: value in @string_types
  def valid?(_), do: false
end
