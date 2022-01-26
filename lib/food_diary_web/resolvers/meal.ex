defmodule FoodDiaryWeb.Resolvers.Meal do
  alias FoodDiary.Meals

  # def create(%{input: input}, _context) do
  #     case result = Meals.Create.call(input) do
  #      {:ok, meal} -> publish_result(meal)
  #      _ -> result
  #     end
  #   end

  # defp publish_result(meal) do
  #   Absinthe.Subscription.publish(FoodDiaryWeb.Endpoint, meal, new_meal: "new_meal_topic")
  #   {:ok, meal}
  # end

  def create(%{input: input}, _context), do: Meals.Create.call(input)
end
