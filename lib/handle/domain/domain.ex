defmodule Handle.Domain.Domain do
  defstruct [:domain, :subdomain, :tld, :type]

  alias Handle.Domain.Rule

  @type t :: %__MODULE__{
          domain: String.t(),
          subdomain: String.t(),
          tld: String.t(),
          type: :public | :private | :test
        }

  @spec build(Rule.t(), list(String.t())) :: {:ok, t()} | {:error, String.t()}
  def build(%Rule{rule_type: :wildcard} = rule, domain_parts) do
    case Enum.split(domain_parts, rule.length - 1) do
      {tld, [domain | subdomain]} ->
        {:ok,
         %__MODULE__{
           domain: domain,
           subdomain: merge_parts(subdomain),
           tld: merge_parts(tld),
           type: rule.domain_type
         }}

      _ ->
        {:error, "Top level domain only"}
    end
  end

  def build(%Rule{} = rule, domain_parts) do
    case Enum.split(domain_parts, rule.length) do
      # Special case localhost as a domain without a TLD
      {["localhost"], subdomain} ->
        {:ok,
         %__MODULE__{
           domain: "localhost",
           subdomain: merge_parts(subdomain),
           tld: "",
           type: :test
         }}

      {tld, [domain | subdomain]} ->
        {:ok,
         %__MODULE__{
           domain: domain,
           subdomain: merge_parts(subdomain),
           tld: merge_parts(tld),
           type: rule.domain_type
         }}

      _ ->
        {:error, "Top level domain only"}
    end
  end

  defp merge_parts(parts), do: parts |> Enum.reverse() |> Enum.join(".")
end
