defmodule Tractor do
  def read_files(scheme) do
    {:ok, apis} = File.ls("../docs/microsoft-graph-docs-main/api-reference/#{scheme}/api")
    IO.inspect(Enum.count(apis))

    apis
    |> Enum.reduce([], fn endpoint, acc ->
      case String.ends_with?(endpoint, ".md") do
        true -> acc ++ [get_endpoint(scheme, endpoint)]
        false -> acc
      end
    end)
  end

  def get_endpoint("v1.0", endpoint) do
    ("../docs/microsoft-graph-docs-main/api-reference/v1.0/api/" <> endpoint)
    |> read_file
  end

  def get_endpoint("beta", endpoint) do
    ("../docs/microsoft-graph-docs-main/api-reference/v1.0/api/" <> endpoint)
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
            {"table", _, _, _} -> true
            _ -> false
          end
        end)
        |> Enum.at(0)
        |> get_tbodies()
        |> Enum.at(0)
        |> get_trs()
        |> Enum.map(&get_permissions/1)

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
              {:cont, nil}
          end
        end)

      %{permissions: permissions, endpoints: endpoints}
    else
      _ -> {:error, "Failed to read file"}
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
        {"tr", [],
         [
           {"td", _style1, permission_type, %{}},
           {"td", _style2, permissions, _}
         ], _}
      ) do
    {permission_type, permissions}
  end

  def get_permissions(_), do: nil
end
