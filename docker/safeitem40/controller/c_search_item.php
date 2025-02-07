<?php
session_start();
include('c_tools.php');
function f_get_exact_match ($items, $searchpattern) {
	$itemfound=null;
	foreach($items as $key => $item) {
		if ($item['item_key'] == $searchpattern) {
			$itemfound=$item;
			break;
		}
	}
	return $itemfound;
}
$loginid=$_SESSION['login_id'];
$items=$_SESSION['items'];
$searchpattern=$_POST["searchpattern"];
$item=f_get_exact_match($items, $searchpattern);
f_reset_item_form_messages ();
$form=$_SESSION['formitem'];
$form['searchpattern']=$searchpattern;
if ($item != null) {
	$form['itemid']=$item['item_id'];
	$form['itemkey']=$item['item_key'];
	$form['itemidentity']=$item['item_identity'];
	$form['itempassphrase']=$item['item_secret'];
	$form['itemclearpassphrase']=$item['item_secret'];
	$form['itemmisc']=$item['item_misc'];
	$message="One Item found";
} else {
	$form['itemid']=-1;
	$form['itemkey']=null;
	$form['itemidentity']=null;
	$form['itempassphrase']=null;
	$form['itemclearpassphrase']=null;
	$form['itemmisc']=null;
	$message="No exact match found";
}
$_SESSION['formitem']=$form;
$_SESSION['message']=$message;
header('Location: ../view/v_item.php');
