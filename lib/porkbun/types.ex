defmodule Porkbun.Types do
  @moduledoc """
  Types and validations for Porkbun API fields.
  """

  alias Ecto.Changeset

  def extra_validations(changeset) do
    changeset.changes
    |> Map.keys()
    |> Enum.reduce(changeset, &validate/2)
  end

  def validate(:content, changeset) do
    type = Changeset.get_field(changeset, :type)
    content = Changeset.get_field(changeset, :content)

    if Porkbun.Types.Content.valid_for_type?(content, type) do
      changeset
    else
      Changeset.add_error(changeset, :content, "is not valid for type #{type}")
    end
  end

  def validate(:prio, changeset) do
    type = Changeset.get_field(changeset, :type)
    prio = Changeset.get_field(changeset, :prio)

    required? = Porkbun.Types.Prio.required_for_type?(type)

    if required? and prio == nil do
      Changeset.add_error(changeset, :prio, "is required for type #{type}")
    else
      changeset
    end
  end

  def validate(:name, changeset) do
    type = Changeset.get_field(changeset, :type)
    name = Changeset.get_field(changeset, :name)

    # CNAME records cannot be at root domain (name must not be empty/nil)
    if type == :cname and (name == nil or name == "") do
      Changeset.add_error(changeset, :name, "CNAME records cannot be created at root domain")
    else
      changeset
    end
  end

  def validate(_field, changeset), do: changeset
end
