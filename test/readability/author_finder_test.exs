defmodule Readability.AuthorFinderTest do
  use ExUnit.Case, async: true

  alias Readability.AuthorFinder

  test "extracting bbc format author" do
    html = TestHelper.parse_fixture("bbc.html")
    assert AuthorFinder.find(html) == ["BBC News"]
  end

  test "extracting buzzfeed format author" do
    html = TestHelper.parse_fixture("buzzfeed.html")
    assert AuthorFinder.find(html) == ["Salvador Hernandez", "Hamza Shaban"]
  end

  test "extracting medium format author" do
    html = TestHelper.parse_fixture("medium.html")
    assert AuthorFinder.find(html) == ["Ken Mazaika"]
  end

  test "extracting nytimes format author" do
    html = TestHelper.parse_fixture("nytimes.html")
    assert AuthorFinder.find(html) == ["Judith H. Dobrzynski"]
  end
end
