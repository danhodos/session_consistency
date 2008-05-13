require File.join(File.dirname(__FILE__), 'test_helper')

class OptionsController < ActionController::Base
  verify_session_consistency :based_on => :remote_ip, :redirect => {:action => 'logout'}, :except => [:no_dice]
  
  def index; render(:text => 'test'); end
  def no_dice; render(:text => "freeeeeee"); end
  def logout; render(:text => 'success!'); end
  
  def rescue_action(e) raise e end;
end

class OptionsControllerTest < Test::Unit::TestCase
  def setup
    @controller = OptionsController.new
    @request    = ActionController::TestRequest.new
    @request.env["HTTP_USER_AGENT"] = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en) AppleWebKit/522.11.1 (KHTML, like Gecko) Version/3.0.3 Safari/522.12.1"
    @response   = ActionController::TestResponse.new
  end
  
  def test_redirect_option_should_work_correctly
    get :index, {}, {:consistency_check => 'faked_out' }
    assert_redirected_to :action => 'logout'
  end
  
  def test_except_option_should_work_correctly
    get :no_dice, {}, {:consistency_check => 'faked_out' }
    assert_response :success
    assert_match(/free/, @response.body)
  end
  
  def test_based_on_option_should_work
    @request.env["HTTP_USER_AGENT"] = "Changed but we don't care!"
    get :index, {}, {:consistency_check => consistency_checksum }
    assert_response :success
  end
  
private
  def consistency_checksum
    Digest::MD5.hexdigest(@request.remote_ip)
  end
end