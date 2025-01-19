defmodule Handle.DomainTest do
  use ExUnit.Case
  doctest Handle.Domain

  alias Handle.Domain.Components

  test "parses public domains" do
    [
      {"google.com", %Components{domain: "google", subdomain: "", tld: "com", type: :public}},
      {"www.google.com",
       %Components{domain: "google", subdomain: "www", tld: "com", type: :public}},
      {"www.google.co.uk",
       %Components{domain: "google", subdomain: "www", tld: "co.uk", type: :public}}
    ]
    |> Enum.each(fn {domain, expected} ->
      assert {:ok, expected} == Handle.Domain.parse(domain)
    end)
  end

  test "parses private domains" do
    [
      {"test.akadns.net",
       %Components{domain: "test", subdomain: "", tld: "akadns.net", type: :private}}
    ]
    |> Enum.each(fn {domain, expected} ->
      assert {:ok, expected} == Handle.Domain.parse(domain)
    end)
  end

  test "parses domain exceptions" do
    assert {:ok,
            %Components{domain: "psl", subdomain: "ignored.wc", tld: "hrsn.dev", type: :private}} ==
             Handle.Domain.parse("ignored.wc.psl.hrsn.dev")

    assert {:ok,
            %Components{
              domain: "notignored",
              subdomain: "",
              tld: "wc.psl.hrsn.dev",
              type: :private
            }} ==
             Handle.Domain.parse("notignored.wc.psl.hrsn.dev")
  end

  test "parses localhost" do
    assert {:ok, %Components{domain: "localhost", subdomain: "", tld: "", type: :test}} ==
             Handle.Domain.parse("localhost")

    assert {:ok, %Components{domain: "localhost", subdomain: "my", tld: "", type: :test}} ==
             Handle.Domain.parse("my.localhost")

    assert {:ok, %Components{domain: "localhost", subdomain: "my.other", tld: "", type: :test}} ==
             Handle.Domain.parse("my.other.localhost")
  end

  test "parses .test" do
    assert {:ok, %Components{domain: "example", subdomain: "", tld: "test", type: :test}} ==
             Handle.Domain.parse("example.test")

    assert {:ok, %Components{domain: "example", subdomain: "www", tld: "test", type: :test}} ==
             Handle.Domain.parse("www.example.test")

    assert {:ok, %Components{domain: "sub", subdomain: "www.example", tld: "test", type: :test}} ==
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
