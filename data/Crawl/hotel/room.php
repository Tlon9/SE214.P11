<?php

// Connect to the database.
$mysqli = new mysqli("localhost", "root", "", "db_ie104");
if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
  } else {
    echo "Connected successfully" . "<br>";
  }

// // Read the JSON file.
$json_file = file_get_contents("./Data/rooms.json");

// Decode the JSON file into an array.
$json_array = json_decode($json_file, true);


// Loop through the JSON array and insert each row into the table.
foreach ($json_array as $row) {
  $sql = "INSERT INTO room VALUES ('".$row['Id']."','".$row['Hotel_id']."','".$row['Name']."','".$row['Max']."','".$row['Price']."','".$row['State']."')";
  if ($mysqli->query($sql) === TRUE) {
    echo "Record inserted successfully";} 
    else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}
}

// Close the database connection.
$mysqli->close();

?>