<?php
require '/aws/aws-autoloader.php';
use Aws\S3\S3Client;
use Aws\Exception\AwsException;

$env = parse_ini_file('/aws/s3-access');
$region = $env["CE_S3_REGION"];
$version = $env["CE_S3_VERSION"];
$key = $env["CE_S3_KEY"];
$secret = $env["CE_S3_SECRET"];
$bucket = $env["CE_S3_BUCKET"];

echo "CE_S3_REGION".$region;
echo "CE_S3_VERSION".$version;
echo "CE_S3_KEY".$key;
echo "CE_S3_SECRET".$secret;
echo "CE_S3_BUCKET".$bucket;

$config = [
                 'region' => $region,
                 'version' => $version,
                 "Effect" => "Allow",
                 'credentials' => [
                   'key' => $key,
                   'secret' => $secret
                  ]
                ];
$s3client = new Aws\S3\S3Client($config);
$file = $s3client->getObject([
                         'Bucket' => $bucket,
                         'Key' => 'create_txt_record.json'
                       ]);
$body = $file->get('Body');
$body->rewind();
echo $body->read(100)
?>
