<?php
if (isset($_GET['community'])){
	echo 'Seached for: ' . $_GET['community'] . '<br>';
	$exit = cmd_exec( './changevlan.sh ' . $_GET['community'] . ' ' . $_GET['searchregex'],$stdout, $stderr);
?>
	<table>
<?php
	foreach ($stdout as $line)
	{
		$pieces = explode(" ", $line);
		if (isset($_GET['mac'])) {
			$url = "<tr><td><a href='change.php?mac=" . $pieces[4] . "&find=" . $_GET['find'] . "&searchregex=" .  $_GET['searchregex'] . "'>$line</a></td></tr>";
		} else {
			$url = "<tr><td><a href='find.php?mac=" . $pieces[4] . "&find=" . $pieces[4] . "&searchregex=" .  $_GET['searchregex'] . "'>$line</a></td></tr>";
		}
		echo $url;
	}
?>
        </table>
<?php
		//in case there an error is returned
		foreach ($stderr as $line)
		{
			echo "$line <br>";
		}
} else {
	$currvlan=substr($_GET['vlan'],4);
?>
<form action="c.php" method="get" name="find">
	<table>
		<tr>
			<td>device ip:</td>
			<td><input class="formtext" name="device" size="12" type="text" value="<?=$_GET['device'];?>">
			</td>
		</tr>
		<tr>
			<td>ifindex</td>
			<td><input class="formtext" name="ifindex" size="12" type="text" value="<?=$_GET['ifindex'];?>">
			</td>
		</tr>
		<tr>
                        <td>Current Vlan</td>
                        <td><input class="formtext" name="currvlan" size="12" type="text" value="<?=$currvlan;?>">
                        </td>
                </tr>
		<tr>
                        <td>New Vlan</td>
                        <td><input class="formtext" name="newvlan" size="12" type="text">
                        </td>
                </tr>
		<tr>
                       <td>Community</td>
                       <td><input class="formtext" name="community" size="12" type="text">
                       </td>
                </tr>
		</table>
		<input class="formbuton" type="submit" value="Go">
</form>
<?php
}

function cmd_exec($cmd, &$stdout, &$stderr)
{
	$outfile = tempnam(".", "cmd");
	$errfile = tempnam(".", "cmd");
	$descriptorspec = array(
		0 => array("pipe", "r"),
		1 => array("file", $outfile, "w"),
		2 => array("file", $errfile, "w")
	);
	$proc = proc_open($cmd, $descriptorspec, $pipes);

	if (!is_resource($proc)) return 255;

	fclose($pipes[0]);    //Don't really want to give any input

	$exit = proc_close($proc);
	$stdout = file($outfile);
	$stderr = file($errfile);

	unlink($outfile);
	unlink($errfile);
	return $exit;
}
?>
