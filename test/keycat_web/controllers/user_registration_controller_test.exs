defmodule KeycatWeb.UserRegistrationControllerTest do
  use KeycatWeb.ConnCase, async: true

  import Keycat.AccountsFixtures

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Create an account"
      assert response =~ "Login here"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get(Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      username = unique_user_username()
      email = unique_user_email()

      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => valid_user_attributes(username: username, email: email)
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ email
      assert response =~ username
      assert response =~ "Settings"
      assert response =~ "Sign out"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"username" => "john", "email" => "with spaces", "password" => "short"}
        })

      response = html_response(conn, 200)
      assert response =~ "Create an account"
      assert response =~ "invalid email"
      assert response =~ "should be at least 6 character(s)"
      assert response =~ "at least one upper case character"
      assert response =~ "at least one digit or punctuation character"
    end
  end
end
