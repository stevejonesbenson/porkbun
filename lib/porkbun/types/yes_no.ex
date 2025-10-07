defmodule Porkbun.Types.YesNo do
  @moduledoc """
  Ecto type for yes/no boolean fields in Porkbun API.

  Many Porkbun API fields use "yes"/"no" strings instead of booleans.
  """

  @behaviour Ecto.Type

  @type t :: boolean()

  @impl Ecto.Type
  def type, do: :string

  @impl Ecto.Type
  def cast(value) when is_boolean(value), do: {:ok, value}
  def cast("yes"), do: {:ok, true}
  def cast("no"), do: {:ok, false}
  def cast(_), do: {:error, [message: "must be true, false, 'yes', or 'no'"]}

  @impl Ecto.Type
  def load("yes"), do: {:ok, true}
  def load("no"), do: {:ok, false}
  def load(_), do: :error

  @impl Ecto.Type
  def dump(true), do: {:ok, "yes"}
  def dump(false), do: {:ok, "no"}
  def dump(_), do: :error

  @impl Ecto.Type
  def embed_as(_format), do: :self

  @impl Ecto.Type
  def equal?(val1, val2), do: val1 == val2

  @doc """
  Validates the yes/no value.
  """
  def valid?(value) when is_boolean(value), do: true
  def valid?(value) when value in ["yes", "no"], do: true
  def valid?(_), do: false
end
