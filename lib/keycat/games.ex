defmodule Keycat.Games do
  import Ecto.Query
  alias Keycat.{Repo, Games.Game, Games.HistoryGames}

  def join_game(user) do
    game = find_game() || create_game()
    add_user_to_game(game, user)
    game
  end

  def leave_game(user_id, game_id) do
    game = Repo.get!(Game, game_id)

    if game.status in ["lobby", "playing"] do
      remove_user_from_game(user_id, game.id)
    end

    :ok
  end

  def get_game_by_id(id, user) do
    HistoryGames
    |> join(:inner, [hg], g in Game, on: hg.game_id == g.id)
    |> where([hg, g], hg.user_id == ^user.id and hg.game_id == ^id and g.status == "lobby")
    |> select([_hg, g], g)
    |> Repo.one()
  end

  defp find_game() do
    HistoryGames
    |> join(:inner, [hg], g in Game, on: hg.game_id == g.id)
    |> where([_hg, g], g.status == "lobby")
    |> group_by([_hg, g], g.id)
    |> having([hg, _g], count(hg.user_id) < 5)
    |> select([_hg, g], g)
    |> limit(1)
    |> Repo.one()
  end

  defp add_user_to_game(game, user) do
    has_joined? =
      Repo.exists?(
        from hg in HistoryGames, where: hg.user_id == ^user.id and hg.game_id == ^game.id
      )

    if has_joined? do
      {:error, "You've joined in this room"}
    else
      %HistoryGames{}
      |> HistoryGames.changeset(%{game_id: game.id, user_id: user.id})
      |> Repo.insert()
    end
  end

  defp remove_user_from_game(user_id, game_id) do
    query = from hg in HistoryGames, where: hg.user_id == ^user_id and hg.game_id == ^game_id

    Repo.delete_all(query)
  end

  defp create_game() do
    typing_text =
      "Since they are still preserved in the rocks for us to see, they must have been formed quite recently, that is, geologically speaking. What can explain these striations and their common orientation? Did you ever hear about the Great Ice Age or the Pleistocene Epoch? Less than one million years ago, in fact, some 12,000 years ago, an ice sheet many thousands of feet thick rode over Burke Mountain in a southeastward direction. The many boulders frozen to the underside of the ice sheet tended to scratch the rocks over which they rode. The scratches or striations seen in the park rocks were caused by these attached boulders. The ice sheet also plucked and rounded Burke Mountain into the shape it possesses today."

    time_limit = trunc(String.length(typing_text) / 5 / 39) * 60

    {:ok, game} =
      %Game{}
      |> Game.changeset(%{min_wpm: 0, max_wpm: 49, paragraph: typing_text, time_limit: time_limit})
      |> Repo.insert()

    game
  end

  def update_game_status(id, status) do
    game = Repo.get!(Game, id)

    game
    |> Game.changeset(%{status: status})
    |> Repo.update()
  end
end
