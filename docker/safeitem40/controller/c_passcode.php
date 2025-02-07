
<?php
session_start();

include('../model/m_include.php');
include('../model/m_db.php');
include('../model/m_item.php');

$passcode=$_POST["passcode"];

$pass_gen=(string)$_SESSION['session_code'];

//var_dump($passcode);
//var_dump($pass_gen);
//die();

if ($passcode == $pass_gen)
{
	$_SESSION['items']=f_get_items();
	$_SESSION['logged_in']=true;
	setcookie('ck_login',$form['login'],time() + 365*24*3600,'/');
	$_SESSION['message']="";
	header('Location: ../view/v_item.php');
}
else 
{
	$error['login'] = "Wrong passcode";
	$_SESSION['errorconnect']=$error;
	$_SESSION['message']="Authentication failed";
	sleep(5);
	header('Location: ../view/v_connect.php');
};

//if ($form['login'] == "debug") {
	//$msgerror="";
	//exec('tail -100 /var/log/apache2/error.log', $msgerror, $retval);
	//print_r($msgerror);
	//die ("");
//}
