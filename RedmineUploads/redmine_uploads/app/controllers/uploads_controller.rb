class UploadsController < ApplicationController

  default_search_scope :uploadForms
  menu_item :upload_forms

  helper :attachments
  helper :sort
  include SortHelper

  require 'zip/zip'

  #For these actions, the project will be taken from params[:project_id]
  before_filter :find_project, :except => [:show, :destroy, :update, :lock, :edit, :download_all, :add_file]
  #For these actions, the project will be taken from the association with UploadForm
  before_filter :find_upload_form, :only => [:show, :destroy, :update, :lock, :edit, :download_all, :add_file]

  before_filter :authorize

  #Displays a list with all of the upload forms
  def index
    @upload_forms = @project.upload_forms
    render :layout => false if request.xhr?
  end

  #Displays the properties of a selected upload form
  def show
    #Initialize sorting helper
    sort_init 'filename', 'asc'
    sort_update 'author' => "#{User.table_name}.firstname",
                'filename' => "#{Attachment.table_name}.filename",
                'created_on' => "#{Attachment.table_name}.created_on",
                'size' => "#{Attachment.table_name}.filesize"

    #The current user's uploaded files
    @my_files = @upload_form.attachments.all(:order => sort_clause, :joins => "LEFT JOIN users ON users.id = attachments.author_id", :conditions => [ "author_id = ?", User.current.id ] )

    if User.current.admin
      @show_files = @upload_form.attachments.all(:order => sort_clause, :joins => "LEFT JOIN users ON users.id = attachments.author_id")
    else
      @show_files = @my_files
    end
  end

  #Displays a html form for creating a new upload
  def new
  end

  #Displays a html form for edit-ing an existing upload form
  def edit
    #Will set disabled property in view to true
    @disable_multiple_uploads = true
  end

  #Creates a new upload form
  def create
    #Initialize new upload form
    @upload_form = @project.upload_forms.build do |uf|
      uf.title = params[:upload_form][:title]
      uf.description = params[:upload_form][:description]
      uf.multiple_uploads = params[:upload_form][:multiple_uploads]
      uf.created_on = Time.now
    end

    if request.post? and @upload_form.save
       flash[:notice] = l(:notice_successful_create)
       redirect_to :action => "index"
    else
       render "new"
    end
  end

  #Updates an existing upload form
  def update
    if @upload_form.update_attributes(params[:upload_form])
      flash[:notice] =l(:notice_successful_update)
      redirect_to :action => "show", :id => params[:id]
    else 
      render "edit"
    end
  end

  #Deletes an existing upload form
  def destroy
        @upload_form.destroy
        redirect_to :action => "index", :project_id => @project
  end

  #Creates an archive with all of the download-able files, 
  #and sends it to the client's browser
  def download_all
    #If user is admin, he should see all the files uploaded for this form
    if User.current.admin
      @atts = @upload_form.attachments.all(:joins => "LEFT JOIN users ON users.id = attachments.author_id")
    else
      @atts = @upload_form.attachments.all(:joins => "LEFT JOIN users ON users.id = attachments.author_id", :conditions => [ "author_id = ?", User.current.id ] )
    end

    #Default root directory, where the files will be stored
    files_root_path="files"
    current_timestamp = Time.new.to_time.to_i
    archive_name = "#{current_timestamp}_attachments.zip"
    archive_path = File.join(files_root_path, archive_name)
 
    #Create a zip file with all the attachments
    Zip::ZipOutputStream::open(archive_path) {
      |zip_file|

      #Add each individual file to the archive
      @atts.each do |att|  
        file_path = File.join(files_root_path, att.disk_filename)
        zip_file.put_next_entry(att.filename)
        zip_file.write File.new(file_path, "r").read
      end
     }

    #Disabled streaming. The whole file will be loaded into the server, and 
    #then sent. Consider adding 'x_sendfile => true' to the parameters list 
    #if your server is apache, to speed-up downloads
    send_file archive_path, :type => "application/x-gzip", :stream => false

    #Clean up after send
    File.delete(archive_path)
  end 

  #Uploads a file for the current upload form 
  def add_file
    #Delete the old attachments  
    unless @upload_form.multiple_uploads
      Attachment.delete_all( ["container_id = ? AND author_id = ?", @upload_form.id, User.current.id] )
    end

    attachments = Attachment.attach_files(@upload_form, params[:attachments])
    redirect_to :back, :params => @upload_form
  end
 
  private

  #Finds the current project based on the parameter passed as 'project_id'
  def find_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
#     render :text => "No permission"
  end

  #Finds the current upload form, and the current project, based
  #on the association
  def find_upload_form
    @upload_form = UploadForm.find(params[:id])
    @project = @upload_form.project
    rescue ActiveRecord::RecordNotFound
      render_404
#     render :text => "No permission"
  end
 
end
