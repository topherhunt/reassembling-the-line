defmodule RTL.AccountsTest do
  use RTL.DataCase

  alias RTL.Accounts
  alias RTL.Accounts.User

  # TODO: Fill in thorough tests for each context.
  # See commented-out sample context tests below.
  describe "users" do
    @valid_attrs %{full_name: "User 1", email: "user_1@example.com", uuid: "abc123"}

    test "validates required fields" do
      assert_valid(User, :changeset, @valid_attrs)
      assert_invalid(User, :changeset, @valid_attrs, %{email: nil})
      assert_invalid(User, :changeset, @valid_attrs, %{full_name: nil})
      assert_invalid(User, :changeset, @valid_attrs, %{email: nil})
    end

    test "validates email uniqueness" do
      Accounts.insert_user(@valid_attrs)
      {:error, changeset} = Accounts.insert_user(@valid_attrs)
      assert changeset.errors[:email] == {"has already been taken", []}
    end

    test "UUID is auto-populated" do
      # TODO
    end
  end

  #
  # Sample context tests:
  #
  # describe "regions" do
  #   alias RTL.Landscapes.Region

  #   @valid_attrs %{name: "some name"}
  #   @update_attrs %{name: "some updated name"}
  #   @invalid_attrs %{name: nil}

  #   def region_fixture(attrs \\ %{}) do
  #     {:ok, region} =
  #       attrs
  #       |> Enum.into(@valid_attrs)
  #       |> Landscapes.create_region()

  #     region
  #   end

  #   test "list_regions/0 returns all regions" do
  #     region = region_fixture()
  #     assert Landscapes.list_regions() == [region]
  #   end

  #   test "get_region!/1 returns the region with given id" do
  #     region = region_fixture()
  #     assert Landscapes.get_region!(region.id) == region
  #   end

  #   test "create_region/1 with valid data creates a region" do
  #     assert {:ok, %Region{} = region} = Landscapes.create_region(@valid_attrs)
  #     assert region.name == "some name"
  #   end

  #   test "create_region/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Landscapes.create_region(@invalid_attrs)
  #   end

  #   test "update_region/2 with valid data updates the region" do
  #     region = region_fixture()
  #     assert {:ok, region} = Landscapes.update_region(region, @update_attrs)
  #     assert %Region{} = region
  #     assert region.name == "some updated name"
  #   end

  #   test "update_region/2 with invalid data returns error changeset" do
  #     region = region_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Landscapes.update_region(region, @invalid_attrs)
  #     assert region == Landscapes.get_region!(region.id)
  #   end

  #   test "delete_region/1 deletes the region" do
  #     region = region_fixture()
  #     assert {:ok, %Region{}} = Landscapes.delete_region(region)
  #     assert_raise Ecto.NoResultsError, fn -> Landscapes.get_region!(region.id) end
  #   end

  #   test "change_region/1 returns a region changeset" do
  #     region = region_fixture()
  #     assert %Ecto.Changeset{} = Landscapes.change_region(region)
  #   end
  # end
end
