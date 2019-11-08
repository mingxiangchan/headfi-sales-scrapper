defmodule Headfi.Application do
  @moduledoc false

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Headfi.Repo, [])
    ]

    opts = [
      strategy: :one_for_one,
      name: Headfi.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
