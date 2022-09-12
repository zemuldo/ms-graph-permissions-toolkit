defmodule Scrapper.Cleaner do

  def clean_endpoint( permission) when is_binary(permission) do
   String.trim(permission)
  end

  def clean_endpoint(%{permissions: permissions} = endpoint) do
  endpoint
  |> Map.put(:permissions, permissions |> Enum.map(&clean_scope/1))
  end



  defp clean_scope(%{scopes: scopes, resource: _} = permission) do
    permission
    |> Map.put(:permission_type, String.trim(permission.permission_type))
    |> Map.put(:resource, String.trim(permission.resource))
    |> Map.put(:scopes, clean_scope(scopes))
  end

  defp clean_scope(scopes) when is_list(scopes), do: Enum.map(scopes, &clean_scope/1)

  defp clean_scope( permission) when is_binary(permission) do
   String.trim(permission)
  end

  defp clean_scope(%{scopes: scopes} = permission) do
    permission
    |> Map.put(:permission_type, String.trim(permission.permission_type))
    |> Map.put(:scopes, clean_scope(scopes))
  end

  defp clean_scope( %{scopes_on_self: _} =  scope) when is_map(scope) do
   scope
    |> Map.put(:permission_type, String.trim(scope.permission_type))
    |> Map.put(:scopes_on_self, clean_scope(scope.scopes_on_self))
  end
  defp clean_scope( %{scopes_on_others: _} =  scope) when is_map(scope) do
   scope
    |> Map.put(:permission_type, String.trim(scope.permission_type))
    |> Map.put(:scopes_on_others, clean_scope(scope.scopes_on_others))
  end
  defp clean_scope(scope) when is_map(scope) do
   scope
    |> Map.put(:permission_type, String.trim(scope.permission_type))
    |> Map.put(:scopes, clean_scope(scope.scopes))
  end

  defp clean_scope(scope) do
    String.trim(scope)
  end
end
