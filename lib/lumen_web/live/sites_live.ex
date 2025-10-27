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
      <div class="min-h-full bg-base-100 py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between mb-8">
            <div class="flex items-center gap-3">
              <.icon name="hero-fire" class="size-8 text-primary" />
              <h1 class="text-4xl font-bold text-base-content">Your Sites</h1>
            </div>

            <.link navigate={~p"/sites/new"} class="btn btn-primary btn-md">
              + Add Site
            </.link>
          </div>
          <%= if Enum.empty?(@sites) do %>
            <div class="card bg-base-100 shadow-lg p-8 text-center">
              <p class="text-base-content/70 mb-3">
                No sites yet. Click “Add Site” to get started!
              </p>
              <.link navigate={~p"/sites/new"} class="btn btn-primary btn-sm">
                Add your first site
              </.link>
            </div>
          <% else %>
            <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
              <%= for site <- @sites do %>
                <div class="card bg-base-100 shadow-sm hover:shadow-md transition-all border border-base-300">
                  <div class="card-body p-5 flex flex-col">
                    <.link navigate={~p"/dashboard/#{site.id}"}>
                      <h3 class="card-title text-lg font-semibold text-base-content truncate">
                        {site.name}
                      </h3>
                      <p class="text-sm text-base-content/70 truncate">{site.domain}</p>
                    </.link>
                    <section class="space-y-2 mt-4">
                      <p class="text-xs text-base-content/60 font-medium">Tracking Code</p>
                      <code class="text-xs font-mono text-base-content bg-base-200 rounded p-2 block overflow-x-auto">
                        &lt;script async src="{url(~p"/js/insight.js")}" data-site="{site.public_id}"&gt;&lt;/script&gt;
                      </code>
                    </section>
                    <section class="space-y-2 mt-4">
                      <div class="flex items-center justify-between">
                        <p class="text-xs text-base-content/60 flex items-center gap-1">
                          <.icon name="hero-eye" class="size-3" />
                          <span>Public Dashboard</span>
                        </p>
                        <input
                          type="checkbox"
                          class="toggle toggle-primary"
                          checked={site.public_dashboard_enabled}
                          phx-click="toggle_public"
                          phx-value-id={site.id}
                        />
                      </div>

                      <div class={[
                        "transition-all overflow-hidden",
                        site.public_dashboard_enabled && "opacity-100 max-h-40",
                        !site.public_dashboard_enabled && "opacity-50 max-h-0"
                      ]}>
                        <div class="space-y-2 mt-2">
                          <div class="flex items-center gap-2">
                            <input
                              type="text"
                              readonly
                              value={url(~p"/public/#{site.share_token}")}
                              class="input input-sm input-bordered w-full font-mono text-xs"
                            />
                            <button
                              id={"copy-share-link-#{site.id}"}
                              phx-hook="Clipboard"
                              phx-click="copy_share_link"
                              phx-value-url={url(~p"/public/#{site.share_token}")}
                              phx-value-id={site.id}
                              class="btn btn-square btn-ghost btn-xs text-primary"
                              title="Copy link"
                            >
                              <.icon name="hero-clipboard" class="size-4" />
                            </button>
                          </div>
                          <button
                            phx-click="regenerate_token"
                            phx-value-id={site.id}
                            data-confirm="This will invalidate the old link. Continue?"
                            class="link text-xs text-base-content/70 hover:text-base-content"
                          >
                            <.icon name="hero-arrow-path" class="size-3" /> Regenerate Link
                          </button>
                        </div>
                      </div>
                    </section>
                    <section class="space-y-2 mt-4">
                      <div class="flex items-center justify-between">
                        <div class="flex items-center gap-2">
                          <.icon name="hero-envelope" class="w-4 h-4 text-base-content/60" />
                          <p class="text-xs text-base-content/80">Weekly Email Reports</p>
                        </div>
                        <input
                          type="checkbox"
                          class="toggle toggle-primary"
                          checked={site.email_reports_enabled}
                          phx-click="toggle_email_reports"
                          phx-value-id={site.id}
                        />
                      </div>
                      <%= if site.email_reports_enabled do %>
                        <p class="text-xs text-success flex items-center gap-1">
                          <.icon name="hero-check-circle" class="w-3 h-3" />
                          Reports sent every Monday at 8 AM
                        </p>
                      <% end %>
                    </section>
                    <div class="card-actions justify-end gap-2 mt-auto pt-2 border-t border-base-300">
                      <.link
                        navigate={~p"/sites/#{site.id}/edit"}
                        class="btn btn-sm btn-outline btn-primary"
                      >
                        Edit
                      </.link>
                      <button
                        phx-click="delete_site"
                        phx-value-id={site.id}
                        data-confirm="Are you sure you want to delete this site?"
                        class="btn btn-sm btn-outline btn-error"
                      >
                        Delete
                      </button>
                    </div>
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
  def handle_event("copy_share_link", %{"url" => url, "id" => site_id}, socket) do
    {:noreply, push_event(socket, "copy-to-clipboard", %{text: url, button_id: "copy-share-link-#{site_id}"})}
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
