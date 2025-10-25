defmodule LumenWeb.DashboardLive do
  use LumenWeb, :live_view
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

  defp load_dashboard_data(socket) do
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

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-gray-50">
        <div class="bg-white shadow">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div class="flex items-center justify-between">
              <div>
                <.link
                  navigate={~p"/sites"}
                  class="text-sm text-blue-600 hover:text-blue-800 mb-2 inline-block"
                >
                  <.icon name="hero-arrow-left" class="size-4" />
                  <span>Back to Sites</span>
                </.link>
                <h1 class="text-3xl font-bold text-gray-900">{@site.name}</h1>
                <p class="text-sm text-gray-500 mt-1">{@site.domain}</p>
              </div>
              <div class="flex items-center space-x-4">
                <div class="inline-flex rounded-lg border border-gray-300 bg-white">
                  <button
                    phx-click="change_date_range"
                    phx-value-range="7"
                    class={[
                      "px-4 py-2 text-sm font-medium rounded-l-lg transition",
                      @date_range == 7 && "bg-blue-600 text-white",
                      @date_range != 7 && "text-gray-700 hover:bg-gray-50"
                    ]}
                  >
                    7 days
                  </button>
                  <button
                    phx-click="change_date_range"
                    phx-value-range="30"
                    class={[
                      "px-4 py-2 text-sm font-medium border-x border-gray-300 transition",
                      @date_range == 30 && "bg-blue-600 text-white",
                      @date_range != 30 && "text-gray-700 hover:bg-gray-50"
                    ]}
                  >
                    30 days
                  </button>
                  <button
                    phx-click="change_date_range"
                    phx-value-range="90"
                    class={[
                      "px-4 py-2 text-sm font-medium rounded-r-lg transition",
                      @date_range == 90 && "bg-blue-600 text-white",
                      @date_range != 90 && "text-gray-700 hover:bg-gray-50"
                    ]}
                  >
                    90 days
                  </button>
                </div>

                <div class="flex items-center space-x-2">
                  <div class="h-2 w-2 bg-green-500 rounded-full animate-pulse"></div>
                  <span class="text-sm text-gray-600">Live</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <.stat_card
              title="Total Views"
              value={@stats.total_views}
              icon="chart-bar"
              subtitle={"Last #{@date_range} days"}
              icon_class="text-red-500"
            />
            <.stat_card
              title="Unique Visitors Today"
              value={@stats.unique_visitors}
              icon="users"
              subtitle={"Last #{@date_range} days"}
              icon_class="text-blue-500"
            />
            <.stat_card
              title="Avg. Views/Day"
              value={@stats.avg_views_per_day}
              icon="arrow-trending-up"
              subtitle={"Last #{@date_range} days"}
              icon_class="text-green-500"
            />
          </div>

          <div class="bg-white rounded-lg shadow p-6 mb-8">
            <div class="flex items-center space-x-2 mb-4">
              <.icon name="hero-chart-bar" class="size-5 text-gray-700" />
              <h2 class="text-lg font-semibold text-gray-900">Pageviews Over Time</h2>
            </div>
            <div style="position: relative; height: 300px;">
              <canvas
                id="pageviews-chart"
                phx-hook="Chart"
                phx-update="ignore"
                data-chart={Jason.encode!(chart_config(@chart_data))}
              >
              </canvas>
            </div>
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 py-4">
            <div class="bg-white rounded-lg shadow p-6">
              <div class="flex items-center space-x-2 mb-4">
                <.icon name="hero-document-text" class="size-5 text-blue-700" />
                <h2 class="text-lg font-semibold text-gray-900">Top Pages</h2>
              </div>
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
              <div class="flex items-center space-x-2 mb-4">
                <.icon name="hero-globe-alt" class="size-5 text-blue-700" />
                <h2 class="text-lg font-semibold text-gray-900">Top Referrers</h2>
              </div>
              <div class="space-y-3">
                <%= if Enum.empty?(@top_referrers) do %>
                  <p class="text-gray-500 text-sm">No referrer data yet</p>
                <% else %>
                  <%= for {referrer, count, percentage} <- @top_referrers do %>
                    <div class="py-2 border-b border-gray-100 last:border-0">
                      <div class="flex items-center justify-between mb-1">
                        <span class="text-sm text-gray-700 truncate flex-1">
                          {format_referrer(referrer)}
                        </span>
                        <span class="text-sm font-semibold text-gray-900 ml-4">{count}</span>
                      </div>
                      <div class="w-full bg-gray-200 rounded-full h-1.5">
                        <div class="bg-blue-600 h-1.5 rounded-full" style={"width: #{percentage}%"}>
                        </div>
                      </div>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8 py-4">
            <div class="bg-white rounded-lg shadow p-6">
              <div class="flex items-center space-x-2 mb-4">
                <.icon name="hero-globe-alt" class="size-5 text-emerald-700" />
                <h2 class="text-lg font-semibold text-gray-900">Browsers</h2>
              </div>
              <div class="space-y-3">
                <%= if Enum.empty?(@browser_stats) do %>
                  <p class="text-gray-500 text-sm">No browser data yet</p>
                <% else %>
                  <%= for {browser, count} <- @browser_stats do %>
                    <div class="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
                      <span class="text-sm text-gray-700">{browser}</span>
                      <span class="text-sm font-semibold text-gray-900">{count}</span>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>

            <div class="bg-white rounded-lg shadow p-6">
              <div class="flex items-center space-x-2 mb-4">
                <.icon name="hero-device-phone-mobile" class="size-5 text-orange-700" />
                <h2 class="text-lg font-semibold text-gray-900">Devices</h2>
              </div>
              <div class="space-y-3">
                <%= if Enum.empty?(@device_stats) do %>
                  <p class="text-gray-500 text-sm">No device data yet</p>
                <% else %>
                  <%= for {device, count} <- @device_stats do %>
                    <div class="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
                      <span class="text-sm text-gray-700">{device}</span>
                      <span class="text-sm font-semibold text-gray-900">{count}</span>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-lg shadow p-6">
            <div class="flex items-center space-x-2 mb-4">
              <.icon name="hero-bolt" class="size-5 text-yellow-500" />
              <h2 class="text-lg font-semibold text-gray-900">Recent Events</h2>
            </div>
            <div class="space-y-2 max-h-96 overflow-y-auto">
              <%= if Enum.empty?(@recent_events) do %>
                <p class="text-gray-500 text-sm">Waiting for events...</p>
              <% else %>
                <%= for event <- @recent_events do %>
                  <div class="flex items-start space-x-3 text-sm p-2 hover:bg-gray-50 rounded transition">
                    <span class="text-gray-400 font-mono">{format_time(event.inserted_at)}</span>
                    <span class="text-gray-700 font-mono flex-1">{event.path}</span>
                    <%= if event.referrer do %>
                      <span class="text-gray-500 text-xs">{format_referrer(event.referrer)}</span>
                    <% end %>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp stat_card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-gray-600">{@title}</p>
          <p class="text-3xl font-bold text-gray-900 mt-2">{@value}</p>
          <%= if @subtitle do %>
            <p class="text-xs text-gray-500 mt-1">{@subtitle}</p>
          <% end %>
        </div>
        <div class="text-4xl">
          <.icon name={"hero-#{@icon}"} class={"#{@icon_class} size-10"} />
        </div>
      </div>
    </div>
    """
  end

  defp chart_config(data) do
    %{
      type: "line",
      data: data,
      options: %{
        responsive: true,
        maintainAspectRatio: false,
        plugins: %{
          legend: %{display: false}
        },
        scales: %{
          y: %{
            beginAtZero: true,
            ticks: %{precision: 0}
          }
        }
      }
    }
  end

  defp format_referrer(referrer) do
    referrer
    |> String.replace(~r/^https?:\/\//, "")
    |> String.replace(~r/^www\./, "")
    |> String.split("/")
    |> List.first()
  end

  defp format_time(datetime) do
    datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> Calendar.strftime("%H:%M:%S")
  end
end
