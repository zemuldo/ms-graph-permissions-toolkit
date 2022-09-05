defmodule Tracktor.TextExtractor do
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
end
