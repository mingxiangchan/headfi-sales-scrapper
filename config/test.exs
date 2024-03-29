use Mix.Config

config :headfi, Headfi.Repo, [
  adapter: Ecto.Adapters.Postgres,
  database: "headfi_#{Mix.env}",
  username: "postgres",
  password: "",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox]

config :logger,
  backends: [:console],
  level: :warn,
  compile_time_purge_level: :info