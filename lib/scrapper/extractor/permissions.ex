defmodule Scrapper.ExTractor.Permissions do

  alias Scrapper.ExTractor.TextExTractor

    def get_permissions(
        resource,
        {"tr", [],
         [
           {"td", _style1, permission_type, %{}},
           {"td", _style2, permissions, _}
         ], _}
      ) do
    %{
      resource: resource |> TextExTractor.extract_text(),
      permission_type: permission_type |> TextExTractor.extract_text(),
      scopes:
        permissions
        |> Enum.map(&TextExTractor.extract_text/1)
        |> Enum.join("")
        |> String.split(",", trim: true)
    }
  end

  def get_permissions(
        _1,
        {"tr", [],
         [
           {"td", _style1, permission_type, %{}},
           {"td", _style2, permissions_on_self, _},
           {"td", _style3, permissions_on_others, _}
         ], _2}
      ) do
    [
      %{
        permission_type: TextExTractor.extract_text(permission_type),
        scopes_on_self:
          permissions_on_self
          |> Enum.map(&TextExTractor.extract_text/1)
          |> Enum.join("")
          |> String.split(",", trim: true)
      },
      %{
        permission_type: TextExTractor.extract_text(permission_type),
        scopes_on_others:
          permissions_on_others
          |> Enum.map(&TextExTractor.extract_text/1)
          |> Enum.join("")
          |> String.split(",", trim: true)
      }
    ]
  end

  def get_permissions(
        _,
        {"tr", [],
         [
           {"td", _, resource, _},
           {"td", _, delegated_ws, _},
           {"td", _, delegated_msa, _},
           {"td", _, application, _}
         ], _}
      ) do
    [
      %{
        resource: TextExTractor.extract_text(resource),
        permission_type: "Delegated (work or school account)",
        scopes:
          delegated_ws
          |> Enum.map(&TextExTractor.extract_text/1)
          |> Enum.join("")
          |> String.split(",", trim: true)
      },
      %{
        resource: TextExTractor.extract_text(resource),
        permission_type: "Delegated (personal Microsoft account)",
        scopes:
          delegated_msa
          |> Enum.map(&TextExTractor.extract_text/1)
          |> Enum.join("")
          |> String.split(",", trim: true)
      },
      %{
        resource: TextExTractor.extract_text(resource),
        permission_type: "Application",
        scopes:
          application
          |> Enum.map(&TextExTractor.extract_text/1)
          |> Enum.join("")
          |> String.split(",", trim: true)
      }
    ]
  end

  def get_permissions(_, _), do: []

end
