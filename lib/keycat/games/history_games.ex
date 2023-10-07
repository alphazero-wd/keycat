defmodule Keycat.Games.HistoryGames do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "history_games" do
    belongs_to :user, Keycat.Accounts.User, primary_key: true
    belongs_to :game, Keycat.Games.Game, primary_key: true
    field :wpm, :integer
    field :acc, :float
    field :time_taken, :integer
  end

  def changeset(history_games, attrs \\ %{}) do
    history_games
    |> cast(attrs, [:wpm, :acc, :time_taken, :user_id, :game_id])
    |> validate_required([:user_id, :game_id])
    |> validate_number(:wpm, greater_than: -1)
    |> validate_inclusion(:acc, 0..100)
    |> assoc_constraint(:user)
    |> assoc_constraint(:game)
    |> unique_constraint([:user_id, :game_id])
  end
end
