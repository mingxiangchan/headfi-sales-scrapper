defmodule Headfi.Scrapper.Item do
  @type t :: %__MODULE__{
          thread_id: integer,
          title: String.t(),
          currency: String.t(),
          price: integer,
          ship_to: String.t()
        }

  @enforce_keys [:thread_id, :title, :currency, :price, :ship_to]
  defstruct [:thread_id, :title, :currency, :price, :ship_to]
end
