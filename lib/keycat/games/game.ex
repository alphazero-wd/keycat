defmodule Keycat.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :min_wpm, :integer
    field :max_wpm, :integer
    field :status, :string
    field :paragraph, :string
    field :time_limit, :integer
    many_to_many :users, Keycat.Accounts.User, join_through: "users_games"

    timestamps()
  end

  def changeset(game, attrs \\ %{}) do
    game
    |> cast(attrs, [:min_wpm, :max_wpm, :status, :time_limit, :paragraph])
    |> validate_required([:time_limit, :paragraph])
    |> validate_number(:min_wpm, greater_than: -1)
    |> validate_number(:max_wpm, greater_than: -1)
    |> validate_number(:time_limit, greater_than: -1)
    |> validate_format(:paragraph, ~r/^[^\n\r]*$/)
    |> validate_inclusion(:status, ~w(lobby playing played))
  end
end
