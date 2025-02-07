<?php
session_start();
include('../model/m_include.php');
include('../model/m_login.php');
include('../model/m_db.php');

$form=$_SESSION['formitem'];
$arr_login=$_SESSION['logins'];
foreach ($arr_login->user as &$user)
{
	if ($_SESSION['login_id']==$user->id) {
		print_r("Trouvé ".$user->id);
		$user->search=$form['searchpattern'];;
		break;
	}
}
unset($user);
$_SESSION['logins']=$arr_login;
f_upd_search();
$_SESSION['message']="Search pattern '".$form['searchpattern']."' updated ".$form['searchpattern'];
header('Location: ../view/v_item.php');
