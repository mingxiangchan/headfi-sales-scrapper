defmodule Headfi.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add(:title, :string)
      add(:thread_id, :integer)
      add(:currency, :string)
      add(:price, :integer)
      add(:ship_to, :string)

      timestamps()
    end
  end
end
