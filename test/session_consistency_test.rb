require File.join(File.dirname(__FILE__), 'test_helper')

class SessionConsistencyController < ActionController::Base
  verify_session_consistency
  
  def index; render(:text => "test"); end
  
  def rescue_action(e) raise e end;
end

class SessionConsistencyTest < Test::Unit::TestCase
  def setup
    @controller = SessionConsistencyController.new
    @request    = ActionController::TestRequest.new
    @request.user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en) AppleWebKit/522.11.1 (KHTML, like Gecko) Version/3.0.3 Safari/522.12.1"
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_set_session_consistency_checksum_on_first_request
    get :index
    assert_not_nil session[:consistency_check]
  end
  
  def test_should_have_checksum_as_hexdigest_of_remote_ip_and_user_agent
    get :index
    assert_equal session[:consistency_check], consistency_checksum
  end
  
  def test_should_render_on_first_request
    get :index
    assert_response :success
  end
  
  def test_should_halt_filter_chain_if_user_agent_changes
    checksum = consistency_checksum
    
    @request.user_agent = "Some New User Agent"
    get :index, {}, {:consistency_check => checksum }
    
    assert_response :error
  end
  
  def test_should_halt_filter_chain_if_remote_ip_changes
    checksum = consistency_checksum
    
    @request.env["REMOTE_ADDR"] = "123.42.67.254"
    get :index, {}, {:consistency_check => checksum }
    
    assert_response :error
  end
  
private
  def consistency_checksum
    Digest::MD5.hexdigest(@request.remote_ip + @request.user_agent)
  end
end