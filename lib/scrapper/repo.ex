defmodule Scrapper.Repo do
  use Ecto.Repo,
    otp_app: :Scrapper,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    {:ok,
     config
     |> Keyword.put(:hostname, System.get_env("PG_DB_HOST", "10.10.10.4"))
     |> Keyword.put(:username, System.get_env("PG_DB_USER", "postgres"))
     |> Keyword.put(:database, System.get_env("PG_DB_NAME", "ms-graph-permissions-tk-dev"))
     |> Keyword.put(:port, System.get_env("PG_DB_PORT", "5432"))
     |> Keyword.put(:password, System.get_env("PG_DB_PASSWORD", "postgres"))
     |> Keyword.put(:url, System.get_env("PG_DB_URL"))
     |> Keyword.put(
       :pool_size,
       System.get_env("PG_DB_POOL_SIZE", "2") |> String.to_integer()
     )}
  end

  alias Scrapper.Schemas.Permission

  def create_for_doc(%{doc: doc, endpoints: endpoints, permissions: permissions}) do
    Enum.map(endpoints, &create_for_endpoint(&1, permissions, doc))
  end

  def create_for_endpoint(endpoint, permissions, doc) do
    Enum.map(permissions, &create_for_permission(&1, endpoint, doc))
  end

  def create_for_permission(
        %{permission_type: _, scopes: scopes} = permission,
        endpoint,
        doc
      )
      when is_binary(scopes) do
    scopes
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.map(&create_for_scope(&1, permission, endpoint, doc, :scope_on_all))
  end

  def create_for_permission(
        %{permission_type: _, scopes: scopes} = permission,
        endpoint,
        doc
      ) do
    scopes
    |> Enum.with_index()
    |> Enum.map(&create_for_scope(&1, permission, endpoint, doc, :scope_on_all))
  end

  def create_for_permission(
        %{permission_type: _, scopes_on_self: scopes} = permission,
        endpoint,
        doc
      ) do
    scopes
    |> Enum.with_index()
    |> Enum.map(&create_for_scope(&1, permission, endpoint, doc, :scopes_on_self))
  end

  def create_for_permission(
        %{permission_type: _, scopes_on_others: scopes} = permission,
        endpoint,
        doc
      ) do
    scopes
    |> Enum.with_index()
    |> Enum.map(&create_for_scope(&1, permission, endpoint, doc, :scope_on_others))
  end

  def create_for_scope({scope, i}, permission, endpoint, doc, scope_for) when is_binary(scope) do
    %{
      permission_type: Map.get(permission, :permission_type),
      resource: Map.get(permission, :resource),
      endpoint: endpoint,
      doc: doc
    }
    |> Map.put(scope_for, scope)
    |> Map.put(:privilege_weight, i)
    |> create_permission()
  end

  defp create_permission(data) do
    %Permission{}
    |> Permission.changeset(data)
    |> insert!()
  end
end
