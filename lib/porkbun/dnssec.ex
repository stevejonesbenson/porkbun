defmodule Porkbun.DNSSEC do
  @moduledoc """
  DNSSEC-related Porkbun API endpoints.
  """

  import Porkbun, only: [request: 4]

  alias Porkbun.Types.Algorithm
  alias Porkbun.Types.Digest
  alias Porkbun.Types.DigestType
  alias Porkbun.Types.Domain
  alias Porkbun.Types.KeyTag

  def create_record(domain, key_tag, alg, digest_type, digest, opts \\ []) do
    types = %{
      domain: Domain,
      key_tag: KeyTag,
      alg: Algorithm,
      digest_type: DigestType,
      digest: Digest,
      max_sig_life: :string,
      key_data_flags: :string,
      key_data_protocol: :string,
      key_data_algo: :string,
      key_data_pub_key: :string
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{
        domain: domain,
        key_tag: key_tag,
        alg: alg,
        digest_type: digest_type,
        digest: digest
      })

    request(opts[:client], "/dns/createDnssecRecord/:domain", types, attrs)
  end

  def get_records(domain, opts \\ []) do
    types = %{
      domain: Domain
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain})

    request(opts[:client], "/dns/getDnssecRecords/:domain", types, attrs)
  end

  def delete_record(domain, key_tag, opts \\ []) do
    types = %{
      domain: Domain,
      key_tag: KeyTag
    }

    attrs =
      Map.new(opts)
      |> Map.delete(:client)
      |> Map.merge(%{domain: domain, key_tag: key_tag})

    request(opts[:client], "/dns/deleteDnssecRecord/:domain/:key_tag", types, attrs)
  end
end
