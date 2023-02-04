require "test_helper"

class ModelComponentsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get model_components_new_url
    assert_response :success
  end

  test "should get create" do
    get model_components_create_url
    assert_response :success
  end

  test "should get destroy" do
    get model_components_destroy_url
    assert_response :success
  end
end
