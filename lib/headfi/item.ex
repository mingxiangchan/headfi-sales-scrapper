require IEx

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
    |> check_max_price
  end

  @spec add(Map.t()) :: Item.t()
  def add(data) do
    case Repo.get_by(Item, thread_id: data[:thread_id]) do
      nil ->
        %Item{}
        |> Item.changeset(data)
        |> Repo.insert!()

      item ->
        item
        |> Item.changeset(data)
        |> Repo.update!()
    end
  end

  @spec check_max_price(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp check_max_price(changeset) do
    if get_field(changeset, :price) > 2_147_483_647 do
      put_change(changeset, :price, 2_147_483_647)
    else
      changeset
    end
  end
end
