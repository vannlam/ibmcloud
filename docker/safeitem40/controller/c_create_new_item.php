<?php
session_start();
include('../model/m_include.php');
include('../model/m_item.php');
include('../model/m_db.php');
include('c_tools.php');

$loginid=$_SESSION['login_id'];
$form['itemid']=-1;
$form['itemkey']=$_POST["itemkey"];
$form['itemidentity']=$_POST["itemidentity"];
$form['itempassphrase']=$_POST["itempassphrase"];
$form['itemmisc']=$_POST["itemmisc"];
$error['searchpattern']="";
$compulsary=true;
$message="";
if (!isset($_POST["itemkey"]) OR strlen($_POST["itemkey"])==0 ) {
	$error['itemkey'] = "Please provide a new key";
	$form['itemkey']="";
	$compulsary=false;
} else {
	$error['itemkey'] = "";
	$form['itemkey']=$_POST["itemkey"];
}
if (!isset($_POST["itemidentity"]) OR strlen($_POST["itemidentity"])==0 ) {
	$error['itemidentity'] = "Please provide a new identity";
	$form['itemidentity']="";
	$compulsary=false;
} else {
	$error['itemidentity'] = "";
	$form['itemidentity']=$_POST['itemidentity'];
}
if (!isset($_POST["itempassphrase"]) OR strlen($_POST["itempassphrase"])==0 ) {
	$error['itempassphrase'] = "Please provide a new passphrase";
	$form['itempassphrase']="";
	$compulsary=false;
} else {
	$error['itempassphrase'] = "";
	$form['itempassphrase']=$_POST['itempassphrase'];
}

if ($compulsary) {
	// check if item already exists
	//
	$items=$_SESSION['items'];
	if (f_chk_item_exists($form['itemkey'], $items)==null) {
		$item['login_id']=$loginid;
		$item['item_key']=$form['itemkey'];
		$item['item_identity']=$form['itemidentity'];
		$item['item_secret']=$form['itempassphrase'];
		$item['item_misc']=$form['itemmisc'];
		$message="New item created for key : '".$item['item_key']."'";
		f_insert_item($item['item_key'], $item['item_identity'], $item['item_secret'], $item['item_misc']);
	} else {
		$error['itemkey'] = "This key already exists";
	}
}
$items=f_get_items();
$_SESSION['items']=$items;
$_SESSION['formnewitem']=$form;
$_SESSION['errornewitem']=$error;
$_SESSION['message']=$message;

header('Location: ../view/v_create_new_item.php');
