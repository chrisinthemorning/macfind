<?php
if (isset($_GET['community'])){
	echo 'Changing to Vlan : ' . $_GET['newvlan'] . '<br>';
	$exit = cmd_exec( './changevlan.sh ' .  $_GET['device'] . ' ' . $_GET['community'] . ' ' . $_GET['ifindex'] . ' ' . $_GET['currvlan'] . ' ' . $_GET['newvlan'],$stdout, $stderr);
?>
	<table>
<?php
	foreach ($stdout as $line)
	{
		echo $line;
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
	$pieces = explode("/",urldecode($_GET['datapath']));
	$exit = cmd_exec( 'cat ' . trim(urldecode($_GET['datapath'])) . '/vlannames  | cut -d "." -f 17 | cut -d " " -f1,4',$stdout, $stderr);
?>
<form action="change.php" method="get" name="find">
	<table>
		<tr>
			<td>device ip:</td>
			<td><input class="formtext" name="device" size="12" type="text" value="<?=$pieces[1];?>">
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
			<td><select name="newvlan">
			<?php
			foreach ($stdout as $line)
                	{
				$options = explode(" ", $line);
				if ($options[0] == $currvlan) {
					echo "<option selected=true value='" . $options[0] . "'>" . $options[0] . "-" . $options[1]  . "</option>" ;	
				} else {
                        		echo "<option value='" . $options[0] . "'>" . $options[0] . "-" . $options[1]  . "</option>" ;
				}
                	}
			?>
			</select></td>
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
