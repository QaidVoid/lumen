defmodule Lumen.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :site_id, references(:sites, type: :uuid, on_delete: :delete_all), null: false
      add :path, :string, null: false
      add :referrer, :string
      add :ip, :string
      add :user_agent, :text

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:events, [:site_id])
    create index(:events, [:inserted_at])
    create index(:events, [:site_id, :inserted_at])
  end
end
