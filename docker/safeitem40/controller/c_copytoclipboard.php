<?php
session_start();
include('../model/m_include.php');
include('../model/m_item.php');
include('../model/m_db.php');
include('c_tools.php');

$_SESSION['message']="Password copied to clipboard";
header('Location: ../view/v_item.php');
