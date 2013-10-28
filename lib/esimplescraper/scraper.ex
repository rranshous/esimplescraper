defrecord Page, url: nil, status: nil, body: nil, error: nil, root_url: nil, 
                links: []

defmodule Esimplescraper.Scraper do

  def scrape_site(root_url) do
    if(!String.ends_with?(root_url, "/")) do
      root_url = root_url <> "/"
    end
    gather_results(root_url)
  end

  defp gather_results(root_url) do
    { result, scrapers } = scrape_links([root_url], root_url,
                                        HashDict.new, [])
    gather_results(result, root_url, scrapers)
  end

  defp gather_results(result, _root_url, []) do
    IO.puts "DONE"
    result
  end

  defp gather_results(result, root_url, scrapers) do
    IO.puts "gather_results: #{Dict.size(result)} #{length(scrapers)}"
    receive do
      { :ok, :page_result, page, scraper } ->
        { result, scrapers } = scrape_links(page.links, root_url,
                                            result, 
                                            List.delete(scrapers, scraper))
        result = Dict.put(result, page.url, page)
        gather_results(result, root_url, scrapers)
    end
  end

  defp scrape_links([], _root_url, result, scrapers) do
    { result, scrapers }
  end

  defp scrape_links([url|urls // []], root_url, result, scrapers)
  defp scrape_links([url|urls], root_url, result, scrapers) do
    if !Dict.has_key?(result, url) do
      pid = spawn(Esimplescraper.PageScraper, :start, [])
      pid <- { :scrape, url, root_url, self() }
      result = Dict.put result, url, pid
      scrapers = [pid|scrapers]
      scrape_links(urls, root_url, result, scrapers)
    else
      scrape_links(urls, root_url, result, scrapers)
    end
  end
end
