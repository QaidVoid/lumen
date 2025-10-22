defmodule Lumen.Analytics do
  @moduledoc """
  The Analytics Context - handles event tracking and queries.
  """

  import Ecto.Query, warn: false
  alias Lumen.Repo
  alias Lumen.Analytics.Event
  alias Lumen.Sites.Site

  @doc """
  Tracks a new event.

  ## Examples

      iex> track_event(%{site_id: "uuid", path: "/home"})
      {:ok, %Event{}}

      iex> track_event(%{site_id: "bad", path: ""})
      {:error, %Ecto.Changeset{}}
  """
  def track_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a site by its public id (used by the JS snippet).
  """
  def get_site_by_public_id(public_id) do
    Repo.get_by(Site, public_id: public_id)
  end

  @doc """
  Lists recent events for a site.
  """
  def list_recent_events(site_id, limit \\ 50) do
    Event
    |> where([e], e.site_id == ^site_id)
    |> order_by([e], desc: e.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Gets basic stats for a site.
  """
  def get_site_stats(site_id) do
    today = Date.utc_today()

    total_views =
      Event
      |> where([e], e.site_id == ^site_id)
      |> Repo.aggregate(:count, :id)

    views_today =
      Event
      |> where([e], e.site_id == ^site_id)
      |> where([e], fragment("DATE(?)", e.inserted_at) == ^today)
      |> Repo.aggregate(:count, :id)

    unique_visitors_today =
      Event
      |> where([e], e.site_id == ^site_id)
      |> where([e], fragment("DATE(?)", e.inserted_at) == ^today)
      |> distinct([e], e.ip)
      |> Repo.aggregate(:count, :id)

    %{
      total_views: total_views,
      views_today: views_today,
      unique_visitors_today: unique_visitors_today
    }
  end
end
