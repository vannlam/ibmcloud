<?php
session_start();
$loginid=$_SESSION['login_id'];
$itemkey=$_POST['itemkey'];
$items=$_SESSION['items'];
foreach ($items as $key => $itm) {
	if ($itm['item_key'] == $itemkey) {
		$item=$itm;
		break;
	}
}


$form=$_SESSION['formitem'];
$form['itemkey']=$itemkey;
$form['itemid']=$item['item_id'];
$form['itemidentity']=$item['item_identity'];
$form['itempassphrase']=$item['item_secret'];
$form['itemclearpassphrase']=$item['item_secret'];
$form['itemmisc']=$item['item_misc'];

$_SESSION['formitem']=$form;
$_SESSION['message']="";

header('Location: ../view/v_item.php');
