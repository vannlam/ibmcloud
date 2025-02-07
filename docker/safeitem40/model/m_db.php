<?php

function f_connect()
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
			$s3login = $s3client->getObject([
					 'Bucket' => $_SESSION['bucket'],
					 'Key' => 'login.json'
				       ]);
			$json_login=(string)$s3login['Body'];
		}
	} catch (Exception $e) {
	    echo 'Caught exception: ',  $e->getMessage(), "\n";
	}
	$arr_login = json_decode($json_login);
	$_SESSION['logins']=$arr_login;
}
