<?php
session_start();

// Check for previous session
if (!isset($_SESSION['logged_in']) OR $_SESSION['logged_in']==false) {
	header('Location: /safeitem40.php');
}

if (isset($_SESSION['formnewitem'])){
	$form = $_SESSION['formnewitem'];
} else {
	$form['itemkey']="";
	$form['itemidentity']="";
	$form['itempassphrase']="";
	$form['itemmisc']="";
	$_SESSION['formnewitem']=$form;
}
if (isset($_SESSION['errornewitem'])) {
	$error = $_SESSION['errornewitem'];
} else {
	$error['itemkey'] = "";
	$error['itemidentity'] = "";
	$error['itempassphrase'] = "";
}

if (isset($_SESSION['message'])){
	$message = $_SESSION['message'];
} else {
	$message = "";
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD X
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
	<head>
		<title>Welcome <?php echo $_SESSION['login_id'] ?> to Serverless safeItem @</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta http-equiv="refresh" content="300;url=../../safeitem.php" />
		<link rel="stylesheet" type="text/css" href="../../dojo-release-1.8.3/dijit/themes/claro/claro.css">
		<link rel="stylesheet" type="text/css" href="includes/style.css" />
		<script src="../../dojo-release-1.8.3/dojo/dojo.js" data-dojo-config="isDebug: true, async: true, parseOnLoad: true"></script>
		<script type="text/javascript" src="javascript/tools.js"></script>
	</head>
	<body class="claro bgstd" >
		<form action="../controller/c_create_new_item.php" method="post" name="newitemform" >
			<fieldset>
				<legend>Menu</legend>
				<button type="button" data-dojo-type="dijit/form/Button" value="" name="search" onclick="window.location='v_clean_message.php?next=v_item.php'" >Back to Search</button>
				<div class="droite" >
					<button type="button" data-dojo-type="dijit/form/Button" name="exit" onclick="decision('Are you sure you want to exit ?','/safeitem40.php') ">Exit</button>
				</div>
			</fieldset>
			<fieldset>
				<legend>Please provide a new item information</legend>
				<label for="itemkey">Key <span class="requis">*</span></label>
				<input type="text" name="itemkey" id="itemkey" autofocus="autofocus" value="<?php echo htmlspecialchars($form['itemkey'], ENT_QUOTES, 'UTF-8') ?>" />
				<span class="error"><?php echo $error['itemkey'] ?></span>
				<br />
				<label for="itemidentity">Identification <span class="requis">*</span></label>
				<input type="text" name="itemidentity" id="itemidentity" value="<?php echo htmlspecialchars($form['itemidentity'], ENT_QUOTES, 'UTF-8') ?>" />
				<span class="error"><?php echo $error['itemidentity'] ?></span>
				<br />
				<label for="itempassphrase">Passphrase <span class="requis">*</span></label>
				<input type="text" name="itempassphrase" id="itempassphrase" size="22" value="<?php echo htmlspecialchars($form['itempassphrase'], ENT_QUOTES, 'UTF-8') ?>" />
				<span class="error"><?php echo $error['itempassphrase'] ?></span>
				<button type="submit" data-dojo-type="dijit/form/Button" >Submit</button>
				<br />
				<label for="itemmisc">Miscellaneous </label>
				<textarea name="itemmisc" id="itemmisc" rows="5" cols="39" ><?php echo htmlspecialchars($form['itemmisc'], ENT_QUOTES, 'UTF-8') ?></textarea>
				<br />
				<span class="sucess"><?php echo $message ?></span>
				<br />
				<button type="button" data-dojo-type="dijit/form/Button" name="randpwd" onclick="generatePassword('newitemform')" >Random Password</button>
				<?php include("v_generatepwd.html"); ?>
			</fieldset>
		</form>
		<script>
			// load requirements for declarative widgets in page content
			require(["dojo/parser", "dijit/form/Button"]);
		</script>
	</body>
</html>

