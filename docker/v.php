
<?php
require '/aws/aws-autoloader.php';
use Aws\S3\S3Client;
use Aws\Exception\AwsException;

$output=null;
$retval=null;
exec('cat /aws/s3-access/CE_S3_REGION', $output, $retval);
$region=$output[0];
exec('cat /aws/s3-access/CE_S3_VERSION', $output, $retval);
$version=$output[0];
exec('cat /aws/s3-access/CE_S3_KEY', $output, $retval);
$key=$output[0];
exec('cat /aws/s3-access/CE_S3_SECRET', $output, $retval);
$secret=$output[0];
exec('cat /aws/s3-access/CE_S3_BUCKET', $output, $retval);
$bucket=$output[0];

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
echo $body->read(100);
?>
