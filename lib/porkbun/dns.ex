defmodule Porkbun.DNS do
  @moduledoc """
  DNS-related Porkbun API endpoints.
  """

  import Porkbun, only: [request: 4]

  alias Porkbun.Types.Content
  alias Porkbun.Types.Domain
  alias Porkbun.Types.Name
  alias Porkbun.Types.Prio
  alias Porkbun.Types.RecordType
  alias Porkbun.Types.TTL

  @doc """

  """
  def create_record(domain, type, content, opts \\ []) do
    types = %{
      content: Content,
      name: Name,
      notes: :string,
      prio: Prio,
      ttl: TTL,
      type: RecordType,
      domain: Domain
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{type: type, content: content, domain: domain})

    request(opts[:client], "/dns/create/:domain", types, attrs)
  end

  def edit_record(domain, id, opts \\ []) do
    types = %{
      content: Content,
      domain: Domain,
      id: :integer,
      name: Name,
      notes: :string,
      prio: Prio,
      ttl: TTL,
      type: RecordType
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{id: id, domain: domain})

    request(opts[:client], "/dns/edit/:domain/:id", types, attrs)
  end

  def edit_record_by_name_type(domain, type, subdomain, opts \\ []) do
    types = %{
      domain: Domain,
      type: RecordType,
      subdomain: Name,
      content: :string,
      ttl: TTL,
      prio: Prio,
      notes: :string
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, type: type, subdomain: subdomain})

    url = fn
      %{domain: _, type: _, subdomain: _} -> "/dns/editByNameType/:domain/:type/:subdomain"
      %{domain: _, type: _} -> "/dns/editByNameType/:domain/:type"
    end

    request(opts[:client], url, types, attrs)
  end

  def delete_record(domain, id, opts \\ []) do
    types = %{
      domain: Domain,
      id: :integer
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, id: id})

    request(opts[:client], "/dns/delete/:domain/:id", types, attrs)
  end

  def delete_record_by_name_type(domain, type, subdomain \\ "", opts \\ []) do
    types = %{
      domain: Domain,
      type: RecordType,
      subdomain: Name
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, type: type, subdomain: subdomain})

    url = fn
      %{domain: _, type: _, subdomain: _} -> "/dns/deleteByNameType/:domain/:type/:subdomain"
      %{domain: _, type: _} -> "/dns/deleteByNameType/:domain/:type"
    end

    request(opts[:client], url, types, attrs)
  end

  def retrieve_records(domain, id \\ nil, opts \\ []) do
    types = %{domain: Domain, id: :integer}

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, id: id})

    url = fn
      %{domain: _, id: _} -> "/dns/retrieve/:domain/:id"
      %{domain: _} -> "/dns/retrieve/:domain"
    end

    request(opts[:client], url, types, attrs)
  end

  def retrieve_records_by_name_type(domain, type, subdomain \\ "", opts \\ []) do
    types = %{
      domain: Domain,
      type: RecordType,
      subdomain: Name
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, type: type, subdomain: subdomain})

    url = fn
      %{domain: _, type: _, subdomain: _} -> "/dns/retrieveByNameType/:domain/:type/:subdomain"
      %{domain: _, type: _} -> "/dns/retrieveByNameType/:domain/:type"
    end

    request(opts[:client], url, types, attrs)
  end
end
