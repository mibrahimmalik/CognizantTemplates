#
# xADUser: DSC resource to wait for the installation of a new forest or domain.
#

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [PSCredential]$DomainUserCredential,

        [UInt64]$RetryIntervalSec = 10,

        [UInt32]$RetryCount = 5
    )

    $returnValue = @{
        DomainName = $Name
        DomainUserCredential = $DomainUserCredential.UserName
        RetryIntervalSec = $RetryIntervalSec
        RetryCount = $RetryCount
    }
    $returnValue
}

function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [PSCredential]$DomainUserCredential,

        [UInt64]$RetryIntervalSec = 10,

        [UInt32]$RetryCount = 5
    )

    $domainFound = $false
    Write-Verbose -Message "Checking for domain '$($DomainName)' ..."

    Add-Content C:\PerfLogs\output.txt "Checking for domain"

    for ($count = 0; $count -lt 200; $count++)
    {
        try
        {
            $domain = Get-ADDomain -Identity $DomainName -Credential $DomainUserCredential
            Write-Verbose -Message "Found domain '$($DomainName)'."
            $domainFound = $true
            Add-Content C:\PerfLogs\output.txt "Found Domain"
            break;
        }
        catch
        {
            Write-Verbose -Message (ConvertTo-JSON $_)
            Write-Verbose -Message "Domain '$($DomainName)' NOT found."
            Write-Verbose -Message "Retrying in $RetryIntervalSec seconds ..."
            Start-Sleep -Seconds $RetryIntervalSec
        }
    }

    if (!$domainFound)
    {
        throw "Domain '$($DomainName)' NOT found after $RetryCount attempts."
    }
}

function Test-TargetResource
{
	[OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [PSCredential]$DomainUserCredential,

        [UInt64]$RetryIntervalSec = 10,

        [UInt32]$RetryCount = 5
    )

    Write-Verbose -Message "Checking for domain '$($DomainName)' ..."

    Add-Content C:\PerfLogs\output.txt "wait for ad domain"
    try
    {
        $domain = Get-ADDomain -Identity $DomainName -Credential $DomainUserCredential
        Write-Verbose -Message "Found domain '$($DomainName)'."

        Add-Content C:\PerfLogs\output.txt "found domain"

        $true
    }
    catch
    {
        if ($error[0]) {Write-Verbose -Message $error[0].Exception}
        Write-Verbose -Message "Domain '$($DomainName)' NOT found."
        $false
    }
}


Export-ModuleMember -Function *-TargetResource
