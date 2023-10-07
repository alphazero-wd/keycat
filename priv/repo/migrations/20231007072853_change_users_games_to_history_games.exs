defmodule Keycat.Repo.Migrations.ChangeHistoryGamesToHistoryGames do
  use Ecto.Migration

  def change do
    rename(table(:users_games), to: table(:history_games))
  end
end
