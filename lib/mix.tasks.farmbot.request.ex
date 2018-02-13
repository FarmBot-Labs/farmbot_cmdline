defmodule Mix.Tasks.Farmbot.Request do
  use Mix.Task

  def run([cmd]) do
    {:ok, _} = Application.ensure_all_started(Mix.Project.config()[:app])
    creds = case File.read("creds") do
      {:ok, bin} -> :erlang.binary_to_term(bin)
      _ -> Mix.Tasks.Farmbot.Login.run([])
    end

    Module.concat([FBAPI, Macro.camelize(cmd)])
    |> Code.ensure_loaded()
    |> case do
      {:module, mod} ->
        mod.run(creds)
        |> check_results()
      false ->
        Mix.raise "Unknown command: #{cmd}"
    end
  end

  defp check_results({:ok, {{_, 200, _}, _, body}}) do
    case Poison.decode(body) do
      {:ok, res} ->
        Mix.shell.info [:green, "Request complete: #{inspect res}"]
      _ ->
        Mix.shell.info [:green, "Request complete: #{body}"]
    end
  end

  defp check_results({:ok, {{_, code, _}, _, body}}) do
    case Poison.decode(body) do
      {:ok, res} ->
        Mix.shell.info [:red, "Failed to complete request(#{code}): #{inspect res}"]
      _ ->
        Mix.shell.info [:red, "Failed to complete request(#{code}): #{body}"]
    end
  end

  defp check_results(res) do
    Mix.shell.info [:red, "Failed to complete request #{inspect res}"]
  end
end
