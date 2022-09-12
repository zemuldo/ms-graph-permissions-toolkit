defmodule Scrapper.Schemas.Endpoint do

  use Ecto.Schema
  import Ecto.Changeset

  schema "endpoints" do
    field :name, :string
    field :permission_id, :integer
  end

   def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, [:name])
    |> validate_required([:name])
  end

end
