defmodule Porkbun.MixProject do
  use Apm.Project

  def project do
    [
      name: "Porkbun",
      description: "Elixir client for the Porkbun API",
      version: "0.1.0",
      type: :library,
      visibility: :public,
      start_permanent: Mix.env() == :prod,
      scm: {:github, "stevejonesbenson", "porkbun"},
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def test_coverage do
    [tool: ExCoveralls, token: "Ute1yYEWvt"]
  end

  def deps do
    [
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"},
      {:ecto, "~> 3.0"}
    ]
  end

  def docs do
    [
      logo: "assets/icon.png",
      favicon: "assets/icon.svg"
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["Stevejones Benson"],
      files: ~w(lib .formatter.exs mix.exs README.md CHANGELOG.md ),
      organization: "hexpm"
    ]
  end
end
