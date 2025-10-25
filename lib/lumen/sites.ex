defmodule Lumen.Sites do
  @moduledoc """
  The Sites context - manages user sites.
  """

  import Ecto.Query, warn: false
  alias Lumen.Repo
  alias Lumen.Sites.Site

  @doc """
  Returns the list of sites for a user.
  """
  def list_user_sites(user_id) do
    Site
    |> where([s], s.user_id == ^user_id)
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single site.
  """
  def get_site!(id), do: Repo.get!(Site, id)

  @doc """
  Gets a site by user_id and site_id.
  """
  def get_user_site!(user_id, site_id) do
    Site
    |> where([s], s.id == ^site_id and s.user_id == ^user_id)
    |> Repo.one!()
  end

  @doc """
  Creates a site.
  """
  def create_site(user_id, attrs \\ %{}) do
    attrs = Map.put(attrs, "user_id", user_id)

    result =
      %Site{}
      |> Site.changeset(attrs)
      |> Repo.insert()

    result
  end

  @doc """
  Updates a site.
  """
  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a site.
  """
  def delete_site(%Site{} = site) do
    Repo.delete(site)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking site changes.
  """
  def change_site(%Site{} = site, attrs \\ %{}) do
    Site.changeset(site, attrs)
  end

  @doc """
  Gets a site by share token (for public dashboard).
  """
  def get_site_by_share_token(share_token) do
    Site
    |> where([s], s.share_token == ^share_token and s.public_dashboard_enabled == true)
    |> Repo.one()
  end

  @doc """
  Toggles public dashboard access for a site.
  """
  def toggle_public_dashboard(%Site{} = site) do
    site
    |> change_site(%{public_dashboard_enabled: !site.public_dashboard_enabled})
    |> Repo.update()
  end

  @doc """
  Regenerates the share token for a site.
  """
  def regenerate_share_token(%Site{} = site) do
    new_token =
      :crypto.strong_rand_bytes(16)
      |> Base.url_encode64(padding: false)

    site
    |> change_site(%{share_token: new_token})
    |> Repo.update()
  end

  @doc """
  Toggles email reports for a site.
  """
  def toggle_email_reports(%Site{} = site) do
    site
    |> change_site(%{email_reports_enabled: !site.email_reports_enabled})
    |> Repo.update()
  end
end
