defmodule Porkbun.Types.Prio do
  @moduledoc """
  Ecto type for Porkbun record priority.

  The priority of the record for those that support it (MX, SRV records).
  """

  use Ecto.Type

  @type t :: non_neg_integer() | nil

  def type, do: :integer

  # Cast from integer - must be non-negative or nil
  def cast(value) when is_integer(value) and value >= 0, do: {:ok, value}
  def cast(nil), do: {:ok, nil}

  def cast(value) when is_binary(value) do
    # Reject strings with leading/trailing whitespace or leading zeros (except "0")
    if String.trim(value) != value or (String.starts_with?(value, "0") and value != "0") do
      {:error, [message: "must be a non-negative integer or nil"]}
    else
      case Integer.parse(value) do
        {int_value, ""} when int_value >= 0 -> {:ok, int_value}
        _ -> {:error, [message: "must be a non-negative integer or nil"]}
      end
    end
  end

  def cast(_), do: {:error, [message: "must be a non-negative integer or nil"]}

  # Load from integer
  def load(value) when is_integer(value) and value >= 0, do: {:ok, value}
  def load(nil), do: {:ok, nil}
  def load(_), do: :error

  # Dump to integer
  def dump(value) when is_integer(value) and value >= 0, do: {:ok, value}
  def dump(nil), do: {:ok, nil}
  def dump(_), do: :error

  def embed_as(_format), do: :self

  def equal?(val1, val2), do: val1 == val2

  @doc """
  Validates that the priority is a non-negative integer.
  """
  def valid?(value) when is_integer(value), do: value >= 0
  def valid?(nil), do: true
  def valid?(_), do: false

  @doc """
  Returns true if priority is required for the given record type.
  """
  def required_for_type?(type) when type in [:mx, :srv, :https, :svcb], do: true
  def required_for_type?(_), do: false
end
