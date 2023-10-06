defmodule Keycat.Games.UsersGames do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "users_games" do
    belongs_to :user, Keycat.Accounts.User, primary_key: true
    belongs_to :game, Keycat.Games.Game, primary_key: true
    field :wpm, :integer
    field :acc, :float
  end

  def changeset(users_games, attrs \\ %{}) do
    users_games
    |> cast(attrs, [:wpm, :acc, :user_id, :game_id])
    |> validate_required([:user_id, :game_id])
    |> validate_number(:wpm, greater_than: -1)
    |> validate_inclusion(:acc, 0..100)
    |> assoc_constraint(:user)
    |> assoc_constraint(:game)
    |> unique_constraint([:user_id, :game_id])
  end
end
