defmodule Readability.DescriptionFinderTest do
  use ExUnit.Case, async: true

  import Floki, only: [parse_document!: 1]

  @html parse_document!("""
        <html>
          <head>
            <title>Tag title - test</title>
            <meta property='og:description' content='og description'>
          </head>
          <body>
            <p>
              <h1>h1 title</h1>
              <h2>h2 title</h2>
            </p>
          </body>
        </html>
        """)

  test "extract the og description" do
    description = Readability.DescriptionFinder.description(@html)
    assert description == "og description"
  end

  test "extract the description meta tag" do
    html =
      parse_document!("""
          <html>
            <head>
              <title>Tag title - test</title>
              <meta name='description' content='description'>
            </head>
            <body>
              <p>
                <h1>h1 title</h1>
                <h2>h2 title</h2>
              </p>
            </body>
          </html>
      """)

    description = Readability.DescriptionFinder.description(html)
    assert description == "description"
  end
end
