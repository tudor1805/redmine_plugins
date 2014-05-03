Details
----------

A plugin that sends periodic notifications to all the members involved in a project.

Installation
---------------

1. Go to the plugin directory path

        cd #{REDMINE_ROOT}/vendor/plugins

2. Copy the folder (*redmine_issue_notification*) inside **#REDMINE_ROOT}/vendor/plugins**

3. Migrate the the notifications model into the database  
    Go to **#{REDMINE_ROOT}** and run:

        rake db:migrate_plugins 

4. Restart Redmine

        ruby script/server     

Notifications
-----------------
To effectively send notifications you will need to configure crontab to run the rake task *'rake issue_notification:send'*

Example:

     crontab -e

choose the text editor, then insert the following code

     0 7 * * * cd /full/path/to/your/rails/application && rake issue_notification:send &> /tmp/cron_issue_notification.log

save it and cron will start automatically

To start/stop/restart cron (on debian) use:

    /etc/init.d/cron command or
    [sudo] service cron command
