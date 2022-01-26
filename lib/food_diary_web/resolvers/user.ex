defmodule FoodDiaryWeb.Resolvers.User do
  alias FoodDiary.Users

  def get(%{id: user_id}, _context), do: Users.Get.call(user_id)
  @spec create(
          %{
            :input => %{optional(:__struct__) => none, optional(atom | binary) => any},
            optional(any) => any
          },
          any
        ) :: any
  def create(%{input: %{} = params}, _context), do: Users.Create.call(params)
  def delete(%{id: id}, _context), do: Users.Delete.call(id)
end
