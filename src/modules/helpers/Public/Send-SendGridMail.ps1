Function Send-SendGridMail {
    param (
        [cmdletbinding()]
        [parameter()]
        [string]$ToAddress,
        [parameter()]
        [string]$ToName,
        [parameter()]
        [string]$FromAddress,
        [parameter()]
        [string]$FromName,
        [parameter()]
        [string]$Subject,
        [parameter()]
        [string]$Body,
        [parameter()]
        [string]$BodyAsHTML,
        [parameter()]
        [string]$Token
    )
    if (-not[string]::IsNullOrEmpty($BodyAsHTML)) {
        $MailbodyType = 'text/HTML'
        $MailbodyValue = $BodyAsHTML
    }
    else{
        $MailbodyType = 'text/plain'
        $MailBodyValue = $Body
    }
    # Create a body for sendgrid
    $SendGridBody = @{
        "personalizations" = @(
            @{
                "to"      = @(
                    @{
                        "email" = $ToAddress
                        "name"  = $ToName
                    }
                )
                "subject" = $Subject
            }
        )
        "content"          = @(
            @{
                "type"  = $mailbodyType
                "value" = $MailBodyValue
            }
        )
        "from"             = @{
            "email" = $FromAddress
            "name"  = $FromName
        }
    }

    $BodyJson = $SendGridBody | ConvertTo-Json -Depth 4

    #Create the header
    $Header = @{
        "authorization" = "Bearer $token"
    }
    #send the mail through Sendgrid
    $Parameters = @{
        Method      = "POST"
        Uri         = "https://api.sendgrid.com/v3/mail/send"
        Headers     = $Header
        ContentType = "application/json"
        Body        = $BodyJson
    }
    Invoke-RestMethod @Parameters
}