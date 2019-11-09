require IEx

defmodule Mix.Tasks.GenChart do
  use Mix.Task
  alias Headfi.Item

  @shortdoc "generate a price history chart for the search term"
  def run(args) do
    {:ok, _} = Application.ensure_all_started(:headfi)
    # {:ok, _} = Application.ensure_all_started(:gnuplot)

    query = "%#{Enum.join(args, "%")}%"
    results = Item.search_title(query)

    if Enum.empty?(results) do
      IO.puts("No results found, unable to generate chart")
    else
      pic_title = Enum.join(args, "_")
      generate_chart(results, pic_title)
    end
  end

  @spec generate_chart(list(Item.t()), String.t()) :: any
  def generate_chart(items, pic_title) do
    prices = Enum.map(items, fn item -> item.price / 100 end)
    max_price = Enum.max(prices)

    dataset =
      Enum.reduce(prices, %{0 => 0}, fn price, acc ->
        if is_nil(acc[price]) do
          Map.put(acc, price, 1)
        else
          Map.put(acc, price, acc[price] + 1)
        end
      end)

    max_quantity = dataset |> Map.values() |> Enum.max()
    formatted_dataset = Enum.into(dataset, [])
    filepath = Path.join("generated", "#{pic_title}.png")

    IO.inspect(dataset)

    Gnuplot.plot(
      [
        [:set, :title, "Price History Chart"],
        [:set, :xlabel, "Price(USD)"],
        [:set, :ylabel, "Num Items"],
        ~w(set xrange [0:#{max_price}])a,
        ~w(set yrange [0:#{max_quantity + 1}])a,
        # ~w(set style line 1 linetype 1 linewidth 2 pointtype 7 pointsize 1.5)a,
        [:set, :term, :pngcairo, :size, '400,400', :font, "Times, 14"],
        [:set, :output, filepath],
        [:plot, "-", :smooth, :sbezier]
      ],
      [formatted_dataset]
    )

    IO.puts("Chart generated at #{filepath}")
  end
end
