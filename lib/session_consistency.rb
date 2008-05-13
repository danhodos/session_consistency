require 'digest/md5'

module DanHodos
  module SessionConsistency
    module ControllerExtensions
      def self.included(klass)
        klass.class_eval do
          class_inheritable_accessor :session_consistency_options
        end
        klass.extend(ClassMethods)
      end
        
      module ClassMethods
        def verify_session_consistency(opts={})
          defaults = {:based_on => [:remote_ip, :user_agent]}
          defaults.update(:based_on => Array(opts.delete(:based_on))) if opts[:based_on]
          defaults.update(:redirect => opts.delete(:redirect)) if opts[:redirect]
        
          write_inheritable_hash :session_consistency_options, defaults
          before_filter :check_session_consistency, opts
        end
      end # ClassMethods
    
      def check_session_consistency
        session[:consistency_check] ||= consistency_checksum
        
        unless session[:consistency_check] == consistency_checksum
          redirect_to self.class.session_consistency_options[:redirect] and return if self.class.session_consistency_options[:redirect]
        end
        
        session[:consistency_check] == consistency_checksum
      end
    
    private
      def consistency_checksum
        string_to_check = self.class.session_consistency_options[:based_on].map {|opt| request.send(opt)}.join
        Digest::MD5.hexdigest(string_to_check)
      end
    end # ControllerExtensions
    
    # TestRequest doesn't include a user_agent accessor, though CgiRequest does. Let's fix that.
    module TestExtensions
      def user_agent
        env["HTTP_USER_AGENT"]
      end
    end
  end # SessionConsistency
end # DanHodos

ActionController::Base.class_eval { include DanHodos::SessionConsistency::ControllerExtensions }