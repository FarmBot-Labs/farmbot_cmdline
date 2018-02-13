defmodule FBAPI.DeleteFbosConfig do
  import FBAPI.HTTP
  
  def run(creds) do
    url = "#{creds.server}/api/fbos_config" |> to_charlist
    payload = ""
    delete(url, payload, creds)
  end
end
