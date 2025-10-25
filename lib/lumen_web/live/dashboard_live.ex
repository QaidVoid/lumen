defmodule LumenWeb.DashboardLive do
  use LumenWeb, :live_view
  import LumenWeb.DashboardComponents
  import LumenWeb.DashboardShared
  alias Lumen.{Analytics, Sites}

  @impl true
  def mount(%{"site_id" => site_id}, _session, socket) do
    user = socket.assigns.current_scope.user

    site = Sites.get_user_site!(user.id, site_id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Lumen.PubSub, "site:#{site.id}")
    end

    socket =
      socket
      |> assign(:site, site)
      |> assign(:date_range, 7)
      |> assign(:loading, true)
      |> load_dashboard_data()

    {:ok, socket}
  end

  @impl true
  def handle_info({:new_event, _event}, socket) do
    {:noreply, load_dashboard_data(socket)}
  end

  @impl true
  def handle_event("change_date_range", %{"range" => range}, socket) do
    date_range = String.to_integer(range)

    socket =
      socket
      |> assign(:date_range, date_range)
      |> load_dashboard_data()

    {:noreply, socket}
  end

  @impl true
  def handle_event("export_csv", _, socket) do
    site = socket.assigns.site
    date_range = socket.assigns.date_range

    csv_data = Analytics.export_to_csv(site.id, date_range)
    filename = "#{site.domain}-analytics-#{Date.utc_today()}.csv"

    {:noreply,
     socket
     |> push_event("download", %{
       data: csv_data,
       filename: filename,
       mime_type: "text/csv"
     })}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-full bg-base-100" phx-hook="Download" id="dashboard-container">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <.dashboard_header
            site={@site}
            date_range={@date_range}
            show_back_link={true}
            show_export={true}
          />

          <.stats_cards stats={@stats} date_range={@date_range} />

          <.pageviews_chart chart_data={@chart_data} />

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 py-4">
            <.top_pages top_pages={@top_pages} />
            <.top_referrers top_referrers={@top_referrers} />
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8 py-4">
            <.browser_stats browser_stats={@browser_stats} />
            <.device_stats device_stats={@device_stats} />
          </div>

          <.recent_events recent_events={@recent_events} />
        </div>
      </div>
    </Layouts.app>
    """
  end
end
