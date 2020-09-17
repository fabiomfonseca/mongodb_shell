# mongodb_shell

Description: A simple automation to provide centralized connection strings to help
             Mongo DBA's life easier.
             
Requirements:
- MongoDB Shell - You can install mongodb and use only mongo shell or install mongosh.
- One file for all your mongodb connections - See sample of connection file.
- It supports MongoDB Enterprise, Percona Server for MongoDB and SSL.

Usage:      
     1) Get URI connection for one or more databases
        Param #1 - uri
        Param #2 - Environment: prod, non-prod, test, dev...
        Param #3 - App/DB Entry Name
        Sample: powershell mongodb_shell.ps1 uri dev app1
                powershell mongodb_shell.ps1 uri dev
                powershell mongodb_shell.ps1 uri app1
     2) Connect on specific database
        Param #1 - Your NT account
        Param #2 - Environment: prod, non-prod, test, dev...
        Param #3 - App/DB Entry Name
        Sample: powershell mongodb_shell.ps1 ntuser dev app1

In order to simplify its usage, I have created a simple bat script to call this powershell script.
In this case, make sure that your mongo shell is on Windows Path's environment variable and all files of Mongo Shell 0.1 as well.

Sample usage with bat script:
mongoshell uri app1

Any suggestion is very welcome to improve this script. :)
