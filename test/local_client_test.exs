defmodule LocalClientTest do
  use ExUnit.Case
  doctest StressMan.LocalClient
  alias StressMan.LocalClient
  alias StressMan.Report

  def http_client(_url), do: {:ok, %HTTPoison.Response{ status_code: 200}}

  test "the local client should start worker" do
    results = LocalClient.start_worker(10, "http://example.com", &http_client/1)
    report = Report.generate({100, results})
    assert report.success_cnt == 10
    assert report.error_cnt == 0
    assert report.throughput == 100
  end

end
