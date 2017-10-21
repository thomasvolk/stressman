defmodule RemoteClientTest do
  use ExUnit.Case
  doctest StressMan.Manager
  alias StressMan.Manager
  alias StressMan.Report

  def http_client(_url), do: {:ok, %HTTPoison.Response{ status_code: 200}}

  test "the client should start remote worker" do
    results = Manager.start(10, "http://example.com", &http_client/1, [node(), node()])
    report = Report.generate({100, results})
    assert report.success_cnt == 20
    assert report.error_cnt == 0
    assert report.throughput == 200
  end

end
