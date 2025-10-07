defmodule Porkbun.SSL do
  @moduledoc """
  SSL-related Porkbun API endpoints.
  """

  import Porkbun, only: [request: 4]

  alias Porkbun.Types.Domain

  def retrieve_bundle(domain, opts \\ []) do
    types = %{
      domain: Domain
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain})

    request(opts[:client], "/ssl/retrieve/:domain", types, attrs)
  end
end
