param([string] $serviceBusMessage, $TriggerMetadata)
$ErrorActionPreference = 'Stop'
ConvertTo-Json $serviceBusMessage -Depth 100

Import-Module 'helpers' -Force

$sendGridMailSplat = @{
    ToAddress   = ''
    FromAddress = ''
    ToName      = ''
    FromName    = ''
    Subject     = 'Serverlessworkshop'
    Body        = 'Secret {0} in KeyVault {1} will expire soon' -f $serviceBusMessage.SubjectData.ObjectName, $serviceBusMessage.SubjectData.VaultName
    Token       = $env:sendGridApiKey
}

Send-SendGridMail @sendGridMailSplat