defmodule Lumen.Analytics.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :path, :string
    field :referrer, :string
    field :ip, :string
    field :user_agent, :string

    belongs_to :site, Lumen.Sites.Site, type: :binary_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:site_id, :path, :referrer, :ip, :user_agent])
    |> validate_required([:site_id, :path])
  end
end
