require "test_helper"

class ModelImagesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get model_images_new_url
    assert_response :success
  end

  test "should get create" do
    get model_images_create_url
    assert_response :success
  end

  test "should get edit" do
    get model_images_edit_url
    assert_response :success
  end

  test "should get update" do
    get model_images_update_url
    assert_response :success
  end

  test "should get destroy" do
    get model_images_destroy_url
    assert_response :success
  end

  test "should get index" do
    get model_images_index_url
    assert_response :success
  end

  test "should get show" do
    get model_images_show_url
    assert_response :success
  end
end
