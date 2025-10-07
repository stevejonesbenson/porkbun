defmodule Porkbun.Domain do
  @moduledoc """
  Domain-related Porkbun API endpoints.
  """

  import Porkbun, only: [request: 4]

  alias Porkbun.Types.Domain
  alias Porkbun.Types.ForwardType
  alias Porkbun.Types.IPAddress
  alias Porkbun.Types.Location
  alias Porkbun.Types.Name
  alias Porkbun.Types.YesNo

  def list_all(opts \\ []) do
    types = %{
      start: :integer,
      include_labels: YesNo
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)

    request(opts[:client], "/domain/listAll", types, attrs)
  end

  def check(domain, opts \\ []) do
    types = %{
      domain: Domain
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain})

    request(opts[:client], "/domain/checkDomain/:domain", types, attrs)
  end

  def get_ns(domain, opts \\ []) do
    types = %{
      domain: Domain
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain})

    request(opts[:client], "/domain/getNs/:domain", types, attrs)
  end

  def update_ns(domain, ns_list, opts \\ []) when is_list(ns_list) do
    types = %{
      domain: Domain,
      ns: {:array, :string}
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, ns: ns_list})

    request(opts[:client], "/domain/updateNs/:domain", types, attrs)
  end

  def add_url_forward(domain, location, opts \\ []) do
    types = %{
      domain: Domain,
      location: Location,
      subdomain: Name,
      type: ForwardType,
      include_path: YesNo,
      wildcard: YesNo
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, location: location})

    request(opts[:client], "/domain/addUrlForward/:domain", types, attrs)
  end

  def get_url_forwarding(domain, opts \\ []) do
    types = %{
      domain: Domain
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain})

    request(opts[:client], "/domain/getUrlForwarding/:domain", types, attrs)
  end

  def delete_url_forward(domain, record_id, opts \\ []) do
    types = %{
      domain: Domain,
      record_id: :integer
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, record_id: record_id})

    request(opts[:client], "/domain/deleteUrlForward/:domain/:record_id", types, attrs)
  end

  def create_glue(domain, subdomain, ips, opts \\ []) when is_list(ips) do
    types = %{
      domain: Domain,
      subdomain: Name,
      ips: {:array, IPAddress}
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, subdomain: subdomain, ips: ips})

    request(opts[:client], "/domain/createGlue/:domain/:subdomain", types, attrs)
  end

  def update_glue(domain, subdomain, ips, opts \\ []) when is_list(ips) do
    types = %{
      domain: Domain,
      subdomain: Name,
      ips: {:array, IPAddress}
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, subdomain: subdomain, ips: ips})

    request(opts[:client], "/domain/updateGlue/:domain/:subdomain", types, attrs)
  end

  def delete_glue(domain, subdomain, opts \\ []) do
    types = %{
      domain: Domain,
      subdomain: Name
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, subdomain: subdomain})

    request(opts[:client], "/domain/deleteGlue/:domain/:subdomain", types, attrs)
  end

  def get_glue(domain, opts \\ []) do
    types = %{
      domain: Domain
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain})

    request(opts[:client], "/domain/getGlue/:domain", types, attrs)
  end
end
