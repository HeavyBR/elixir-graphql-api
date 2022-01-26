defmodule FoodDiaryWeb.Schema.Types.Root do
  use Absinthe.Schema.Notation

  alias Crudry.Middlewares.TranslateErrors
  alias FoodDiaryWeb.Resolvers.Meal, as: MealsResolver
  alias FoodDiaryWeb.Resolvers.User, as: UsersResolver

  import_types FoodDiaryWeb.Schema.Types.User
  import_types FoodDiaryWeb.Schema.Types.Meal

  object :root_query do
    field :user, type: :user do
      arg :id, non_null(:id)

      resolve &UsersResolver.get/2
    end
  end

  object :root_mutation do
    # users
    @desc "Create a new user"
    field :create_user, type: :user do
      arg :input, non_null(:create_user_input)

      resolve &UsersResolver.create/2
      middleware TranslateErrors
    end

    field :delete_user, type: :user do
      @desc "Delete a user by id"
      arg :id, non_null(:id)

      resolve &UsersResolver.delete/2
    end

    # meals
    @desc "Create new meal"
    field :create_meal, type: :meal do
      arg :input, non_null(:create_meal_input)

      resolve &MealsResolver.create/2
      middleware TranslateErrors
    end
  end

  object :root_subscription do
    # field :new_meal, type: :meal do
    #   config fn _args, _info ->
    #     {:ok, topic: "new_meal_topic"}
    #   end
    # end

    field :new_meal, :meal do
      config fn _args, _info ->
        {:ok, topic: "new_meal_topic"}
      end

      trigger :create_meal, topic: fn _ -> ["new_meal_topic"] end
    end
  end
end