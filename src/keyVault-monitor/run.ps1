param($eventGridEvent, $TriggerMetadata)
$ErrorActionPreference = 'Stop'
ConvertTo-Json $eventGridEvent -Depth 100

switch -Wildcard ($eventGridEvent.eventType) {
    '*Expir*' {
        $alertSplat = @{
            ResourceId  = $eventGridEvent.topic
            SubjectData = $eventGridEvent.data
            EventType   = $eventGridEvent.eventType
            EventTime   = $eventGridEvent.eventTime
        }
        Push-OutputBinding -Name serviceBusMessage -Value $alertSplat
    }
}