module Plugin
  module Uploads
    module Project
      module ClassMethods
      end

      module InstanceMethods
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval do
          unloadable
          has_many :upload_forms
        end
      end
    end
  end
end
