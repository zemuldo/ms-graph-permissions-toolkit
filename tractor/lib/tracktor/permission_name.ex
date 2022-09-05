defmodule Tracktor.PermissionName do
  def is_valid([text]) do
    string = text |> String.downcase()
    String.contains?(string, "delegated") or String.contains?(string, "application")
  end

  def is_valid(text) do
    string = text |> String.downcase()
    String.contains?(string, "delegated") or String.contains?(string, "application")
  end
end
