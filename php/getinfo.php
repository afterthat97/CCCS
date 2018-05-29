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


	$cid = $_GET["cid"];
	if (isset($_GET["sid"])) {
		    $sid = $_GET["sid"];
        
            $sql_query = "select * from temp where temp.cid='$cid' and temp.sid='$sid'";
       }
    else
    {
		$sql_query = "select * from temp where temp.cid='$cid'";
	}

        $retval = mysqli_query( $conn, $sql_query );
        $results = array();
	while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
	    array_push($results, $row);
  
	if ($results) {
	    echo json_encode($results);
	}
           
    
     mysqli_close($conn);
?>

