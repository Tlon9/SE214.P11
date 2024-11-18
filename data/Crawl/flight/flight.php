<?php

// Connect to the database.
$mysqli = new mysqli("localhost", "root", "", "db_ie104");
if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
  } else {
    echo "Connected successfully" . "<br>";
  }

// // Read the JSON file.
$json_file = file_get_contents("./Data/flights.json");

// Decode the JSON file into an array.
$json_array = json_decode($json_file, true);
// foreach ($json_array as $flight) {
//     echo "Flight ID: {$flight['Id']}" . "<br>";
//     echo "Flight Name: {$flight['Name']}" . "<br>";
//     echo "Departure Airport: {$flight['From']}" . "<br>";
//     echo "Arrival Airport: {$flight['To']}" . "<br>";
//     echo "Departure Time: {$flight['DepartureTime']}" . "<br>";
//     echo "Arrival Time: {$flight['ArrivalTime']}" . "<br>";
//     echo "----------------------- " . "<br>";
//   }

// Loop through the JSON array and insert each row into the table.
foreach ($json_array as $row) {
  $sql = "INSERT INTO flight VALUES ('".$row['Id']."','".$row['From']."','".$row['To']."','".$row['Date']."','".$row['DepartureTime']."','".$row['ArrivalTime']."','".$row['TravelTime']."','".$row['Stop/Direct']."','".$row['Name']."','".$row['SeatClass']."','".$row['Price']."')";
  if ($mysqli->query($sql) === TRUE) {
    echo "Record inserted successfully";} 
    else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}
}

// Close the database connection.
$mysqli->close();

?>