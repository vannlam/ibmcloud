
<?php
session_start();

include('../model/m_include.php');
include('../model/m_db.php');
include('../model/m_item.php');

$form['login']=$_POST["login"];

$arr_login=$_SESSION['logins'];
foreach ($arr_login->user as $user)
{
	if (($form['login']==$user->id)) {
		$_SESSION['login_id']=$form['login'];
		$_SESSION['searchpattern']=$user->search;
		$_SESSION['login_email']=$user->email;
		break;
	}
}

$session_match=rand(1000,9999);
$session_code=rand(100000,999999);

$to      = $_SESSION['login_email'];
$subject = 'Your passcode';
$message = $session_match."-".$session_code;
$headers = 'From: webmaster@lam-s.com' . "\r\n" .
    'Reply-To: webmaster@example.com' . "\r\n" .
    'X-Mailer: PHP/' . phpversion();

mail($to, $subject, $message, $headers);

$_SESSION['session_match']=$session_match;
$_SESSION['session_code']=$session_code;
header('Location: ../view/v_passcode.php');

//if ($not_found) {
	//$error['login'] = "Login and password do not match";
//} else {
	//$_SESSION['items']=f_get_items();
	//$_SESSION['logged_in']=true;
//}


//if (!isset($_SESSION['logged_in'])) {
	//$_SESSION['errorconnect']=$error;
	//$_SESSION['message']="Authentication failed";
	//header('Location: ../view/v_connect.php');
//} else {
	//setcookie('ck_login',$form['login'],time() + 365*24*3600,'/');
	//$_SESSION['message']="";
	//if ($form['login'] == "debug") {
		//$msgerror="";
		//exec('tail -100 /var/log/apache2/error.log', $msgerror, $retval);
		//print_r($msgerror);
		//die ("");
	//} else {
		//header('Location: ../view/v_item.php');
	//}
//}
