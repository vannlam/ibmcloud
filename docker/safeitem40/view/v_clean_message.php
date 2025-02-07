<?php
session_start();

$url=$_GET['next'];
$_SESSION['message']="";
header('Location: '.$url);