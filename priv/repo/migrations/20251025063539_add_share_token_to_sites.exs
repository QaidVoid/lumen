defmodule Lumen.Repo.Migrations.AddShareTokenToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add :share_token, :string
      add :public_dashboard_enabled, :boolean, default: false
    end

    create unique_index(:sites, [:share_token])
  end
end
