<?php
$output=null;
$retval=null;
exec('ls /aws', $output, $retval);
echo "Status code $retval \n";
print_r($output);
?>
