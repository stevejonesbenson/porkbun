defmodule Elixir.Porkbun.MixProject do
  use Mix.Project

  def project do
    [
      aliases: [],
      app: :porkbun,
      build_embedded: false,
      build_per_environment: true,
      build_scm: Mix.SCM.Path,
      config_path: "config/config.exs",
      consolidate_protocols: true,
      deps: [
        {:mix_test_watch, "~> 1.2", [only: [:dev, :test], runtime: false, targets: [:host]]},
        {:excoveralls, "~> 0.18", [only: [:dev, :test], runtime: false, targets: [:host]]},
        {:credo, "~> 1.7", [only: [:dev, :test], runtime: false, targets: [:host]]},
        {:dialyxir, "~> 1.4", [only: [:dev, :test], runtime: false, targets: [:host]]},
        {:doctor, "~> 0.22", [only: [:dev, :test], runtime: false, targets: [:host]]},
        {:ex_doc, "~> 0.38", [only: [:dev, :test], runtime: false, targets: [:host]]},
        {:castore, "~> 1.0.15"},
        {:req, "~> 0.5"},
        {:jason, "~> 1.4"},
        {:ecto, "~> 3.0"}
      ],
      deps_path: "deps",
      description: "Elixir client for the Porkbun API",
      dialyzer: [],
      docs: [
        source_ref: "v0.1.0",
        main: "Porkbun",
        banner: nil,
        api_reference: false,
        extra_section: "pages",
        assets: %{"docs/assets" => "assets"},
        formatters: ["html"],
        extras: ["CHANGELOG.md"],
        groups_for_extras: %{},
        logo: "assets/icon.png",
        favicon: "assets/icon.svg"
      ],
      elixir: "~> 1.18",
      elixirc_paths: ["lib"],
      erlc_include_path: "include",
      erlc_options: [],
      erlc_paths: ["src"],
      expected_entry: Porkbun,
      lockfile: "mix.lock",
      name: "Porkbun",
      package: [
        links: %{"GitHub" => "https://github.com/stevejonesbenson/porkbun"},
        organization: "hexpm",
        licenses: ["MIT"],
        maintainers: ["Stevejones Benson"],
        files: ["lib", "mix.exs", ".formatter.exs", "README.md", "CHANGELOG.md", "LICENSE"],
        org: "hexpm"
      ],
      scm: {:github, "stevejonesbenson", "porkbun"},
      source_url: "https://github.com/stevejonesbenson/porkbun",
      start_permanent: true,
      test_coverage: [token: "Ute1yYEWvt", tool: ExCoveralls],
      type: :library,
      version: "0.1.0",
      visibility: :public
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end
end
