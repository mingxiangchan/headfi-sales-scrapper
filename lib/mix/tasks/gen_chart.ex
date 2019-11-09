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
      pic_title = Enum.join(args, " ")
      generate_chart(results, pic_title)
    end
  end

  @spec generate_chart(list(Item.t()), String.t()) :: any
  def generate_chart(items, pic_title) do
    prices = Enum.map(items, fn item -> item.price / 100 end)
    max_price = Enum.max(prices)

    dataset =
      Enum.reduce(prices, %{}, fn price, acc ->
        if is_nil(acc[price]) do
          Map.put(acc, price, 1)
        else
          Map.put(acc, price, acc[price] + 1)
        end
      end)

    y_interval =
      cond do
        max_price >= 5000 -> 500
        max_price >= 2000 -> 250
        max_price >= 1000 -> 100
        max_price >= 500 -> 50
        max_price >= 200 -> 25
        true -> 10
      end

    formatted_dataset = Enum.into(dataset, [])
    filepath = Path.join("generated", "#{String.replace(pic_title, " ", "_")}.png")

    IO.inspect(dataset)

    Gnuplot.plot(
      [
        [:set, :ylabel, "Price(USD)"],
        ~w(set grid)a,
        ~w(set yrange [0:#{trunc(1.1 * max_price)}])a,
        ~w(set style fill solid 0.25 border -1)a,
        ~w(set style boxplot outliers pointtype 7 medianlinewidth 1.5)a,
        ~w(set style data boxplot)a,
        ~w(set xtics ("#{pic_title}" 1\) scale 0.0)a,
        ~w(set xtics nomirror)a,
        ~w(set ytics #{y_interval})a,
        [:set, :term, :pngcairo, :size, '600, 800', :font, "Times, 14"],
        [:set, :output, filepath],
        ~w(plot "-" using (1\):1 notitle)a
      ],
      [formatted_dataset]
    )

    IO.puts("Chart generated at #{filepath}")
  end
end
