require 'test_helper'

class InfluencerControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
