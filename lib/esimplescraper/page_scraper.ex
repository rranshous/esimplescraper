defmodule Esimplescraper.PageScraper do

  import Esimplescraper.HtmlParser, only: [parse_root_links: 2]
  import Esimplescraper.Requester, only: [get: 1]

  def start() do
    IO.puts "spawned scraper"
    start([])
  end

  # if we don't have any work, wait for a msg
  def start([]) do
    IO.puts "scraper about to wait"
    receive do
      { :scrape, url, root_url, rec } ->
        start([{url, root_url, rec}])
    end
  end

  def start(url, root_url, rec) do
    start({ url, root_url, rec })
  end

  # if we have work, do it than tail call ourself
  def start([{ url, root_url, rec }|work // []])
  def start([{ url, root_url, rec }|work]) do
    scrape_page(url)
      |> add_root(root_url)
      |> add_links
      |> report_back(rec)
    start(work)
  end

  defp add_root(page, root_url) do
    page.root_url(root_url)
  end

  defp add_links(page) do
    page.links(parse_root_links(page.body, page.root_url))
  end

  defp scrape_page(url) do
    IO.puts "scraping: #{url}"
    case get(url) do
      { :ok, status, body } ->
        IO.puts "status: #{status} #{url}"
        Page.new(body: body, status: status, error: false, url: url )
      { :error, reason } ->
        Page.new(error: reason, url: url)
    end
  end

  defp report_back(page, rec) do
    rec <- { :ok, :page_result, page, self() }
  end
end
