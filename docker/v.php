
<?php
require '/aws/aws-autoloader.php';
use Aws\S3\S3Client;
use Aws\Exception\AwsException;

$region=null;
$version=null;
$key=null;
$secret=null;
$bucket=null;
$retval=null;
exec('cat /aws/s3-access/CE_S3_REGION', $region, $retval);
exec('cat /aws/s3-access/CE_S3_VERSION', $version, $retval);
exec('cat /aws/s3-access/CE_S3_KEY', $key, $retval);
exec('cat /aws/s3-access/CE_S3_SECRET', $secret, $retval);
exec('cat /aws/s3-access/CE_S3_BUCKET', $bucket, $retval);

print_r($region[0]);
print_r($version[0]);
print_r($key[0]);
print_r($secret[0]);
print_r($bucket[0]);

$config = [
                 'region' => $region[0],
                 'version' => $version[0],
                 "Effect" => "Allow",
                 'credentials' => [
                   'key' => $key[0],
                   'secret' => $secret[0]
                  ]
                ];
$s3client = new Aws\S3\S3Client($config);
$file = $s3client->getObject([
                         'Bucket' => $bucket[0],
                         'Key' => 'create_txt_record.json'
                       ]);
$body = $file->get('Body');
$body->rewind();
echo $body->read(100);
?>
