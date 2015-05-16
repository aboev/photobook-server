require 'net/http'
class PushSender
  @queue = :push

  EVENT_NEW_COMMENT 	= 	0
  EVENT_NEW_IMAGE 	= 	1
  EVENT_NEW_MESSAGE 	=	2
  EVENT_NEW_CONTACT 	=	3

  def self.perform(id, event, msg)
    if APP_CONFIG['ENABLE_PUSH'] != 1
      return
    end

    Resque.after_fork = Proc.new do
      Rails.logger.auto_flushing = true
    end

    log = Logger.new 'log/resque.log'

    user = User.where(id: id).first
    if ((user == nil) or (user.pushid == nil) or (user.pushid.length == 0))
      log.debug("No pushid found for user with id " + id)
      return
    end
    log.debug("Delivering push notification to user " + user.id.to_s)

    http = Net::HTTP.new('android.googleapis.com', 80)
    request = Net::HTTP::Post.new('/gcm/send', 
      {'Content-Type' => 'application/json',
       'Authorization' => 'key=' + APP_CONFIG['google_api_key']})
    data = {:registration_ids => [user.pushid], :data => {:event => event, :msg => msg}}
    request.body = data.to_json
    response = http.request(request)
    if response.kind_of? Net::HTTPSuccess
      log.debug("Notification sent to user " + user.id.to_s + ", response message: " + response.body)
    else
      log.debug("Failed to send notification to user " + user.id.to_s + ", response message: " + response.body)
    end
  end

end
