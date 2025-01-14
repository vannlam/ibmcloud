<?php
require '/aws/aws-autoloader.php';
use Aws\S3\S3Client;
use Aws\Exception\AwsException;

echo 'HERE 1\n";

$env = parse_ini_file('/aws/s3-access');
echo 'HERE 2\n";
$region = $env["CE_S3_REGION"];
$version = $env["CE_S3_VERSION"];
$key = $env["CE_S3_KEY"];
$secret = $env["CE_S3_SECRET"];
$bucket = $env["CE_S3_BUCKET"];

echo "CE_S3_REGION".$region"."\n";
echo "CE_S3_VERSION".$version"."\n";
echo "CE_S3_KEY".$key"."\n";
echo "CE_S3_SECRET".$secret"."\n";
echo "CE_S3_BUCKET".$bucket"."\n";

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
