defmodule Handle.Domain do
  @moduledoc """
  Provides functionality to parse and extract domain components from a given hostname
  using a list of public and test suffix rules.

  ## Overview

  This module loads public suffix rules from a local file (`priv/public_suffix_list.dat`)
  and combines them with predefined test domains. It offers a `parse/1` function
  that takes a hostname and returns a structured representation of the domain components
  (domain, subdomain, TLD, and type) or an error if the domain is invalid.

  ## Parsing a Hostname

  - The `parse/1` function takes a hostname as a string.
  - If a matching rule is found, it builds a domain component struct using `Components.build/2`.
  - If no rule matches, it returns an error tuple indicating an invalid domain.

  ## Example

      iex> Handle.Domain.parse("sub.example.co.uk")
      {:ok, %Handle.Domain.Components{
        domain: "example",
        subdomain: "sub",
        tld: "co.uk",
        type: :public
      }}

  """

  alias Handle.Domain.Components
  alias Handle.Domain.Rule

  @test_domains [
                  "example",
                  "invalid",
                  "localhost",
                  "test",
                  "local"
                ]
                |> Enum.map(&Rule.parse(&1, :test))

  @suffix_rules File.read!("priv/public_suffix_list.dat")
                |> String.split("\n", trim: true)
                |> Enum.reduce({:public, []}, fn line, {type, acc} ->
                  case Rule.parse(line, type) do
                    nil -> {type, acc}
                    :begin_private_domains -> {:private, acc}
                    rule -> {type, [rule | acc]}
                  end
                end)
                |> elem(1)
                |> Enum.concat(@test_domains)

  @spec parse(String.t()) :: {:ok, Components.t()} | {:error, String.t()}
  @doc """
  Parses a given hostname and returns a structured representation of its domain components.

  If the hostname matches a public suffix rule, the function returns a domain component struct.
  If no rule matches, it returns an error tuple with a message indicating an invalid domain.

  ## Example

      iex> Handle.Domain.parse("sub.example.co.uk")
      {:ok, %Handle.Domain.Components{
        domain: "example",
        subdomain: "sub",
        tld: "co.uk",
        type: :public
      }}

      iex> Handle.Domain.parse("sub.example.not_a_tld")
      {:error, "Invalid domain"}

  ## localhost

  The function recognizes `localhost` as a special case and returns a domain component struct
  with an empty TLD and the type set to `:test`.

      iex> Handle.Domain.parse("sub.localhost")
      {:ok, %Handle.Domain.Components{
        domain: "localhost",
        subdomain: "sub",
        tld: "",
        type: :test
      }}


  ## Test Domains

  The function recognizes predefined test domains that are not strictly valid TLDs.

  Examples include:

    - `.example`
    - `.invalid`
    - `.test`
    - `.local`
  """
  def parse(host) do
    domain_parts =
      host
      |> String.split(".")
      |> Enum.reverse()

    @suffix_rules
    |> Enum.filter(&Rule.match?(&1, domain_parts))
    |> best_match()
    |> case do
      nil -> {:error, "Invalid domain"}
      rule -> Components.build(rule, domain_parts)
    end
  end

  @spec best_match(list(Rule.t()), Rule.t() | nil) :: Rule.t() | nil
  defp best_match(rules, best \\ nil)
  defp best_match([], best), do: best

  # Ignore the previous match and continue searching on exceptions
  defp best_match([%Rule{rule_type: :exception}, _ignored | rest], best),
    do: best_match(rest, best)

  # Only match so far, so it's currently the best match
  defp best_match([rule | rest], nil), do: best_match(rest, rule)

  defp best_match([%Rule{length: new_length} = rule | rest], %Rule{length: best_length})
       when new_length > best_length do
    # This rule is longer than the best match so far
    best_match(rest, rule)
  end

  # Not the best match, continue searching
  defp best_match([_ | rest], best), do: best_match(rest, best)
end
