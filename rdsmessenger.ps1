<#
#### requires ps-version 4.0 ####
<#
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

.LINK
   https://blog.it-koehler.com/en/

.COMPONENT
 Required Modules:RemoteDesktop 

.LICENSE
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the Software), to deal
in the Software without restriction, including without limitation the rights
to use copy, modify, merge, publish, distribute sublicense and /or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 
.EXAMPLE
.\rdsmessenger.ps1 -rdbroker rds02.demo01.it-koehler.com -messagetitel "admin message" -message "new message for all users from it koehler blog" [-rdsessionhost "rdsh01.demo01.it-koehler.com"] 
#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#>


[CmdletBinding()]
param (
   
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [String]$rdbroker,
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [String]$messagetitel,
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [String]$message,
    [Parameter(Mandatory = $false)]
    [ValidateNotNull()]
    [String]$rdsessionhost
    )

#---------------------------------------------------------[Functions]--------------------------------------------------------
#>
#checking module if its installed
function Get-InstalledModule {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory = $true)]
      [string]$modulename
    )
    
    Write-Verbose "Checking if module $modulename is installed correctly"
    if (Get-Module -ListAvailable -Name $modulename) {
      $Script:moduleavailable = $true
      Write-Verbose "Module $modulename found successfully!"
    } 
    else {
      Write-Verbose "Module $modulename not found!"
      throw "Module $modulename is not installed or does not exist, please install and retry.
      In an administrative Powershell console try typing: Install-Module $modulename"
    }
  
  }
#checking if module is imported, if not load it
function Get-ImportedModule {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory = $true)]
      [string]$modulename
    )
         #check if module is imported, otherwise try to import it
         if (Get-Module -Name $modulename) {
            Write-Verbose "Module $modulename already loaded"
            Write-Verbose "Getting cmdlets from module"
            #write output to variable to get all cmdlets
            $global:commands = Get-Command -Module $modulename | Format-Table -AutoSize -Wrap
            Write-Verbose "Cmdlets stored in variable commands"

        }
        else {
            Write-Verbose "Module found but not imported, import starting"
            Import-Module $modulename -force
            Write-Verbose "Module $modulename loaded successfully"
            #write output to variable to get all cmdlets
            Write-Verbose "Getting cmdlets from module"
            $global:commands = Get-Command -Module $modulename | Format-Table -AutoSize -Wrap
            Write-Verbose "Cmdlets stored in variable commands"
           
        }
  }
#function to send message to all users connected to the specified connectionbroker
  function Send-RDMessageAll {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory = $true)]
      [string]$msgtitel,
      [Parameter(Mandatory = $true)]
      [string]$msg,
      [Parameter(Mandatory = $true)]
      [string]$broker
  
    )
         #getting all active session on rdbroker
         Write-Verbose "Getting all user ids from active users"
         $userids = Get-RDUserSession -ConnectionBroker "$broker" | Sort-Object Username
         Write-Output "script paused for 10 seconds before sending, to abort press crtl+c ... "
         Write-Verbose "waiting 10 seconds before sending to all users on broker $broker"
         Start-Sleep -Seconds 10
         #send message to each user with active session
         foreach($uid in $userids){
            $id = (($uid).UnifiedSessionID)
            $user = (($uid).UserName)
            $hostserver = (($uid).HostServer)
            Write-output "sending message to $user with titel $msgtitel on server $hostserver"
            Send-RDUserMessage -HostServer $rdsessionhost -UnifiedSessionID $id -MessageTitle "$msgtitel" -MessageBody "$msg"
            Write-Verbose "send message on rdbroker $broker to usersessionid $id with titel $msgtitel on RDSH $hostserver"
            }
            
  }
  ####send message to users on special rdsessionhost 
    function Send-RDMessageRDSH {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory = $true)]
      [string]$msgtitel,
      [Parameter(Mandatory = $true)]
      [string]$msg,
      [Parameter(Mandatory = $true)]
      [string]$broker,
      [Parameter(Mandatory = $true)]
      [string]$sessionhost
  
    )
         #getting all active session on rdbroker
         Write-Verbose "Getting all user ids from active users"
         $userids = Get-RDUserSession -ConnectionBroker "$broker"| Where-Object {$_.HostServer -eq "$sessionhost"} | Sort-Object Username
         Write-Output "script paused for 10 seconds before sending, to abort press crtl+c ... "
         Write-Verbose "waiting 10 seconds before sending to users on sessionhost $broker "
         Start-Sleep -Seconds 10
         #send message to each user with active session
         foreach($uid in $userids){
            $id = (($uid).UnifiedSessionID)
            $user = (($uid).UserName)
            $hostserver = (($uid).HostServer)
            Write-output "sending message to $user with titel $msgtitel"
            Send-RDUserMessage -HostServer $rdsessionhost -UnifiedSessionID $id -MessageTitle "$msgtitel" -MessageBody "$msg"
            Write-Verbose "send message on rdbroker $broker to usersessionid $id with titel $msgtitel on RDSH $hostserver"
            }
            
  }
    #call functions
    Get-InstalledModule -modulename RemoteDesktop
    Get-ImportedModule -modulename RemoteDesktop
    #check if parameter rdessionhost is set or not
    if($PSBoundParameters.ContainsKey('rdsessionhost')){
    Write-Verbose "parameter rdessionhost is set, only connections on $rdsessionhost will be notified!"
    Send-RDMessageRDSH -broker $rdbroker -sessionhost $rdsessionhost -msgtitel $messagetitel -msg $message
    }
    else {
    Write-Verbose "No RDSessionHost Server specified, all users on $rdbroker will be notified"
    Send-RDMessageAll -msgtitel $messagetitel -msg $message -broker $rdbroker
    }
    #waiting for userinput 
    pause





