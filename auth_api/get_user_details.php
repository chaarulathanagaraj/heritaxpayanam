<?php
// Enable CORS and set content type
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Get the posted data
$data = json_decode(file_get_contents("php://input"));

// Check if email is provided
if(!empty($data->email)) {
    // Database connection details
    $host = 'localhost';
    $db_user = 'root'; // Replace with your MySQL username
    $db_password = ''; // Replace with your MySQL password
    $db_name = 'auth_app';
    // Create connection
    $conn = new mysqli($host, $db_user, $db_password, $db_name);

    // Check connection
    if ($conn->connect_error) {
        http_response_code(500);
        echo json_encode(array("error" => "Connection failed: " . $conn->connect_error));
        exit;
    }

    // Prepare a select statement to get user details
    $sql = "SELECT name FROM users WHERE email = ?";
    
    if($stmt = $conn->prepare($sql)) {
        // Bind variables to the prepared statement as parameters
        $stmt->bind_param("s", $data->email);
        
        // Execute the prepared statement
        if($stmt->execute()) {
            // Store result
            $result = $stmt->get_result();
            
            // Check if email exists
            if($result->num_rows > 0) {
                $row = $result->fetch_assoc();
                
                // Return user data
                http_response_code(200);
                echo json_encode(array(
                    "name" => $row["name"]
                ));
            } else {
                // User not found
                http_response_code(404);
                echo json_encode(array("error" => "User not found."));
            }
        } else {
            http_response_code(500);
            echo json_encode(array("error" => "Query execution failed."));
        }
        
        // Close statement
        $stmt->close();
    } else {
        http_response_code(500);
        echo json_encode(array("error" => "Could not prepare statement."));
    }
    
    // Close connection
    $conn->close();
} else {
    // Email is empty
    http_response_code(400);
    echo json_encode(array("error" => "Email is required."));
}
?>