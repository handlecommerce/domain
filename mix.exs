defmodule Handle.Domain.MixProject do
  use Mix.Project

  def project do
    [
      app: :handle_domain,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers() ++ [:rule_downloader],
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      aliases: aliases(),
      name: "Handle.Domain",
      description: description(),
      source_url: "https://github.com/handlecommerce/domain",
      homepage_url: "https://github.com/handlecommerce/domain",
      docs: [main: "Handle.Domain", extras: ["README.md", "LICENSE"]],
      package: [
        maintainers: ["markglenn@gmail.com"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/handlecommerce/domain"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      lint: ["format --check-formatted", "credo --strict", "dialyzer"]
    ]
  end

  defp description do
    """
    Domain parser for Elixir using the Public Suffix List.
    """
  end
end
