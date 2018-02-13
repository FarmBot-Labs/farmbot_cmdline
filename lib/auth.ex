defmodule FBAPI.Auth do
  @moduledoc "Functionality responsible for getting a JWT."

  @doc "Authorizes with the farmbot api."
  def authorize(email, password, server) do
    with {:ok, {:RSAPublicKey, _, _} = rsa_key} <- fetch_rsa_key(server),
         {:ok, secret}  <- build_secret(email, password, rsa_key),
         {:ok, payload} <- build_payload(secret),
         {:ok, resp}    <- request_token(server, payload),
         {:ok, body}    <- Poison.decode(resp),
         {:ok, map}     <- Map.fetch(body, "token"),
         {:ok, encoded} <- Map.fetch(map, "encoded") do
      {:ok, %{secret: secret, token: encoded, server: server}}
    else
      :error -> {:error, "unknown error."}
      err -> err
    end
  end

  def fetch_rsa_key(server) do
    url_char_list = '#{server}/api/public_key'
    with {:ok, {{_, 200, _}, _, body}} <- :httpc.request(url_char_list) do
      r = body |> to_string() |> RSA.decode_key()
      {:ok, r}
    end
  end

  defp build_secret(email, password, rsa_key) do
    {:ok, %{email: email, password: password, id: UUID.uuid1(), version: 1}
    |> Poison.encode!()
    |> RSA.encrypt({:public, rsa_key})}
  end

  defp build_payload(secret) do
    %{user: %{credentials: secret |> Base.encode64()}} |> Poison.encode()
  end

  defp request_token(server, payload) do
    url = "#{server}/api/tokens" |> to_charlist()
    case :httpc.request(:post, {url, [], 'application/json', payload}, [], []) do
      {:ok, {{_, 200, _}, _, body}} -> {:ok, body}
      _ -> {:error, :http_error}
    end
  end
end
