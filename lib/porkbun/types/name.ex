defmodule Porkbun.Types.Name do
  @moduledoc """
  Ecto type for Porkbun record names (subdomains).

  The subdomain for the record being created, not including the domain itself.
  Leave blank to create a record on the root domain. Use * to create a wildcard record.
  """

  use Ecto.Type

  @type t :: binary() | nil

  def type, do: :string

  # Cast from binary - accept any string or nil, validate subdomain
  def cast(value) when is_binary(value) do
    if valid?(value) do
      {:ok, value}
    else
      {:error, [message: "must be a valid subdomain name"]}
    end
  end

  def cast(nil), do: {:ok, nil}
  def cast(""), do: {:ok, nil}
  def cast(_), do: {:error, [message: "must be a string"]}

  # Load from string - convert empty string to nil
  def load(value) when is_binary(value) and value != "", do: {:ok, value}
  def load(""), do: {:ok, nil}
  def load(nil), do: {:ok, nil}
  def load(_), do: :error

  # Dump to string - convert nil to empty string for API
  def dump(value) when is_binary(value), do: {:ok, value}
  def dump(nil), do: {:ok, ""}
  def dump(_), do: :error

  def embed_as(_format), do: :self

  def equal?("", nil), do: true
  def equal?(nil, ""), do: true
  def equal?(val1, val2), do: val1 == val2

  @doc """
  Validates that the name is a valid subdomain format.

  A valid subdomain:
  - Is an empty string (indicating the root domain)
  - Is a single label (no dots)
  - Is 63 characters or fewer
  - Starts and ends with a letter or digit
  - Contains only letters, digits, and hyphens in between
  """
  def valid?(nil), do: true
  def valid?(""), do: true
  def valid?("*"), do: true

  def valid?(name) when is_binary(name) do
    cond do
      String.contains?(name, ".") -> false
      String.length(name) > 63 -> false
      true -> String.match?(name, ~r/^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$/)
    end
  end

  def valid?(_), do: false
end
