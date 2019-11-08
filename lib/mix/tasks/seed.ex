defmodule Mix.Tasks.Seed do
  use Mix.Task

  @shortdoc "Seeds 1692 pages of headfi threads into local DB"
  def run(_) do
    {:ok, _} = Application.ensure_all_started(:hackney)
    {:ok, _} = Application.ensure_all_started(:headfi)

    Task.Supervisor.start_link(name: :seed_supervisor)

    Task.Supervisor.async_stream_nolink(
      :seed_supervisor,
      Enum.to_list(1..1692),
      fn page_num ->
        Headfi.Scrapper.Worker.process(page_num)
      end,
      max_concurrency: 10
    )
    |> Enum.to_list()

    IO.puts("Completed All")
  end
end
