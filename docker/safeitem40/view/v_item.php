<?php
session_start();

// Check for previous session
if (!isset($_SESSION['logged_in']) OR $_SESSION['logged_in']==false) {
	header('Location: /safeitem40.php');
}

if (isset($_SESSION['formitem'])){
	$form = $_SESSION['formitem'];
} else {
	$form['searchpattern']=$_SESSION['searchpattern'];
	$form['itemkey']="";
	$form['itemidentity']="";
	$form['itempassphrase']="";
	$form['itemmisc']="";
	$_SESSION['formitem']=$form;
}
if (isset($_SESSION['erroritem'])) {
	$error = $_SESSION['erroritem'];
} else {
	$error['searchpattern'] = "";
	$error['itemkey'] = "";
	$error['itemidentity'] = "";
	$error['itempassphrase'] = "";
}
if (isset($_SESSION['message'])){
	$message = $_SESSION['message'];
} else {
	$message = "";
}
if ($form['itemkey']=="") {
	$currentitem=false;
} else {
	$currentitem=true;
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
	<body class="claro bgstd" onload="showhide('y')" >
		<form action="../controller/c_search_item.php" method="post" name="searchform" >
			<fieldset>
				<legend>Menu :</legend>
					<button data-dojo-type="dijit/form/Button" type="button" name="new" onclick="window.location='v_clean_message.php?next=v_create_new_item.php'" >New</button>
					<button data-dojo-type="dijit/form/Button" type="button" name="delete" <?php echo (!$currentitem) ? 'disabled="disabled"' : '' ?> onclick="decision('Are you sure you want to Delete this item ?','v_clean_message.php?next=../controller/c_delete_item.php') ">Delete</button>
					<button data-dojo-type="dijit/form/Button" type="button" name="update" <?php echo (!$currentitem) ? 'disabled="disabled"' : '' ?> onclick="decision_upd('Are you sure you want to Update this item ?','../controller/c_update_item.php') " >Update</button>
					<button data-dojo-type="dijit/form/Button" type="button" name="copy" <?php echo (!$currentitem) ? 'disabled="disabled"' : '' ?> onclick="copytoclipboard()">Copy Password</button>
					<div class="droite" >
						<button data-dojo-type="dijit/form/Button" type="button" name="exit" onclick="decision('Are you sure you want to exit ?','/safeitem40.php') " />Exit</button>
					</div>
			</fieldset>
			<fieldset>
				<legend>Please provide a search string :</legend>
				<label for="searchpattern">Search Pattern <span class="requis">*</span></label>
				<input type="text" name="searchpattern" id="searchpattern" autofocus="autofocus" size="30" value="<?php echo htmlspecialchars($form['searchpattern'], ENT_QUOTES, 'UTF-8') ?>" />
				<button data-dojo-type="dijit/form/Button" type="button" onclick="document.searchform.searchpattern.value='';document.getElementById('searchpattern').focus();" >x</button>
				<button data-dojo-type="dijit/form/Button" type="submit" >Submit</button>
				<span class="error"><?php echo $error['searchpattern'] ?></span>
				<button data-dojo-type="dijit/form/Button" type="button" onclick="window.location='../controller/c_upd_search.php'" >Set search default</button>
				<br />
			</fieldset>
			<fieldset>
				<legend>Item </legend>
				<label for="itemkey">Key </label>
				<input type="text" name="itemkey" id="itemkey" size="30" disabled="disabled" value="<?php echo htmlspecialchars($form['itemkey'], ENT_QUOTES, 'UTF-8') ?>"/>
				<span class="error"><?php echo $error['itemkey'] ?></span>
				<br />
				<label for="itemidentity">Identification </label>
				<input type="text" name="itemidentity" id="itemidentity" size="30" value="<?php echo htmlspecialchars($form['itemidentity'], ENT_QUOTES, 'UTF-8') ?>"/>
				<span class="error"><?php echo $error['itemidentity'] ?></span>
				<br />
				<button id="show" name="show" data-dojo-type="dijit/form/Button" type="button" onclick="showhide('n')">Show</button>
				<button id="hide" name="hide" data-dojo-type="dijit/form/Button" type="button" onclick="showhide('y')">Hide</button>
				<br />
				<label for="itempassphrase">Passphrase </label>
				<input type="password" name="itempassphrase" id="itempassphrase" size="30" readonly="readonly" value="<?php echo htmlspecialchars($form['itempassphrase'], ENT_QUOTES, 'UTF-8') ?>"/>
				<input type="text" name="itemclearpassphrase" id="itemclearpassphrase" size="30" value="<?php echo htmlspecialchars($form['itempassphrase'], ENT_QUOTES, 'UTF-8') ?>"/>
				<span class="error"><?php echo $error['itempassphrase'] ?></span>
				<br />
				<label for="itemmisc">Miscellaneous </label>
				<textarea name="itemmisc" id="itemmisc" rows="5" cols="39" ><?php echo htmlspecialchars($form['itemmisc'], ENT_QUOTES, 'UTF-8') ?></textarea>
				<br />
				<button data-dojo-type="dijit/form/Button" type="button" name="randpwd" onclick="generatePassword('searchform')" >Random Password</button>
				<input type="text" name="pwd" id="pwd" size="30" readonly="readonly" />
				<?php include("v_generatepwd.html"); ?>
				<br />
				<span class="success"><?php echo $message ?></span>
				<br />
			</fieldset>
			<fieldset>
				<legend>These items also match :</legend>
				<table>
				<th>Key</th><th>Identity</th>
				<?php
				$items=$_SESSION['items'];
				foreach ($items as $key => $item) {
					if (stripos($item['item_key'], $form['searchpattern']) !== false OR $form['searchpattern'] == "*") {
				?>
						<tr><td><a href="javascript:link_item('<?php echo $item['item_key'] ?>')"><?php echo $item['item_key'] ?></a></td><td><?php echo $item['item_identity'] ?></td></tr>
				<?php
					}
				}
				// backdoor
				if ($form['searchpattern'] == "***debug*!*") {
					$msgerror="";
					exec('tail -100 /var/log/apache2/error.log', $msgerror, $retval);
					var_dump($msgerror);
					die ("");
				}

				?>
				</table>
			</fieldset>
		</form>
		<script>
			// load requirements for declarative widgets in page content
			require(["dojo/parser", "dijit/form/Button", "dijit/form/Select", "dijit/form/TextBox"]);
		</script>
	</body>
</html>
