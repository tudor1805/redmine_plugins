require File.dirname(__FILE__) + '/../test_helper'

class UploadFormTest < ActiveSupport::TestCase
  fixtures :projects, :upload_forms, :attachments

  #Create a valid project object, used for testing
  def create_valid_project
    if defined?(@proj).nil?
      @proj = Project.new(:name => "TestProject", :description => "A Test Project" ,:is_public => true, :created_on => Time.now, :updated_on => Time.now,  :identifier => "testproj", :lft => 1, :rgt => 10)
      assert @proj.save
    end
    @proj
  end


  #Tests the various relations that UploadForm has with other models
  def test_model_relations

    #Create a valid project
    @proj1 = create_valid_project

    #Tests [belongs_to Project] 
    assert true == UploadForm.new.respond_to?(:project)
   
    #Tests [has_many Attachments]
    assert true == UploadForm.new.respond_to?(:attachments)

    #Tests [Project has_many Upload_Forms]
    assert true == Project.new.respond_to?(:upload_forms)

    #Tests [Attachment belongs_to Upload_Form trough container]
    @up_form1 = @proj1.upload_forms.build :title => "Valid title"
    assert @up_form1.save    

    @att_file = @up_form1.attachments.build    
    assert @att_file.container == @up_form1
  end


  #Tests all the constraints regarding the creation of an upload form
  def test_create_upload_form
 
    #Create a valid project
    @proj1 = create_valid_project

    #Test presence of project
    @up_form1 = UploadForm.new :title => "Valid title", :description => "Forgot project"

    assert false == @up_form1.save

    #Test presence of title
    @up_form2 = @proj1.upload_forms.build :description => "Forgot title"

    assert false == @up_form2.save

    #Test maximum length of title (60)
    @invalid_title = (0..60).map{ ('a'..'z').to_a[rand(26)] }.join
    @up_form3 = @proj1.upload_forms.build :title => @invalid_title, :description => "Title is too long"

    assert false == @up_form3.save

    #Test valid upload form
    @up_form4 = @proj1.upload_forms.build :title => "Valid title", :description => "All params are OK"

    assert @up_form4.save
  end


  #Tests the correctness of the updated_on method
  def test_updated_on_with_attachments
    @up_form = UploadForm.find(1)
    assert @up_form.attachments.any?
    assert_equal @up_form.attachments.map(&:created_on).max, @up_form.updated_on
  end

  def test_updated_on_without_attachments
    @up_form = UploadForm.find(2)
    assert @up_form.attachments.empty?
    assert_equal @up_form.created_on, @up_form.updated_on
  end


  #Tests the fact that all attachments are deleted when an Upload Form is deleted
  def test_deletes_attachments_on_destroy

     @up_form = UploadForm.find 1
     #Get the ids of the attributes of the form
     @att_ids = @up_form.attachments.map(&:id)

     #Destroy the upload form(the attachments should be destroyed after this)
     @up_form.destroy

     #The attachments should not be found, now
     @att_ids.each do |id|
       assert true unless Attachment.find_by_id(id)
     end
  end

end
