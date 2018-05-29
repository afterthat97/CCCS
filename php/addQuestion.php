<?php
	$dbhost = 'localhost:3306';
	$dbuser = 'root';
	$dbpass = 'breeze320681';
	$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
	if (!$conn) {
		echo '{ "code":1, "info" : "Failed to connect to database." }';
		die('');
	}
    mysqli_select_db($conn, 'cccs');

	if (isset($_GET["tid"])) {
		$tid = $_GET["tid"];
		$password = $_GET["password"];
        $cid = $_GET["cid"];
		$quescontent = $_GET["quescontent"];
		$Achoice = $_GET["Achoice"];
		$Bchoice = $_GET["Bchoice"];
		$Cchoice = $_GET["Cchoice"];
		$Dchoice = $_GET["Dchoice"];
        $correct = $_GET["Choose"];
        
        $sql_query = "select * from Teacher where tid='$tid'";
        $retval = mysqli_query( $conn, $sql_query );
        $row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
        if ($row['password'] == $password) {
            $sql = "INSERT INTO Question".
            "(tid, cid, questext, Achoice, Bchoice, Cchoice, Dchoice,correct)".
            "VALUES".
            "('$tid', '$cid', '$quescontent', '$Achoice', '$Bchoice', '$Cchoice', '$Dchoice','$correct')";
            mysqli_query( $conn, $sql );
            echo '{ "code" : 0, "info" : "Question has been added." }';
        } else {
            echo '{ "code" : 1, "info" : "Authentication failed." }';
        }
    }
    mysqli_close($conn);
?>

		
		
