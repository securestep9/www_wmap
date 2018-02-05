class DiscoveryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

=begin
  def on_complete(status,params)
    logger.info "Sending out email notice to: #{receiver}"
    end_time=Time.now.to_s
    receiver=User.find(params['sid']).email
    UserMailer.discovery_completion_notice(receiver, end_time).deliver_later
  end
=end
  def perform(uid)
    start_time=Time.now.to_s
    dir = Rails.root.join('uploads', uid.to_s)
    s_dir = dir.to_s + "/"
    file = Rails.root.join('uploads', uid.to_s, 'seed')
    cmd = "wmap" + " " + file.to_s + " " + s_dir
    #my_url= Rails.application.routes.url_helpers.users_path
    if system(cmd)
      logger.info "Discovery successful!"
      end_time=Time.now.to_s
      receiver=User.find(uid).email
      logger.info "Sending out email notice to: #{receiver}"
      UserMailer.discovery_completion_notice(receiver, start_time, end_time).deliver_later
    else
      logger.info "Discovery failed!"
      logger.debug "Here's some information related to failed discovery: #{self.class.name}, #{__method__}"
    end
  end

end
