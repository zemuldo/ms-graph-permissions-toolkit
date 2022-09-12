defmodule ScrapperWeb.Api.PermissionsController do
  use ScrapperWeb, :controller

  alias Scrapper.Schemas.Permission

  def search(conn, %{"query" => query, "types" => types} = params) do
    permission =
      query |> String.split(" ") |> Enum.find(fn item -> String.contains?(item, ".") end)

    data = Permission.get_endpoints(permission, get_types(types))

    conn |> json(data)
  end

  def search(conn, %{"query" => query} = params) do
    permission =
      query |> String.split(" ") |> Enum.find(fn item -> String.contains?(item, ".") end)

    data = Permission.get_endpoints(permission)

    conn |> json(data)
  end

  def search(conn, _), do: conn |> json([])

  defp get_types("") do
    [
      "Delegated (work or school account)",
      "Delegated (personal Microsoft account)",
      "Application"
    ]
  end
  defp get_types(types) do
    types |> String.split(",")
  end
end
