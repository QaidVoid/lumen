defmodule LumenWeb.PublicDashboardLive do
  use LumenWeb, :live_view
  import LumenWeb.DashboardComponents
  import LumenWeb.DashboardShared
  alias Lumen.Sites

  @impl true
  def mount(%{"share_token" => share_token}, _session, socket) do
    case Sites.get_site_by_share_token(share_token) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Invalid or disabled public dashboard link")
         |> redirect(to: ~p"/")}

      site ->
        if connected?(socket) do
          Phoenix.PubSub.subscribe(Lumen.PubSub, "site:#{site.id}")
        end

        socket =
          socket
          |> assign(:site, site)
          |> assign(:date_range, 7)
          |> load_dashboard_data()

        {:ok, socket}
    end
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
  def handle_info({:new_event, _event}, socket) do
    {:noreply, load_dashboard_data(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-full bg-gray-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <.dashboard_header
            site={@site}
            date_range={@date_range}
            is_public={true}
          />

          <.stats_cards stats={@stats} date_range={@date_range} />

          <.pageviews_chart chart_data={@chart_data} />

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
            <.top_pages top_pages={@top_pages} />
            <.top_referrers top_referrers={@top_referrers} />
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
            <.browser_stats browser_stats={@browser_stats} />
            <.device_stats device_stats={@device_stats} />
          </div>

          <div class="mt-12 text-center">
            <p class="text-sm text-gray-500">
              Powered by <span class="font-semibold text-gray-700">Lumen Analytics</span>
            </p>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
