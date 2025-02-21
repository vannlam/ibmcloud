
<?php
session_start();

include('../model/m_include.php');
include('../model/m_db.php');
include('../model/m_item.php');

$passcode=$_POST["passcode"];

$pass_gen=(string)$_SESSION['session_code'];

if ($passcode == $pass_gen)
{
	$_SESSION['items']=f_get_items();
	$_SESSION['logged_in']=true;
	$_SESSION['message']="";
	setcookie('ck_login', $_SESSION['login_id'], time() + 365*24*3600,'/');
	header('Location: ../view/v_item.php');
}
else 
{
	$_SESSION['message']="Authentication failed";
	sleep(5);
	header('Location: ../view/v_connect.php');
};
