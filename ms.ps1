###################### MongoDB Shell 0.1 #######################################################
# Author: Fabio Miguel Blasak da Fonseca
# Description: A simple automation to provide centralized connection strings to help
#              Mongo DBA's life easier.
#              
# Requirements:
# - MongoDB Shell - You can install mongodb and use only mongo shell or install mongosh.
# - One file for all your mongodb connections - See sample of connection file.
# - It supports MongoDB Enterprise, Percona Server for MongoDB and SSL.
# 
# Usage:      
#      1) Get URI connection for one or more databases
#         Param #1 - uri
#         Param #2 - Environment: prod, non-prod, test, dev...
#         Param #3 - App/DB Entry Name
#         Sample: powershell mongodb_shell.ps1 uri dev app1
#                 powershell mongodb_shell.ps1 uri dev
#                 powershell mongodb_shell.ps1 uri app1
#      2) Connect on specific database
#         Param #1 - Your NT account
#         Param #2 - Environment: prod, non-prod, test, dev...
#         Param #3 - App/DB Entry Name
#         Sample: powershell mongodb_shell.ps1 ntuser dev app1
################################################################################################

###################### Environment Variables ###################################################

$param_adm = $args[0]
$param_env = $args[1]
$param_appname = $args[2]
$param_getURI = $args[0]

# Location of your MongoDB Connections File
$MCF = "<path>\mongodbcf.txt"

###################### Check Parameters ########################################################

cls
Write-Host " "
Write-Host "=================================="
Write-Host "MongoDB Shell 0.1"
Write-Host "=================================="
Write-Host " "

if ((!$param_adm -and !$param_env -and !$param_appname) -or (!$param_getURI[0] -and !$param_env[1]))  {
  Write-Host "MongoDB Shell has the following options:"
  Write-Host "1) Get URI connection for one or more databases"
  Write-Host "   Param #1 - uri"
  Write-Host "   Param #2 - Environment: prod, non-prod, test, dev..."
  Write-Host "   Param #3 - App/DB Entry Name"
  Write-Host "   Sample: powershell mongodb_shell.ps1 uri dev app1"
  Write-Host "           powershell mongodb_shell.ps1 uri dev"
  Write-Host "           powershell mongodb_shell.ps1 uri app1"
  Write-Host " "
  Write-Host "2) Connect on specific database"
  Write-Host "   Param #1 - Your NT account"
  Write-Host "   Param #2 - Environment: prod, non-prod, test, dev..."
  Write-Host "   Param #3 - App/DB Entry Name"
  Write-Host "   Sample: powershell mongodb_shell.ps1 ntuser dev app1"
  Write-Host " "
  Exit
}

###################### Main Script #############################################################

# Read mongodb connection file
$TNS = Import-Csv -Path $MCF -Header 'environment', 'application', 'servers', 'replicaset', 'port', 'ldap', 'dbuser','ssl', 'cacert', 'pemcert' -Delimiter ';' | Where-Object {$_ -notmatch '#'}

