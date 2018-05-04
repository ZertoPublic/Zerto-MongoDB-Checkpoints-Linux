#################################################################
# GetVPGInfo.ps1
# 
# By Justin Paul, Zerto Technical Alliances Architect
# Contact info: jp@zerto.com
# Repo: https://www.github.com/recklessop/ZertoScripts
#
# This script gets the VPG ID among other info for a given VPG Name
#
# Note this script is provided as-is and comes with no warranty.
# The author takes no responsability for dataloss or corruption of any kind.
# Also this script is not supported by Zerto Technical Support.
#
# With that said, the script only uses "GET" commands so you should be pretty safe.
#
#################################################################

################ Variables for your script ######################

$strZVMIP = "172.16.1.20"
$strZVMPort = "9669"
$strZVMUser = "administrator@vsphere.local"
$strZVMPwd = "myPassword"
$vpgName = "myVPG"

############### ignore self signed SSL ##########################
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
 }
[ServerCertificateValidationCallback]::Ignore()
#################################################################

## Perform authentication so that Zerto APIs can run. Return a session identifier that needs tobe inserted in the header for subsequent requests.
function getxZertoSession ($userName, $password){
    $baseURL = "https://" + $strZVMIP + ":" + $strZVMPort
    $xZertoSessionURL = $baseURL +"/v1/session/add"
    $authInfo = ("{0}:{1}" -f $userName,$password)
    $authInfo = [System.Text.Encoding]::UTF8.GetBytes($authInfo)
    $authInfo = [System.Convert]::ToBase64String($authInfo)
    $headers = @{Authorization=("Basic {0}" -f $authInfo)}
    $contentType = "application/json"
    $xZertoSessionResponse = Invoke-WebRequest -Uri $xZertoSessionURL -Headers $headers -Method POST -Body $body -ContentType $contentType
    #$xZertoSessionResponse = Invoke-WebRequest -Uri $xZertoSessionURL -Headers $headers -Body $body -Method POST
    return $xZertoSessionResponse.headers.get_item("x-zerto-session")
}

#Extract x-zerto-session from the response, and add it to the actual API:
$xZertoSession = getxZertoSession $strZVMUser $strZVMPwd
$zertoSessionHeader = @{"x-zerto-session"=$xZertoSession}
$zertoSessionHeader_xml = @{"Accept"="application/xml"
"x-zerto-session"=$xZertoSession}

################ Your Script starts here #######################
#Invoke the Zerto API:
$peerListApiUrl = "https://" + $strZVMIP + ":"+$strZVMPort+"/v1/vpgs"

#Iterate with JSON:
$vpgListJSON = Invoke-RestMethod -Uri $peerListApiUrl -Headers $zertoSessionHeader
foreach ($vpg in $vpgListJSON){
	if ( $vpg.VpgName -eq $vpgName ){
	$vpg
	}
}
##End of script
