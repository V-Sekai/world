package main

import (
	"bufio"
	"fmt"
	"net"
	"testing"
	"time"
	"encoding/json"
	"net/http/httptest"
	"strings"
	"os"
	"io"
	"log"
	"net/http"
	"bytes"
	"errors"
	"github.com/golang-jwt/jwt"
)

func TestConnection(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Give the server some time to start up
	time.Sleep(2 * time.Second)

	// Connect to the server
	conn, err := net.Dial("tcp", "localhost:6000")
	if err != nil {
		t.Fatalf("Failed to connect to server: %v", err)
	}
	defer conn.Close()

	loginTest(t, conn, "testUser1")

	moveTest(t, conn, "testUser1")
}

func TestMovement(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Give the server some time to start up
	time.Sleep(2 * time.Second)

	// Connect to the server
	conn, err := net.Dial("tcp", "localhost:6000")
	if err != nil {
		t.Fatalf("Failed to connect to server: %v", err)
	}
	defer conn.Close()

	loginTest(t, conn, "testUser1")

	moveTest(t, conn, "testUser1")
}

func TestClientKickUser(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

    // Connect two clients
    conn1 := connectClient(t)
    defer conn1.Close()
    conn2 := connectClient(t)
    defer conn2.Close()


	loginTest(t, conn1, "testUser1")

	loginTest(t, conn2, "testUser2")

	
	checkUserJoinedReceived(t, conn1, "testUser2", "joined the chat!")

	// Give the clients some time to connect
	time.Sleep(5 * time.Second)


	kickReq := struct {
		Username string `json:"username"`
	}{
		Username: "testUser2",
	}

	kickReqBytes, err := json.Marshal(kickReq)
	if err != nil {
		t.Fatal("Failed to marshal kick request")
	}

	req, err := http.NewRequest("POST", "http://localhost:5000/api/kickUser", bytes.NewBuffer(kickReqBytes))
	if err != nil {
		t.Fatal("Failed to create kick request")
	}

	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	fmt.Println("Sending http call to kick user")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal("Failed to execute kick request")
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code 200, got %d", resp.StatusCode)
	}

	// Read kicked announcement from testUser1
	response, err := bufio.NewReader(conn1).ReadString('\n')
	if err != nil {
		t.Fatalf("Failed to read server response: %v", err)
	}

	fmt.Println(response)

	var announcement struct {
		Action   string `json:"action"`
		Username string `json:"username"`
		Message  string `json:"message"`
	}
	err = json.Unmarshal([]byte(response), &announcement)
	if err != nil {
		t.Fatalf("Failed to parse server response: %v", err)
	}

	expectedMessage := "has been kicked from the server."
	if announcement.Action != "announcement" || announcement.Username != "testUser2" || announcement.Message != expectedMessage {
		t.Fatalf("Unexpected announcement: %+v", announcement)
	}

	// Read kicked announcement from testUser1
	response_after, err := bufio.NewReader(conn2).ReadString('\n')
	if err != nil {
		t.Fatalf("Failed to read server response: %v", err)
	}

	// Parse the response
	var actionResponse struct {
		Action   string `json:"action"`
		Message string `json:"message"`
	}
	fmt.Printf("Server Response: %s", response)
	err = json.Unmarshal([]byte(response_after), &actionResponse)
	if err != nil {
		t.Fatalf("Failed to parse server response: %v", err)
	}
	if actionResponse.Action != "kicked" || actionResponse.Message != "You have been kicked." {
		t.Fatalf("Unexpected kicked response: %+v", actionResponse)
	}


	_, err2 := bufio.NewReader(conn2).ReadString('\n')
	if errors.Is(err2, io.EOF) {
		fmt.Println("TestClientKickUser: PASSED")
	} else if err2 != nil {
		t.Fatalf("Failed to read server response: %v", err)
	}
}

func connectClient(t *testing.T) net.Conn {
    conn, err := net.Dial("tcp", "localhost:6000")
    if err != nil {
        t.Fatalf("Failed to connect to server: %v", err)
    }
    return conn
}

