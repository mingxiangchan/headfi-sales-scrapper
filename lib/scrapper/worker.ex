defmodule Headfi.Scrapper.Worker do
  @moduledoc """
  Handles a specific url
  """
  alias Headfi.Scrapper.Item

  @spec process(integer) :: any
  def process(page_num) when is_integer(page_num) do
    IO.puts("Begin seeding from page #{page_num}.")

    html_items = get_page_html(page_num)

    Task.Supervisor.async_stream_nolink(
      :seed_worker_supervisor,
      html_items,
      fn item_html ->
        item_html
        |> parse_item
        |> store_in_db
      end,
      # there can be 10 workers at a time so handle only 1 DB connection per worker at a time
      max_concurrency: 1
    )
    |> Enum.to_list()
  end

  @spec get_page_html(integer) :: Floki.html_tree()
  defp get_page_html(page_num) when is_integer(page_num) do
    "https://www.head-fi.org/forums/headphones-for-sale-trade.6550/page-#{page_num}"
    |> HTTPoison.get!([], follow_redirect: true)
    |> Map.get(:body)
    |> Floki.find("li.discussionListItem")
  end

  @spec parse_item(Floki.html_tree()) :: Item.t()
  defp parse_item(html) do
    thread_id = html |> Floki.attribute("id") |> hd
    regex = ~r/\w*-*(\d*)/
    # 2nd, 3rd, 4th elements are what we are concerned with
    [_, currency, price, ship_to | _] = Floki.find(html, "dd")

    %Item{
      thread_id: Regex.run(regex, thread_id) |> Enum.at(1) |> String.to_integer(),
      title: html |> Floki.find("h3.title") |> extract_text,
      currency: extract_text(currency),
      price: price |> extract_text |> process_price,
      ship_to: extract_text(ship_to)
    }
  end

  @spec store_in_db(Item.t()) :: any
  defp store_in_db(item) do
    item
    |> Map.from_struct()
    |> Headfi.Item.add()
  end

  @spec extract_text(Floxi.html_tree()) :: String.t()
  defp extract_text(html) do
    html |> Floki.text() |> String.trim()
  end

  @spec process_price(String.t()) :: integer
  defp process_price(price_string) do
    price_string
    |> String.trim()
    |> Float.parse()
    |> elem(0)
    # convert dollars -> cents
    |> Kernel.*(100)
    |> trunc
  end
end
