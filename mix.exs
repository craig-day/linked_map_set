defmodule LinkedMapSet.MixProject do
  use Mix.Project

  def project do
    [
      name: "LinkedMapSet",
      app: :linked_map_set,
      version: "0.1.0",
      elixir: "~> 1.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/craig-day/linked_map_set",
      homepage_url: "https://github.com/craig-day/linked_map_set",
      docs: docs()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    An extension to `MapSet` that maintains ordering based on insert order.
    """
  end

  defp package do
    [
      name: "linked_map_set",
      licenses: ["MIT"],
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG*),
      links: %{"GitHub" => "https://github.com/craig-day/linked_map_set"}
    ]
  end

  defp docs do
    [
      main: "LinkedMapSetSet",
      extras: ["README.md"]
    ]
  end
end
