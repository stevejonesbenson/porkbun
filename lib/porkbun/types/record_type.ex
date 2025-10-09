defmodule Porkbun.Types.RecordType do
  @moduledoc """
  Ecto type for Porkbun record types.
  """

  use Ecto.Type

  @type t :: binary()

  @types [:a, :aaaa, :cname, :alias, :mx, :txt, :srv, :ns, :caa, :tlsa, :https, :svcb]
  @binary_types for type <- @types, do: "#{type}"

  @uppercase_types for type <- @types, do: String.to_atom(String.upcase("#{type}"))
  @upcase_binary_types for type <- @types, do: String.upcase("#{type}")

  def type, do: :string

  # Cast from lowercase atom
  def cast(value) when is_atom(value) and value in @types do
    {:ok, value |> Atom.to_string() |> String.upcase()}
  end

  # Cast from uppercase atom
  def cast(value) when is_atom(value) and value in @uppercase_types do
    {:ok, value |> Atom.to_string()}
  end

  # Cast from uppercase binary
  def cast(value) when is_binary(value) and value in @upcase_binary_types do
    {:ok, value}
  end

  # Cast from lowercase binary
  def cast(value) when is_binary(value) and value in @binary_types do
    {:ok, String.upcase(value)}
  end

  # Cast from any case binary by normalizing to uppercase and checking
  def cast(value) when is_binary(value) do
    normalized = String.upcase(value)

    if normalized in @upcase_binary_types do
      {:ok, normalized}
    else
      {:error, [message: "must be one of: #{Enum.join(@upcase_binary_types, ", ")}"]}
    end
  end

  def cast(_), do: {:error, [message: "must be one of: #{Enum.join(@upcase_binary_types, ", ")}"]}

  # Load from string to uppercase binary
  def load(value) when is_binary(value) and value in @upcase_binary_types do
    {:ok, value}
  end

  def load(value) when is_binary(value) and value in @binary_types do
    {:ok, String.upcase(value)}
  end

  def load(_), do: :error

  # Dump from uppercase binary to uppercase string (already uppercase)
  def dump(value) when is_binary(value) and value in @upcase_binary_types do
    {:ok, value}
  end

  def dump(_), do: :error

  def embed_as(_format), do: :self

  def equal?(val1, val2) when is_binary(val1) and is_binary(val2) do
    String.upcase(val1) == String.upcase(val2)
  end

  def equal?(val1, val2) when is_atom(val1) and is_binary(val2) do
    String.upcase(Atom.to_string(val1)) == String.upcase(val2)
  end

  def equal?(val1, val2) when is_binary(val1) and is_atom(val2) do
    String.upcase(val1) == String.upcase(Atom.to_string(val2))
  end

  def equal?(val1, val2) when is_atom(val1) and is_atom(val2) do
    String.upcase(Atom.to_string(val1)) == String.upcase(Atom.to_string(val2))
  end

  def equal?(_, _), do: false

  def types do
    Enum.map(@types, &{&1, Atom.to_string(&1)})
  end
end
