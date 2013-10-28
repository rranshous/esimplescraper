defrecord Page, url: nil, status: nil, body: nil, error: nil

defmodule Esimplescraper.Scraper do

  import Esimplescraper.HtmlParser, only: [parse_root_links: 2]
  import Esimplescraper.Requester, only: [get: 1]

  def scrape_site(root_url) do
    scrape_pages [root_url], root_url
  end

  def scrape_pages(urls, root_url) do
    scrape_pages(urls, root_url, HashDict.new)
  end

  defp scrape_pages([url|urls=[]], root_url, results)
  defp scrape_pages([url|urls], root_url, results) do
    IO.puts "URL: #{url}"
    IO.puts "URLS: #{length(urls)}"
    case scrape_page(url) do
      { :ok, page } ->
        new_urls = parse_root_links(page.body, root_url)
                     |> Enum.filter(&(!Dict.has_key?(results, &1)))
        IO.puts "NEWURLS: #{inspect(new_urls)}"
        results = new_urls
                    |> Enum.reduce(results, &Dict.put_new(&2, &1, :inqueue))
                    |> Dict.put(page.url, page)
        scrape_pages(new_urls ++ urls, root_url, results)
      { :error, page } ->
        scrape_pages(urls, root_url, Dict.put(results, page.url, page))
    end
  end

  defp scrape_pages([], _root_url, results) do
    results
  end

  defp scrape_page(url) do
    case get(url) do
      { :ok, status, body } ->
        IO.puts "status: #{status}"
        { :ok, Page.new(body: body, status: status, error: false, url: url) }
      { :error, reason } ->
        { :error, Page.new(error: reason, url: url) }
    end
  end

end
