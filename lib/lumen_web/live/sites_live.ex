defmodule LumenWeb.SitesLive do
  use LumenWeb, :live_view
  alias Lumen.Sites

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    sites = Sites.list_user_sites(user.id)
    {:ok, assign(socket, sites: sites)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="h-full bg-gray-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div class="flex items-center justify-between mb-8">
            <div class="flex items-center space-x-3">
              <.icon name="hero-fire" class="size-8 text-orange-500" />
              <h1 class="text-4xl font-bold text-gray-900">Your Sites</h1>
            </div>
            <.link
              navigate={~p"/sites/new"}
              class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition"
            >
              + Add Site
            </.link>
          </div>

          <%= if Enum.empty?(@sites) do %>
            <div class="bg-white rounded-lg shadow p-8 text-center">
              <p class="text-gray-500 mb-4">No sites yet. Click "Add Site" to get started!</p>
            </div>
          <% else %>
            <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
              <%= for site <- @sites do %>
                <div class="bg-white rounded-lg shadow hover:shadow-lg transition p-6">
                  <.link navigate={~p"/dashboard/#{site.id}"} class="block">
                    <h3 class="text-xl font-semibold text-gray-900">{site.name}</h3>
                    <p class="text-sm text-gray-500 mt-1">{site.domain}</p>
                  </.link>

                  <div class="mt-4 pt-4 border-t border-gray-100">
                    <p class="text-xs text-gray-400 mb-1">Tracking Code</p>
                    <code class="text-xs font-mono text-gray-700 bg-gray-50 p-2 rounded block overflow-x-auto">
                      &lt;script async src="{url(~p"/js/insight.js")}" data-site="{site.public_id}"&gt;&lt;/script&gt;
                    </code>
                  </div>

                  <div class="mt-4 flex space-x-2">
                    <.link
                      navigate={~p"/sites/#{site.id}/edit"}
                      class="text-sm text-blue-600 hover:text-blue-800"
                    >
                      Edit
                    </.link>
                    <button
                      phx-click="delete_site"
                      phx-value-id={site.id}
                      data-confirm="Are you sure you want to delete this site?"
                      class="text-sm text-red-600 hover:text-red-800"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("delete_site", %{"id" => site_id}, socket) do
    user = socket.assigns.current_scope.user
    site = Sites.get_user_site!(user.id, site_id)

    case Sites.delete_site(site) do
      {:ok, _} ->
        sites = Sites.list_user_sites(user.id)

        {:noreply,
         socket
         |> assign(sites: sites)
         |> put_flash(:info, "Site deleted successfully.")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete site.")}
    end
  end
end
