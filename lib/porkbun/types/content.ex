defmodule Porkbun.Types.Content do
  @moduledoc """
  Ecto type for DNS record content.

  The answer content for the record. Content validation depends on the record type.
  """

  @behaviour Ecto.Type

  @type t :: binary()

  @impl Ecto.Type
  def type, do: :string

  @impl Ecto.Type
  def cast(value) when is_binary(value) and value != "", do: {:ok, value}
  def cast(_), do: {:error, [message: "must be a non-empty string"]}

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
  Validates content based on record type.
  """
  def valid_for_type?(content, :a) when is_binary(content) do
    Porkbun.Types.IPAddress.ipv4?(content)
  end

  def valid_for_type?(content, :aaaa) when is_binary(content) do
    Porkbun.Types.IPAddress.ipv6?(content)
  end

  def valid_for_type?(content, :cname) when is_binary(content),
    do: Porkbun.Types.Name.valid?(content)

  def valid_for_type?(content, :alias) when is_binary(content),
    do: Porkbun.Types.Name.valid?(content)

  def valid_for_type?(content, :mx) when is_binary(content),
    do: Porkbun.Types.Name.valid?(content)

  def valid_for_type?(content, :ns) when is_binary(content),
    do: Porkbun.Types.Name.valid?(content)

  def valid_for_type?(content, :srv) when is_binary(content) do
    # SRV format: "weight port target" (priority is separate field)
    # Example: "10 80 target.example.com"
    case String.split(content, " ", parts: 3) do
      [weight, port, target] ->
        valid_weight?(weight) and valid_port?(port) and Porkbun.Types.Name.valid?(target)

      _ ->
        false
    end
  end

  def valid_for_type?(content, :caa) when is_binary(content) do
    # CAA format: "flags tag value"
    # Example: "0 issue letsencrypt.org"
    case String.split(content, " ", parts: 3) do
      [flags, tag, value] ->
        valid_caa_flags?(flags) and valid_caa_tag?(tag) and String.length(value) > 0

      _ ->
        false
    end
  end

  def valid_for_type?(content, :tlsa) when is_binary(content) do
    # TLSA format: "cert_usage selector matching_type cert_data"
    # Example: "3 1 1 1234567890abcdef..."
    case String.split(content, " ", parts: 4) do
      [cert_usage, selector, matching_type, cert_data] ->
        valid_tlsa_usage?(cert_usage) and
          valid_tlsa_selector?(selector) and
          valid_tlsa_matching_type?(matching_type) and
          valid_hex_data?(cert_data)

      _ ->
        false
    end
  end

  def valid_for_type?(content, type) when type in [:https, :svcb] and is_binary(content) do
    # HTTPS/SVCB format: "target [params...]"
    # Example: "." or "svc.example.com port=443"
    parts = String.split(content, " ")

    case parts do
      [target | _params] ->
        # Target can be "." for root or a valid domain name
        target == "." or Porkbun.Types.Name.valid?(target)

      [] ->
        false
    end
  end

  def valid_for_type?(content, _type) when is_binary(content),
    do: String.length(content) > 0

  def valid_for_type?(_, _), do: false

  # Helper validation functions
  defp valid_weight?(weight) do
    case Integer.parse(weight) do
      {int_val, ""} when int_val >= 0 and int_val <= 65_535 -> true
      _ -> false
    end
  end

  defp valid_port?(port) do
    case Integer.parse(port) do
      {int_val, ""} when int_val >= 1 and int_val <= 65_535 -> true
      _ -> false
    end
  end

  defp valid_caa_flags?(flags) do
    case Integer.parse(flags) do
      {int_val, ""} when int_val >= 0 and int_val <= 255 -> true
      _ -> false
    end
  end

  defp valid_caa_tag?(tag) when is_binary(tag) do
    tag in ["issue", "issuewild", "iodef"]
  end

  defp valid_tlsa_usage?(usage) do
    case Integer.parse(usage) do
      {int_val, ""} when int_val >= 0 and int_val <= 3 -> true
      _ -> false
    end
  end

  defp valid_tlsa_selector?(selector) do
    case Integer.parse(selector) do
      {int_val, ""} when int_val >= 0 and int_val <= 1 -> true
      _ -> false
    end
  end

  defp valid_tlsa_matching_type?(matching_type) do
    case Integer.parse(matching_type) do
      {int_val, ""} when int_val >= 0 and int_val <= 2 -> true
      _ -> false
    end
  end

  defp valid_hex_data?(data) when is_binary(data) do
    String.match?(data, ~r/^[A-Fa-f0-9]+$/) and String.length(data) > 0
  end
end
