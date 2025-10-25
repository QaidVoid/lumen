defmodule LumenWeb.DashboardComponents do
  use Phoenix.Component
  use LumenWeb, :html

  @doc """
  Renders the dashboard header with site info and controls.
  """
  attr :site, :map, required: true, doc: "the site to display"
  attr :date_range, :integer, default: 7, doc: "the date range to display"
  attr :show_back_link, :boolean, default: false, doc: "whether to show the back link"
  attr :show_export, :boolean, default: false, doc: "whether to show the export link"
  attr :is_public, :boolean, default: false, doc: "whether the site is public"

  def dashboard_header(assigns) do
    ~H"""
    <div class="bg-base-100 shadow mb-8 border border-base-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 flex items-center justify-between">
        <div>
          <%= if @show_back_link do %>
            <.link
              navigate={~p"/sites"}
              class="text-sm text-primary hover:underline inline-flex items-center gap-1 mb-2"
            >
              <.icon name="hero-arrow-left" class="size-4" />
              <span>Back to Sites</span>
            </.link>
          <% end %>

          <%= if @is_public do %>
            <div class="flex items-center gap-2 mb-2 text-sm text-base-content/70">
              <.icon name="hero-eye" class="size-5" />
              <span>Public Dashboard</span>
            </div>
          <% end %>

          <h1 class="text-3xl font-bold text-base-content">{@site.name}</h1>
          <p class="text-sm text-base-content/70 mt-1">{@site.domain}</p>
        </div>

        <div class="flex items-center gap-4">
          <.date_range_selector date_range={@date_range} />

          <%= if @show_export do %>
            <button id="export-csv" class="btn btn-success btn-sm gap-2">
              <.icon name="hero-arrow-down-tray" class="size-5" /> Export CSV
            </button>
          <% end %>

          <div class="flex items-center gap-2">
            <div class="size-2 bg-success rounded-full animate-pulse"></div>
            <span class="text-sm text-base-content/80">Live</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders date range selector buttons.
  """
  attr :date_range, :integer, required: true, doc: "the date range to display"

  def date_range_selector(assigns) do
    ~H"""
    <div class="join border border-base-content/10 rounded-md shadow-md">
      <%= for range <- [7, 30, 90] do %>
        <button
          phx-click="change_date_range"
          phx-value-range={range}
          class={[
            "join-item btn btn-sm rounded-md border-none",
            @date_range == range && "btn-primary",
            @date_range != range && "btn-outline"
          ]}
        >
          {range} days
        </button>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders the stats cards section.
  """
  attr :stats, :map, required: true, doc: "the stats to display"
  attr :date_range, :integer, required: true, doc: "the date range to display"

  def stats_cards(assigns) do
    ~H"""
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <.stat_card
        title="Total Views"
        value={@stats.total_views}
        icon="hero-chart-bar"
        icon_class="text-error"
        subtitle={"Last #{@date_range} days"}
      />
      <.stat_card
        title="Unique Visitors"
        value={@stats.unique_visitors}
        icon="hero-users"
        icon_class="text-primary"
        subtitle={"Last #{@date_range} days"}
      />
      <.stat_card
        title="Avg. Views/Day"
        value={@stats.avg_views_per_day}
        icon="hero-arrow-trending-up"
        icon_class="text-success"
        subtitle={"Last #{@date_range} days"}
      />
    </div>
    """
  end

  defp stat_card(assigns) do
    ~H"""
    <div class="bg-base-100 rounded-lg shadow p-6 hover:shadow-lg transition border border-base-200">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-base-content/80">{@title}</p>
          <p class="text-3xl font-bold text-base-content mt-2">{@value}</p>
          <p class="text-xs text-base-content/70 mt-1">{@subtitle}</p>
        </div>
        <div class="text-4xl">
          <.icon name={@icon} class={"#{@icon_class} size-10"} />
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders the pageviews chart.
  """
  attr :chart_data, :map, required: true, doc: "the chart data to display"

  def pageviews_chart(assigns) do
    ~H"""
    <div class="bg-base-100 rounded-xl shadow p-6 mb-8 border border-base-200 transition-colors">
      <div class="flex items-center space-x-2 mb-4">
        <.icon name="hero-chart-bar" class="size-5 text-primary" />
        <h2 class="text-lg font-semibold text-base-content">Pageviews Over Time</h2>
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

  @doc """
  Renders the top pages list.
  """
  attr :top_pages, :list, required: true, doc: "the top pages to display"

  def top_pages(assigns) do
    ~H"""
    <div class="bg-base-100 rounded-xl shadow p-6 border border-base-200 transition-colors">
      <div class="flex items-center space-x-2 mb-4">
        <.icon name="hero-document-text" class="size-5 text-primary" />
        <h2 class="text-lg font-semibold text-base-content">Top Pages</h2>
      </div>
      <div class="space-y-3">
        <%= if Enum.empty?(@top_pages) do %>
          <p class="text-base-content/70 text-sm">No data yet. Visit some pages!</p>
        <% else %>
          <%= for {path, count} <- @top_pages do %>
            <div class="flex items-center justify-between py-2 border-b border-base-200 last:border-0">
              <span class="text-sm text-base-content font-mono truncate">{path}</span>
              <span class="text-sm font-semibold text-base-content">{count} views</span>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders the top referrers list.
  """
  attr :top_referrers, :list, required: true, doc: "the top referrers to display"

  def top_referrers(assigns) do
    ~H"""
    <div class="bg-base-100 rounded-xl shadow p-6 border border-base-200 transition-colors">
      <div class="flex items-center space-x-2 mb-4">
        <.icon name="hero-globe-alt" class="size-5 text-primary" />
        <h2 class="text-lg font-semibold text-base-content">Top Referrers</h2>
      </div>
      <div class="space-y-3">
        <%= if Enum.empty?(@top_referrers) do %>
          <p class="text-base-content/70 text-sm">No referrer data yet</p>
        <% else %>
          <%= for {referrer, count, percentage} <- @top_referrers do %>
            <div class="py-2 border-b border-base-200 last:border-0">
              <div class="flex items-center justify-between mb-1">
                <span class="text-sm text-base-content truncate flex-1">
                  {format_referrer(referrer)}
                </span>
                <span class="text-sm font-semibold text-base-content ml-4">{count}</span>
              </div>
              <div class="w-full bg-base-200 rounded-full h-1.5">
                <div class="bg-primary h-1.5 rounded-full" style={"width: #{percentage}%"}></div>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders the browser stats.
  """
  attr :browser_stats, :list, required: true, doc: "the browser stats to display"

  def browser_stats(assigns) do
    ~H"""
    <div class="bg-base-100 rounded-xl shadow p-6 border border-base-200 transition-colors">
      <div class="flex items-center space-x-2 mb-4">
        <.icon name="hero-globe-alt" class="size-5 text-success" />
        <h2 class="text-lg font-semibold text-base-content">Browsers</h2>
      </div>
      <div class="space-y-3">
        <%= if Enum.empty?(@browser_stats) do %>
          <p class="text-base-content/70 text-sm">No browser data yet</p>
        <% else %>
          <%= for {browser, count} <- @browser_stats do %>
            <div class="flex items-center justify-between py-2 border-b border-base-200 last:border-0">
              <span class="text-sm text-base-content">{browser}</span>
              <span class="text-sm font-semibold text-base-content">{count}</span>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders the device stats.
  """
  attr :device_stats, :list, required: true, doc: "the device stats to display"

  def device_stats(assigns) do
    ~H"""
    <div class="bg-base-100 rounded-xl shadow p-6 border border-base-200 transition-colors">
      <div class="flex items-center space-x-2 mb-4">
        <.icon name="hero-device-phone-mobile" class="size-5 text-warning" />
        <h2 class="text-lg font-semibold text-base-content">Devices</h2>
      </div>
      <div class="space-y-3">
        <%= if Enum.empty?(@device_stats) do %>
          <p class="text-base-content/70 text-sm">No device data yet</p>
        <% else %>
          <%= for {device, count} <- @device_stats do %>
            <div class="flex items-center justify-between py-2 border-b border-base-200 last:border-0">
              <span class="text-sm text-base-content">{device}</span>
              <span class="text-sm font-semibold text-base-content">{count}</span>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders the recent events list.
  """
  attr :recent_events, :list, required: true, doc: "the recent events to display"

  def recent_events(assigns) do
    ~H"""
    <div class="bg-base-100 rounded-xl shadow p-6 border border-base-200 transition-colors">
      <div class="flex items-center space-x-2 mb-4">
        <.icon name="hero-bolt" class="size-5 text-warning" />
        <h2 class="text-lg font-semibold text-base-content">Recent Events</h2>
      </div>
      <div class="space-y-2 max-h-96 overflow-y-auto">
        <%= if Enum.empty?(@recent_events) do %>
          <p class="text-base-content/70 text-sm">Waiting for events...</p>
        <% else %>
          <%= for event <- @recent_events do %>
            <div class="flex items-start space-x-3 text-sm p-2 rounded transition hover:bg-base-200/50">
              <span class="text-base-content/60 font-mono">{format_time(event.inserted_at)}</span>
              <span class="text-base-content font-mono flex-1 truncate">{event.path}</span>
              <%= if event.referrer do %>
                <span class="text-base-content/70 text-xs">{format_referrer(event.referrer)}</span>
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
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
