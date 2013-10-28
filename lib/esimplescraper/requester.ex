defmodule Esimplescraper.Requester do

  def get(url), do: request(url, :get)

  defp request(url, method) do
    options = [ { :follow_redirect, true }, { :max_redirect, true } ]
    handle_hackney_result :hackney.request(method, url, [], [], options)
  end

  defp handle_hackney_result({ :ok, status, _headers, c }) do
    { :ok, body, _c } = :hackney.body(c)
    { :ok, status, body }
  end

  defp handle_hackney_result({ :error, reason }) do
    { :error, reason }
  end
end
