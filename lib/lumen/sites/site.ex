defmodule Lumen.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sites" do
    field :name, :string
    field :domain, :string
    field :public_id, :string
    field :share_token, :string
    field :public_dashboard_enabled, :boolean, default: false
    field :email_reports_enabled, :boolean, default: false

    belongs_to :user, Lumen.Accounts.User, type: :integer
    has_many :events, Lumen.Analytics.Event

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(attrs, [:name, :domain, :public_id, :user_id, :public_dashboard_enabled, :email_reports_enabled])
    |> validate_required([:name, :domain, :user_id])
    |> unique_constraint(:public_id)
    |> unique_constraint(:domain)
    |> unique_constraint(:share_token)
    |> generate_public_id()
    |> generate_share_token()
    |> validate_required([:public_id])
  end

  defp generate_public_id(changeset) do
    if get_field(changeset, :public_id) do
      changeset
    else
      put_change(changeset, :public_id, generate_random_id())
    end
  end

  defp generate_share_token(changeset) do
    if get_field(changeset, :share_token) do
      changeset
    else
      put_change(changeset, :share_token, generate_random_token())
    end
  end

  defp generate_random_id do
    :crypto.strong_rand_bytes(8)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, 8)
  end

  defp generate_random_token do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end
