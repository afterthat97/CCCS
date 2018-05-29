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
        
            $sql_query = "select temp.sid temp.cid state reason from Choose,Course,temp  where Course.tid ='$tid' and Course.cid=temp.cid and Course.cid = Choose.cid and Choose.sid= temp.sid";
       }
    else
    {
            $sid=$_GET["sid"];
		$sql_query = "select temp.sid temp.cid state reason from temp where temp.sid='$sid'";
        $retval = mysqli_query( $conn, $sql_query );
        $results = array();
	while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
	    array_push($results, $row);
  
	if ($results) {
	    echo json_encode($results);
	}
           
    
     mysqli_close($conn);
?>
