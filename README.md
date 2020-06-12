# Readability

**🚨 This is a fork of a (from what I can tell) currently unmaintained hex package**

## Installation

1. Add this fork to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:readability, git: "https://github.com/willrax/readability.git"}]
end
```

2. Ensure readability is started before your application:

```elixir
def application do
  [applications: [:readability]]
end
```

Note: Readability requires Elixir 1.3 or higher.

## Usage

### Examples

#### Just pass a url

```elixir
url = "https://medium.com/@kenmazaika/why-im-betting-on-elixir-7c8f847b58"
summary = Readability.summarize(url)

summary.title
#=> "Why I’m betting on Elixir"

summary.authors
#=> ["Ken Mazaika"]

summary.article_html
#=>
# <div><div><p id=\"3476\"><strong><em>Background: </em></strong><em>I’ve spent...
# ...
# ...button!</em></h3></div></div>

summary.article_text
#=>
# Background: I’ve spent the past 6 years building web applications in Ruby and.....
# ...
# ... value in this article, it would mean a lot to me if you hit the recommend button!
```

#### From raw html

```elixir
### Extract the title.
Readability.title(html)

### Extract authors.
Readability.authors(html)

### Extract the primary content with transformed html.
html
|> Readability.article
|> Readability.readable_html

### Extract only text from the primary content.
html
|> Readability.article
|> Readability.readable_text

### you can extract the primary images with Floki
html
|> Readability.article
|> Floki.find("img")
|> Floki.attribute("src")
```

### Options

If the result is different from your expectations, you can add options to customize it.

#### Example

```elixir
url = "https://medium.com/@kenmazaika/why-im-betting-on-elixir-7c8f847b58"
summary = Readability.summarize(url, [clean_conditionally: false])
```

- min_text_length \\\\ 25
- remove_unlikely_candidates \\\\ true
- weight_classes \\\\ true
- clean_conditionally \\\\ true
- retry_length \\\\ 250

**You can find other algorithm and regex options in `readability.ex`**

## Test

To run the test suite:

    $ mix test

## Todo

- [x] Extract authors
- [x] More configurable
- [x] Summarize function
- [ ] Convert relative paths into absolute paths of `img#src` and `a#href`

## Contributions are welcome!

Check out [the main features milestone](https://github.com/keepcosmos/readability/milestones) and features of related projects below

**Contributing**

1. **Fork** the repo on GitHub
2. **Clone** the project to your own machine
3. **Commit** changes to your own branch
4. **Push** your work back up to your fork
5. Submit a **Pull request** so that we can review your changes

NOTE: Be sure to merge the latest from "upstream" before making a pull request!

## Related and Inpired Projects

- [readability.js](https://github.com/mozilla/readability) is a standalone version of the readability library used for Firefox Reader View.
- [newspaper](https://github.com/codelucas/newspaper) is an advanced news extraction, article extraction, and content curation library for Python.
- [ruby-readability](https://github.com/cantino/ruby-readability) is a tool for extracting the primary readable content of a webpage.

## LICENSE

This code is under the Apache License 2.0. See <http://www.apache.org/licenses/LICENSE-2.0>.
