defmodule Handle.DomainTest do
  use ExUnit.Case
  doctest Handle.Domain

  alias Handle.Domain.Domain

  test "parses public domains" do
    [
      {"google.com", %Domain{domain: "google", subdomain: "", tld: "com", type: :public}},
      {"www.google.com", %Domain{domain: "google", subdomain: "www", tld: "com", type: :public}},
      {"www.google.co.uk",
       %Domain{domain: "google", subdomain: "www", tld: "co.uk", type: :public}}
    ]
    |> Enum.each(fn {domain, expected} ->
      assert {:ok, expected} == Handle.Domain.parse(domain)
    end)
  end

  test "parses private domains" do
    [
      {"test.akadns.net",
       %Domain{domain: "test", subdomain: "", tld: "akadns.net", type: :private}}
    ]
    |> Enum.each(fn {domain, expected} ->
      assert {:ok, expected} == Handle.Domain.parse(domain)
    end)
  end

  test "parses domain exceptions" do
    assert {:ok, %Domain{domain: "psl", subdomain: "ignored.wc", tld: "hrsn.dev", type: :private}} ==
             Handle.Domain.parse("ignored.wc.psl.hrsn.dev")

    assert {:ok,
            %Domain{domain: "notignored", subdomain: "", tld: "wc.psl.hrsn.dev", type: :private}} ==
             Handle.Domain.parse("notignored.wc.psl.hrsn.dev")
  end

  test "parses localhost" do
    assert {:ok, %Domain{domain: "localhost", subdomain: "", tld: "", type: :test}} ==
             Handle.Domain.parse("localhost")

    assert {:ok, %Domain{domain: "localhost", subdomain: "my", tld: "", type: :test}} ==
             Handle.Domain.parse("my.localhost")

    assert {:ok, %Domain{domain: "localhost", subdomain: "my.other", tld: "", type: :test}} ==
             Handle.Domain.parse("my.other.localhost")
  end

  test "parses .test" do
    assert {:ok, %Domain{domain: "example", subdomain: "", tld: "test", type: :test}} ==
             Handle.Domain.parse("example.test")

    assert {:ok, %Domain{domain: "example", subdomain: "www", tld: "test", type: :test}} ==
             Handle.Domain.parse("www.example.test")

    assert {:ok, %Domain{domain: "sub", subdomain: "www.example", tld: "test", type: :test}} ==
             Handle.Domain.parse("www.example.sub.test")
  end

  test "parse invalid domain" do
    # Not a valid TLD
    assert {:error, "Invalid domain"} == Handle.Domain.parse("test.notatld")

    # Only a TLD without a domain
    assert {:error, "Top level domain only"} == Handle.Domain.parse("co.uk")

    # Only a TLD without a domain using wildcard
    assert {:error, "Top level domain only"} == Handle.Domain.parse("sys.qcx.io")
  end
end
