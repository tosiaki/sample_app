require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  test "signup post url" do
    get signup_path
    assert_select 'form[action="/signup"]'
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name: "", email: "user@invalid", password: "foo", password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation', /The form contains 4 errors/
    assert_select 'div#error_explanation' do
      assert_select 'ul' do
        assert_select 'li', "Name can't be blank"
        assert_select 'li', "Email is invalid"
        assert_select 'li', "Password confirmation doesn't match Password"
        assert_select 'li', "Password is too short (minimum is 6 characters)"
      end
    end
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User", email: "user@example.com", password: "password", password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert_select 'div', /welcome/i
    assert is_logged_in?
  end
end
