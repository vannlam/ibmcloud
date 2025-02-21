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
			$s3item = $s3client->getObject([
				 'Bucket' => $_SESSION['bucket'],
				 'Key' => $_SESSION['login_id']."_item.json"
			]);
			$json_item=(string)$s3item['Body'];
			$arr_item = json_decode($json_item, true);
			foreach ($arr_item as $id=>$item) {
				$itm=null;
				foreach ($item as $field=>$value) {
					$itm[$field]=$value;
					if ($field == "item_key") {
						$k=$value;
					}
				}
				$items[$k]=$itm;
			}
			ksort($items, 4);
		}
	} catch (Exception $e) {
            echo 'Caught exception: ',  $e->getMessage(), "\n";
        }

    return $items;
}
function f_insert_item($key, $identity, $secret, $misc)
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
			$item=null;
			$item['item_key']=$key;
			$item['item_identity']=$identity;
			$item['item_secret']=$secret;
			$item['item_misc']=$misc;
			$items=$_SESSION['items'];
			$items[$key]=$item;
			ksort($items, 4);
			$json_items=json_encode($items, 0, 2);

			$result	= $s3client->putObject([
                                         'Bucket' => $_SESSION['bucket'],
					 'Key' => $_SESSION['login_id']."_item.json",
					 'Body' => $json_items
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

	$items=$_SESSION['items'];
	foreach ($items as $k => $item) {
		if ($k == $_SESSION['formitem']['itemkey']) {
			unset($items[$k]);
		}
	}

	$json_items=json_encode($items, 0, 2);

        try {
                $s3client = new Aws\S3\S3Client($config);
                if ($s3client!=null) {
			$result = $s3client->putObject([
                                         'Bucket' => $_SESSION['bucket'],
					 'Key' => $_SESSION['login_id'].'_item.json',
					 'Body' => $json_items
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
	$items=$_SESSION['items'];
	foreach ($items as $k => $item) {

		if ($item['item_key']==$key) {
			$item['item_identity']=$identity;
			$item['item_secret']=$secret;
			$item['item_misc']=$misc;
			$items[$k]=$item;
			break;
		}
	}

        try {
                $s3client = new Aws\S3\S3Client($config);
                if ($s3client!=null) {
			$json_items=json_encode($items, 0, 2);
			$result	= $s3client->putObject([
                                         'Bucket' => $_SESSION['bucket'],
					 'Key' => $_SESSION['login_id'].'_item.json',
					 'Body' => $json_items
                                       ]);
		}
        } catch (Exception $e) {
            echo 'Caught exception: ',  $e->getMessage(), "\n";
        }

}
