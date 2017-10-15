defmodule RemoteClientTest do
  use ExUnit.Case
  doctest StressMan.RemoteClient
  alias StressMan.RemoteClient
  alias StressMan.Report

  def http_client(_url), do: {:ok, %HTTPoison.Response{ status_code: 200}}

  test "the client should start remote worker" do
    results = RemoteClient.start_worker(10, [node(), node()], "http://example.com", &http_client/1)
    report = Report.generate({100, results})
    assert report.success_cnt == 20
    assert report.error_cnt == 0
    assert report.throughput == 200
  end

end
