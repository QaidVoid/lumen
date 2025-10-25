defmodule Lumen.Workers.WeeklyReportWorker do
  use Oban.Worker, queue: :reports

  alias Lumen.{Repo, Sites, Mailer}
  alias Lumen.Emails.ReportEmail
  import Ecto.Query

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    sites_with_reports =
      Sites.Site
      |> where([s], s.email_reports_enabled == true)
      |> Repo.all()
      |> Repo.preload(:user)

    Enum.each(sites_with_reports, fn site ->
      send_report(site, site.user)
    end)

    :ok
  end

  defp send_report(site, user) do
    site
    |> ReportEmail.weekly_report(user)
    |> Mailer.deliver()
  end
end
