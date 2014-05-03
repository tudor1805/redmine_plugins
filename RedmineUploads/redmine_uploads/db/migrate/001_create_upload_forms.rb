class CreateUploadForms < ActiveRecord::Migration
  def self.up
    create_table :upload_forms, :force => true do |t|
      t.string :title, :limit => 60, :default => "", :null => false
      t.text :description
      t.integer :project_id, :default => 0, :null => false
      t.boolean :multiple_uploads, :default => false, :null => false
      t.timestamp :created_on
    end
    add_index 'upload_forms',['created_on'],:name => "index_upload_forms_on_created_on"
    add_index 'upload_forms', ['project_id'], :name => "upload_forms_project_id"
  end

  def self.down
    drop_table :upload_forms
  end
end
