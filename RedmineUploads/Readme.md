A plugin for managing upload forms

Details
The plugin is useful for collecting information from groups of users, similar to a homework assignment on Moodle.

Features

Allows creation/deletion of upload forms.
Allows separate views of the uploaded files (each unprivileged user will see only his own uploaded files,
privileged users can see all the files, and download them , if needed)
Allows a privileged user to download the uploaded files to a zip archive.
Searchable
Appears in the 'Activity tab'
Installation notes

Installation

Copy the folder (redmine_uploads) inside #{REDMINE_ROOT}/vendor/plugins
Go to #{REDMINE_ROOT} and run : 
   rake db:migrate_plugins

Before this, you might need to run :
   export RAILS_ENV="production" (Linux)  or
   set RAILS_ENV="production"    (Windows)
Restart redmine
Dependencies
This plugin depends on the 'rubyzip' gem
You can install it by running :

    [sudo] gem install rubyzip
Now, when logged on as an admin, in the Plugins section, under the
Administration panel, you should see the plugin.
Redmine uploads is a 'per project' module. In order to use it, you should
enable it from Settings => Modules from your project.
In order to use it efficiently, make sure you set the correct permissions
for the roles under Administration => Roles & Permissions
Atom
Changelog

0.0.2 (2011-07-28)

Compatible with Redmine 1.2.x.

Have eliminated the restriction for a single uploaded file per-form 
(The user can choose multiple uploads now , when creating the form).