func loginTest(t *testing.T, conn net.Conn, username string) {
// Send a username to the server
fmt.Fprintf(conn, username + "\n")

// Read server response
response, err := bufio.NewReader(conn).ReadString('\n')
if err != nil {
	t.Fatalf("Failed to read server response: %v", err)
}

// Parse the response
var mapUpdate [][]CellInfo
err = json.Unmarshal([]byte(response), &mapUpdate)
if err != nil {
	t.Fatalf("Failed to parse map update: %v", err)
}
fmt.Fprintf(os.Stdout, "loginTest(%s): PASSED\n", username)
}

func moveTest(t *testing.T, conn net.Conn, username string) {
	directionTest(t, conn, "south", 0, 1, username)
	directionTest(t, conn, "north", 0, 0, username)
	directionTest(t, conn, "east", 1, 0, username)
	directionTest(t, conn, "west", 0, 0, username)
}

func directionTest(t *testing.T, conn net.Conn, direction string, dx, dy int, username string) {
	// Send move command
	conn.Write([]byte("/" + direction + "\n"))

	// Read server response
	response, err := bufio.NewReader(conn).ReadString('\n')
	if err != nil {
		t.Fatalf("Failed to read server response: %v", err)
	}

	// Parse the response
	var moveResponse struct {
		Action   string `json:"action"`
		Username string `json:"username"`
		X        int    `json:"x"`
		Y        int    `json:"y"`
	}
	fmt.Printf("Server Response: %s", response)
	err = json.Unmarshal([]byte(response), &moveResponse)
	if err != nil {
		t.Fatalf("Failed to parse server response: %v", err)
	}

	// Check if the position is correct
	expectedX := 0 + dx
	expectedY := 0 + dy
	if moveResponse.Action != "move" || moveResponse.Username != username || moveResponse.X != expectedX || moveResponse.Y != expectedY {
		t.Fatalf("Unexpected move response: %+v", moveResponse)
	}
	fmt.Fprintf(os.Stdout, "moveTest(%s): PASSED\n", direction)
}

func TestSendAnnouncementHandler(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

	// Connect two clients
	client1 := connectClient(t)
	defer client1.Close()
	client2 := connectClient(t)
	defer client2.Close()

	loginTest(t, client1, "testUser1")

	loginTest(t, client2, "testUser2")

	checkUserJoinedReceived(t, client1, "testUser2", "joined the chat!")

	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	// Prepare the request payload
	payload := strings.NewReader(`{"message": "This is a test announcement."}`)
	req := httptest.NewRequest("POST", "/api/sendAnnouncement", payload)
	req.Header.Set("Content-Type", "application/json")
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	// Record the HTTP response
	w := httptest.NewRecorder()

	// Call the sendAnnouncementHandler function
	sendAnnouncementHandler(w, req)

	// Check the HTTP status code
	resp := w.Result()
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code %d, got %d", http.StatusOK, resp.StatusCode)
	}

	// Check if both clients received the announcement
	checkAnnouncementReceived(t, client1, "This is a test announcement.")
	checkAnnouncementReceived(t, client2, "This is a test announcement.")
}

func checkAnnouncementReceived(t *testing.T, conn net.Conn, expectedMsg string) {
	msg, err := bufio.NewReader(conn).ReadString('\n')
	if err != nil {
		t.Fatalf("Failed to read message from client: %v", err)
	}

	fmt.Println(msg)

	var announcement struct {
		Action  string `json:"action"`
		Message string `json:"message"`
	}

	err = json.Unmarshal([]byte(msg), &announcement)
	if err != nil {
		t.Fatalf("Failed to parse JSON: %v", err)
	}

	if announcement.Action != "announcement" || announcement.Message != expectedMsg {
		t.Fatalf("Unexpected announcement received: %+v", announcement)
	}
}

func checkUserJoinedReceived(t *testing.T, conn net.Conn, username, expectedMsg string) {
	msg, err := bufio.NewReader(conn).ReadString('\n')
	if err != nil {
		t.Fatalf("Failed to read message from client: %v", err)
	}

	fmt.Println(msg)

	var joined struct {
		Action  string `json:"action"`
		Username string `json:"username"`
		Message string `json:"message"`
	}

	err = json.Unmarshal([]byte(msg), &joined)
	if err != nil {
		t.Fatalf("Failed to parse JSON: %v", err)
	}

	if joined.Action != "joined" || joined.Username != username || joined.Message != expectedMsg {
		t.Fatalf("Unexpected user join received: %+v", joined)
	}
}

