require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_select 'div.stats', /#{@user.following.count}/
    @user.following.each do |user|
      assert_select "aside" do
        assert_select "a[href=?]", user_path(user)
      end
      assert_select "li" do
        assert_select "a[href=?]", user_path(user)
      end
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_select 'div.stats', /#{@user.followers.count}/
    @user.followers.each do |user|
      assert_select "aside" do
        assert_select "a[href=?]", user_path(user)
      end
      assert_select "li" do
        assert_select "a[href=?]", user_path(user)
      end
    end
  end

  test "should follow a user the standard way" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
  end

  test "should follow a user with Ajax" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, xhr: true, params: { followed_id: @other.id }
    end
    assert_select 'form'
  end

  test "should unfollow a user the standard way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
    assert_select 'form'
  end
end
