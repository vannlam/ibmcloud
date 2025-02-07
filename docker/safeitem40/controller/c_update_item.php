<?php
session_start();
include('../model/m_include.php');
include('../model/m_item.php');
include('../model/m_db.php');
include('c_tools.php');

$item['item_key']=$_POST['itemkey'];
$item['item_identity']=$_POST['itemidentity'];
$item['item_secret']=$_POST['itemsecret'];
$item['item_misc']=$_POST['itemmisc'];
$form=$_SESSION['formitem'];
$form['itemkey']=$item['item_key'];
$form['itemidentity']=$item['item_identity'];
$form['itempassphrase']=$item['item_secret'];
$form['itemmisc']=$item['item_misc'];
$_SESSION['formitem']=$form;
f_update_item($item['item_key'], $item['item_identity'], $item['item_secret'], $item['item_misc']);
$items=f_get_items();
$_SESSION['message']="Item updated";
$_SESSION['items']=$items;
header('Location: ../view/v_item.php');