func createTestJWT() string {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"iss": "testIssuer",
		"sub": "testSubject",
		"aud": "testAudience",
		"exp": time.Now().Add(time.Hour * 1).Unix(),
		"nbf": time.Now().Unix(),
		"iat": time.Now().Unix(),
		"jti": "testJti",
	})

	tokenString, err := token.SignedString([]byte(apijwtSecret))
	if err != nil {
		log.Fatalf("Error creating test JWT: %v", err)
	}

	return tokenString
}

func TestLoadUserHandler(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	// Prepare the request payload
	payload := strings.NewReader(`{"username": "testUser1", "x": 5, "y": 5}`)
	req := httptest.NewRequest("POST", "/api/loadUser", payload)
	req.Header.Set("Content-Type", "application/json")
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	// Record the HTTP response
	w := httptest.NewRecorder()

	// Call the loadUserHandler function
	loadUserHandler(w, req)

	// Check the HTTP status code
	resp := w.Result()
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code %d, got %d", http.StatusOK, resp.StatusCode)
	}

	// Check if the user was loaded correctly
	if loadedUser, ok := loadedUsers["testUser1"]; !ok || loadedUser.X != 5 || loadedUser.Y != 5 {
		t.Fatalf("Failed to load user: %+v", loadedUser)
	}

	fmt.Println("TestLoadUserHandler: PASSED")
}

func TestClientKickAllUsers(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

    // Connect two clients
    conn1 := connectClient(t)
    defer conn1.Close()
    conn2 := connectClient(t)
    defer conn2.Close()


	loginTest(t, conn1, "testUser1")

	loginTest(t, conn2, "testUser2")

	
	checkUserJoinedReceived(t, conn1, "testUser2", "joined the chat!")

	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	req, err := http.NewRequest("POST", "http://localhost:5000/api/kickAllUsers", nil)
	if err != nil {
		t.Fatal("Failed to create kick request")
	}
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	fmt.Println("Sending http call to kick all users")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal("Failed to execute kick request")
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code 200, got %d", resp.StatusCode)
	}

	// Give the server some time to process the kick action
	time.Sleep(2 * time.Second)

	// Check if the clients are disconnected
	if _, ok := clients.Load("testUser1"); ok {
		t.Fatalf("Client 1 (%s) was not kicked from the server", "testUser1")
	}

	if _, ok := clients.Load("testUser2"); ok {
		t.Fatalf("Client 2 (%s) was not kicked from the server", "testUser2")
	}

	fmt.Println("TestKickAllUsersHandler: PASSED")
}

func TestSendMessageToUserHandler(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

    // Connect two clients
    conn1 := connectClient(t)
    defer conn1.Close()


	loginTest(t, conn1, "testUser1")

	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	payload := struct {
		FromUsername string `json:"from_username"`
		ToUsername   string `json:"to_username"`
		FromServer   string `json:"from_server"`
		Message      string `json:"message"`
	}{
		ToUsername:       "testUser1",
		FromUsername:       "testUser2",
		FromServer: "testServer2",
		Message:    "This is only a test",
	}
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("Failed to marshal payload: %v", err)
	}


	req, err := http.NewRequest("POST", "http://localhost:5000/api/sendMessageToUser", bytes.NewBuffer(payloadBytes))
	if err != nil {
		t.Fatal("Failed to create message request")
	}
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	fmt.Println("Sending message to user")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal("Failed to execute message request")
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code 200, got %d", resp.StatusCode)
	}

	// Give the server some time to process the kick action
	time.Sleep(2 * time.Second)

	checkUserMessageViaAPIReceived(t, conn1, "testUser1", "testUser2", "This is only a test")

	fmt.Println("TestSendMessageToUserHandler: PASSED")
}

