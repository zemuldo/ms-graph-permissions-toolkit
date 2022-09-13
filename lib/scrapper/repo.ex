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

  def create_for_doc(%{doc: doc, endpoints: endpoints, scheme: scheme, permissions: permissions}) do
    # Endpoints listing not matching permissions https://docs.microsoft.com/en-us/graph/api/opentypeextension-delete?view=graph-rest-1.0&tabs=http&viewFallbackFrom=graph-rest-beta.0
    # Lets use doc name for this - Ignore endpoints.
    case permissions |> Enum.at(0) |> Map.get(:resource) != doc do
      true ->
        permissions
        |> Enum.chunk_every(3)
        |> Enum.map(fn permissions ->
          create_for_endpoint(nil, permissions, doc, scheme)
        end)

      false ->
        Enum.map(endpoints, &create_for_endpoint(&1, permissions, doc, scheme))
    end
  end

  def create_for_endpoint(endpoint, permissions, doc, scheme) do
    Enum.map(permissions, &create_for_permission(&1, endpoint, doc, scheme))
  end

  def create_for_permission(
        %{permission_type: _, scopes: scopes} = permission,
        endpoint,
        doc,
        scheme
      )
      when is_binary(scopes) do
    scopes
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.map(&create_for_scope(&1, permission, endpoint, doc, scheme, :scope_on_all))
  end

  def create_for_permission(
        %{permission_type: _, scopes: scopes} = permission,
        endpoint,
        doc,
        scheme
      ) do
    scopes
    |> Enum.with_index()
    |> Enum.map(&create_for_scope(&1, permission, endpoint, doc, scheme, :scope_on_all))
  end

  def create_for_permission(
        %{permission_type: _, scopes_on_self: scopes} = permission,
        endpoint,
        doc,
        scheme
      ) do
    scopes
    |> Enum.with_index()
    |> Enum.map(&create_for_scope(&1, permission, endpoint, doc, scheme, :scope_on_self))
  end

  def create_for_permission(
        %{permission_type: _, scopes_on_others: scopes} = permission,
        endpoint,
        doc,
        scheme
      ) do
    scopes
    |> Enum.with_index()
    |> Enum.map(&create_for_scope(&1, permission, endpoint, doc, scheme, :scope_on_others))
  end

  def create_for_scope({scope, i}, permission, nil, doc, scheme, scope_for)
      when is_binary(scope) do
    doc_name = doc |> String.split("/") |> Enum.at(-1) |> String.split(".") |> Enum.at(0)
    resource = Map.get(permission, :resource)

    %{
      permission_type: Map.get(permission, :permission_type),
      resource: Map.get(permission, :resource),
      endpoint: "#{resource} >> #{doc_name}",
      doc: doc,
      scheme: scheme
    }
    |> Map.put(scope_for, scope)
    |> Map.put(:privilege_weight, i)
    |> create_permission()
  end

  def create_for_scope({scope, i}, permission, endpoint, doc, scheme, scope_for)
      when is_binary(scope) do
    permission_type = Map.get(permission, :permission_type)

    case permission_type |> String.downcase() == "application" and
           endpoint |> String.contains?("/me") do
      true ->
        # /me cant not be called using application permissions
        :ok

      false ->
        %{
          permission_type: permission_type,
          resource: Map.get(permission, :resource),
          endpoint: endpoint,
          doc: doc,
          scheme: scheme
        }
        |> Map.put(scope_for, scope)
        |> Map.put(:privilege_weight, i)
        |> create_permission()
    end
  end

  defp create_permission(data) do
    %Permission{}
    |> Permission.changeset(data)
    |> insert!()
    :ok
  end
end
