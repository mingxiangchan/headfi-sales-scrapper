defmodule Headfi.ActionTest do
  use ExUnit.Case, async: true

  alias Headfi.{Action, Repo}
  doctest Headfi.Action

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "Return an empty summary on an unknown student" do
    assert [] == Action.summary("Student", "999")
  end

  test "Add actions and then get a summary for an entity" do
    assert [] == Action.summary("Student", "148")

    Action.add("create_student", "Student", "148")
    Action.add("add_course", "Student", "148")
    Action.add("remove_course", "Student", "1234")

    assert ["create_student", "add_course"] == Action.summary("Student", "148")
    assert ["remove_course"] == Action.summary("Student", "1234")
  end
end
