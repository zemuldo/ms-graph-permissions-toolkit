defmodule Tractor.DistortedTable do
  def extract_from_paragraph([_ | _] = permissions, _) do
    permissions
  end

  def extract_from_paragraph(extracted, ast) do
    ast
    |> Enum.filter(&is_permissions_paragraph/1)
    |> Enum.at(0)
    |> extract()
  end

  defp is_permissions_paragraph({"p", _styles, text, %{}}) do
    text
    |> Tractor.extract_text()
    |> String.downcase()
    |> String.contains?("permission type")
  end

  defp is_permissions_paragraph(_), do: false

  defp extract({"p", _styles, text, %{}}) do
    case text |> Tractor.extract_text() |> String.split("|") |> Enum.take(-6) do
      [_, delegated_ws, _, delegated_msa, _, application] ->
        [
          %{ permissions: delegated_ws, permission_type: "Delegated (work or school account)"},
          %{ permissions: delegated_msa, permission_type: "Delegated (personal Microsoft account)"},
          %{ permissions: application, permission_type: "Application"}
        ]
      _ -> []
    end
  end

  defp extract(data) do
    []
  end
end
