
<?php
$output=null;
$retval=null;
exec('ls /aws/s3-access', $output, $retval);
echo "Status code $retval \n";
print_r($output);
?>
