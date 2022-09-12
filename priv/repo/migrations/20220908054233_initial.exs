defmodule Scrapper.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do

    create table("permissions") do
      add :doc, :text
      add :endpoint, :text
      add :resource, :text
      add :permission_type, :text
      add :scope_on_all, :text
      add :scope_on_others, :text
      add :scope_on_self, :text
      add :privilege_weight, :integer
    end
  end
end
