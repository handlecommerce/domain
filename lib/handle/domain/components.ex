defmodule Handle.Domain.Components do
  @moduledoc """
  Provides functionality to build a structured domain representation from parsed rules and domain parts.

  The module defines a struct for a domain, including:
    - `:domain` – the main domain name
    - `:subdomain` – any subdomain portions
    - `:tld` – top-level domain portion
    - `:type` – domain type (`:public`, `:private`, or `:test`)

  ## Building Domains

  The primary function `build/2` takes a parsed rule (`Handle.Domain.Rule.t()`) and a list of domain parts,
  then attempts to construct a `%Handle.Domain.Components{}` struct based on the rule type.

  - For wildcard rules (`:wildcard`), it splits the domain parts to extract the TLD, domain, and subdomain.
  - For other rule types, it handles the special case where the domain is "localhost"
    (treated as a test domain without a TLD), and standard domain parsing for other cases.

  If the domain parts do not meet expectations (e.g., top-level domain only),
  it returns an error tuple with an appropriate message.

  ## Examples

      iex> rule = %Handle.Domain.Rule{rule_type: :standard, length: 1, parts: ["com"], domain_type: :public}
      iex> Handle.Domain.Components.build(rule, ["com", "example", "sub"])
      {:ok, %Handle.Domain.Components{
         domain: "example",
         subdomain: "sub",
         tld: "com",
         type: :public
       }}

  """
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
