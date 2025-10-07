defmodule Porkbun.Types.TTL do
  @moduledoc """
  Ecto type for Porkbun record TTL (Time To Live).

  The time to live in seconds for the record.
  The minimum and the default is 600 seconds.
  """

  use Ecto.Type

  @type t :: pos_integer() | nil

  @minimum_ttl 600
  @default_ttl 600

  def type, do: :integer

  def cast(value) when is_integer(value) and value >= @minimum_ttl, do: {:ok, value}
  def cast(value) when is_integer(value) and value < @minimum_ttl, do: {:ok, @minimum_ttl}
  def cast(nil), do: {:ok, nil}

  def cast(value) when is_binary(value) do
    case Integer.parse(value) do
      {int_value, ""} when int_value >= @minimum_ttl -> {:ok, int_value}
      {int_value, ""} when int_value < @minimum_ttl -> {:ok, @minimum_ttl}
      _ -> {:error, [message: "must be a non-negative integer >= #{@minimum_ttl} or nil"]}
    end
  end

  def cast(_), do: :error

  def load(value) when is_integer(value) and value >= @minimum_ttl, do: {:ok, value}
  def load(value) when is_integer(value) and value < @minimum_ttl, do: {:ok, @minimum_ttl}
  def load(nil), do: {:ok, nil}
  def load(_), do: :error

  def dump(value) when is_integer(value) and value >= @minimum_ttl, do: {:ok, value}
  def dump(value) when is_integer(value) and value < @minimum_ttl, do: {:ok, @minimum_ttl}
  def dump(nil), do: {:ok, @default_ttl}
  def dump(_), do: :error

  def embed_as(_format), do: :self

  def equal?(val1, val2), do: val1 == val2

  @doc """
  Returns the minimum allowed TTL value.
  """
  def minimum, do: @minimum_ttl

  @doc """
  Returns the default TTL value.
  """
  def default, do: @default_ttl

  @doc """
  Validates that the TTL is within acceptable range.
  """
  def valid?(value) when is_integer(value), do: value >= @minimum_ttl
  def valid?(nil), do: true
  def valid?(_), do: false
end
