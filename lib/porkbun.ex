defmodule Porkbun do
  @external_resource readme = Path.join(File.cwd!(), "README.md")

  readme =
    readme
    |> File.read!()
    |> String.split("<!-- MDOC -->")
    |> Enum.fetch!(1)
    |> String.split("<!-- CI -->", parts: 3)
    |> List.delete_at(1)

  pre = "Porkbun API Client."
  mdoc = ((mdoc = Module.get_attribute(__MODULE__, :moduledoc, nil)) && elem(mdoc, 1)) || ""
  @moduledoc Enum.join([pre, readme, mdoc], "\n\n")

  @base_url "https://api-ipv4.porkbun.com/api/json/v3"
  defstruct [
    :req,
    :api_key,
    :secret_key,
    :url_fun,
    :url,
    :types,
    attrs: %{},
    validated_attrs: %{},
    path_params: %{},
    body_params: %{}
  ]

  @doc """
  Gets the current pricing from Porkbun.
  """
  def pricing do
    Req.post!(req(), url: "/pricing/get", json: %{})
  end

  @doc """
  Pings the Porkbun API to check connectivity.
  """
  def ping(client \\ nil) do
    request(client, fn _ -> "/ping" end, nil, %{})
  end

  @doc false
  def req do
    Req.new(base_url: @base_url)
  end

  @doc """
  Creates a Porkbun client struct.


  ## Options

    * `:api_key` - Your Porkbun API key. Defaults to the `PORKBUN_API` environment variable.
    * `:secret_key` - Your Porkbun secret key. Defaults to the `PORKBUN_SECRET` environment variable.

  """
  def client(opts \\ []) do
    api_key = opts[:api_key] || System.get_env("PORKBUN_API")
    secret_key = opts[:secret_key] || System.get_env("PORKBUN_SECRET")

    %__MODULE__{
      req: req(),
      api_key: api_key,
      secret_key: secret_key
    }
  end

  @doc false
  def request(client, url_fun) do
    client = client || client()

    new = %__MODULE__{client | url_fun: url_fun, types: nil}

    new
    |> fetch_url()
    |> send()
  end

  @doc false
  def request(client, url_fun, types, attrs) do
    client = client || client()

    new = %__MODULE__{client | url_fun: url_fun, types: types, attrs: attrs}

    new
    |> validate_attrs()
    |> fetch_url()
    |> split_params()
    |> send()
  end

  @doc false
  def validate_attrs(%__MODULE__{types: nil, attrs: attrs} = request) do
    %__MODULE__{request | validated_attrs: attrs}
  end

  def validate_attrs(%__MODULE__{types: types, attrs: attrs} = request) do
    validated =
      {%{}, types}
      |> Ecto.Changeset.cast(attrs, Map.keys(types))
      |> Porkbun.Types.extra_validations()
      |> Ecto.Changeset.apply_action!(:insert)
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> Map.new()

    %__MODULE__{request | validated_attrs: validated}
  end

  @doc false
  def fetch_url(%__MODULE__{url_fun: url_fun, validated_attrs: validated_attrs} = request)
      when is_function(url_fun, 1) do
    %__MODULE__{request | url: url_fun.(validated_attrs)}
  end

  def fetch_url(%__MODULE__{url_fun: url_fun} = request)
      when is_binary(url_fun) do
    %__MODULE__{request | url: url_fun}
  end

  @doc false
  def split_params(%__MODULE__{url: url, validated_attrs: validated} = request) do
    param_fields = parse_path_params(url)

    {path_params, body_params} = Map.split(validated, param_fields)

    %__MODULE__{request | path_params: path_params, body_params: body_params}
  end

  @doc false
  def parse_path_params(url) do
    url
    |> String.split("/", trim: true)
    |> Enum.filter(&String.starts_with?(&1, ":"))
    |> Enum.map(
      &(&1
        |> String.trim_leading(":")
        |> String.to_atom())
    )
  end

  @doc false

  def send(%__MODULE__{} = request) do
    %__MODULE__{
      api_key: api_key,
      secret_key: secret_key,
      req: req,
      url: url,
      path_params: path_params,
      body_params: body_params
    } = request

    json_body = prepare_body(body_params)

    secrets = %{"apikey" => api_key, "secretapikey" => secret_key}

    path_params =
      if map_size(path_params) > 0,
        do: [path_params: Keyword.new(request.path_params)],
        else: []

    req_opts = Application.get_env(:porkbun, :req_opts, [])

    req_opts = [url: url, json: Map.merge(json_body, secrets)] ++ path_params ++ req_opts

    case Req.post!(req, req_opts).body do
      %{"status" => "SUCCESS"} = resp_body -> {:ok, Map.drop(resp_body, ["status"])}
      %{"status" => status, "message" => message} -> {:error, "#{status}: #{message}"}
      other -> {:error, "Unexpected response: #{inspect(other)}"}
    end
  end

  defp prepare_body(params) when is_map(params) do
    key_mapping = %{
      # DNSSEC keys
      key_tag: "keyTag",
      digest_type: "digestType",
      max_sig_life: "maxSigLife",
      key_data_flags: "keyDataFlags",
      key_data_protocol: "keyDataProtocol",
      key_data_algo: "keyDataAlgo",
      key_data_pub_key: "keyDataPubKey",

      # Domain keys
      include_labels: "includeLabels",
      include_path: "includePath"
    }

    Enum.reduce(params, %{}, fn
      {key, value}, acc ->
        if key in Map.keys(key_mapping) do
          Map.put(acc, Map.fetch!(key_mapping, key), "#{value}")
        else
          Map.put(acc, "#{key}", "#{value}")
        end
    end)
  end
end
