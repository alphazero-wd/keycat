defmodule Keycat.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add(:join_code, :string)
      add(:creator_id, references(:users, on_delete: :delete_all))
      timestamps()
    end

    create table(:games) do
      add(:room_id, references(:rooms, on_delete: :delete_all))
      add(:player_id, references(:users, on_delete: :delete_all))
      add(:wpm, :integer, default: 0)
      add(:acc, :integer, default: 0)
      add(:awpm, :integer, default: 0)
      timestamps()
    end

    create(index(:rooms, [:creator_id]))
  end
end
