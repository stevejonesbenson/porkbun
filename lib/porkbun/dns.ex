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
  Creates a DNS record for the specified domain.

  This function corresponds to the Porkbun API endpoint `/dns/create/{domain}`.

  ## Parameters

  - `domain` - The domain name to create the record for
  - `type` - The type of record being created. Valid types are: A, MX, CNAME, ALIAS, TXT, NS, AAAA, SRV, TLSA, CAA, HTTPS, SVCB
  - `content` - The answer content for the record. See the DNS management console for proper formatting of each record type
  - `opts` - Optional parameters:
    - `:name` - The subdomain for the record, not including the domain itself. Leave blank for root domain. Use "*" for wildcard
    - `:ttl` - The time to live in seconds for the record. Minimum and default is 600 seconds
    - `:prio` - The priority of the record for those that support it (e.g., MX records)
    - `:notes` - Any notes to set for the record
    - `:client` - The client to use for the request

  ## Returns

  `{:ok, response}` where response is a map containing:
  - `:id` - The ID of the created record

  ## Examples

      # Create an A record for www subdomain
      iex> Porkbun.DNS.create_record("example.com", "A", "1.1.1.1", name: "www", ttl: 600)
      {:ok, %{id: "106926659"}}

      # Create a root domain A record
      iex> Porkbun.DNS.create_record("example.com", "A", "1.1.1.1")
      {:ok, %{id: "106926660"}}

      # Create an MX record with priority
      iex> Porkbun.DNS.create_record("example.com", "MX", "mail.example.com", prio: 10)
      {:ok, %{id: "106926661"}}

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

  @doc """
  Edits a specific DNS record by domain and record ID.

  This function corresponds to the Porkbun API endpoint `/dns/edit/{domain}/{id}`.

  ## Parameters

  - `domain` - The domain name containing the record to edit
  - `id` - The ID of the record to edit
  - `opts` - Optional parameters to update:
    - `:name` - The subdomain for the record, not including the domain itself. Leave blank for root domain. Use "*" for wildcard
    - `:type` - The type of record. Valid types are: A, MX, CNAME, ALIAS, TXT, NS, AAAA, SRV, TLSA, CAA, HTTPS, SVCB
    - `:content` - The answer content for the record
    - `:ttl` - The time to live in seconds for the record. Minimum and default is 600 seconds
    - `:prio` - The priority of the record for those that support it
    - `:notes` - Any notes to set for the record. Pass empty string to clear notes, null to make no changes
    - `:client` - The client to use for the request

  ## Returns

  `:ok` on success.

  ## Examples

      # Edit an existing record's content
      iex> Porkbun.DNS.edit_record("example.com", 106926659, content: "1.1.1.2")
      :ok

      # Edit multiple properties of a record
      iex> Porkbun.DNS.edit_record("example.com", 106926659,
      ...>   content: "1.1.1.2",
      ...>   ttl: 3600,
      ...>   notes: "Updated IP address"
      ...> )
      :ok

  """
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

  @doc """
  Edits all DNS records for the domain that match a particular subdomain and type.

  This function corresponds to the Porkbun API endpoint `/dns/editByNameType/{domain}/{type}/{subdomain}`.

  ## Parameters

  - `domain` - The domain name containing the records to edit
  - `type` - The type of records to edit. Valid types are: A, MX, CNAME, ALIAS, TXT, NS, AAAA, SRV, TLSA, CAA, HTTPS, SVCB
  - `subdomain` - The subdomain name (without the domain). Use empty string for root domain records
  - `opts` - Optional parameters to update:
    - `:content` - The answer content for the record
    - `:ttl` - The time to live in seconds for the record. Minimum and default is 600 seconds
    - `:prio` - The priority of the record for those that support it
    - `:notes` - Any notes to set for the record. Pass empty string to clear notes, null to make no changes
    - `:client` - The client to use for the request

  ## Returns

  `:ok` on success.

  ## Examples

      # Edit all A records for www subdomain
      iex> Porkbun.DNS.edit_record_by_name_type("example.com", "A", "www", content: "1.1.1.2")
      :ok

      # Edit all root domain A records
      iex> Porkbun.DNS.edit_record_by_name_type("example.com", "A", "", content: "1.1.1.2")
      :ok

      # Edit MX records with new priority and TTL
      iex> Porkbun.DNS.edit_record_by_name_type("example.com", "MX", "",
      ...>   content: "mail.example.com",
      ...>   prio: 5,
      ...>   ttl: 3600
      ...> )
      :ok

  """
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

  @doc """
  Deletes a specific DNS record by domain and record ID.

  This function corresponds to the Porkbun API endpoint `/dns/delete/{domain}/{id}`.

  ## Parameters

  - `domain` - The domain name containing the record to delete
  - `id` - The ID of the record to delete
  - `opts` - Optional parameters:
    - `:client` - The client to use for the request

  ## Returns

  `:ok` on success.

  ## Examples

      # Delete a specific DNS record by ID
      iex> Porkbun.DNS.delete_record("example.com", 106926659)
      :ok

      # Delete using a custom client
      iex> Porkbun.DNS.delete_record("example.com", 106926659, client: my_client)
      :ok

  """
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

  @doc """
  Deletes all DNS records for the domain that match a particular subdomain and type.

  This function corresponds to the Porkbun API endpoint `/dns/deleteByNameType/{domain}/{type}/{subdomain}`.

  ## Parameters

  - `domain` - The domain name containing the records to delete
  - `type` - The type of records to delete. Valid types are: A, MX, CNAME, ALIAS, TXT, NS, AAAA, SRV, TLSA, CAA, HTTPS, SVCB
  - `subdomain` - The subdomain name (without the domain). Use empty string for root domain records (optional, defaults to "")
  - `opts` - Optional parameters:
    - `:client` - The client to use for the request

  ## Returns

  `:ok` on success.

  ## Examples

      # Delete all A records for www subdomain
      iex> Porkbun.DNS.delete_record_by_name_type("example.com", "A", "www")
      :ok

      # Delete all root domain A records
      iex> Porkbun.DNS.delete_record_by_name_type("example.com", "A")
      :ok
      # or explicitly:
      iex> Porkbun.DNS.delete_record_by_name_type("example.com", "A", "")
      :ok

      # Delete all MX records for the domain
      iex> Porkbun.DNS.delete_record_by_name_type("example.com", "MX")
      :ok

  """
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

  @doc """
  Retrieves all editable DNS records associated with a domain or a single record for a particular record ID.

  This function corresponds to the Porkbun API endpoint `/dns/retrieve/{domain}` or `/dns/retrieve/{domain}/{id}`.

  ## Parameters

  - `domain` - The domain name to retrieve records for
  - `id` - The ID of a specific record to retrieve (optional, defaults to nil for all records)
  - `opts` - Optional parameters:
    - `:client` - The client to use for the request

  ## Returns

  `{:ok, response}` where response is a map containing:
  - `:records` - An array of DNS records, each containing:
    - `id` - The record ID
    - `name` - The full record name (including domain)
    - `type` - The record type
    - `content` - The record content
    - `ttl` - The time to live value
    - `prio` - The priority value
    - `notes` - Any notes associated with the record

  ## Examples

      # Retrieve all DNS records for a domain
      iex> Porkbun.DNS.retrieve_records("example.com")
      {:ok, %{records: [%{id: "106926652", name: "example.com", type: "A", content: "1.1.1.1", ttl: "600", prio: "0", notes: ""}]}}

      # Retrieve a specific record by ID
      iex> Porkbun.DNS.retrieve_records("example.com", 106926659)
      {:ok, %{records: [%{id: "106926659", name: "www.example.com", type: "A", content: "1.1.1.1", ttl: "600", prio: "0", notes: ""}]}}

      # Using a custom client
      iex> Porkbun.DNS.retrieve_records("example.com", nil, client: my_client)
      {:ok, %{records: [...]}}

  """
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

  @doc """
  Retrieves all editable DNS records associated with a domain, subdomain and type.

  This function corresponds to the Porkbun API endpoint `/dns/retrieveByNameType/{domain}/{type}/{subdomain}`.

  ## Parameters

  - `domain` - The domain name to retrieve records for
  - `type` - The type of records to retrieve. Valid types are: A, MX, CNAME, ALIAS, TXT, NS, AAAA, SRV, TLSA, CAA, HTTPS, SVCB
  - `subdomain` - The subdomain name (without the domain). Use empty string for root domain records (optional, defaults to "")
  - `opts` - Optional parameters:
    - `:client` - The client to use for the request

  ## Returns

  `{:ok, response}` where response is a map containing:
  - `:records` - An array of DNS records, each containing:
    - `id` - The record ID
    - `name` - The full record name (including domain)
    - `type` - The record type
    - `content` - The record content
    - `ttl` - The time to live value
    - `prio` - The priority value
    - `notes` - Any notes associated with the record

  ## Examples

      # Retrieve all A records for www subdomain
      iex> Porkbun.DNS.retrieve_records_by_name_type("example.com", "A", "www")
      {:ok, %{records: [%{id: "106926659", name: "www.example.com", type: "A", content: "1.1.1.1", ttl: "600", prio: "0", notes: ""}]}}

      # Retrieve all root domain A records
      iex> Porkbun.DNS.retrieve_records_by_name_type("example.com", "A")
      {:ok, %{records: [%{id: "106926652", name: "example.com", type: "A", content: "1.1.1.1", ttl: "600", prio: "0", notes: ""}]}}
      # or explicitly:
      iex> Porkbun.DNS.retrieve_records_by_name_type("example.com", "A", "")
      {:ok, %{records: [...]}}

      # Retrieve all MX records for the domain
      iex> Porkbun.DNS.retrieve_records_by_name_type("example.com", "MX")
      {:ok, %{records: [%{id: "106926660", name: "example.com", type: "MX", content: "mail.example.com", ttl: "600", prio: "10", notes: ""}]}}

  """
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
