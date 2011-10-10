# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

	config.gem "xml-simple", :lib => "xmlsimple"
	config.gem "oauth"
	config.gem "ruby-hmac", :lib => "hmac-sha1"

	# Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
	config.time_zone = 'UTC'

  config.action_controller.session = {
    :session_key => '_raider_session',
    :secret      => '959a27c75f5cb1e5f0d54266226aa4de6d4da3903e59acb890230878990286bf5ad1da7b8f059040e58c3a7cd8177a73cbf1896cc3ec269f21bc8af91d52cab8'
  }

end

Time::DATE_FORMATS[:filename] = "%Y%m%d%H%M%S"   # 20091231235959

