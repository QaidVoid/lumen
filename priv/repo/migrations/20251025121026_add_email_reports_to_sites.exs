defmodule Lumen.Repo.Migrations.AddEmailReportsToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add :email_reports_enabled, :boolean, default: false
    end
  end
end
