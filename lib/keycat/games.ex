defmodule Keycat.Games do
  import Ecto.Query
  alias Keycat.{Repo, Games.Game, Games.HistoryGames}

  def join_game(user) do
    afk_game = find_afk_game(user)

    if afk_game do
      afk_game
    else
      game = find_game() || create_game()
      add_user_to_game(game, user)
      game
    end
  end

  def leave_game(user, game) do
    case game.status do
      "lobby" ->
        remove_user_from_game(user, game)
        :ok

      "playing" ->
        {:warn, "Please reconnect again or you'll be penalized."}

      "played" ->
        :ok
    end
  end

  def find_afk_game(user) do
    HistoryGames
    |> join(:inner, [ug], g in Game, on: ug.game_id == g.id)
    |> where([ug, g], ug.user_id == ^user.id and is_nil(ug.time_taken))
    |> select([_ug, g], g)
    |> Repo.one()
  end

  def get_game_by_id(id, user) do
    game = Repo.get!(Game, id) |> Repo.preload([:users])
    already_in_game? = Enum.any?(game.users, &(user.id == &1.id))
    if already_in_game? and game.status != "played", do: game
  end

  defp find_game() do
    HistoryGames
    |> join(:inner, [ug], g in Game, on: ug.game_id == g.id)
    |> where([ug, g], g.status == "lobby")
    |> group_by([_ug, g], g.id)
    |> having([ug, _g], count(ug.user_id) < 5)
    |> select([_ug, g], g)
    |> limit(1)
    |> Repo.one()
  end

  defp add_user_to_game(game, user) do
    has_joined? =
      Repo.exists?(
        from ug in HistoryGames, where: ug.user_id == ^user.id and ug.game_id == ^game.id
      )

    if has_joined? do
      {:error, "You've joined in this room"}
    else
      %HistoryGames{}
      |> HistoryGames.changeset(%{game_id: game.id, user_id: user.id})
      |> Repo.insert()
    end
  end

  defp remove_user_from_game(user, game) do
    query = from ug in HistoryGames, where: ug.user_id == ^user.id and ug.game_id == ^game.id

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
end
