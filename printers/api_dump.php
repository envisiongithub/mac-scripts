<?php
//requires Composer and guzzlehttp/guzzle
require_once __DIR__ . '/vendor/autoload.php';

$addigyApi = new GuzzleHttp\Client([
    'base_uri' => 'https://prod.addigy.com/api/',
    'headers'  => [
        'client-id'     => '',
        'client-secret' => ''
    ]
]);

$policiesResponse = $addigyApi->request('GET', 'policies');
$policies         = json_decode($policiesResponse->getBody());
foreach($policies as $policy) {
    if ($policy->parent == null) continue;
    $devicesRequest = [
        'policy_id' => $policy->policyId
    ];
    $devicesResponse = $addigyApi->request('GET', 'policies/devices?' . http_build_query($devicesRequest));
    $devices         = json_decode($devicesResponse->getBody());
    if (count($devices) == 0) continue;
    echo PHP_EOL . $policy->name . PHP_EOL;
    $deviceIds       = array();
    foreach($devices as $device) {
        echo $device->{'Device Name'} . PHP_EOL;
        $deviceIds[] = $device->agentid;
    }

    $commandsRequest = [
        'agents_ids' => $deviceIds,
        'command'    => '/bin/cat /etc/cups/printers.conf'
    ];
    $commandsResponse = $addigyApi->request('POST', 'devices/commands', ['body' => json_encode($commandsRequest)]);
    $commands         = json_decode($commandsResponse->getBody());
    sleep(2);
    foreach($commands->actionids as $command) {
        $outputRequest = [
            'actionid' => $command->actionid,
            'agentid'  => $command->agentid
        ];
        try {
            $outputResponse = $addigyApi->request('GET', 'devices/output?' . http_build_query($outputRequest));
            $output         = json_decode($outputResponse->getBody());
            echo $output->stdout;
            echo $output->stderr;
        } catch (Exception $e) {
            echo 'skipped' . PHP_EOL;
        }
    }
}
