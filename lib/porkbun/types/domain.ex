defmodule Porkbun.Types.Domain do
  @moduledoc """
  Ecto type for domain names.

  Domain names used in Porkbun API endpoints.
  """

  @type t :: binary()

  @behaviour Ecto.Type

  @impl Ecto.Type
  def type, do: :string

  @impl Ecto.Type
  def cast(value) when is_binary(value) and value != "" do
    if valid?(value) do
      {:ok, value}
    else
      {:error, [message: "must be a valid domain name"]}
    end
  end

  def cast(_), do: {:error, [message: "must be a non-empty string"]}

  @impl Ecto.Type
  def load(value) when is_binary(value), do: {:ok, value}
  def load(_), do: :error

  @impl Ecto.Type
  def dump(value) when is_binary(value), do: {:ok, value}
  def dump(_), do: :error

  @impl Ecto.Type
  def embed_as(_format) do
    :self
  end

  @impl Ecto.Type
  def equal?("", nil), do: true
  def equal?(nil, ""), do: true
  def equal?(nil, val2) when is_binary(val2), do: false
  def equal?(val1, nil) when is_binary(val1), do: false

  def equal?(val1, val2) when is_binary(val1) and is_binary(val2) do
    String.downcase(val1) == String.downcase(val2)
  end

  @doc """
  Validates that the domain is a valid domain name format.

  ## Examples

      iex> Porkbun.Types.Domain.valid?("example.com")
      true

      iex> Porkbun.Types.Domain.valid?("subdomain.example.com")
      true

      iex> Porkbun.Types.Domain.valid?("")
      false

      iex> Porkbun.Types.Domain.valid?("invalid domain")
      false
  """
  def valid?(domain) when is_binary(domain) do
    # Basic domain validation - contains at least one dot and valid characters
    domain =~
      ~r/^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$/
  end

  def valid?(_), do: false
end
