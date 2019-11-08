defmodule Headfi.Item do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Headfi.{Item, Repo}

  schema "items" do
    field(:title, :string)
    field(:thread_id, :integer)
    field(:currency, :string)
    field(:price, :integer)
    field(:ship_to, :string)

    timestamps()
  end

  @required_params [
    :title,
    :thread_id,
    :currency,
    :price,
    :ship_to
  ]

  def changeset(record, params) do
    record
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end

  def add(data) do
    %Item{}
    |> Item.changeset(data)
    |> Repo.insert!()
  end
end
