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
  alias Scrapper.Schemas.PermissionType
  alias Scrapper.Schemas.Endpoint

  def create_permission_type(data) do
    %PermissionType{}
    |> PermissionType.changeset(data)
    |> insert()
  end

  def create_permission(data) do
    %Permission{}
    |> Permission.changeset(data)
    |> insert()
  end

  def create_endpoint(data) do
    %Endpoint{}
    |> Endpoint.changeset(data)
    |> insert()
  end
end