func checkUserMessageViaAPIReceived(t *testing.T, conn net.Conn, toUsername, fromUsername, expectedMsg string) {
	msg, err := bufio.NewReader(conn).ReadString('\n')
	if err != nil {
		t.Fatalf("Failed to read message from client: %v", err)
	}

	fmt.Println(msg)

	var fromMsg struct {
		Action string `json:"action"`
		Message  string `json:"message"`
		From string `json:"from"`
		FromServer  string `json:"fromServer"`
		To  string `json:"to"`
	}

	err = json.Unmarshal([]byte(msg), &fromMsg)
	if err != nil {
		t.Fatalf("Failed to parse JSON: %v", err)
	}

	if fromMsg.Action != "private_message" || fromMsg.To != toUsername || fromMsg.From != fromUsername || fromMsg.Message != expectedMsg {
		t.Fatalf("Unexpected user message received: %+v", fromMsg)
	}
}

func TestMoveUserHandler(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

    // Connect two clients
    conn1 := connectClient(t)
    defer conn1.Close()


	loginTest(t, conn1, "testUser1")

	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	// Prepare the request payload
	newX, newY := 1, 1
	payload := struct {
		Username string `json:"username"`
		X        int    `json:"x"`
		Y        int    `json:"y"`
	}{
		Username: "testUser1",
		X:        newX,
		Y:        newY,
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("Failed to marshal payload: %v", err)
	}

	req, err := http.NewRequest("POST", "http://localhost:5000/api/moveUser", bytes.NewBuffer(payloadBytes))
	if err != nil {
		t.Fatal("Failed to create message request")
	}
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	fmt.Println("Sending message to user")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal("Failed to execute message request")
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code 200, got %d", resp.StatusCode)
	}

	// Give the server some time to process the kick action
	time.Sleep(2 * time.Second)

	// Read the move announcement from the target client
	reader := bufio.NewReader(conn1)
	msg, err := reader.ReadString('\n')
	if err != nil {
		t.Fatalf("Failed to read message from client: %v", err)
	}

	fmt.Println(msg)

	// Parse the response
	var moveResponse struct {
		Action   string `json:"action"`
		Username string `json:"username"`
		X        int    `json:"x"`
		Y        int    `json:"y"`
	}
	err = json.Unmarshal([]byte(msg), &moveResponse)
	if err != nil {
		t.Fatalf("Failed to parse server response: %v", err)
	}

	// Check if the position is correct
	if moveResponse.Action != "move" || moveResponse.Username != "testUser1" || moveResponse.X != newX || moveResponse.Y != newY {
		t.Fatalf("Unexpected move response: %+v", moveResponse)
	}

	fmt.Println("TestMoveUserHandler: PASSED")
}

func TestSendMessageToCellHandler(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

    // Connect two clients
    conn1 := connectClient(t)
    defer conn1.Close()
    conn2 := connectClient(t)
    defer conn2.Close()


	loginTest(t, conn1, "testUser1")

	loginTest(t, conn2, "testUser2")

	
	checkUserJoinedReceived(t, conn1, "testUser2", "joined the chat!")

	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	// Prepare the request payload
	message := "Hello, cell!"
	payload := struct {
		X       int    `json:"x"`
		Y       int    `json:"y"`
		Message string `json:"message"`
	}{
		X:       0,
		Y:       0,
		Message: message,
	}
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("Failed to marshal payload: %v", err)
	}


	req, err := http.NewRequest("POST", "http://localhost:5000/api/sendMessageToCell", bytes.NewBuffer(payloadBytes))
	if err != nil {
		t.Fatal("Failed to create message request")
	}
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	fmt.Println("Sending message to user")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal("Failed to execute message request")
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code 200, got %d", resp.StatusCode)
	}

	// Give the server some time to process the kick action
	time.Sleep(2 * time.Second)

// Check if both clients received the announcement
checkCellMessageReceived(t, conn1, "Hello, cell!")
checkCellMessageReceived(t, conn2, "Hello, cell!")

	fmt.Println("TestSendMessageToCellHandler: PASSED")
}

func checkCellMessageReceived(t *testing.T, conn net.Conn, expectedMsg string) {
	msg, err := bufio.NewReader(conn).ReadString('\n')
	if err != nil {
		t.Fatalf("Failed to read message from client: %v", err)
	}

	fmt.Println(msg)

	var announcement struct {
		Action  string `json:"action"`
		Message string `json:"message"`
	}

	err = json.Unmarshal([]byte(msg), &announcement)
	if err != nil {
		t.Fatalf("Failed to parse JSON: %v", err)
	}

	if announcement.Action != "cell_message" || announcement.Message != expectedMsg {
		t.Fatalf("Unexpected cell_message received: %+v", announcement)
	}
}

