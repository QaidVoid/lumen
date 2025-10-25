defmodule LumenWeb.SiteFormLive do
  use LumenWeb, :live_view
  alias Lumen.Sites
  alias Lumen.Sites.Site

  @impl true
  def mount(params, _session, socket) do
    user = socket.assigns.current_scope.user

    {site, page_title} =
      case params do
        %{"id" => id} ->
          site = Sites.get_user_site!(user.id, id)
          {site, "Edit Site"}

        _ ->
          {%Site{}, "New Site"}
      end

    changeset = Sites.change_site(site)

    socket =
      socket
      |> assign(:site, site)
      |> assign(:page_title, page_title)
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"site" => site_params}, socket) do
    changeset =
      socket.assigns.site
      |> Sites.change_site(site_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"site" => site_params}, socket) do
    save_site(socket, socket.assigns.site, site_params)
  end

  defp save_site(socket, %Site{id: nil}, site_params) do
    user = socket.assigns.current_scope.user

    case Sites.create_site(user.id, site_params) do
      {:ok, _site} ->
        {:noreply,
         socket
         |> put_flash(:info, "Site created successfully.")
         |> redirect(to: ~p"/sites")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_site(socket, %Site{} = site, site_params) do
    case Sites.update_site(site, site_params) do
      {:ok, _site} ->
        {:noreply,
         socket
         |> put_flash(:info, "Site updated successfully.")
         |> redirect(to: ~p"/sites")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-full bg-base-100 py-8 overflow-y-scroll scrollbar-gutter-stable">
        <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="bg-base-100 rounded-xl shadow-md p-6 border border-base-200">
            <h1 class="text-2xl font-semibold text-base-content mb-6">
              {@page_title}
            </h1>

            <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-4">
              <div>
                <label for="site_name" class="label pb-1">
                  <span class="label-text">Site Name</span>
                </label>
                <.input
                  field={@form[:name]}
                  type="text"
                  placeholder="My Awesome Blog"
                  required
                  class="input input-bordered w-full"
                />
              </div>

              <div>
                <label for="site_domain" class="label pb-1">
                  <span class="label-text">Domain</span>
                </label>
                <.input
                  field={@form[:domain]}
                  type="text"
                  placeholder="example.com"
                  required
                  class="input input-bordered w-full"
                />
                <p class="mt-1 text-xs text-base-content/70">
                  Without http:// or https://
                </p>
              </div>

              <div class="flex items-center justify-between pt-3">
                <.link
                  navigate={~p"/sites"}
                  class="btn btn-ghost btn-sm"
                >
                  Cancel
                </.link>

                <button type="submit" class="btn btn-primary btn-sm">
                  Save Site
                </button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
