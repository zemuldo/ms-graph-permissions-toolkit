defmodule Scrapper.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do

    create table("permission_types") do
      add :name, :string
    end

    create table("permissions") do
      add :name, :string
      add :doc, :string
      add :privilege_weight, :integer
    end

    create table("endpoints") do
      add :name, :string
      add :permission_id, references(:permissions)
    end
  end
end
