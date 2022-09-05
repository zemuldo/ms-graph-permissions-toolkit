defmodule Tractor do
  alias Tractor.DistortedTable
  alias Tracktor.PermissionName

  def list_permissions(scheme \\ "v1.0") do
    scheme
    |> run()
    |> Enum.reduce([], fn item, acc ->
      acc ++ Enum.reduce(item.permissions, [], fn {_, _, perms}, acc -> acc ++ perms end)
    end)
    |> Enum.map(&format_permission/1)
    |> Enum.uniq()
  end

  def format_permission(
        {"em", [],
         [
           permission_1,
           {"em", [], [permissions_2], %{}}
         ], %{}}
      ) do
    (permission_1 |> String.split(",", trim: true)) ++
      (permissions_2 |> String.split(",", trim: true))
  end

  def format_permission({_, _, [permission], _}) do
    permission |> String.split(",", trim: true)
  end

  def format_permission(permission) do
    permission |> String.split(",", trim: true)
  end

  def to_json(data) do
    data
    |> Enum.map(fn item ->
      try do
        Poison.encode!(item)
      rescue
        e ->
          IO.inspect(item)
          raise("Some itemns not well encoded")
      end
    end)

    File.write("dump.json", Poison.encode!(data), [:binary])
  end

  def run(scheme \\ "v1.0") do
    {:ok, apis} = File.ls("../docs/microsoft-graph-docs-main/api-reference/#{scheme}/api")

    apis
    |> Flow.from_enumerable()
    |> Flow.reject(&(not String.ends_with?(&1, ".md")))
    |> Flow.reduce(fn -> [] end, fn endpoint, acc ->
      case get_endpoint(scheme, endpoint) do
        {:error, _} -> acc
        %{} = suit -> acc ++ [suit]
      end
    end)
    |> Enum.to_list()
  end

  def get_endpoint("v1.0", endpoint) do
    ("../docs/microsoft-graph-docs-main/api-reference/v1.0/api/" <> endpoint)
    |> read_file
  end

  def get_endpoint("beta", endpoint) do
    ("../docs/microsoft-graph-docs-main/api-reference/beta/api/" <> endpoint)
    |> read_file
  end

  def read_file(path) do
    with {:ok, markdown} <-
           File.read(path),
         {:ok, ast, _} <- EarmarkParser.as_ast(markdown) do
      permissions =
        ast
        |> Enum.take(25)
        |> Enum.filter(fn item ->
          case item do
            {"table", _, data, _} -> is_permissions_table(data)
            _ -> false
          end
        end)
        |> Enum.reduce_while([], fn table, _ ->
          case table
               |> get_tbodies()
               |> Enum.at(0)
               |> get_trs()
               |> Enum.map(&get_permissions(path, &1)) do
            [[%{} | _] | _] = perms ->
              {:halt, perms |> List.flatten()}

            [%{} | _] = perms ->
              {:halt, perms}

            _ ->
              {:cont, []}
          end
        end)

      endpoints =
        ast
        |> Enum.reduce_while([], fn item, _ ->
          case item do
            {"pre", [],
             [
               {"code", [{"class", "http"}], [endpoints], _}
             ], _} ->
              {:halt, endpoints |> String.split("\n", trim: true)}

            _ ->
              {:cont, []}
          end
        end)

      permissions = DistortedTable.extract_from_paragraph(permissions, ast)

      case permissions do
        [_ | _] ->
          true

        _ ->
          IO.puts("Failed to process file ==> #{path}")
      end

      %{
        permissions: DistortedTable.extract_from_paragraph(permissions, ast),
        endpoints: endpoints,
        doc: path
      }
    else
      _ ->
        {:error, "Failed to read file"}
    end
  end

  def get_tbodies({"table", [], elements, _}) do
    elements
    |> Enum.take(25)
    |> Enum.filter(fn item ->
      case item do
        {"tbody", _, _, _} -> true
        _ -> false
      end
    end)
  end

  def get_tbodies(_) do
    []
  end

  def get_trs({"tbody", [], elements, _}) do
    elements
    |> Enum.take(25)
    |> Enum.filter(fn item ->
      case item do
        {"tr", _, _, _} -> true
        _ -> false
      end
    end)
  end

  def get_trs(_) do
    []
  end

  def get_permissions(
        resource,
        {"tr", [],
         [
           {"td", _style1, permission_type, %{}},
           {"td", _style2, permissions, _}
         ], _}
      ) do
    %{
      resource: resource |> extract_text(),
      permission_type: permission_type |> extract_text(),
      permissions:
        permissions |> Enum.map(&extract_text/1) |> Enum.join("") |> String.split(",", trim: true)
    }
  end
  def get_permissions(
        resource,
        {"tr", [],
         [
           {"td", _style1, permission_type, %{}},
           {"td", _style2, permissions_on_self, _},
           {"td", _style2, permissions_on_others, _}
         ], _}
      ) do
    [%{
        permission_type: extract_text(permission_type),
        permissions_on_self:
          permissions_on_self
          |> Enum.map(&extract_text/1)
          |> Enum.join("")
          |> String.split(",", trim: true)
      },
      %{
        permission_type: extract_text(permission_type),
        permissions_on_others:
          permissions_on_others
          |> Enum.map(&extract_text/1)
          |> Enum.join("")
          |> String.split(",", trim: true)
      }]
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
        resource: extract_text(resource),
        permission_type: "Delegated (work or school account)",
        permissions:
          delegated_ws
          |> Enum.map(&extract_text/1)
          |> Enum.join("")
          |> String.split(",", trim: true)
      },
      %{
        resource: extract_text(resource),
        permission_type: "Delegated (personal Microsoft account)",
        permissions:
          delegated_msa
          |> Enum.map(&extract_text/1)
          |> Enum.join("")
          |> String.split(",", trim: true)
      },
      %{
        resource: extract_text(resource),
        permission_type: "Application",
        permissions:
          application
          |> Enum.map(&extract_text/1)
          |> Enum.join("")
          |> String.split(",", trim: true)
      }
    ]
  end

  def get_permissions(_, _), do: []

  def extract_text([text]) when is_binary(text), do: text
  def extract_text(text) when is_binary(text), do: text
  def extract_text({"td", _style, [text], %{}}) when is_binary(text), do: text

  def extract_text(
        {"td", _style,
         [
           {"a", [{"href", resource_doc}], [resource], %{}},
           _link
         ], %{}}
      ),
      do: resource <> ">>" <> resource_doc

  def extract_text([
        {"a", [{"href", resource_doc}], [resource], %{}},
        link
      ]),
      do: resource <> ">>" <> resource_doc <> ">>" <> format_link(link)

  def extract_text([
        {"a", [{"href", resource_doc}], [resource], %{}}
      ]),
      do: resource <> ">>" <> resource_doc

  def extract_text({"td", _style, [text], %{}}) when is_binary(text), do: text
  def extract_text(_), do: ""

  defp format_link(" (" <> string), do: string |> String.trim() |> String.replace(")", "")
  defp format_link(string), do: string |> String.trim() |> String.replace(")", "")

  def is_permissions_table(
        [
          {"thead", [],
           [
             {"tr", [],
              [
                {"th", _style1, _, _1},
                {"th", _style2, delegated_ws, _3},
                {"th", _style2, delegated_msa, _3},
                {"th", _style2, application, _3}
              ], _4}
           ], _5}
          | _
        ] = table
      ) do
    PermissionName.is_valid(delegated_ws) and PermissionName.is_valid(delegated_msa) and
      PermissionName.is_valid(application)
  end

  def is_permissions_table(
        [
          {"thead", [],
           [
             {"tr", [],
              [
                {"th", _style1, ["Permission type"], _1} | _
              ], _4}
           ], _5}
          | _
        ] = table
      ) do
    true
  end

  def is_permissions_table(
        [
          {"thead", [],
           [
             {"tr", [],
              [
                {"th", _style1, ["Permission Type"], _1},
                {"th", _style2, _2, _3}
              ], _4}
           ], _5}
          | _
        ] = table
      ) do
    true
  end

  def is_permissions_table(
        [
          {"thead", [],
           [
             {"tr", [],
              [
                {"th", _style1, ["Supported resource"], _1} | _
              ], _4}
           ], _5}
          | _
        ] = table
      ) do
    true
  end

  def is_permissions_table(table) do
    false
  end
end
