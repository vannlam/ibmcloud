<?php
function f_get_items()
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
		$items=null;
		if ($s3client!=null) {
			$prefix='_'.$_SESSION['login_id'].'_';
			$itemids = $s3client->listObjectsV2([
					 'Bucket' => $_SESSION['bucket'],
					 'Prefix' => $prefix
				       ]);
			foreach ($itemids['Contents'] as $itemid) {
				$s3item = $s3client->getObject([
						 'Bucket' => $_SESSION['bucket'],
						 'Key' => $itemid['Key']
					       ]);
				$json_item=(string)$s3item['Body'];
				$arr_item = json_decode($json_item);
				echo " Key : ", $arr_item->item_key;
				$item=null; 
				$item['item_id']=$itemid['Key'];
				$item['item_key']=$arr_item->item_key;
				$item['item_identity']=$arr_item->item_identity;
				$item['item_secret']=$arr_item->item_secret;
				$item['item_misc']=$arr_item->item_misc;
				$items[]=$item;
			}
		}
	} catch (Exception $e) {
            echo 'Caught exception: ',  $e->getMessage(), "\n";
        }

    return $items;
}
function f_insert_item($loginid, $key, $identity, $secret, $misc)
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
                        $prefix='_'.$loginid.'_'.$key.'.json';
			$body_json=json_encode(array('item_key' => $key,
					    'item_identity' => $identity,
					    'item_secret' => $secret,
					    'item_misc' => $misc));
			$result	= $s3client->putObject([
                                         'Bucket' => $_SESSION['bucket'],
					 'Key' => $prefix,
					 'Body' => $body_json
                                       ]);
		}
        } catch (Exception $e) {
            echo 'Caught exception: ',  $e->getMessage(), "\n";
        }

}
function f_delete_item()
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
                        $s3itemid=$_SESSION['formitem']['itemid'];
			$result = $s3client->deleteObject([
                                         'Bucket' => $_SESSION['bucket'],
					 'Key' => $s3itemid
                                       ]);
		}
        } catch (Exception $e) {
            echo 'Caught exception: ',  $e->getMessage(), "\n";
        }
}
function f_update_item($key, $identity, $secret, $misc)
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
			$body_json=json_encode(array('item_key' => $key,
					    'item_identity' => $identity,
					    'item_secret' => $secret,
					    'item_misc' => $misc));
                        $s3itemid=$_SESSION['formitem']['itemid'];
			$result	= $s3client->putObject([
                                         'Bucket' => $_SESSION['bucket'],
					 'Key' => $s3itemid,
					 'Body' => $body_json
                                       ]);
		}
        } catch (Exception $e) {
            echo 'Caught exception: ',  $e->getMessage(), "\n";
        }

}
