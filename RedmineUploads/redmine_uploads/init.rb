require 'redmine'
require 'dispatcher'

# Solves common rails bug that occurs only in development environment
# This plugin should be reloaded in development mode.
# See http://strd6.com/2009/04/cant-dup-nilclass-maybe-try-unloadable/
# for details 
if RAILS_ENV == 'development'
  ActiveSupport::Dependencies.load_once_paths.reject!{|x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/}
end

# Load the patch
Dispatcher.to_prepare do
  require_dependency 'project'
  require 'redmine_uploads/patch_redmine_classes'
  Project.send(:include, ::Plugin::Uploads::Project)
end

Redmine::Plugin.register :redmine_uploads do
  name 'Redmine Upload Forms plugin'
  author 'Tudor Cornea'
  description 'Redmine plugin used for managing upload forms'
  version '0.0.2'
  url 'https://projects.rosedu.org/projects/redmine-uploads'
# author_url ''

  #Module permissions
  project_module :uploads do
     permission :manage_upload_forms, {:uploads => [:edit, :update]}, :require => :member
     permission :delete_upload_forms, {:uploads => [:destroy]}, :require => :member
     permission :create_upload_forms, {:uploads => [:new, :create]}, :require => :member
     permission :view_upload_forms  , {:uploads => [:index, :show]}
     permission :delete_files, :require => :member
     permission :download_files, :require => :member     
     permission :download_all_files, {:uploads => [:download_all]}, :require => :loggedin
     permission :upload_files, {:uploads => [:add_file]}, :require => :loggedin
  end

  menu :project_menu, :uploads, {:controller => 'uploads', :action => 'index'},   {:caption => 'Uploads', :after => :activity, :param => :project_id }

  activity_provider :upload_forms, :default => false, :class_name => ['UploadForm']
end

# Register the plugin for searching
Redmine::Search.map do |search|
  search.register :upload_forms
end

# Register the plugin as activity provider
Redmine::Activity.map do |activity|
   activity.register :upload_forms
end
