defmodule LumenWeb.DashboardLive do
  use LumenWeb, :live_view
  alias Lumen.{Analytics, Sites, Repo}

  @impl true
  def mount(%{"site_id" => site_id}, _session, socket) do
    site = Repo.get!(Sites.Site, site_id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Lumen.PubSub, "site:#{site.id}")
    end

    socket =
      socket
      |> assign(:site, site)
      |> assign(:loading, true)
      |> load_dashboard_data()

    {:ok, socket}
  end

  @impl true
  def handle_info({:new_event, _event}, socket) do
    {:noreply, load_dashboard_data(socket)}
  end

  defp load_dashboard_data(socket) do
    site = socket.assigns.site
    stats = Analytics.get_site_stats(site.id)
    recent_events = Analytics.list_recent_events(site.id, 20)
    top_pages = Analytics.get_top_pages(site.id, limit: 10)

    socket
    |> assign(:stats, stats)
    |> assign(:recent_events, recent_events)
    |> assign(:top_pages, top_pages)
    |> assign(:loading, false)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="bg-white shadow">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-3xl font-bold text-gray-900">{@site.name}</h1>
              <p class="text-sm text-gray-500 mt-1">{@site.domain}</p>
            </div>
            <div class="flex items-center space-x-2">
              <div class="h-2 w-2 bg-green-500 rounded-full animate-pulse"></div>
              <span class="text-sm text-gray-600">Live</span>
            </div>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <.stat_card
            title="Total Views"
            value={@stats.total_views}
            icon="📊"
          />
          <.stat_card
            title="Views Today"
            value={@stats.views_today}
            icon="🔥"
          />
          <.stat_card
            title="Unique Visitors Today"
            value={@stats.unique_visitors_today}
            icon="👥"
          />
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">📄 Top Pages</h2>
            <div class="space-y-3">
              <%= if Enum.empty?(@top_pages) do %>
                <p class="text-gray-500 text-sm">No data yet. Visit some pages!</p>
              <% else %>
                <%= for {path, count} <- @top_pages do %>
                  <div class="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
                    <span class="text-sm text-gray-700 font-mono">{path}</span>
                    <span class="text-sm font-semibold text-gray-900">{count} views</span>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
          <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">⚡ Recent Events</h2>
            <div class="space-y-2 max-h-96 overflow-y-auto">
              <%= if Enum.empty?(@recent_events) do %>
                <p class="text-gray-500 text-sm">Waiting for events...</p>
              <% else %>
                <%= for event <- @recent_events do %>
                  <div class="flex items-start space-x-3 text-sm p-2 hover:bg-gray-50 rounded">
                    <span class="text-gray-400">{format_time(event.inserted_at)}</span>
                    <span class="text-gray-700 font-mono flex-1">{event.path}</span>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp stat_card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-6">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-gray-600">{@title}</p>
          <p class="text-3xl font-bold text-gray-900 mt-2">{@value}</p>
        </div>
        <div class="text-4xl">{@icon}</div>
      </div>
    </div>
    """
  end

  defp format_time(datetime) do
    datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> Calendar.strftime("%H:%M:%S")
  end
end
