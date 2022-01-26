defmodule FoodDiaryWeb.SchemaTest do
  use FoodDiaryWeb.ConnCase, async: true
  use FoodDiaryWeb.SubscriptionCase

  alias FoodDiary.{User, Users}

  describe "users query" do
    test "when a valid id is given, the query returns an user", %{conn: conn} do
      {:ok, %User{id: user_id}} =
        %{email: "matheus@email.com", name: "Matheus"}
        |> Users.Create.call()

      query = """
      {
        user(id: "#{user_id}"){
          name,
          email
        }
      }
      """

      expected_response = %{
        "data" => %{"user" => %{"email" => "matheus@email.com", "name" => "Matheus"}}
      }

      response =
        conn
        |> post("api/graphql", %{query: query})
        |> json_response(:ok)

      assert response == expected_response
    end

    test "when the user does not exists, returns an error", %{conn: conn} do
      query = """
      {
        user(id: "#{1}"){
          name,
          email
        }
      }
      """

      expected_response = %{
        "data" => %{"user" => nil},
        "errors" => [
          %{
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "User not found",
            "path" => ["user"]
          }
        ]
      }

      response =
        conn
        |> post("api/graphql", %{query: query})
        |> json_response(:ok)

      assert response == expected_response
    end
  end

  describe "users mutations" do
    test "when all params are valid, create an user", %{conn: conn} do
      mutation =
        """
        mutation{
          createUser(input: {
            email: "matheus@email.com",
            name: "Matheus"
          }){
            id,
            name,
            email
          }
        }
        """

        response =
          conn
          |> post("api/graphql", %{query: mutation})
          |> json_response(:ok)

        assert %{"data" => %{"createUser" => %{"email" => "matheus@email.com", "name" => "Matheus", "id" => _id}}} = response
    end
  end

  describe "subscriptions" do
    test "should publish on meals topic after a meal creation", %{socket: socket, conn: conn} do
      {:ok, %User{id: user_id}} =
        %{email: "matheus@email.com", name: "Matheus"}
        |> Users.Create.call()

      mutation = """
      mutation{
        createMeal(input: {
          userId: #{user_id},
          description: "Parmegina de frango",
          calories: 500.30,
          category: FOOD
        }){
          description,
          calories,
          category
        }
      }
      """

      subscription = """
        subscription {
          newMeal {
            description
          }
        }
      """

      # Subscription setup
      socket_ref = push_doc(socket, subscription)
      assert_reply socket_ref, :ok, %{subscriptionId: subscription_id}


      # Setup mutation
      socket_ref = push_doc(socket, mutation)
      assert_reply socket_ref, :ok, mutation_response

      expected_mutation_response = %{data: %{"createMeal" => %{"calories" => 500.3, "category" => "FOOD", "description" => "Parmegina de frango"}}}

      expected_subscription_response = "abacaxi"

      assert mutation_response == expected_mutation_response

      assert_push "subscription:data", subscription_response
      assert  %{result: %{data: %{"newMeal" => %{"description" => "Parmegina de frango"}}}, subscriptionId: subscription_id} = subscription_response
    end
  end
end
