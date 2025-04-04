<?php
session_start();

$_SESSION['message']="Password copied to clipboard";
header('Location: ../view/v_item.php');
