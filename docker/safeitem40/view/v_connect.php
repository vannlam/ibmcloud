<?php
session_start();

include('../model/m_include.php');
include('../model/m_db.php');

// Check for previous session
$form['login']=isset($_COOKIE['ck_login']) ? $_COOKIE['ck_login'] : '';

if (isset($_SESSION['errorconnect'])) {
	$error = $_SESSION['errorconnect'];
} else {
	$error['login'] = "";
	$error['pwd'] = "";
}

if (isset($_SESSION['message'])) {
	$message = $_SESSION['message'];
} else {
	$message = "";
}

$region=null;
$version=null;
$key=null;
$secret=null;
$bucket=null;
$retval=null;
exec('cat /aws/s3-access/CE_S3_REGION', $region, $retval);
exec('cat /aws/s3-access/CE_S3_VERSION', $version, $retval);
exec('cat /aws/s3-access/CE_S3_KEY', $key, $retval);
exec('cat /aws/s3-access/CE_S3_SECRET', $secret, $retval);
exec('cat /aws/s3-access/CE_S3_BUCKET', $bucket, $retval);

$_SESSION['region']=$region[0];
$_SESSION['version']=$version[0];
$_SESSION['key']=$key[0];
$_SESSION['secret']=$secret[0];
$_SESSION['bucket']=$bucket[0];

f_connect();

?>
<!DOCTYPE html>
<html >
	<head>
		<title>SafeItem Serverless</title>
		<meta charset=utf-8" content="width=device-width; initial-scale=1.0" />
    <link rel="stylesheet" href="../../dojo-release-1.8.3/dijit/themes/claro/claro.css">
    <link type="text/css" rel="stylesheet" href="includes/style.css" />
    <script src="../../dojo-release-1.8.3/dojo/dojo.js" data-dojo-config="isDebug: true, async: true, parseOnLoad: true"></script>
	</head>
	<body class="claro bgstd" >
		<form action="../controller/c_connect.php" method="post" name="formlogin" >
			<fieldset>
				<legend>Choose login :</legend>
				<label for="login">Login <span class="requis">*</span></label>
				<select name="login" id="login" selected = "<?php echo $form['login'] ?>" autofocus="autofocus">
				<?php
                  		$arr_login=$_SESSION['logins'];
				foreach ($arr_login->user as $user)
				{
				?>
				<option <?php if ($form['login'] == $user->id) { echo "selected"; } ?> value="<?php echo $user->id ?>"><?php echo $user->id ?></option>
				<?php
				}
  				?>
				</select>
				<span class="error"><?php echo $error['login'] ?></span>
				<br />
				<button data-dojo-type="dijit/form/Button" type="submit">Submit</button>
				<span class="success"><?php echo $message ?></span>
			</fieldset>
		</form>
		<script>
			// load requirements for declarative widgets in page content
			require(["dojo/parser", "dijit/form/Button"]);
		</script>
	</body>
</html>
