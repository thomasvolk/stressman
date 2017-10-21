defmodule StressMan.HttpClientHandler do
    require Logger

    def get(url, http_client \\ &HTTPoison.get/1) do
      http_client.(url) |> handle_response
    end

    defp handle_response({:ok, %HTTPoison.Response{ status_code: code}}) do
      case code do
        code when code >= 200 and code < 400 -> { :success, "#{code}"}
        _ -> { :error, "http error - #{code}"}
      end
    end

    defp handle_response({:error, reason}) do
      Logger.error("http_client #{node()}-#{inspect self()} error: #{inspect reason}")
      {:error, "#{inspect reason}"}
    end

    defp handle_response(_) do
      Logger.error("http_client #{node()}-#{inspect self()} error: unknown")
      {:error, "unknown"}
    end
end
