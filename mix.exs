defmodule JaResource.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ja_resource,
      version: "0.3.4",
      elixir: "~> 1.2",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/StephSanchez/ja_resource",
      package: package(),
      description: description(),
      deps: deps(),
      consolidate_protocols: Mix.env() != :test # to avoid protole consolidation during test
    ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger, :phoenix]]
  end

  defp deps do
    [
      {:ecto, "~> 3.10"},
      {:plug, "~> 1.2"},
      {:phoenix, "~> 1.7"},
      {:ja_serializer, "~> 0.18.0"},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.30.9", only: :dev},
      {:jason, "~> 1.4", only: :test, optional: true},
    ]
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["Alan Peabody", "Pete Brown"],
      links: %{
        "GitHub" => "https://github.com/StephSanchez/ja_resource"
      }
    ]
  end

  defp description do
    """
    A behaviour for defining JSON-API spec controllers in Phoenix.

    Lets you focus on your data, not on boilerplate controller code. Like Webmachine for Phoenix.
    """
  end
end
