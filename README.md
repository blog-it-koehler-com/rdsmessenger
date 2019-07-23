# rdsmessenger
generate messages for RD Users in RemoteDesktop Farms 
.SYNOPSIS
rdmessager.ps1
.DESCRIPTION
send a message to all active users in a remotedesktop farm
.PARAMETER rdbroker
specify the rdbroker of your rd farm (2012 and above) with the FQDN
.PARAMETER messagetitel 
write down the message titel you want to send
.PARAMETER message
write down the message you want to send to your users
.PARAMETER rdsessionhost
OPTIONAL: specify one special RemoteDesktopSessionHost in your deployment (FQDN)
if not set, all users on ALL Sessionhosts will be notified
.INPUTS
none
.OUTPUTS
none
.NOTES
   Version:        0.1
   Author:         Alexander Koehler
   Creation Date:  Sunday, July 21st 2019, 8:34:39 pm
   File: rdsmessenger-0-1.ps1
   Copyright (c) 2019 blog.it-koehler.com
HISTORY:
Date      	          By	Comments
----------	          ---	----------------------------------------------------------
2019-07-21-10-49-pm	 AK	    added function for on rdsessionhost

.EXAMPLE
.\rdsmessenger.ps1 -rdbroker rds02.demo01.it-koehler.com -messagetitel "admin message" -message "new message for all users from it koehler blog" [-rdsessionhost "rdsh01.demo01.it-koehler.com"] 
