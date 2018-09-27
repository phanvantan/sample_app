require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "phanvantan", email: "tan@tandeptrai.com",
     password: "chode10con", password_confirmation: "chode10con")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@tandeptrai.com"
    assert_not @user.valid?
  end
  test "email validation should accept valid addresses" do
    valid_addresses = %w(tan@tandeptrai.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn)
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@tandeptrai.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, "")
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    phanvantan = users(:phanvantan)
    archer = users(:archer)
    assert_not phanvantan.following?(archer)
    phanvantan.follow(archer)
    assert phanvantan.following?(archer)
    assert archer.followers.include?(phanvantan)
    phanvantan.unfollow(archer)
    assert_not phanvantan.following?(archer)
  end

  test "feed should have the right posts" do
    phanvantan = users(:phanvantan)
    archer = users(:archer)
    lana = users(:lana)
    lana.microposts.each do |post_following|
      assert phanvantan.feed.include?(post_following)
    end
    phanvantan.microposts.each do |post_self|
      assert phanvantan.feed.include?(post_self)
    end
    archer.microposts.each do |post_unfollowed|
      assert_not phanvantan.feed.include?(post_unfollowed)
    end
  end
end
