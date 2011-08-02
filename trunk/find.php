<?php
if (isset($_GET['find'])){
	echo 'Seached for: ' . $_GET['find'] . '<br>';
	$exit = cmd_exec( './find.sh ' . $_GET['find'] . ' ' . $_GET['searchregex'],$stdout, $stderr);
?>
	<table border="1" cellspacing="0" cellpadding="4">
<?php
	foreach ($stdout as $line)
	{
		$pieces = explode(",", $line);
		if (isset($_GET['mac'])) {
			$pieces = explode(",", $line);
			$url = "<td><a href='change.php?vlan=" . $pieces[1] . "&ifindex=" .  $pieces[0] . "&datapath=" . urlencode($pieces[5]) . "'>$pieces[1]</a></td>";
		} else {
			$pieces = explode(" ", $line);
			$url = "<td><a href='find.php?mac=" . $pieces[4] . "&find=" . $pieces[4] . "&searchregex=" .  $_GET['searchregex'] . "'>$pieces[4]</a></td>";
		}
		echo "<tr>";
		for($i = 0; $i < count($pieces); $i++){
			if ($i==1 && isset($_GET['mac'])) {
				echo $url;
			} elseif ($i==4 && !( isset($_GET['mac']))) {
				echo $url;
			} else {
				echo "<td>$pieces[$i]</td>";
			}
		}
		echo "</tr>";
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
<form action="find.php" method="get" name="find">
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
