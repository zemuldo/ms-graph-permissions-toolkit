defmodule Scrapper.ExTractor.DistortedTable do
  alias Scrapper.ExTractor.TextExTractor

  def extract_from_paragraph([_ | _] = permissions, _) do
    permissions
  end

  def extract_from_paragraph(_, ast) do
    ast
    |> Enum.filter(&is_permissions_paragraph/1)
    |> Enum.at(0)
    |> extract()
  end

  defp is_permissions_paragraph({"p", _styles, text, %{}}) do
    text
    |> TextExTractor.extract_text()
    |> String.downcase()
    |> String.contains?("permission type")
  end

  defp is_permissions_paragraph(_), do: false

  defp extract({"p", _styles, text, %{}}) do
    case text |> TextExTractor.extract_text() |> String.split("|") |> Enum.take(-6) do
      [_, delegated_ws, _, delegated_msa, _, application] ->
        [
          %{scopes: delegated_ws, permission_type: "Delegated (work or school account)"},
          %{
            scopes: delegated_msa,
            permission_type: "Delegated (personal Microsoft account)"
          },
          %{scopes: application, permission_type: "Application"}
        ]

      _ ->
        []
    end
  end

  defp extract(_) do
    []
  end
end
