defrecord Page, url: nil, status: nil, body: nil, error: nil

defmodule Esimplescraper.Scraper do

  import Esimplescraper.HtmlParser, only: [parse_root_links: 2]
  import Esimplescraper.Requester, only: [get: 1]

  def scrape_site(root_url) do
    scrape_pages [root_url], root_url
  end

  def scrape_pages(urls, root_url) do
    scrape_pages(urls, root_url, [])
  end

  defp scrape_pages([url|[]], root_url, results)
  defp scrape_pages([url|urls], root_url, results) do
    case scrape_page(url) do
      { :ok, page } ->
        new_urls = parse_root_links(page.body, root_url) |> Enum.to_list
        IO.puts "NEWURLS: #{inspect new_urls}"
        scrape_pages(new_urls ++ urls, root_url, [page|results])
      { :error, reason } ->
        scrape_pages(urls, root_url, results)
    end
  end

  defp scrape_pages([], root_url, results) do
    results
  end

  defp scrape_page(url) do
    case get(url) do
      { :ok, status, body } ->
        IO.puts "status: #{status}"
        { :ok, Page.new(body: body, status: status, error: false, url: url) }
      { :error, reason } -> { :error, reason }
    end
  end

end
