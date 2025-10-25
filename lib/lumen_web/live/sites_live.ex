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

                  <div class="mt-4 pt-4 border-t border-gray-100">
                    <div class="flex items-center justify-between mb-2">
                      <p class="text-xs text-gray-400 flex items-center space-x-1">
                        <.icon name="hero-eye" class="size-3" />
                        <span>Public Dashboard</span>
                      </p>
                      <button
                        phx-click="toggle_public"
                        phx-value-id={site.id}
                        class={"relative inline-flex h-6 w-11 items-center rounded-full transition #{if site.public_dashboard_enabled, do: "bg-blue-600", else: "bg-gray-200"}"}
                      >
                        <span class={"inline-block size-4 transform rounded-full bg-white transition #{if site.public_dashboard_enabled, do: "translate-x-6", else: "translate-x-1"}"}>
                        </span>
                      </button>
                    </div>

                    <%= if site.public_dashboard_enabled do %>
                      <div class="space-y-2">
                        <div class="flex items-center space-x-2">
                          <input
                            type="text"
                            readonly
                            value={url(~p"/public/#{site.share_token}")}
                            class="flex-1 text-xs font-mono bg-gray-50 border border-gray-200 rounded px-2 py-1 text-gray-700"
                            id={"share-link-#{site.id}"}
                          />
                          <button
                            id={"copy-share-link-#{site.id}"}
                            phx-hook="Clipboard"
                            phx-click="copy_share_link"
                            phx-value-url={url(~p"/public/#{site.share_token}")}
                            class="text-blue-600 hover:text-blue-800"
                            title="Copy link"
                          >
                            <.icon name="hero-clipboard" class="size-4" />
                          </button>
                        </div>
                        <button
                          phx-click="regenerate_token"
                          phx-value-id={site.id}
                          data-confirm="This will invalidate the old link. Continue?"
                          class="text-xs text-gray-600 hover:text-gray-800 flex items-center space-x-1"
                        >
                          <.icon name="hero-arrow-path" class="size-3" />
                          <span>Regenerate Link</span>
                        </button>
                      </div>
                    <% else %>
                      <p class="text-xs text-gray-500 mt-1">Enable to share publicly</p>
                    <% end %>
                  </div>

                  <div class="mt-4 pt-4 border-t border-gray-100">
                    <div class="flex items-center justify-between">
                      <div class="flex items-center space-x-2">
                        <.icon name="hero-envelope" class="w-4 h-4 text-gray-400" />
                        <p class="text-xs text-gray-600">Weekly Email Reports</p>
                      </div>
                      <button
                        phx-click="toggle_email_reports"
                        phx-value-id={site.id}
                        class={"relative inline-flex h-6 w-11 items-center rounded-full transition #{if site.email_reports_enabled, do: "bg-blue-600", else: "bg-gray-200"}"}
                      >
                        <span class={"inline-block h-4 w-4 transform rounded-full bg-white transition #{if site.email_reports_enabled, do: "translate-x-6", else: "translate-x-1"}"}>
                        </span>
                      </button>
                    </div>
                    <%= if site.email_reports_enabled do %>
                      <p class="text-xs text-green-600 mt-1 flex items-center space-x-1">
                        <.icon name="hero-check-circle" class="w-3 h-3" />
                        <span>Reports sent every Monday at 9 AM</span>
                      </p>
                    <% end %>
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

  @impl true
  def handle_event("toggle_public", %{"id" => site_id}, socket) do
    user = socket.assigns.current_scope.user
    site = Sites.get_user_site!(user.id, site_id)

    {:ok, _updated_site} = Sites.toggle_public_dashboard(site)

    sites = Sites.list_user_sites(user.id)
    {:noreply, assign(socket, sites: sites)}
  end

  @impl true
  def handle_event("regenerate_token", %{"id" => site_id}, socket) do
    user = socket.assigns.current_scope.user
    site = Sites.get_user_site!(user.id, site_id)

    {:ok, _updated_site} = Sites.regenerate_share_token(site)

    sites = Sites.list_user_sites(user.id)

    {:noreply,
     socket
     |> assign(sites: sites)
     |> put_flash(:info, "Share link regenerated")}
  end

  @impl true
  def handle_event("copy_share_link", %{"url" => url}, socket) do
    {:noreply, push_event(socket, "copy-to-clipboard", %{text: url})}
  end

  @impl true
  def handle_event("toggle_email_reports", %{"id" => site_id}, socket) do
    user = socket.assigns.current_scope.user
    site = Sites.get_user_site!(user.id, site_id)

    {:ok, _updated_site} = Sites.toggle_email_reports(site)

    sites = Sites.list_user_sites(user.id)
    {:noreply, assign(socket, sites: sites)}
  end
end
