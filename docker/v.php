
<?php
$output=null;
$retval=null;
exec('cat /aws/s3-access/CE_S3_BUCKET', $output, $retval);
print_r($output);
?>
