defmodule ReadabilityHttpTest do
  use ExUnit.Case
  import Mock
  require IEx

  test "blank response is parsed as plain text" do
    url = "https://tools.ietf.org/rfc/rfc2616.txt"
    content = TestHelper.read_fixture("rfc2616.txt")
    response = {:ok, %HTTPoison.Response{status_code: 200, headers: [], body: content}}

    with_mock HTTPoison, get: fn _url, _headers, _opts -> response end do
      {:ok, %Readability.Summary{article_text: result_text}} = Readability.summarize(url)

      assert result_text =~ ~r/3 Protocol Parameters/
    end
  end

  test "text/plain response is parsed as plain text" do
    url = "https://tools.ietf.org/rfc/rfc2616.txt"
    content = TestHelper.read_fixture("rfc2616.txt")

    response =
      {:ok,
       %HTTPoison.Response{
         status_code: 200,
         headers: [{"Content-Type", "text/plain"}],
         body: content
       }}

    with_mock HTTPoison, get: fn _url, _headers, _opts -> response end do
      {:ok, %Readability.Summary{article_text: result_text}} = Readability.summarize(url)

      assert result_text =~ ~r/3 Protocol Parameters/
    end
  end

  test "*ml responses are parsed as markup" do
    url = "https://news.bbc.co.uk/test.html"
    content = TestHelper.read_fixture("bbc.html")
    mimes = ["text/html", "application/xml", "application/xhtml+xml"]

    mimes
    |> Enum.each(fn mime ->
      response =
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           headers: [{"Content-Type", mime}],
           body: content
         }}

      with_mock HTTPoison, get: fn _url, _headers, _opts -> response end do
        {:ok, %Readability.Summary{article_html: result_html}} = Readability.summarize(url)

        assert result_html =~ ~r/connected computing devices\".<\/p><\/div><\/div>$/
      end
    end)
  end

  test "response with charset is parsed correctly" do
    url = "https://news.bbc.co.uk/test.html"
    content = TestHelper.read_fixture("bbc.html")

    response =
      {:ok,
       %HTTPoison.Response{
         status_code: 200,
         headers: [{"Content-Type", "text/html; charset=UTF-8"}],
         body: content
       }}

    with_mock HTTPoison, get: fn _url, _headers, _opts -> response end do
      {:ok, %Readability.Summary{article_html: result_html}} = Readability.summarize(url)

      assert result_html =~ ~r/connected computing devices\".<\/p><\/div><\/div>$/
    end
  end

  test "response with content-type in different case is parsed correctly" do
    # HTTP header keys are case insensitive (RFC2616 - Section 4.2)
    url = "https://news.bbc.co.uk/test.html"
    content = TestHelper.read_fixture("bbc.html")

    response =
      {:ok,
       %HTTPoison.Response{
         status_code: 200,
         headers: [{"content-Type", "text/html; charset=UTF-8"}],
         body: content
       }}

    with_mock HTTPoison, get: fn _url, _headers, _opts -> response end do
      {:ok, %Readability.Summary{article_html: result_html}} = Readability.summarize(url)

      assert result_html =~ ~r/connected computing devices\".<\/p><\/div><\/div>$/
    end
  end

  test "a bad domain returns an error" do
    response = {:error, %HTTPoison.Error{id: nil, reason: :econnrefused}}

    with_mock HTTPoison, get: fn _url, _headers, _opts -> response end do
      {:error, error} = Readability.summarize("www.pizza.com")
      assert error.reason == :econnrefused
    end
  end
end
