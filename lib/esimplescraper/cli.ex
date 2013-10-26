defmodule Esimplescraper.CLI do

  def run(argv) do
    argv |> parse_args |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help   ])
    case  parse  do

    { [ help: true ], _,           _ } -> :help
    { _, [ root_url ],             _ } -> { root_url }
    _                                  -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: esimplescraper root_url (ex: http://www.example.com)
    """
    System.halt(0)
  end

  def process({ root_url }) do
    IO.puts inspect(Esimplescraper.Scraper.scrape_site root_url)
  end

end