func TestMuteUserHandler(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

    // Connect two clients
    conn1 := connectClient(t)
    defer conn1.Close()
    conn2 := connectClient(t)
    defer conn2.Close()


	loginTest(t, conn1, "testUser1")

	loginTest(t, conn2, "testUser2")

	
	checkUserJoinedReceived(t, conn1, "testUser2", "joined the chat!")

	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	// Prepare the request payload
	payload := struct {
		Username string `json:"username"`
	}{
		Username: "testUser2",
	}
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("Failed to marshal payload: %v", err)
	}


	req, err := http.NewRequest("POST", "http://localhost:5000/api/muteUser", bytes.NewBuffer(payloadBytes))
	if err != nil {
		t.Fatal("Failed to create message request")
	}
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	fmt.Println("Muting user")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal("Failed to execute message request")
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code 200, got %d", resp.StatusCode)
	}

	// Give the server some time to process the kick action
	time.Sleep(2 * time.Second)

		// Iterate over the clients sync.Map to find the user and disconnect them
		clients.Range(func(_, v interface{}) bool {
			cli := v.(*client)
			if cli.username == "testUser2" {
				fmt.Println("User Found!")
				if (!cli.muted) {
					t.Fatalf("Failed to mute user: %+v", cli.username)
				}
				return false
			}
			return true
		})
	
	fmt.Println("TestMuteUserHandler: PASSED")
}

func TestSaveMapHandler(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()


	// Give the clients some time to connect
	time.Sleep(5 * time.Second)


	req, err := http.NewRequest("GET", "http://localhost:5000/api/saveMap", nil)
	if err != nil {
		t.Fatal("Failed to create message request")
	}
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	fmt.Println("Saving Map")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal("Failed to execute message request")
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code 200, got %d", resp.StatusCode)
	}

	// Give the server some time to process the kick action
	time.Sleep(2 * time.Second)

	// Check if the map file was saved
	_, err = os.Stat("map.json")
	if os.IsNotExist(err) {
		t.Fatalf("Map file was not saved")
	} else if err != nil {
		t.Fatalf("Error checking map file: %v", err)
	}

	// Clean up the test map file
	err = os.Remove("map.json")
	if err != nil {
		t.Fatalf("Failed to clean up test map file: %v", err)
	}

	fmt.Println("TestSaveMapHandler: PASSED")
}

func TestLoadMapHandler(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()


	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	// Save a test map file
	err := os.WriteFile("map.json", []byte(`[[{"Type":"Empty","Clients":{}},{"Type":"Empty","Clients":{}},{"Type":"Empty","Clients":{}}]]`), 0644)
	if err != nil {
		t.Fatalf("Failed to create test map file: %v", err)
	}



	req, err := http.NewRequest("GET", "http://localhost:5000/api/loadMap", nil)
	if err != nil {
		t.Fatal("Failed to create message request")
	}
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	fmt.Println("Loading Map")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal("Failed to execute message request")
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code 200, got %d", resp.StatusCode)
	}

	// Give the server some time to process the kick action
	time.Sleep(2 * time.Second)

	// Clean up the test map file
	err = os.Remove("map.json")
	if err != nil {
		t.Fatalf("Failed to clean up test map file: %v", err)
	}

	fmt.Println("TestLoadMapHandler: PASSED")
}

func TestAddCellHandler(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	// Prepare the request payload
	payload := struct {
		X int `json:"x"`
		Y int `json:"y"`
	}{
		X: 250,
		Y: 250,
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("Failed to marshal payload: %v", err)
	}


	req, err := http.NewRequest("POST", "http://localhost:5000/api/addCell", bytes.NewBuffer(payloadBytes))
	if err != nil {
		t.Fatal("Failed to create message request")
	}
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	fmt.Println("Adding Cell")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal("Failed to execute message request")
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code 200, got %d", resp.StatusCode)
	}

	// Give the server some time to process the kick action
	time.Sleep(2 * time.Second)

	// Verify that the cell was added
	ok := grid[250][250]
	if ok == nil {
		t.Fatalf("Cell was not added at position (250, 250)")
	}
	
	fmt.Println("TestAddCellHandler: PASSED")
}

