defmodule Graphito.MixProject do
  use Mix.Project

  @version "0.1.3"

  def project do
    [
      app: :graphito,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      package: package(),
      description: description(),
      docs: [
        source_ref: "v#{@version}",
        main: "readme",
        logo: "logo.png",
        extra_section: "README",
        formatters: ["html", "epub"],
        extras: ["README.md"]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      name: "graphito",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Adrián Quintás"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/qgadrian/graphito"}
    ]
  end

  defp description do
    "Server utils to automate common tasks like pagination or authentication"
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.8", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:git_hooks, "~> 0.2"},
      {:tesla, "0.10.0"},
      {:poison, "~> 3.1"}
    ]
  end

  defp aliases do
    [
      compile: ["compile --warnings-as-errors"],
      coveralls: ["coveralls.html --umbrella"],
      "coveralls.html": ["coveralls.html --umbrella"]
    ]
  end
end
