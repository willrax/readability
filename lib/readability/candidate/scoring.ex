defmodule Readability.Candidate.Scoring do
  @moduledoc """
  Score html tree
  """

  alias Readability.Candidate

  @element_scores %{"div" => 5,
                    "blockquote" => 3,
                    "form" => -3,
                    "th" => -5
                  }

  @type html_tree :: tuple | list

  @doc """
  Score html tree by some algorithm that check children nodes, attributes, link densities, etcs..
  """
  @spec calc_score(html_tree) :: number
  def calc_score(html_tree) do
    score = calc_node_score(html_tree)
    score = score + calc_children_content_score(html_tree) + calc_grand_children_content_score(html_tree)
    score * (1 - calc_link_density(html_tree))
  end

  defp calc_children_content_score({_, _, children_tree}) do
    children_tree
    |> Enum.filter(&(is_tuple(&1) && Candidate.match?(&1)))
    |> calc_content_score
  end

  defp calc_grand_children_content_score({_, _, children_tree}) do
    score = children_tree
            |> Enum.filter_map(&is_tuple(&1), &elem(&1, 2))
            |> List.flatten
            |> Enum.filter(&(is_tuple(&1) && Candidate.match?(&1)))
            |> calc_content_score
    score / 2
  end

  def calc_content_score(html_tree) do
    score = 1
    inner_text = html_tree |> Floki.text
    split_score = inner_text |> String.split(",") |> length
    length_score = [(String.length(inner_text) / 100), 3] |> Enum.min
    score + split_score + length_score
  end

  defp calc_node_score(tag, attrs) do
    score = class_weight(attrs)
    score + (@element_scores[tag] || 0)
  end
  defp calc_node_score([h|t]), do: calc_node_score(h) + calc_node_score(t)
  defp calc_node_score({tag, attrs, _}), do: calc_node_score(tag, attrs)
  defp calc_node_score([]), do: 0


  defp class_weight(attrs) do
    weight = 0
    class = attrs |> List.keyfind("class", 0, {"", ""}) |> elem(1)
    id = attrs |> List.keyfind("id", 0, {"", ""}) |> elem(1)

    if class =~ Readability.regexes[:positiveRe], do: weight = weight + 25
    if id =~ Readability.regexes[:positiveRe], do: weight = weight + 25
    if class =~ Readability.regexes[:negativeRe], do: weight = weight - 25
    if id =~ Readability.regexes[:negativeRe], do: weight = weight - 25

    weight
  end

  defp calc_link_density(html_tree) do
    link_length = html_tree
                  |> Floki.find("a")
                  |> Floki.text
                  |> String.length

    text_length = html_tree
                  |> Floki.text
                  |> String.length

    if text_length == 0 do
      0
    else
      link_length / text_length
    end
  end
end