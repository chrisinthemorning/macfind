<?php
if (isset($_GET['find'])){
	echo 'Seached for: ' . $_GET['find'] . '<br>';
	$exit = cmd_exec( './find.sh ' . $_GET['find'] . ' ' . $_GET['searchregex'],$stdout, $stderr);
?>
	<table>
<?php
	foreach ($stdout as $line)
	{
		$pieces = explode(",", $line);
		if (isset($_GET['mac'])) {
			$pieces = explode(",", $line);
			$subpieces = explode("/",$pieces[5]);
			$url = "<tr><td><a href='change.php?vlan=" . $pieces[1] . "&ifindex=" .  $pieces[0] . "&device=" .   $subpieces[1] . "'>$line</a></td></tr>";
		} else {
			$pieces = explode(" ", $line);
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
?>
<form action="c.php" method="get" name="find">
	<table>
		<tr>
			<td>IP or MAC:</td>
			<td><input class="formtext" name="find" size="12" type="text">
			</td>
		</tr>
		<tr>
			<td>Date: (YY-MM-DD-hh)</td>
			<td><input class="formtext" name="searchregex" size="12" type="text">
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
