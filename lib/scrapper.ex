defmodule Scrapper do
  alias Scrapper.ExTractor.DistortedTable
  alias Scrapper.ExTractor.DetectTable
  alias Scrapper.ExTractor.Permissions
  alias Scrapper.Cleaner
  alias Scrapper.Repo

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
        _ ->
          IO.inspect(item)
          raise("Some itemns not well encoded")
      end
    end)

    File.write("dump.json", Poison.encode!(data), [:binary])
  end

  def to_db(data) do
    data
    |> Enum.map(fn item ->
      try do
        Repo.create_for_doc(item)
      rescue
        e ->
          IO.inspect(e)
          IO.inspect(item)
          raise("Failed to dump")
      end
    end)
:ok
  end

  def run(scheme \\ "v1.0") do
    {:ok, apis} = File.ls("docs/microsoft-graph-docs-main/api-reference/#{scheme}/api")

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
    ("docs/microsoft-graph-docs-main/api-reference/v1.0/api/" <> endpoint)
    |> read_file
  end

  def get_endpoint("beta", endpoint) do
    ("docs/microsoft-graph-docs-main/api-reference/beta/api/" <> endpoint)
    |> read_file
  end

  def read_file(path) do
    IO.puts("==> Extracting #{path}")

    with {:ok, markdown} <-
           File.read(path),
         {:ok, ast, _} <- EarmarkParser.as_ast(markdown) do
      permissions =
        ast
        |> Enum.take(25)
        |> Enum.filter(fn item ->
          case item do
            {"table", _, data, _} -> DetectTable.is_permissions_table(data)
            _ -> false
          end
        end)
        |> Enum.reduce_while([], fn table, _ ->
          case table
               |> get_tbodies()
               |> Enum.at(0)
               |> get_trs()
               |> Enum.map(&Permissions.get_permissions(path, &1)) do
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
            {"pre", [],
             [
               {"code", [{"class", "msgraph-interactive"}], [endpoints], _}
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
      |> Cleaner.clean_endpoint()
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
end
