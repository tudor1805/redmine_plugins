#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|
  map.resources :projects, :only => [] do |project|
   project.resources :uploads, :shallow => true, :member => { :add_file => [:post] , :download_all => [:get] }  do |upload| 
    end   
  end
end

