defrecord Page, url: nil, status: nil, body: nil, error: nil

defmodule Esimplescraper.Scraper do

  import Esimplescraper.HtmlParser, only: [parse_root_links: 2]
  import Esimplescraper.Requester, only: [get: 1]

  def scrape_site(root_url) do
    if(!String.ends_with?(root_url, "/")) do
      root_url = root_url <> "/"
    end
    scrape_page root_url, root_url, self()
    gather_results HashDict.new, 1, root_url, self()
  end

  defp gather_results(result, 0, root_url, rec) do
    if Dict.size(result) > 0 do
      IO.puts "DONE"
      result
    else
      gather_results(result, 0, root_url, rec)
    end
  end

  defp gather_results(result, to_go, root_url, rec) do
    IO.puts "gathering: #{to_go} :: #{inspect result}"
    receive do
      { _, :new_page, page } ->
        IO.puts "new_page: #{page.url}"
        gather_results(Dict.put(result, page.url, page), to_go, root_url, rec)

      { :ok, :page_processed } ->
        gather_results(result, to_go - 1, root_url, rec)

      { :ok, :link_found, url } ->
        case link_found(url, result) do
          { :true, result } -> 
            scrape_page(url, root_url, rec)
            gather_results(result, to_go + 1, root_url, rec)
          { :false, result } ->
            gather_results(result, to_go, root_url, rec)
        end
    end
  end

  def link_found(url, result) do
    case Dict.put_new(result, url, :inflight) do
      ^result -> { false, result }
      result -> { true, result }
    end
  end

  def scrape_page(url, root_url, rec) do
    spawn(Esimplescraper.Scraper, :_scrape_page, [url, root_url, rec])
  end

  def _scrape_page(url, root_url, rec) do
    IO.puts "scrape_page: #{inspect(url)}"
    case get(url) do
      { :ok, status, body } ->
        IO.puts "status: #{status} #{url}"
        rec <- { :ok, :new_page, Page.new(body: body, status: status,
                                          error: false, url: url) }
        parse_links(body, root_url, rec)
      { :error, reason } ->
        rec <- { :error, :new_page, Page.new(error: reason, url: url) }
    end
    rec <- { :ok, :page_processed }
  end

  defp parse_links(body, root_url, rec) do
    parse_root_links(body, root_url)
      |> Enum.each(fn(url) -> rec <- { :ok, :link_found, url } end)
  end
end
