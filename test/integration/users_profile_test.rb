require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination', count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
    log_in_as(@user)
    get root_path
    assert_select 'div.stats', text: /#{@user.following.count}/
    assert_select 'div.stats', text: /#{@user.followers.count}/
    assert_select 'div.stats', text: /following/
    assert_select 'div.stats', text: /follower/
  end
end
