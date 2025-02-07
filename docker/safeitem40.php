<?php
session_start();
session_destroy();
ini_set('display_errors', 'On');
error_reporting(E_ALL);

header('Location: ./safeitem40/view/v_connect.php');
