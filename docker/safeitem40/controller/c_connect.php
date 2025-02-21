
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

$session_code="";
$alphanum="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
$session_match=rand(1000,9999);
for ($i=0; $i < 12; $i++) {
	$j=rand(0,61);
	$session_code=$session_code.substr($alphanum, $j, 1);
}

$to      = $_SESSION['login_email'];
$subject = 'Your passcode';
$message = $session_match."     ---     ".$session_code;
$headers = 'From: webmaster@lam-s.com' . "\r\n" .
    'Reply-To: webmaster@example.com' . "\r\n" .
    'X-Mailer: PHP/' . phpversion();

mail($to, $subject, $message, $headers);

$_SESSION['session_match']=$session_match;
$_SESSION['session_code']=$session_code;
header('Location: ../view/v_passcode.php');

