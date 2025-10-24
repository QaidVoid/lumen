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
  Gets top pages by view count.
  """
  def get_top_pages(site_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)

    Event
    |> where([e], e.site_id == ^site_id)
    |> group_by([e], e.path)
    |> select([e], {e.path, count(e.id)})
    |> order_by([e], desc: count(e.id))
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Gets pageviews grouped by date.
  """
  def get_pageviews_by_date(site_id, date_range \\ 7) do
    start_date = Date.utc_today() |> Date.add(-date_range)

    Event
    |> where([e], e.site_id == ^site_id)
    |> where([e], fragment("DATE(?)", e.inserted_at) >= ^start_date)
    |> group_by([e], fragment("DATE(?)", e.inserted_at))
    |> select([e], {fragment("DATE(?)", e.inserted_at), count(e.id)})
    |> order_by([e], asc: fragment("DATE(?)", e.inserted_at))
    |> Repo.all()
    |> fill_missing_dates(start_date, Date.utc_today())
  end

  defp fill_missing_dates(data, start_date, end_date) do
    data_map = Map.new(data)

    # Generate all dates in range
    Date.range(start_date, end_date)
    |> Enum.map(fn date ->
      {date, Map.get(data_map, date, 0)}
    end)
  end

  @doc """
  Gets top referrers with count and percentage.
  """
  def get_top_referrers(site_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)

    # Get total views for percentage calculation
    total_views =
      Event
      |> where([e], e.site_id == ^site_id)
      |> where([e], not is_nil(e.referrer) and e.referrer != "")
      |> Repo.aggregate(:count, :id)

    referrers =
      Event
      |> where([e], e.site_id == ^site_id)
      |> where([e], not is_nil(e.referrer) and e.referrer != "")
      |> group_by([e], e.referrer)
      |> select([e], {e.referrer, count(e.id)})
      |> order_by([e], desc: count(e.id))
      |> limit(^limit)
      |> Repo.all()

    # Add percentage
    Enum.map(referrers, fn {referrer, count} ->
      percentage = if total_views > 0, do: Float.round(count / total_views * 100, 1), else: 0
      {referrer, count, percentage}
    end)
  end

  @doc """
  Gets browser breakdown from user agents.
  """
  def get_browser_stats(site_id) do
    Event
    |> where([e], e.site_id == ^site_id)
    |> where([e], not is_nil(e.user_agent) and e.user_agent != "")
    |> select([e], e.user_agent)
    |> Repo.all()
    |> Enum.map(&parse_browser/1)
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_browser, count} -> count end, :desc)
    |> Enum.take(5)
  end

  defp parse_browser(user_agent) do
    ua = String.downcase(user_agent)

    cond do
      String.contains?(ua, "edg") -> "Edge"
      String.contains?(ua, "chrome") and not String.contains?(ua, "edg") -> "Chrome"
      String.contains?(ua, "firefox") -> "Firefox"
      String.contains?(ua, "safari") and not String.contains?(ua, "chrome") -> "Safari"
      String.contains?(ua, "opera") or String.contains?(ua, "opr") -> "Opera"
      true -> "Other"
    end
  end

  @doc """
  Gets device type breakdown.
  """
  def get_device_stats(site_id) do
    Event
    |> where([e], e.site_id == ^site_id)
    |> where([e], not is_nil(e.user_agent) and e.user_agent != "")
    |> select([e], e.user_agent)
    |> Repo.all()
    |> Enum.map(&parse_device/1)
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_device, count} -> count end, :desc)
  end

  defp parse_device(user_agent) do
    ua = String.downcase(user_agent)

    cond do
      String.contains?(ua, "mobile") or String.contains?(ua, "android") -> "📱 Mobile"
      String.contains?(ua, "tablet") or String.contains?(ua, "ipad") -> "📱 Tablet"
      true -> "💻 Desktop"
    end
  end

  @doc """
  Gets site stats
  """
  def get_site_stats(site_id, date_range \\ :today) do
    {start_date, end_date} =
      case date_range do
        :today -> {Date.utc_today(), Date.utc_today()}
        :week -> {Date.utc_today() |> Date.add(-7), Date.utc_today()}
        :month -> {Date.utc_today() |> Date.add(-30), Date.utc_today()}
        :all -> {~D[2000-01-01], Date.utc_today()}
        days when is_integer(days) -> {Date.utc_today() |> Date.add(-days), Date.utc_today()}
      end

    base_query =
      Event
      |> where([e], e.site_id == ^site_id)
      |> where([e], fragment("DATE(?)", e.inserted_at) >= ^start_date)
      |> where([e], fragment("DATE(?)", e.inserted_at) <= ^end_date)

    total_views = base_query |> Repo.aggregate(:count, :id)

    unique_visitors =
      base_query
      |> distinct([e], e.ip)
      |> Repo.aggregate(:count, :id)

    days_in_range = Date.diff(end_date, start_date) + 1

    avg_views_per_day =
      if total_views > 0, do: Float.round(total_views / days_in_range, 1), else: 0

    %{
      total_views: total_views,
      unique_visitors: unique_visitors,
      avg_views_per_day: avg_views_per_day,
      date_range: {start_date, end_date}
    }
  end
end
