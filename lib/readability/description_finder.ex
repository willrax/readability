defmodule Readability.DescriptionFinder do
  @moduledoc """
  The DescriptionFinder engine traverses HTML tree searching for a description.
  """

  @type html_tree :: tuple | list

  def description(html_tree) do
    case og_description(html_tree) do
      "" ->
        tag = description_tag(html_tree)

        if tag != nil do
          tag
        else
          nil
        end

      description when is_binary(description) ->
        description
    end
  end

  defp og_description(html_tree) do
    html_tree
    |> find_tag("meta[property='og:description']")
    |> Floki.attribute("content")
    |> clean()
  end

  def description_tag(html_tree) do
    html_tree
    |> find_tag("meta[name='description']")
    |> Floki.attribute("content")
    |> clean()
  end

  defp find_tag(html_tree, selector) do
    case Floki.find(html_tree, selector) do
      [] ->
        []

      matches when is_list(matches) ->
        hd(matches)
    end
  end

  defp clean([]), do: ""

  defp clean([string]) when is_binary(string) do
    String.trim(string)
  end

  defp clean(html_tree) do
    html_tree
    |> Floki.text()
    |> String.trim()
  end
end
