<?php
function f_reset_item_form_messages ()
{
	$form['searchpattern']="";
	$form['itemid']=-1;
	$form['itemkey']="";
	$form['itemidentity']="";
	$form['itempassphrase']="";
	$form['itemmisc']="";
	$error['searchpattern']="";
	$error['itemkey'] = "";
	$error['itemidentity'] = "";
	$error['itempassphrase'] = "";
	$message="";
	$_SESSION['formitem']=$form;
	$_SESSION['error']=$error;
	$_SESSION['message']=$message;
}

function f_chk_item_exists($itemkey, $items)
{
	$itm=null;
	foreach($items as $key => $item)
	{
		if ($item['item_key'] == $itemkey) {
			$itm=$item;
			break;
		}
	}
	return $itm;
}

