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
end
