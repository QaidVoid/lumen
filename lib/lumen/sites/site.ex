defmodule Lumen.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sites" do
    field :name, :string
    field :domain, :string
    field :public_id, :string

    belongs_to :user, Lumen.Accounts.User, type: :integer
    has_many :events, Lumen.Analytics.Event

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(attrs, [:name, :domain, :public_id, :user_id])
    |> validate_required([:name, :domain, :user_id])
    |> unique_constraint(:public_id)
    |> unique_constraint(:domain)
    |> generate_public_id()
    |> validate_required([:public_id])
  end

  defp generate_public_id(changeset) do
    if get_field(changeset, :public_id) do
      changeset
    else
      put_change(changeset, :public_id, generate_random_id())
    end
  end

  defp generate_random_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false) |> binary_part(0, 8)
  end
end
