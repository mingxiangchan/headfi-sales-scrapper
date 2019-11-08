defmodule Headfi.Tasks.Seed do
  use Mix.Task

  @shortdoc "Seeds 1692 pages of headfi threads into local DB"
  def run(_) do
    1..1692
    |> Enum.to_list()
    |> Enum.each(fn page_num ->
      Task.start(fn ->
        Headfi.Scrapper.Worker.process(page_num)
      end)
    end)
  end
end
