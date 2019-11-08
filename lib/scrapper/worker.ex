require IEx

defmodule Headfi.Scrapper.Worker do
  @moduledoc """
  Handles a specific url
  """
  alias Headfi.Scrapper.Item

  @spec process(integer) :: any
  def process(page_num) when is_integer(page_num) do
    page_num
    |> get_page_html
    |> parse_html
    |> store_in_db
  end

  @spec get_page_html(integer) :: String.t()
  defp get_page_html(page_num) when is_integer(page_num) do
    url = "https://www.head-fi.org/forums/headphones-for-sale-trade.6550/page-#{page_num}"

    %{body: body} = HTTPoison.get!(url, [], follow_redirect: true)
    body
  end

  @spec parse_html(String.t()) :: list(Item.t())
  defp parse_html(html) do
    html
    |> Floki.find("li.discussionListItem")
    |> Enum.map(fn itemHtml ->
      thread_id = itemHtml |> Floki.attribute("id") |> hd
      regex = ~r/\w*-*(\d*)/
      # 2nd, 3rd, 4th elements are what we are concerned with
      [_, currency, price, ship_to | _] = Floki.find(itemHtml, "dd")

      %Item{
        thread_id: Regex.run(regex, thread_id) |> Enum.at(1) |> String.to_integer(),
        title: itemHtml |> Floki.find("h3.title") |> extract_text,
        currency: extract_text(currency),
        price: price |> extract_text |> process_price,
        ship_to: extract_text(ship_to)
      }
    end)
  end

  @spec store_in_db(list(Item.t())) :: any
  defp store_in_db(items) do
    Enum.each(items, fn item ->
      item
      |> Map.from_struct()
      |> Headfi.Item.add()
    end)
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
