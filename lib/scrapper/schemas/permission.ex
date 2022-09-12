defmodule Scrapper.Schemas.Permission do

  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
      field :doc, :string
      field :endpoint, :string
      field :resource, :string
      field :permission_type, :string
      field :scope_on_all, :string
      field :scope_on_others, :string
      field :scope_on_self, :string
      field :privilege_weight, :integer
  end

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, [:doc, :endpoint, :resource, :permission_type, :scope_on_all, :scope_on_others, :scope_on_self, :privilege_weight])
    |> validate_required([:doc, :endpoint, :permission_type, :privilege_weight])
  end
end
