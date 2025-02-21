function decision(message, url){
	if (confirm(message)) location.href = url;
}

function showhide(hidepwd)
{
	document.searchform.itempassphrase.style.display = 'none';
	document.searchform.itemclearpassphrase.style.display = 'none';

	dojo.style(dijit.byId('show').domNode, {
		visibility: 'hidden',
		display: 'none'
	});

	dojo.style(dijit.byId('hide').domNode, {
		visibility: 'hidden',
		display: 'none'
	});

	if (hidepwd == 'n') {
		$f='itemclearpassphrase';
		document.searchform.itemclearpassphrase.style.display = 'block';
		
		dojo.style(dijit.byId('hide').domNode, {
			visibility: 'visible',
			display: 'block'
		});

		var text_input = document.getElementById ($f);
		text_input.focus ();
		text_input.select ();
	}
	else {
		$f='itempassphrase';
		document.searchform.itempassphrase.style.display = 'block';

		dojo.style(dijit.byId('show').domNode, {
			visibility: 'visible',
			display: 'block'
		});

	}
}

function post_to_url(path, params) {
	var form = document.createElement("form");
	form.setAttribute("method", "post");
	form.setAttribute("action", path);

	for(var key in params) {
		if(params.hasOwnProperty(key)) {
			var hiddenField = document.createElement("input");
			hiddenField.setAttribute("type", "hidden");
			hiddenField.setAttribute("name", key);
			hiddenField.setAttribute("value", params[key]);

			form.appendChild(hiddenField);
		 }
	}

	document.body.appendChild(form);
	form.submit();
}

function decision_upd(message, url){
	if (confirm(message)) {
		var itemkey = document.searchform.itemkey.value;
		var itemidentity = document.searchform.itemidentity.value;
		var itemsecret = document.searchform.itemclearpassphrase.value; 
		var itemmisc = document.searchform.itemmisc.value; 
		post_to_url(url, {itemkey: itemkey, itemidentity: itemidentity, itemsecret: itemsecret, itemmisc: itemmisc});
	}
}

function keep_data(url){
	var itemkey = document.searchform.itemkey.value;
	var itemidentity = document.searchform.itemidentity.value;
	var itemsecret = document.searchform.itemclearpassphrase.value; 
	var itemmisc = document.searchform.itemmisc.value; 
	post_to_url(url, {itemkey: itemkey, itemidentity: itemidentity, itemsecret: itemsecret, itemmisc: itemmisc});
}

function copytoclipboard() {
  // Get the text field
  var copyText = document.getElementById("itemclearpassphrase");

  // Select the text field
  copyText.select();
  copyText.setSelectionRange(0, 40); // For mobile devices

   // Copy the text inside the text field
  navigator.clipboard.writeText(copyText.value);

  // Alert the copied text
  //alert("Copied the text: " + copyText.value);
} 

function link_item(itemkey){
	post_to_url('../controller/c_link_item.php', {itemkey: itemkey});
}

function generatePassword(id) {
	var pwdlevel=4;
	if (id=='searchform') {
		pwdlevel=document.searchform.pwdlevel.value;
	}
	else if (id=='newitemform'){
		pwdlevel=document.newitemform.pwdlevel.value;
	}
	var ch="test";
	length=16;
	switch (pwdlevel) {
		case "1":
			ch='0123456789';
			length=8;
			break;
		case "2":
			ch='aeiouybacedifoguhyjakeimonupyqaresitovuwyxaz0123456789';
			length=10;
			break;
		case "3":
			ch='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
			length=12
			break;
		case "4":
			ch='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789&#"{([-|_@)]+=}%!:;,?.<>';
			length=16
			break;
		case "5":
			ch='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789&#"{([-|_@)]+=}%!:;,?.<>';
			length=20
			break;
	}
	var password = '';
	for (i = 0; i < length; i++) {
			password = password + ch.charAt(Math.random() * ch.length);
	}
	if (id=='searchform') {
		document.searchform.pwd.value=password;
	}
	else if (id=='newitemform'){
		document.newitemform.itempassphrase.value=password;
	}
}
