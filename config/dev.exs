use Mix.Config

config :headfi, Headfi.Repo, [
  adapter: Ecto.Adapters.Postgres,
  database: "headfi_#{Mix.env}",
  username: "postgres",
  password: "",
  hostname: "localhost",
]