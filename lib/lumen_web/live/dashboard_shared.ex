defmodule LumenWeb.DashboardShared do
  @moduledoc """
  Shared functionality for the dashboard live views.
  """

  alias Lumen.Analytics
  use Phoenix.Component

  def load_dashboard_data(socket) do
    site = socket.assigns.site
    date_range = socket.assigns.date_range

    stats = Analytics.get_site_stats(site.id, date_range)
    recent_events = Analytics.list_recent_events(site.id, 20)
    top_pages = Analytics.get_top_pages(site.id, limit: 10)
    top_referrers = Analytics.get_top_referrers(site.id, limit: 10)
    browser_stats = Analytics.get_browser_stats(site.id)
    device_stats = Analytics.get_device_stats(site.id)
    pageviews_by_date = Analytics.get_pageviews_by_date(site.id, date_range)

    chart_data = prepare_chart_data(pageviews_by_date)

    socket
    |> assign(:stats, stats)
    |> assign(:recent_events, recent_events)
    |> assign(:top_pages, top_pages)
    |> assign(:top_referrers, top_referrers)
    |> assign(:browser_stats, browser_stats)
    |> assign(:device_stats, device_stats)
    |> assign(:chart_data, chart_data)
    |> assign(:loading, false)
  end

  defp prepare_chart_data(pageviews) do
    labels =
      Enum.map(pageviews, fn {date, _count} ->
        Calendar.strftime(date, "%b %d")
      end)

    data = Enum.map(pageviews, fn {_date, count} -> count end)

    %{
      labels: labels,
      datasets: [
        %{
          label: "Pageviews",
          data: data,
          backgroundColor: [
            "rgba(255, 99, 132, 0.2)",
            "rgba(54, 162, 235, 0.2)",
            "rgba(255, 206, 86, 0.2)",
            "rgba(75, 192, 192, 0.2)",
            "rgba(153, 102, 255, 0.2)",
            "rgba(255, 159, 64, 0.2)"
          ],
          borderColor: [
            "rgba(255, 99, 132, 1)",
            "rgba(54, 162, 235, 1)",
            "rgba(255, 206, 86, 1)",
            "rgba(75, 192, 192, 1)",
            "rgba(153, 102, 255, 1)",
            "rgba(255, 159, 64, 1)"
          ],
          tension: 0.4,
          fill: true
        }
      ]
    }
  end
end
