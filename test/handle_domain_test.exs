defmodule HandleDomainTest do
  use ExUnit.Case
  doctest HandleDomain

  alias HandleDomain.Domain

  test "parses public domains" do
    [
      {"google.com", %Domain{domain: "google", subdomain: "", tld: "com", type: :public}},
      {"www.google.com", %Domain{domain: "google", subdomain: "www", tld: "com", type: :public}},
      {"www.google.co.uk",
       %Domain{domain: "google", subdomain: "www", tld: "co.uk", type: :public}}
    ]
    |> Enum.each(fn {domain, expected} ->
      assert {:ok, expected} == HandleDomain.parse(domain)
    end)
  end

  test "parses private domains" do
    [
      {"test.akadns.net",
       %Domain{domain: "test", subdomain: "", tld: "akadns.net", type: :private}}
    ]
    |> Enum.each(fn {domain, expected} ->
      assert {:ok, expected} == HandleDomain.parse(domain)
    end)
  end

  test "parses domain exceptions" do
    assert {:ok, %Domain{domain: "psl", subdomain: "ignored.wc", tld: "hrsn.dev", type: :private}} ==
             HandleDomain.parse("ignored.wc.psl.hrsn.dev")

    assert {:ok,
            %Domain{domain: "notignored", subdomain: "", tld: "wc.psl.hrsn.dev", type: :private}} ==
             HandleDomain.parse("notignored.wc.psl.hrsn.dev")
  end

  test "parses localhost" do
    assert {:ok, %Domain{domain: "localhost", subdomain: "", tld: "", type: :test}} ==
             HandleDomain.parse("localhost")

    assert {:ok, %Domain{domain: "localhost", subdomain: "my", tld: "", type: :test}} ==
             HandleDomain.parse("my.localhost")

    assert {:ok, %Domain{domain: "localhost", subdomain: "my.other", tld: "", type: :test}} ==
             HandleDomain.parse("my.other.localhost")
  end

  test "parses .test" do
    assert {:ok, %Domain{domain: "example", subdomain: "", tld: "test", type: :test}} ==
             HandleDomain.parse("example.test")

    assert {:ok, %Domain{domain: "example", subdomain: "www", tld: "test", type: :test}} ==
             HandleDomain.parse("www.example.test")

    assert {:ok, %Domain{domain: "sub", subdomain: "www.example", tld: "test", type: :test}} ==
             HandleDomain.parse("www.example.sub.test")
  end

  test "parse invalid domain" do
    # Not a valid TLD
    assert {:error, "Invalid domain"} == HandleDomain.parse("test.notatld")

    # Only a TLD without a domain
    assert {:error, "Top level domain only"} == HandleDomain.parse("co.uk")

    # Only a TLD without a domain using wildcard
    assert {:error, "Top level domain only"} == HandleDomain.parse("sys.qcx.io")
  end
end
