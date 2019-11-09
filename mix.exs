defmodule Headfi.Mixfile do
  use Mix.Project

  @name :headfi
  @version "0.1.0"

  @deps [
    {:mix_test_watch, github: "aforward/mix-test.watch", only: :dev, runtime: false},
    {:postgrex, "~> 0.13.2"},
    {:ecto, "~> 2.1"},
    {:poison, "~> 3.1.0"},
    {:ex_doc, ">= 0.0.0", only: :dev},
    {:floki, "~> 0.23.0"},
    {:httpoison, "~> 1.6"},
    {:gnuplot, "~>1.19"}
  ]

  @aliases [
    "ecto.reset": ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate"],
    "test.once": ["ecto.reset", "test"]
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      elixir: ">= 1.9.4",
      deps: @deps,
      aliases: @aliases,
      build_embedded: in_production
    ]
  end

  def application do
    [
      mod: {Headfi.Application, []},
      extra_applications: [
        :logger
      ]
    ]
  end
end