func TestDeleteCellHandler(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	// Prepare the request payload
	payload := struct {
		X int `json:"x"`
		Y int `json:"y"`
	}{
		X: 5,
		Y: 5,
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("Failed to marshal payload: %v", err)
	}


	req, err := http.NewRequest("POST", "http://localhost:5000/api/deleteCell", bytes.NewBuffer(payloadBytes))
	if err != nil {
		t.Fatal("Failed to create message request")
	}
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	fmt.Println("Adding Cell")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal("Failed to execute message request")
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code 200, got %d", resp.StatusCode)
	}

	// Give the server some time to process the kick action
	time.Sleep(2 * time.Second)

	// Verify that the cell has been deleted from the grid
	gridMutex.Lock()
	defer gridMutex.Unlock()
	if len(grid[0]) != gridWidth {
		t.Fatalf("The cell was not deleted from the grid")
	}

	fmt.Println("TestDeleteCellHandler: PASSED")
}

func TestKickUsersInCellHandler(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

    // Connect two clients
    conn1 := connectClient(t)
    defer conn1.Close()
    conn2 := connectClient(t)
    defer conn2.Close()


	loginTest(t, conn1, "testUser1")

	loginTest(t, conn2, "testUser2")

	
	checkUserJoinedReceived(t, conn1, "testUser2", "joined the chat!")


	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	// Prepare the request payload
	payload := struct {
		X int `json:"x"`
		Y int `json:"y"`
	}{
		X: 0,
		Y: 0,
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("Failed to marshal payload: %v", err)
	}


	req, err := http.NewRequest("POST", "http://localhost:5000/api/kickAllUsersInCell", bytes.NewBuffer(payloadBytes))
	if err != nil {
		t.Fatal("Failed to create message request")
	}
	
	// Set the RPG_AUTH header
	req.Header.Set("RPG_AUTH", createTestJWT())

	fmt.Println("Adding Cell")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal("Failed to execute message request")
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Expected status code 200, got %d", resp.StatusCode)
	}

	// Give the server some time to process the kick action
	time.Sleep(2 * time.Second)

	// Check if the clients are disconnected
	if _, ok := clients.Load("testUser1"); ok {
		t.Fatalf("Client 1 (%s) was not kicked from the server", "testUser1")
	}

	if _, ok := clients.Load("testUser2"); ok {
		t.Fatalf("Client 2 (%s) was not kicked from the server", "testUser2")
	}
	
	fmt.Println("TestDeleteCellHandler: PASSED")
}

func TestBroadcastSay(t *testing.T) {
	// Start the server in a separate goroutine
	go func() {
		err := startServer()
		if err != nil {
			t.Fatalf("Failed to start server: %v", err)
		}
	}()
	go startAPI()

    // Connect two clients
    conn1 := connectClient(t)
    defer conn1.Close()
    conn2 := connectClient(t)
    defer conn2.Close()


	loginTest(t, conn1, "testUser1")

	loginTest(t, conn2, "testUser2")

	
	checkUserJoinedReceived(t, conn1, "testUser2", "joined the chat!")

	// Give the clients some time to connect
	time.Sleep(5 * time.Second)

	// Send a message using the `/say` command from client1 to client2
	message := "hello"
	fmt.Fprintf(conn1, fmt.Sprintf("/say %s\n", message))

	// Read the response from client2
	responseString, err := bufio.NewReader(conn2).ReadString('\n')
	if err != nil {
		t.Fatalf("Failed to read server response: %v", err)
	}
	fmt.Println(responseString)
	// Unmarshal the response into a struct
	var response struct {
		Action   string `json:"action"`
		Username string `json:"username"`
		Message  string `json:"message"`
	}
	err = json.Unmarshal([]byte(responseString), &response)
	if err != nil {
		t.Fatalf("Error unmarshalling response: %v", err)
	}

	// Check if the response has the correct fields
	if response.Action != "say" || response.Username != "testUser1" || response.Message != message {
		t.Fatalf("Unexpected response: %v", response)
	}

	fmt.Println("TestBroadcastSay: PASSED")
}


