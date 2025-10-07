defmodule Porkbun.Types.IPAddress do
  @moduledoc """
  Ecto type for IP addresses (IPv4 or IPv6).

  Used for glue records and other IP-based fields.
  """

  @behaviour Ecto.Type

  @type t :: binary()

  @impl Ecto.Type
  def type, do: :string

  @impl Ecto.Type
  def cast(value) when is_binary(value) do
    if valid_ip?(value), do: {:ok, value}, else: :error
  end

  def cast(_), do: {:error, [message: "must be a valid IPv4 or IPv6 address"]}

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
  Validates that the value is a valid IP address.
  """
  def valid?(value) when is_binary(value), do: valid_ip?(value)
  def valid?(_), do: false

  @doc """
  Returns true if the IP is IPv4.
  """
  def ipv4?(ip) when is_binary(ip) do
    case :inet.parse_ipv4_address(String.to_charlist(ip)) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  @doc """
  Returns true if the IP is IPv6.
  """
  def ipv6?(ip) when is_binary(ip) do
    case :inet.parse_ipv6_address(String.to_charlist(ip)) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp valid_ip?(ip) do
    ipv4?(ip) or ipv6?(ip)
  end
end
