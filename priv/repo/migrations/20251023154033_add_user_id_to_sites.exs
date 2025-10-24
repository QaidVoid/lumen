defmodule Lumen.Repo.Migrations.AddUserIdToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:sites, [:user_id])
  end
end
