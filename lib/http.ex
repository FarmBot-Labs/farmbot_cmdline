defmodule FBAPI.HTTP do
  def get(url, creds) do
    :httpc.request(:get, {url, [{'Authorization', '#{creds.token}'}]}, [], [])
  end

  def delete(url, payload, creds) do
    :httpc.request(:delete, {url, [{'Authorization', '#{creds.token}'}], 'application/json', payload}, [], [])
  end
end
