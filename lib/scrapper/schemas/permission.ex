defmodule Scrapper.Schemas.Permission do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Scrapper.Repo
  alias Scrapper.Schemas.Permission

  @fields [
    :doc,
    :endpoint,
    :resource,
    :permission_type,
    :scope_on_all,
    :scope_on_others,
    :scope_on_self,
    :privilege_weight
  ]

  schema "permissions" do
    field(:doc, :string)
    field(:endpoint, :string)
    field(:resource, :string)
    field(:permission_type, :string)
    field(:scope_on_self, :string)
    field(:scope_on_others, :string)
    field(:scope_on_all, :string)
    field(:privilege_weight, :integer)
  end

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, @fields)
    |> validate_required([:doc, :endpoint, :permission_type, :privilege_weight])
  end

  def get_endpoints(permission) do
    from(p in Permission)
    |> where(
      [p],
      p.scope_on_all == ^permission or p.scope_on_self == ^permission or
        p.scope_on_others == ^permission
    )
    |> select([p], map(p, @fields))
    |> Repo.all()
  end

  def get_endpoints(permission, permission_type) when is_binary(permission_type) do
    from(p in Permission)
    |> where(
      [p],
      (p.scope_on_all == ^permission or p.scope_on_self == ^permission or
         p.scope_on_others == ^permission) and p.permission_type == ^permission_type
    )
    |> select([p], map(p, @fields))
    |> Repo.all()
  end
  def get_endpoints(permission, permission_types) do
    from(p in Permission)
    |> where(
      [p],
      (p.scope_on_all == ^permission or p.scope_on_self == ^permission or
         p.scope_on_others == ^permission) and p.permission_type in ^permission_types
    )
    |> select([p], map(p, @fields))
    |> Repo.all()
  end

  def get_endpoints(permission, permission_type, endpoint_text) do
    from(p in Permission)
    |> where(
      [p],
      (p.scope_on_all == ^permission or p.scope_on_self == ^permission or
         p.scope_on_others == ^permission) and p.permission_type == ^permission_type and
        like(p.endpoint, ^"%#{String.replace(endpoint_text, "%", "\\%")}%")
    )
    |> select([p], map(p, @fields))
    |> Repo.all()
  end
end
