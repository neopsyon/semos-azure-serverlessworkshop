function New-AzKeyVaultSecretSet {
    <#
    .SYNOPSIS
    Deploys set of secrets to the target key vault(s).
    
    .DESCRIPTION
    Ability to deploy set of secrets to the target key vault, or to the multiple key vaults in different subscriptions.
    
    .PARAMETER KeyVault
    Name of the key vault
    
    .PARAMETER VaultandSubscription
    Hash table - key vault mapping of keyvaultname = subscriptionid , name of the keyvault and subscription where it is located: $vaultandsub = @{ vault1 = 'subscription1' ; vault2 = 'subscrption2' }
    
    .PARAMETER SecretSet
    Hash table - set of secrets: $secrets = @{ secret1 = 'value1' ; secret2 = 'value2' }
    
    .EXAMPLE
    New-AzKeyVaultSecretSet -KeyVault 'vault' -SecretSet $secretHash

    Deploys set of secrets to the keyvault with the name vault.

    .EXAMPLE
    New-AzKeyVaultSecretSet -VaultandSubscription $vaultandsubhash -SecretSet $secretHash

    Deploys set of secrets to multiple key vaults, located in different or same subscription.
    
    .NOTES
    Please send the PR to njovic@schubergphilis.com
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Set1')]
        [ValidateNotNullOrEmpty()]
        [string]$KeyVault,

        [Parameter(Mandatory, ParameterSetName = 'Set2')]
        [ValidateNotNullOrEmpty()]
        [hashtable]$VaultandSubscription,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$SecretSet

    )
    process {
        $ErrorActionPreference = 'Stop'
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'Set1' {
                    $keyVaultObject = Get-AzKeyVault -VaultName $KeyVault
                    if ([string]::IsNullOrWhiteSpace($keyVaultObject)) {
                        Write-Warning ('Cannot find key vault with the name [{0}]. Terminatting.' -f $KeyVault)
                        return
                    }
                    foreach ($secret in ($SecretSet.GetEnumerator())) {
                        $secretName = $secret.Key
                        $secretValue = $secret.Value
                        $secretSplat = @{
                            VaultName   = $keyVault
                            Name        = $secretName
                            SecretValue = (Convertto-Securestring $secretValue -AsPlainText -Force)
                        }
                        Set-AzKeyVaultSecret @secretSplat
                    }
                }
                'Set2' {
                    foreach ($set in ($VaultandSubscription.GetEnumerator())) {
                        $vaultName = $set.Key
                        $subscriptionId = $set.Value
                        $subscriptionObject = Get-AzSubscription -SubscriptionId $subscriptionId -ErrorAction SilentlyContinue
                        if ([string]::IsNullOrWhiteSpace($subscriptionObject)) {
                            Write-Warning ('Cannot find subscription with the id [{0}]. Terminatting.' -f $subscriptionId)
                            return
                        }
                        [void](Set-AzContext -SubscriptionId $subscriptionId)
                        $keyVaultObject = Get-AzKeyVault -VaultName $vaultName
                        if ([string]::IsNullOrWhiteSpace($keyVaultObject)) {
                            Write-Warning ('Cannot find key vault with the name [{0}]. Terminatting.' -f $vaultName)
                            return
                        }
                        foreach ($secret in ($SecretSet.GetEnumerator())) {
                            $secretName = $secret.Key
                            $secretValue = $secret.Value
                            $secretSplat = @{
                                VaultName   = $vaultName
                                Name        = $secretName
                                SecretValue = (Convertto-Securestring $secretValue -AsPlainText -Force)
                            }
                            Set-AzKeyVaultSecret @secretSplat
                        }
                    }
                }
            }
        }
        catch {
            throw $_
        }
    }
}