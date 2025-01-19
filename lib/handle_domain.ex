defmodule HandleDomain do
  alias HandleDomain.Domain
  alias HandleDomain.Rule

  @test_domains [
                  "example",
                  "invalid",
                  "localhost",
                  "test"
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

  @spec parse(String.t()) :: {:ok, Domain.t()} | {:error, String.t()}
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
      rule -> Domain.build(rule, domain_parts)
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
