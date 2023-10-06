defmodule Keycat.GamesFixtures do
  alias Keycat.{Repo, Games.Game, Games.UsersGames}

  def valid_game_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      min_wpm: 0,
      max_wpm: 49,
      time_limit: 100,
      paragraph: "lorem ipsum",
      status: "lobby"
    })
  end

  def game_fixture(attrs \\ %{}) do
    game_params = attrs |> valid_game_attributes()

    {:ok, game} =
      Game.changeset(%Game{}, game_params)
      |> Repo.insert()

    game
  end

  def add_user_to_game(user, game, attrs \\ %{}) do
    merge_attrs = Enum.into(attrs, %{game_id: game.id, user_id: user.id})

    %UsersGames{}
    |> UsersGames.changeset(merge_attrs)
    |> Repo.insert()
  end
end
