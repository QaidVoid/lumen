defmodule LumenWeb.SitesLive do
  use LumenWeb, :live_view
  alias Lumen.{Repo, Sites.Site}

  @impl true
  def mount(_params, _session, socket) do
    sites = Repo.all(Site)
    {:ok, assign(socket, sites: sites)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <h1 class="text-4xl font-bold text-gray-900 mb-8">🔥 Your Sites</h1>

        <%= if Enum.empty?(@sites) do %>
          <div class="bg-white rounded-lg shadow p-8 text-center">
            <p class="text-gray-500 mb-4">No sites yet. Create one in IEx:</p>
            <code class="bg-gray-800 px-4 py-2 rounded text-sm">
              Lumen.Repo.insert(%Lumen.Sites.Site&#123;name: "My Site", domain: "example.com"&#125;)
            </code>
          </div>
        <% else %>
          <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            <%= for site <- @sites do %>
              <.link
                navigate={~p"/dashboard/#{site.id}"}
                class="block bg-white rounded-lg shadow hover:shadow-lg transition p-6"
              >
                <h3 class="text-xl font-semibold text-gray-900">{site.name}</h3>
                <p class="text-sm text-gray-500 mt-1">{site.domain}</p>
                <div class="mt-4 pt-4 border-t border-gray-100">
                  <p class="text-xs text-gray-400">Public ID</p>
                  <code class="text-sm font-mono text-gray-700">{site.public_id}</code>
                </div>
              </.link>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
