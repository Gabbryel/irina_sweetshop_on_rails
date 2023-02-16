require "test_helper"

class FeaturesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get features_new_url
    assert_response :success
  end

  test "should get create" do
    get features_create_url
    assert_response :success
  end

  test "should get edit" do
    get features_edit_url
    assert_response :success
  end

  test "should get update" do
    get features_update_url
    assert_response :success
  end

  test "should get index" do
    get features_index_url
    assert_response :success
  end

  test "should get show" do
    get features_show_url
    assert_response :success
  end

  test "should get destroy" do
    get features_destroy_url
    assert_response :success
  end
end
