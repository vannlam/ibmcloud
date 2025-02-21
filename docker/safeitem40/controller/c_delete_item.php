<?php
session_start();
include('../model/m_include.php');
include('../model/m_item.php');
include('../model/m_db.php');
include('c_tools.php');
f_delete_item();
$items=f_get_items();
f_reset_item_form_messages ();
$message="Item deleted";
$_SESSION['message']=$message;
$_SESSION['items']=$items;
unset($_SESSION['formitem']);
header('Location: ../view/v_item.php');
