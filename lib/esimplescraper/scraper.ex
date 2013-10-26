defrecord Page, url: nil, status: nil, body: nil, error: nil

defmodule Esimplescraper.Scraper do

  import Esimplescraper.HtmlParser, only: [parse_root_links: 2]
  import Esimplescraper.Requester, only: [get: 1]

  def scrape_site(root_url) do
    scrape_page Page.new(url: root_url), root_url
  end

  defp scrape_page(page, root_url) do
    case get(page.url) do
      { :ok, status, body } ->
        IO.puts "status: #{status}"
        page = (page.body(body)).status(status)
        [ page |
          parse_root_links(body, root_url) 
            |> Enum.map(&page_from_url/1)
            |> Enum.map(&scrape_page(&1, root_url))
        ]
      { :error, reason } -> [ page.error(reason) ]
    end
  end

  defp page_from_url(url) do
    Page.new([url: url])
  end

end
