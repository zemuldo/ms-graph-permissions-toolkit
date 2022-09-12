defmodule Scrapper.Schemas.Permission do
  
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field(:name, :string)
    field(:doc, :string)
    field(:privilege_weight, :integer)
  end

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, [:name, :doc, :privilege_weight])
    |> validate_required([:name, :doc, :privilege_weight])
  end
end
