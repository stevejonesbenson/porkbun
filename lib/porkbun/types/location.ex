defmodule Porkbun.Types.Location do
  @moduledoc """
  Ecto type for URL location fields in Porkbun API.

  Used for URL forwarding locations. Must be a valid HTTP or HTTPS URL.
  """

  @behaviour Ecto.Type

  @type t :: binary()

  @impl Ecto.Type
  def type, do: :string

  @impl Ecto.Type
  def cast(value) when is_binary(value) do
    if valid_url?(value) do
      {:ok, value}
    else
      {:error, [message: "must be a valid URL (http:// or https://)"]}
    end
  end

  def cast(_), do: {:error, [message: "must be a valid URL string"]}

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
  Validates that the URL is a valid HTTP or HTTPS URL.
  """
  def valid?(url) when is_binary(url), do: valid_url?(url)
  def valid?(_), do: false

  defp valid_url?(url) do
    uri = URI.parse(url)

    uri.scheme != nil and
      uri.host != nil and
      uri.scheme in ["http", "https"] and
      String.length(uri.host) > 0 and
      not String.contains?(uri.host, " ")
  end
end
