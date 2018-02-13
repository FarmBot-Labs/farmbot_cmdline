defmodule FBAPI.GetFbosConfig do
  import FBAPI.HTTP

  def run(creds) do
    url = "#{creds.server}/api/fbos_config" |> to_charlist
    get(url, creds)
  end
  
end
