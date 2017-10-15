defmodule ClientTest do
  use ExUnit.Case
  doctest StressMan.Client

  def http_client(url), do: {:ok, %HTTPoison.Response{ status_code: 200}}

  test "the client should start remote worker" do
    results = StressMan.Client.start_remote_worker(10, [node()], "http://example.com", &http_client/1)
    report = StressMan.Report.generate({100, results})
    assert report.success_cnt == 10
    assert report.error_cnt == 0
    assert report.throughput == 100
  end

  test "the client should start local worker" do
    results = StressMan.Client.start_local_worker(10, "http://example.com", &http_client/1)
    report = StressMan.Report.generate({100, results})
    assert report.success_cnt == 10
    assert report.error_cnt == 0
    assert report.throughput == 100
  end

end
