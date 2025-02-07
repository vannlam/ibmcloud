<?php
session_start();
?>
<!DOCTYPE html>
<html >
	<head>
		<title>SafeItem Serverless</title>
		<meta charset="utf-8" content="width=device-width; initial-scale=1.0" />
    <link rel="stylesheet" href="../../dojo-release-1.8.3/dijit/themes/claro/claro.css">
    <link type="text/css" rel="stylesheet" href="includes/style.css" />
    <script src="../../dojo-release-1.8.3/dojo/dojo.js" data-dojo-config="isDebug: true, async: true, parseOnLoad: true"></script>
	</head>
	<body class="claro bgstd" >
		<form action="../controller/c_passcode.php" method="post" name="formpasscode" >
			<fieldset>
				<legend>Enter your passcode : </legend>
				<label for="passcode"> <span class="requis"><?php echo $_SESSION['session_match']." - "  ?></span></label>
				<input type="text" name="passcode" id="passcode" size="6" autofocus />
				<br />
				<button data-dojo-type="dijit/form/Button" type="submit">Submit</button>
			</fieldset>
		</form>
		<script>
			// load requirements for declarative widgets in page content
			require(["dojo/parser", "dijit/form/Button"]);
		</script>
	</body>
</html>
