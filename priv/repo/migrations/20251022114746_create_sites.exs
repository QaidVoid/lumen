defmodule Lumen.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :name, :string, null: false
      add :domain, :string, null: false
      add :public_id, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sites, [:public_id])
    create unique_index(:sites, [:domain])
  end
end
