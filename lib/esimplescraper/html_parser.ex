defmodule Esimplescraper.HtmlParser do

  def parse_root_links(html, root_url) do
    if data_is_html?(html) do
      parse_links_from_html(html)
        |> Enum.filter(&(!non_html_link?(&1)))
        |> Enum.map(&resolve_relative_links(&1, root_url))
        |> Enum.filter(&url_off_root?(&1, root_url))
        |> Enum.filter(&strip_extras/1)
    else
      []
    end
  end

  def url_off_root?(url, root_url) do
    # TODO: make better
    String.slice(url, 0, String.length(root_url)) == root_url
  end

  def parse_links_from_html(html) do
    tree_from_html(html)
      |> parse_links_from_tree
      |> Enum.filter(&(&1 != nil))
      |> Enum.uniq
  end

  def tree_from_html(html) do
    try do
      :mochiweb_html.parse(html)
    rescue
      _ -> IO.puts "FAILed parse"
    end
  end

  def parse_links_from_tree({ "a", args, children }) do
    [ args_get(args, "href") | parse_links_from_children(children) ]
  end

  def parse_links_from_tree({ _tag, _args, children }) do
    parse_links_from_children(children)
  end

  def parse_links_from_tree(_content) do
    []
  end

  def parse_links_from_children(children) do
    Enum.flat_map children, &parse_links_from_tree(&1)
  end

  def args_get(args, arg) do
    case Enum.find(args, fn({k,_v}) -> arg ==  k end) do
      { ^arg, value } -> value
      _ -> nil
    end
  end

  def data_is_html?(data) do
    !data_is_image?(data)
  end

  def data_is_image?(data) do
    data_is_jpeg?(data) or data_is_png?(data) or data_is_gif?(data)
  end

  def data_is_jpeg?(data) do
    size(data) >= 10 and 
      (binary_part(data, 6, 4) == "JFIF" or binary_part(data, 6, 4) == "Exif")
  end

  def data_is_png?(data) do
    size(data) >= 8 and binary_part(data, 0, 8) == "\211PNG\r\n\032\n"
  end

  def data_is_gif?(data) do
    size(data) >= 6 and
      (binary_part(data, 0, 6) == "GIF87a" or binary_part(data, 0, 6) == "GIF89a")
  end

  def resolve_relative_links(url, root_url) do
    if(String.starts_with?(url, "/")) do
      if(String.starts_with?(url, "/")) do
        url = root_url <> String.slice(url, 1, String.length(url)-1)
      else
        url = root_url <> url
      end
    else
      if(!String.starts_with?(url, "http")) do
        if(String.starts_with?(url,"./")) do
          url = String.slice(url,2,String.length(url)-2)
        end
        if(String.starts_with?(url,"../")) do
          url = String.slice(url,3,String.length(url)-3)
        end
        if(String.at(url,0) == "/") do
          url = root_url <> String.slice(url, 1, String.length(url)-1)
        else
          url = root_url <> url
        end
      end
    end
    IO.puts "FRRL: #{url} #{root_url}"
    url
  end

  def non_html_link?(url) do
    String.starts_with?(url, "mailto:") or String.starts_with?(url, "tel:")
  end

  def strip_extras(url) do
    [url|_] = String.split(url,"#")
    url
  end
end