# Option 1 - Get URI Connection
if ($param_getURI -eq "uri") {
  if ($param_env -ne $null -and $param_appname -ne $null) {
    $DB = $TNS | Where-Object -Property environment -like $param_env | Where-Object -Property application -like $param_appname
  } else {
        $DB = $TNS | Where-Object -Property environment -like $param_env
		if ($DB -eq $null) {
		  $DB = $TNS | Where-Object -Property application -like $param_env
		}
	}
  if ($DB -eq $null) {
    Write-Host "Database entry has been not found."
	Write-Host "Parameters:"
	Write-Host "- Environment:" $param_env
	Write-Host "- Application:" $param_appname
  } else {
        $DB = $DB | Sort-Object -Property @{Expression = "application"; Descending = $False}, @{Expression = "environment"; Descending = $False}
		$current_app = ""
		
		$count = $DB.length
		# When $DB has only one element, length is null
		if ($count -eq $null) {
		  $count = 1
		}
		For ($i=0; $i -lt $count; $i++) {           
		   $env = $DB[$i] | select -ExpandProperty environment
           $app = $DB[$i] | select -ExpandProperty application
           $str_servers = $DB[$i] | select -ExpandProperty servers
           $array_servers = $str_servers.split(",")
           $port = $DB[$i] | select -ExpandProperty port
           $ldap = $DB[$i] | select -ExpandProperty ldap
           $dbuser = $DB[$i] | select -ExpandProperty dbuser
           $ssl = $DB[$i] | select -ExpandProperty ssl
           $replicaset = $DB[$i] | select -ExpandProperty replicaset
           $cacert = $DB[$i] | select -ExpandProperty cacert
           $pemcert = $DB[$i] | select -ExpandProperty pemcert
		   
		   # Generate servers list with port. E.g: server1:27100,server2:27100
           $list_servers = ""
           for ($j=0; $j -lt $array_servers.length; $j++) {
	          if ($j-1 -ne $array_servers.length-2) {
	            $list_servers += $array_servers[$j] + ":" + $port + ","
	          } else {
	                $list_servers += $array_servers[$j] + ":" + $port
	            }
           }
		   
		   if ($dbuser -ne "null") {
		     $uri = "mongo://" + $dbuser + ":<password>@" + $list_servers + "/<db_name>?replicaSet=" + $replicaSet
       } else {
             $uri = "mongo://<user>:<password>@" + $list_servers + "/<db_name>?replicaSet=" + $replicaSet
       }  
		   
		   if ($ssl -eq "yes") {
		     $uri += "&tls=true&tlsCertificateKeyFile=$pemcert&tlsCAFile=$cacert"
		   }
		   
		   if ($current_app -ne $app) {
		     $current_app = $app
			 Write-Host "----------------------------------"
			 Write-Host "Application/DB Entry:" $current_app
			 Write-Host "----------------------------------"
			 Write-Host " "
		   }
		   Write-Host "Environment:" $env
		   Write-Host "URI:" $uri
		   Write-Host " "
        }
	}
	Exit
}

$DB = $TNS | Where-Object -Property environment -like $param_env | Where-Object -Property application -like $param_appname

# If DB Entry exists on tns_mongodbs
if ($DB -ne $null) {
  $env = $DB | select -ExpandProperty environment
  $app = $DB | select -ExpandProperty application
  $str_servers = $DB | select -ExpandProperty servers
  $array_servers = $str_servers.split(",")
  $port = $DB | select -ExpandProperty port
  $ldap = $DB | select -ExpandProperty ldap
  $dbuser = $DB | select -ExpandProperty dbuser
  $ssl = $DB | select -ExpandProperty ssl
  $replicaset = $DB | select -ExpandProperty replicaset
  $cacert = $DB | select -ExpandProperty cacert
  $pemcert = $DB | select -ExpandProperty pemcert
    
  Write-Host "Application/DB Entry:" $app
  Write-Host "Environment:" $env
  if ($ldap -eq "yes") {
    Write-Host "User ID:" $dbuser
  } else {        
        Write-Host "User ID:" $param_adm
	}
  Write-Host " "
  Write-Host "Note: You should provide password for above user id to connect on mongodb."
  Write-Host "----------------------------------"
  Write-Host " "
  
  # If DB has SSL Enabled, add additional ssl parameters
  # Note:
  # Mongo Shell 4.2.x - Uses SSL parameters: tls,tlsCertificateKeyFile,tlsCAFile
  # Mongo Shell 4.1.x - Uses SSL parameters: ssl,sslCAFile,sslPEMKeyFile
  if ($ldap -eq "no") {
    if ($ssl -eq "yes") {
	  mongo --host $str_servers --port $port --authenticationDatabase='admin' --tls --tlsCAFile $cacert --tlsCertificateKeyFile $pemcert --username $dbuser --password
	} else {
	      mongo --host $str_servers --port $port --authenticationDatabase=admin --username $dbuser --password
	  }
  } else {
	    if ($ssl -eq "yes") {
		  mongo --host $str_servers --port $port --authenticationDatabase='$external' --authenticationMechanism=PLAIN --tls --tlsCAFile $cacert --tlsCertificateKeyFile $pemcert --username $param_adm --password
		} else {
              mongo --host $str_servers --port $port --authenticationDatabase='$external' --authenticationMechanism=PLAIN --username $param_adm --password
		  }		
	}
  
# If DB Entry does not exist on tns_mongodbs file  
} else {
      Write-Host "Database entry has been not found."
	  Write-Host "Parameters:"
	  Write-Host "- Environment:" $param_env
	  Write-Host "- Application:" $param_appname
}