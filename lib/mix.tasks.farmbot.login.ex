defmodule Mix.Tasks.Farmbot.Login do
  use Mix.Task
  @usage "mix farmbot.login email password server"

  def run([email, password, server]) do
    {:ok, _} = Application.ensure_all_started(Mix.Project.config()[:app])
    case FBAPI.Auth.authorize(String.trim(email), String.trim(password), String.trim(server)) do
      {:ok, %{token: _token, secret: _secret, server: ^server} = res} ->
        File.write!("creds", :erlang.term_to_binary(res))
        res
      {:error, err} ->
        IO.inspect(System.stacktrace())
        Mix.raise(inspect(err))
    end
  end

  def run([]) do
    email = :io.get_line("email: ") |> to_string() |> String.trim_trailing("\n")
    password = password_get("password: ") |> String.trim_trailing("\n")
    server = :io.get_line("server: ") |> to_string() |> String.trim_trailing("\n")
    run([email, password, server])
  end

  def run(_) do
    Mix.shell().info([:red, @usage])
  end

  # Password prompt that hides input by every 1ms
  # clearing the line with stderr
  def password_get(prompt) do
    pid = spawn_link(fn -> loop(prompt) end)
    ref = make_ref()

    value = IO.gets(prompt <> " ")

    send(pid, {:done, self(), ref})
    receive do: ({:done, ^pid, ^ref} -> :ok)

    value
  end

  defp loop(prompt) do
    receive do
      {:done, parent, ref} ->
        send(parent, {:done, self(), ref})
        IO.write(:standard_error, "\e[2K\r")
    after
      1 ->
        IO.write(:standard_error, "\e[2K\r#{prompt} ")
        loop(prompt)
    end
  end
end
