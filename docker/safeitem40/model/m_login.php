<?php
function f_upd_search()
{
        $config = [
                 'region' => $_SESSION['region'],
                 'version' => $_SESSION['version'],
                 "Effect" => "Allow",
                 'credentials' => [
                   'key' => $_SESSION['key'],
                   'secret' => $_SESSION['secret']
                  ]
                ];

        try {
                $s3client = new Aws\S3\S3Client($config);
                if ($s3client!=null) {
			$body_json=json_encode($_SESSION['logins']);
                        $result = $s3client->putObject([
                                         'Bucket' => $_SESSION['bucket'],
					 'Key' => 'login.json',
					 'Body' => $body_json
                                       ]);
                }
        } catch (Exception $e) {
            echo 'Caught exception: ',  $e->getMessage(), "\n";
        }
}
