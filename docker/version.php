<?php
require '/aws/aws-autoloader.php';
use Aws\S3\S3Client;
use Aws\Exception\AwsException;
$config = [
                 'region' => 'eu-west-3',
                 'version' => 'latest',
                 "Effect" => "Allow",
                 'credentials' => [
                   'key' => $_ENV["CE_S3_KEY"],
                   'secret' => $_ENV["CE_S3_SECRET"]
                  ]
                ];
$s3client = new Aws\S3\S3Client($config);
$file = $s3client->getObject([
                         'Bucket' => 'bao3lei3',
                         'Key' => 'create_txt_record.json'
                       ]);
$body = $file->get('Body');
$body->rewind();
echo $body->read(100)
?>
