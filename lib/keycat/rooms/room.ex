defmodule Keycat.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :join_code, :string
    field :creator_id, :id

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:join_code])
    |> validate_required([:join_code])
  end
end
