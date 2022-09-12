defmodule Scrapper.Schemas.PermissionType do

  use Ecto.Schema
  import Ecto.Changeset

  schema "permission_types" do
    field :name, :string
  end

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, [:name])
    |> validate_required([:name])
  end

end
