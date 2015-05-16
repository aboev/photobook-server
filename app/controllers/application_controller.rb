require 'constants'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :check_credentials, :restrict_demo_account

  def check_credentials()
    private_id = request.headers[Constants::HEADER_USERID]
    @user = User.where(private_id: private_id).first
    if @user == nil
      msg = { :result => "ERROR", :msg => "Wrong user id" }
      respond_to do |format|
        format.json  { render :json => msg } 
      end  
    else
      @public_id = @user.id
    end
  end

  def restrict_demo_account()
    private_id = request.headers[Constants::HEADER_USERID]
    @user = User.where(private_id: private_id).first
    if ((@user != nil) and (@user.id == APP_CONFIG['demo_acct_id']))
      msg = { :result => "ERROR", :msg => "Demo account is limited. Please register" }
      respond_to do |format|
        format.json  { render :json => msg }
      end
    end
  end

  def info
    msg = {:result => Constants::RESULT_OK, :data => {
		Constants::KEY_SERVER_VERSION => APP_CONFIG['server_version'],
		Constants::KEY_MIN_CLIENT_VERSION => APP_CONFIG['min_client_version'],
		Constants::KEY_LATEST_APK_VER => 8,
		Constants::KEY_LATEST_APK_URL => "http://dev.snufan.com/app-release.apk"}}
    respond_to do |format|
        format.json  { render :json => msg }
    end
  end
end
