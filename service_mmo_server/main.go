package main

import (
	"bufio"
	"container/heap"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"os"
	"runtime"
	"strings"
	"sync"
	"time"

	//"github.com/dgrijalva/jwt-go"
	"github.com/golang-jwt/jwt"
	"github.com/joho/godotenv"
)

const (
	Empty CellType = "Empty"
	Mountain CellType = "Mountain"
	Grass CellType = "Grass"
	Water CellType = "Water"
)
var clients sync.Map
var channels sync.Map
const serverjwtSecret = "your_jwt_secret1"
var loadedUsers = make(map[string]LoadUserRequest)
var defaultSleepDelay = 3 * time.Second
const mapFilename = "map.json"
var grid [][]*Cell
var gridHeight = 25
var gridWidth = 25
const apijwtSecret = "your_jwt_secret2"
var gridMutex sync.RWMutex
var serverName = "TestServer1"
var stopChan chan struct{}

type client struct {
	conn     net.Conn
	username string
	channel    *channel
	muted    bool
	x        int
	y        int
	commandRateLimiter *rateLimiter
	sleepDelay time.Duration
	mutedUsernames map[string]bool
	kicked              bool
}

type ClientInfo struct {
	Username string `json:"username"`
	X        int    `json:"x"`
	Y        int    `json:"y"`
}

type addCellRequest struct {
	X    int      `json:"x"`
	Y    int      `json:"y"`
	Type CellType `json:"type"`
}

type CellType string

type travelClaims struct {
	jwt.StandardClaims
	ServerName string `json:"server_name"`
	Username   string `json:"username"`
}

type rateLimiter struct {
	tokens           int
	maxTokens        int
	tokenFillRate    time.Duration
	lastCheck        time.Time
}

type Cell struct {
	Type    CellType
	Clients sync.Map
}

type CellInfo struct {
	Type    CellType     `json:"type"`
	Clients []ClientInfo `json:"clients"`
	X		int			 `json:"x"`
	Y		int			 `json:"y"`
}

type deleteCellRequest struct {
	X int `json:"x"`
	Y int `json:"y"`
}


type sessionPayload struct {
	ServerName string `json:"server_name"`
	Username   string `json:"username"`
}

type HealthResponse struct {
	Status string `json:"status"`
}

type LoadUserRequest struct {
	Username string `json:"username"`
	X        int    `json:"x"`
	Y        int    `json:"y"`
}

type sendMessagePayload struct {
	FromUsername string `json:"from_username"`
	ToUsername   string `json:"to_username"`
	FromServer   string `json:"from_server"`
	Message      string `json:"message"`
}

type kickUsersInCellRequest struct {
	X int `json:"x"`
	Y int `json:"y"`
}

type moveUserPayload struct {
	Username string `json:"username"`
	X        int    `json:"x"`
	Y        int    `json:"y"`
}

type channel struct {
	name    string
	title   string
	clients sync.Map
}

type cellInfo struct {
	X, Y int
}

type priorityQueueItem struct {
	value    cellInfo
	priority int
	index    int
}

type priorityQueue []*priorityQueueItem


func init() {
	// Check if the map file exists
	if _, err := os.Stat(mapFilename); os.IsNotExist(err) {
		// If the file does not exist, generate a new map
		fmt.Println("Creating a empty Map, since no map was found..")
		initGrid()
	} else {
		// If the file exists, load the map from the file
		loadedGrid, err := loadMap(mapFilename)
		if err != nil {
			fmt.Printf("Error loading map from file: %v\n", err)
			return
		}
		grid = loadedGrid
	}
	
	// Load the .env file
	err := godotenv.Load()
	if err != nil {
		fmt.Println("Error loading .env file:", err)
	}

	// Get the SERVER_NAME variable
	serverName := os.Getenv("SERVER_NAME")
	if serverName == "" {
		fmt.Println("SERVER_NAME not set, using default value")
		serverName = "default_server"
	}

	// Get the API_SECRET variable
	apijwtSecret := os.Getenv("API_SECRET")
	if apijwtSecret == "" {
		fmt.Println("API_SECRET not set, using default value")
		apijwtSecret = "default_api_secret"
	}

	// Get the SERVER_SECRET variable
	serverjwtSecret := os.Getenv("SERVER_SECRET")
	if serverjwtSecret == "" {
		fmt.Println("SERVER_SECRET not set, using default value")
		serverjwtSecret = "default_server_secret"
	}


}

func main() {
    stopChan = make(chan struct{})

	go startAPI()

	os := runtime.GOOS
    switch os {
    case "windows":
        fmt.Println("Windows not setting max open files limit.")
    default:
		// Set the maximum number of open files allowed by the system
		/*
		err := setMaxOpenFiles(2048)
		if err != nil {
			fmt.Printf("Error setting max open files limit: %v\n", err)
			return
		}
		*/
    }

	
	err := startServer()
	if err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}

    // Wait for a stop signal
    <-stopChan
}

func startServer() error {
	ln, err := net.Listen("tcp", ":6000")
	if err != nil {
		return fmt.Errorf("failed to listen: %v", err)
	}
	fmt.Println("Starting MMO server on :6000")
	defer ln.Close()

	for {
		select {
		case <-stopChan:
			break
		default:
			conn, err := ln.Accept()
			if err != nil {
				log.Printf("Failed to accept connection: %v\n", err)
				continue
			}
			go handleConnection(conn)
		}
	}
}

/*
func setMaxOpenFiles(limit uint64) error {
	var rLimit syscall.Rlimit
	err := syscall.Getrlimit(syscall.RLIMIT_NOFILE, &rLimit)
	if err != nil {
		return err
	}

	rLimit.Cur = rLimit.Max
	err = syscall.Setrlimit(syscall.RLIMIT_NOFILE, &rLimit)
	if err != nil {
		return err
	}

	return nil
}
*/

func handleConnection(conn net.Conn) {
	defer conn.Close()

	reader := bufio.NewReader(conn)

	input, err := reader.ReadString('\n')
	if err != nil {
		fmt.Println("Error reading input:", err)
		return
	}

	input = input[:len(input)-1] // Remove the newline character

	fmt.Println(input)

	// Try to decode the input as a session token
	serverName, username, err := decodeSessionToken(input)
	if err != nil {
		// If decoding fails, treat the input as a regular username
		username = input
	}

	cli := &client{
		conn:     conn,
		username: username,
		commandRateLimiter: newRateLimiter(5, time.Second),
		sleepDelay: defaultSleepDelay,
		mutedUsernames: make(map[string]bool),
	}
	clients.Store(cli.username, cli)
	if loadedUser, ok := loadedUsers[username]; ok {
		addToGridDirectly(cli, loadedUser.X, loadedUser.Y)
		delete(loadedUsers, username)
	} else {
		fmt.Println("Not a Loaded User, adding directly to Grid")
		addToGridDirectly(cli, 0, 0)
	}

	fmt.Println("Announcing the Map to the Client")
	announceMap(cli)

	if serverName != "" {
		announceEventJSON(cli, cli.username, "transferred", fmt.Sprintf("transferred from %s and joined the chat!", serverName))
	} else {
		announceEventJSON(cli, cli.username, "joined", "joined the chat!")
	}

	defer func() {
		clients.Delete(cli.username)
		if !cli.kicked {
			announceEventJSON(cli, cli.username, "left", "left the chat!")
		} else {
			fmt.Println("User was kicked from the Server")
		}
	}()

	for {
		msg, err := reader.ReadString('\n')
		if err != nil {
			break
		}

		// Check if the message starts with the command prefix
		if len(msg) > 0 && msg[0] == '/' {
			handleCommand(cli, msg)
		} else {
			echo(cli, msg)
		}
	}
}

func announce(cli *client, action string) {
	msg := fmt.Sprintf("%s %s\n", cli.username, action)

	clients.Range(func(_, v interface{}) bool {
		client := v.(*client)
		if client.username != cli.username {
			client.conn.Write([]byte(msg))
		}
		return true
	})
}

func echo(cli *client, msg string) {
	if cli.muted {
		cli.conn.Write([]byte("You are muted and cannot send messages.\n"))
		return
	}

	if cli.channel != nil {
		chatChannel(cli, msg)
	} else {
		response := fmt.Sprintf("%s: %s", cli.username, msg)
		cli.conn.Write([]byte(response))
	}
}

func broadcast(cli *client) {
	msg := fmt.Sprintf("%s has requested a broadcast!\n", cli.username)

	clients.Range(func(_, v interface{}) bool {
		client := v.(*client)
		client.conn.Write([]byte(msg))
		return true
	})
}

func handleCommand(cli *client, msg string) {
	if !cli.commandRateLimiter.isAllowed() {
		cli.conn.Write([]byte("You are sending commands too fast. Please slow down.\n"))
		return
	}
	// Remove the newline character and command prefix
	msg = msg[1 : len(msg)-1]

	args := strings.Split(msg, " ")
	command := args[0]

	switch command {
	case "say":
		if len(args) < 2 {
			cli.conn.Write([]byte("Usage: /say [message]\n"))
		} else {
			message := strings.Join(args[1:], " ")
			broadcastSay(cli, message)
		}
		/*
	case "msg":
		if len(args) < 3 {
			cli.conn.Write([]byte("Usage: /msg [username] [message]\n"))
		} else {
			targetUsername := args[1]
			message := strings.Join(args[2:], " ")
			privateMessage(cli, targetUsername, message)
		}
	case "list":
		listUsers(cli)
	case "mute":
		if len(args) < 2 {
			cli.conn.Write([]byte("Usage: /mute [username]\n"))
		} else {
			mute(cli, args)
		}
	case "unmute":
		if len(args) < 2 {
			cli.conn.Write([]byte("Usage: /unmute [username]\n"))
		} else {
			unmute(cli, args)
		}
	case "create":
		if len(args) < 2 {
			cli.conn.Write([]byte("Usage: /create [channel_name]\n"))
		} else {
			channelName := args[1]
			createChannel(cli, channelName)
		}
	case "join":
		if len(args) < 2 {
			cli.conn.Write([]byte("Usage: /join [channel_name]\n"))
		} else {
			channelName := args[1]
			joinChannel(cli, channelName)
		}
	case "part":
		partChannel(cli)
	case "setChannelTitle":
		if len(args) < 2 {
			cli.conn.Write([]byte("Usage: /setChannelTitle [title]\n"))
		} else {
			title := strings.Join(args[1:], " ")
			setChannelTitle(cli, title)
		}
		*/
	case "north":
		moveClient(cli, 0, -1)
	case "east":
		moveClient(cli, 1, 0)
	case "south":
		moveClient(cli, 0, 1)
	case "west":
		moveClient(cli, -1, 0)
		/*
	case "travel":
		jwt, err := generateJWT(serverName, cli.username)
		if err != nil {
			cli.conn.Write([]byte("Error generating travel token.\n"))
			return
		}
		response := fmt.Sprintf("Travel token: %s\n", jwt)
		cli.conn.Write([]byte(response))
		
	case "whisper":
		if len(args) < 3 {
			cli.conn.Write([]byte("Usage: /whisper [username] [message]\n"))
		} else {
			targetUsername := args[1]
			message := strings.Join(args[2:], " ")
			whisper(cli, targetUsername, message)
		}
	case "moveTo":
		if len(args) < 3 {
			cli.conn.Write([]byte("Usage: /moveTo [x] [y]\n"))
		} else {
			x, err1 := strconv.Atoi(args[1])
			y, err2 := strconv.Atoi(args[2])
			if err1 != nil || err2 != nil {
				cli.conn.Write([]byte("Invalid coordinates. Please enter integers.\n"))
			} else {
				moveTo(cli, x, y, cli.sleepDelay)
			}
		}
		*/
	case "help":
		help(cli)
	default:
		response := fmt.Sprintf("Unknown command: /%s\n", msg)
		cli.conn.Write([]byte(response))
	}
}

func listUsers(cli *client) {
	cli.conn.Write([]byte("Connected users:\n"))

	clients.Range(func(_, v interface{}) bool {
		client := v.(*client)
		cli.conn.Write([]byte(fmt.Sprintf(" - %s\n", client.username)))
		return true
	})
}

func privateMessage(cli *client, targetUsername, message string) {
	targetClient, ok := clients.Load(targetUsername)
	if !ok {
		response := fmt.Sprintf("User '%s' not found.\n", targetUsername)
		cli.conn.Write([]byte(response))
		return
	}

	response := fmt.Sprintf("(Private) %s: %s\n", cli.username, message)
	targetClient.(*client).conn.Write([]byte(response))
}

func muteUserGlobal(cli *client, targetUsername string) {
	targetClient, ok := clients.Load(targetUsername)
	if !ok {
		response := fmt.Sprintf("User '%s' not found.\n", targetUsername)
		cli.conn.Write([]byte(response))
		return
	}

	targetClient.(*client).muted = true
	response := fmt.Sprintf("You have muted '%s'.\n", targetUsername)
	cli.conn.Write([]byte(response))
}

func unmuteUserGlobal(cli *client, targetUsername string) {
	targetClient, ok := clients.Load(targetUsername)
	if !ok {
		response := fmt.Sprintf("User '%s' not found.\n", targetUsername)
		cli.conn.Write([]byte(response))
		return
	}

	targetClient.(*client).muted = false
	response := fmt.Sprintf("You have unmuted '%s'.\n", targetUsername)
	cli.conn.Write([]byte(response))
}

func createChannel(cli *client, channelName string) {
	_, ok := channels.Load(channelName)
	if ok {
		cli.conn.Write([]byte("Channel already exists.\n"))
		return
	}

	newChannel := &channel{
		name: channelName,
	}
	channels.Store(channelName, newChannel)
	response := fmt.Sprintf("Channel '%s' created.\n", channelName)
	cli.conn.Write([]byte(response))
}

func joinChannel(cli *client, channelName string) {
	newChannel, ok := channels.Load(channelName)
	if !ok {
		cli.conn.Write([]byte("Channel not found.\n"))
		return
	}

	if cli.channel != nil {
		cli.channel.clients.Delete(cli.username)
	}
	newChannel.(*channel).clients.Store(cli.username, cli)
	cli.channel = newChannel.(*channel)
	response := fmt.Sprintf("You have joined the channel '%s'.\n", channelName)
	cli.conn.Write([]byte(response))
}

func partChannel(cli *client) {
	if cli.channel == nil {
		cli.conn.Write([]byte("You are not in any channel.\n"))
		return
	}

	channelName := cli.channel.name
	cli.channel.clients.Delete(cli.username)
	cli.channel = nil
	response := fmt.Sprintf("You have left the channel '%s'.\n", channelName)
	cli.conn.Write([]byte(response))
}

func chatChannel(cli *client, msg string) {
	if cli.channel == nil {
		cli.conn.Write([]byte("You are not in any channel.\n"))
		return
	}

	response := fmt.Sprintf("[#%s] %s: %s", cli.channel.name, cli.username, msg)
	cli.channel.clients.Range(func(_, v interface{}) bool {
		client := v.(*client)
		if client.username != cli.username {
			client.conn.Write([]byte(response))
		}
		return true
	})
}

func setChannelTitle(cli *client, title string) {
	if cli.channel == nil {
		cli.conn.Write([]byte("You are not in any channel.\n"))
		return
	}

	cli.channel.title = title
	response := fmt.Sprintf("Channel title set to '%s'.\n", title)
	cli.conn.Write([]byte(response))
}

func moveClient(cli *client, dx, dy int) {
	newX, newY := cli.x+dx, cli.y+dy

	if newX < 0 || newX >= gridWidth || newY < 0 || newY >= gridHeight {
		sendJSON(cli.conn, map[string]interface{}{
			"type": "error",
			"msg":  "You cannot move outside the grid",
		})
		return
	}

	newCell := grid[newY][newX]
	switch newCell.Type {
	case Empty:
		removeFromGrid(cli)
		cli.x, cli.y = newX, newY
		addToGrid(cli)
		response := struct {
			Action string `json:"action"`
			Username string `json:"username"`
			X      int    `json:"x"`
			Y      int    `json:"y"`
		}{
			Action: "move",
			Username: cli.username,
			X:      newX,
			Y:      newY,
		}
	
		jsonResponse, err := json.Marshal(response)
		if err != nil {
			cli.conn.Write([]byte("Error generating move response.\n"))
			return
		}
	
		cli.conn.Write(append(jsonResponse, '\n'))
		broadcastLocation(cli)
	case Mountain:
		sendJSON(cli.conn, map[string]interface{}{
			"type": "error",
			"msg":  "You cannot move onto a mountain",
		})
	default:
		sendJSON(cli.conn, map[string]interface{}{
			"type": "error",
			"msg":  "You cannot move to that location",
		})
	}
}

func removeFromGrid(cli *client) {
	cell := grid[cli.y][cli.x]
	cell.Clients.Delete(cli.username)
}

func addToGrid(cli *client) {
	cell := grid[cli.y][cli.x]
	cell.Clients.Store(cli.username, cli)
}

func addToGridDirectly(cli *client, x int, y int) {
	fmt.Printf("Adding to Grid X(%d) Y(%d)\n", x, y)

	// Check if y is within the grid bounds
	if y < 0 || y >= len(grid) {
		fmt.Printf("Error: Y coordinate (%d) is out of range\n", y)
		return
	}

	// Check if x is within the grid bounds
	if x < 0 || x >= len(grid[y]) {
		fmt.Printf("Error: X coordinate (%d) is out of range\n", x)
		return
	}

	cell := grid[y][x]
	cell.Clients.Store(cli.username, cli)
}

func announceMap(cli *client) {
	gridInfo := make([][]CellInfo, len(grid))
	for i := range grid {
		gridInfo[i] = make([]CellInfo, len(grid[i]))
		for j := range grid[i] {
			cellInfo := CellInfo{
				Type:    grid[i][j].Type,
				Clients: []ClientInfo{},
			}

			grid[i][j].Clients.Range(func(_, v interface{}) bool {
				client := v.(*client)
				cellInfo.Clients = append(cellInfo.Clients, ClientInfo{
					Username: client.username,
					X:        client.x,
					Y:        client.y,
				})
				return true
			})

			gridInfo[i][j] = cellInfo
		}
	}

	payload := struct {
		Action       string    `json:"action"`
		Map [][]CellInfo `json:"map"`
	}{
		Action:       "map",
		Map: gridInfo,
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		fmt.Println("Error marshaling grid data:", err)
		return
	}

	cli.conn.Write(append(jsonData, '\n'))
}

func generateJWT(serverName, username string) (string, error) {
	claims := &travelClaims{
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(time.Hour * 1).Unix(),
		},
		ServerName: serverName,
		Username:   username,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(serverjwtSecret))
}

func newRateLimiter(maxTokens int, fillRate time.Duration) *rateLimiter {
	return &rateLimiter{
		tokens:           maxTokens,
		maxTokens:        maxTokens,
		tokenFillRate:    fillRate,
		lastCheck:        time.Now(),
	}
}

func (rl *rateLimiter) isAllowed() bool {
	now := time.Now()
	elapsedTime := now.Sub(rl.lastCheck)
	rl.tokens += int(elapsedTime / rl.tokenFillRate)
	if rl.tokens > rl.maxTokens {
		rl.tokens = rl.maxTokens
	}
	rl.lastCheck = now

	if rl.tokens > 0 {
		rl.tokens--
		return true
	}

	return false
}

func broadcastLocation(cli *client) {
	response := struct {
		Action   string `json:"action"`
		Username string `json:"username"`
		X        int    `json:"x"`
		Y        int    `json:"y"`
	}{
		Action:   "user_moved",
		Username: cli.username,
		X:        cli.x,
		Y:        cli.y,
	}

	jsonResponse, err := json.Marshal(response)
	if err != nil {
		return
	}

	clients.Range(func(_, v interface{}) bool {
		client := v.(*client)
		if client.username != cli.username {
			client.conn.Write(append(jsonResponse, '\n'))
		}
		return true
	})
}

func broadcastSay(cli *client, message string) {
	response := struct {
		Action   string `json:"action"`
		Username string `json:"username"`
		Message string `json:"message"`
	}{
		Action:   "say",
		Username: cli.username,
		Message: message,
	}

	jsonResponse, err := json.Marshal(response)
	if err != nil {
		return
	}

	clients.Range(func(_, v interface{}) bool {
		client := v.(*client)
		if client.username != cli.username {
			client.conn.Write(append(jsonResponse, '\n'))
		}
		return true
	})
}

func (pq priorityQueue) Len() int { return len(pq) }

func (pq priorityQueue) Less(i, j int) bool {
	return pq[i].priority < pq[j].priority
}

func (pq priorityQueue) Swap(i, j int) {
	pq[i], pq[j] = pq[j], pq[i]
	pq[i].index = i
	pq[j].index = j
}

func (pq *priorityQueue) Push(x interface{}) {
	n := len(*pq)
	item := x.(*priorityQueueItem)
	item.index = n
	*pq = append(*pq, item)
}

func (pq *priorityQueue) Pop() interface{} {
	old := *pq
	n := len(old)
	item := old[n-1]
	old[n-1] = nil
	item.index = -1
	*pq = old[0 : n-1]
	return item
}

func aStarPathfinding(start, target cellInfo, grid *[][]*Cell) []cellInfo {
	// Initialize the priority queue with the starting position
	pq := &priorityQueue{}
	heap.Init(pq)
	heap.Push(pq, &priorityQueueItem{value: start, priority: 0})

	// Create maps to store the cost to move to a cell and the path from the starting cell
	costs := make(map[cellInfo]int)
	costs[start] = 0
	from := make(map[cellInfo]cellInfo)

	// Define a helper function to calculate the heuristic (Manhattan distance) between two cells
	heuristic := func(a, b cellInfo) int {
		return abs(a.X-b.X) + abs(a.Y-b.Y)
	}

	for pq.Len() > 0 {
		current := heap.Pop(pq).(*priorityQueueItem).value

		// If the target is reached, build the path and return it
		if current == target {
			path := []cellInfo{}
			for current != start {
				path = append([]cellInfo{current}, path...)
				current = from[current]
			}
			return path
		}

		neighbors := []cellInfo{
			{current.X - 1, current.Y},
			{current.X + 1, current.Y},
			{current.X, current.Y - 1},
			{current.X, current.Y + 1},
		}

		for _, neighbor := range neighbors {
			// Skip if the neighbor is out of bounds or is not an "Empty" cell
			if neighbor.X < 0 || neighbor.Y < 0 || neighbor.X >= len(*grid) || neighbor.Y >= len((*grid)[0]) || (*grid)[neighbor.X][neighbor.Y].Type != "Empty" {
				continue
			}

			newCost := costs[current] + 1
			if cost, ok := costs[neighbor]; !ok || newCost < cost {
				costs[neighbor] = newCost
				priority := newCost + heuristic(neighbor, target)
				heap.Push(pq, &priorityQueueItem{value: neighbor, priority: priority})
				from[neighbor] = current
			}
		}
	}
	// If the target is not reached, return an empty path
	return []cellInfo{}
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func whisper(cli *client, targetUsername, message string) {
	targetClient, ok := clients.Load(targetUsername)
	if !ok {
		response := fmt.Sprintf("User '%s' not found.\n", targetUsername)
		cli.conn.Write([]byte(response))
		return
	}

	whisperMessage := map[string]interface{}{
		"type":     "whisper",
		"from":     cli.username,
		"message":  message,
	}
	jsonData, err := json.Marshal(whisperMessage)
	if err != nil {
		cli.conn.Write([]byte("Error encoding JSON.\n"))
		return
	}

	targetClient.(*client).conn.Write(jsonData)
	cli.conn.Write([]byte("Message sent.\n"))
}

func decodeSessionToken(token string) (string, string, error) {
	decoded, err := base64.StdEncoding.DecodeString(token)
	if err != nil {
		return "", "", err
	}

	var payload sessionPayload
	err = json.Unmarshal(decoded, &payload)
	if err != nil {
		return "", "", err
	}

	if payload.ServerName == "" || payload.Username == "" {
		return "", "", errors.New("invalid session payload")
	}

	return payload.ServerName, payload.Username, nil
}

func initGrid() {
	grid = make([][]*Cell, gridHeight)
	for i := range grid {
		grid[i] = make([]*Cell, gridWidth)
		for j := range grid[i] {
			grid[i][j] = &Cell{
				Type:    Empty, // Assign the default type for now
				Clients: sync.Map{},
			}
		}
	}
}

func help(cli *client) {
	helpMessages := []map[string]string{
		{"command": "/help", "description": "Show this help message."},
		{"command": "/whisper [username] [message]", "description": "Send a private message to the specified user."},
		{"command": "/list", "description": "List all connected users."},
		{"command": "/mute [username]", "description": "Mute the specified user."},
		{"command": "/unmute [username]", "description": "Unmute the specified user."},
		{"command": "/move [direction]", "description": "Move to an adjacent cell in the specified direction (north, east, south, or west)."},
		{"command": "/travel", "description": "Generate a JWT to travel to another server."},
		{"command": "/map", "description": "Show the current 2D grid map."},
	}

	helpData := map[string]interface{}{
		"type":    "help",
		"commands": helpMessages,
	}
	jsonData, err := json.Marshal(helpData)
	if err != nil {
		cli.conn.Write([]byte("Error encoding JSON.\n"))
		return
	}

	cli.conn.Write(jsonData)
}

// Save the map to a JSON file.
func saveMap(grid [][]*Cell, filename string) error {
	jsonData, err := json.Marshal(grid)
	if err != nil {
		return err
	}

	err = ioutil.WriteFile(filename, jsonData, 0644)
	if err != nil {
		return err
	}

	return nil
}

// Load the map from a JSON file.
func loadMap(filename string) ([][]*Cell, error) {
	jsonFile, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer jsonFile.Close()

	byteValue, err := ioutil.ReadAll(jsonFile)
	if err != nil {
		return nil, err
	}

	var grid [][]*Cell
	err = json.Unmarshal(byteValue, &grid)
	if err != nil {
		return nil, err
	}

	return grid, nil
}

func moveTo(cli *client, targetX, targetY int, sleepDelay time.Duration) {
	start := cellInfo{X: cli.x, Y: cli.y}
	target := cellInfo{X: targetX, Y: targetY}

	path := aStarPathfinding(start, target, &grid)

	if len(path) == 0 {
		cli.conn.Write([]byte("{\"type\":\"move_error\", \"message\":\"Path not found.\"}\n"))
		return
	}

	go func() {
		for _, step := range path {
			time.Sleep(sleepDelay)

			cli.x = step.X
			cli.y = step.Y

			response := fmt.Sprintf("{\"type\":\"move\", \"username\":\"%s\", \"position\":{\"x\":%d, \"y\":%d}}\n", cli.username, cli.x, cli.y)
			announceMove(cli, response)
		}
	}()
}

func announceMove(cli *client, msg string) {
	clients.Range(func(_, v interface{}) bool {
		client := v.(*client)
		client.conn.Write([]byte(msg))
		return true
	})
}

func sendJSON(conn net.Conn, data interface{}) {
	jsonData, err := json.Marshal(data)
	if err != nil {
		fmt.Println("Error marshaling JSON data:", err)
		return
	}
	conn.Write(append(jsonData, '\n'))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{Status: "OK"}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func loadUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, jwterr := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if jwterr != nil || !token.Valid {
		fmt.Println("Invalid Token was received")
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	var req LoadUserRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	loadedUsers[req.Username] = req
	w.WriteHeader(http.StatusOK)
}

func startAPI() {
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/healthz", healthHandler)
	http.HandleFunc("/api/loadUser", loadUserHandler)
	http.HandleFunc("/api/kickUser", kickUserHandler)
	http.HandleFunc("/api/sendAnnouncement", sendAnnouncementHandler)
	http.HandleFunc("/api/kickAllUsers", kickAllUsersHandler)
	http.HandleFunc("/api/sendMessageToUser", sendMessageToUserHandler)
	http.HandleFunc("/api/moveUser", moveUserHandler)
	http.HandleFunc("/api/sendMessageToCell", sendMessageToCellHandler)
	http.HandleFunc("/api/muteUser", muteUserHandler)
	http.HandleFunc("/api/saveMap", saveMapHandler)
	http.HandleFunc("/api/loadMap", loadMapHandler)
	http.HandleFunc("/api/addCell", addCellHandler)
	http.HandleFunc("/api/deleteCell", deleteCellHandler)
	http.HandleFunc("/api/kickAllUsersInCell", kickUsersInCellHandler)


	fmt.Println("Starting API server on :5000")
	http.ListenAndServe(":5000", nil)
}

func kickUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, jwterr := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if jwterr != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	var req struct {
		Username string `json:"username"`
	}
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	kicked := false

	// Iterate over the clients sync.Map to find the user and disconnect them
	clients.Range(func(_, v interface{}) bool {
		cli := v.(*client)
		if cli.username == req.Username {
			cli.kicked = true
			// Send "you have been kicked" message to the kicked user
			sendJSON(cli.conn, map[string]string{
				"action":  "kicked",
				"message": "You have been kicked.",
			})

			cli.conn.Close()
			kicked = true
			return false
		}
		return true
	})

	// Send an announcement to all connected clients that the user has been kicked
	if kicked {
		announcement := map[string]string{
			"action":   "announcement",
			"username": req.Username,
			"message":  "has been kicked from the server.",
		}
		clients.Range(func(_, v interface{}) bool {
			cli := v.(*client)
			sendJSON(cli.conn, announcement)
			return true
		})

		w.WriteHeader(http.StatusOK)
	} else {
		w.WriteHeader(http.StatusNotFound)
	}
}

func sendAnnouncementHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, jwterr := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if jwterr != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	var req struct {
		Message string `json:"message"`
	}
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	announcement := struct {
		Action  string `json:"action"`
		Message string `json:"message"`
	}{
		Action:  "announcement",
		Message: req.Message,
	}

	// Broadcast the message to all connected clients
	clients.Range(func(_, v interface{}) bool {
		cli := v.(*client)
		sendJSON(cli.conn, announcement)
		return true
	})

	w.WriteHeader(http.StatusOK)
}

func kickAllUsersHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, err := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if err != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Iterate over the clients sync.Map and disconnect all users
	clients.Range(func(_, v interface{}) bool {
		cli := v.(*client)
		cli.conn.Close()
		return true
	})

	w.WriteHeader(http.StatusOK)
}

func sendMessageToUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, jwterr := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if jwterr != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	decoder := json.NewDecoder(r.Body)
	var payload sendMessagePayload
	err := decoder.Decode(&payload)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	toClient, ok := clients.Load(payload.ToUsername)
	if !ok {
		w.WriteHeader(http.StatusNotFound)
		return
	}

	toCli := toClient.(*client)
	sendJSON(toCli.conn, map[string]interface{}{
		"action":       "private_message",
		"from":       payload.FromUsername,
		"fromServer": payload.FromServer,
		"to": payload.ToUsername,
		"message":    payload.Message,
	})

	w.WriteHeader(http.StatusOK)
}

func moveUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, jwterr := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if jwterr != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	decoder := json.NewDecoder(r.Body)
	var payload moveUserPayload
	err := decoder.Decode(&payload)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	cli, ok := clients.Load(payload.Username)
	if !ok {
		w.WriteHeader(http.StatusNotFound)
		return
	}

	client := cli.(*client)

	//if !isValidMove(client.x, client.y, payload.X, payload.Y) {
	//	w.WriteHeader(http.StatusBadRequest)
	//	return
	//}

	// Move the user and announce to all connected clients
	moveClient(client, payload.X, payload.Y)

	w.WriteHeader(http.StatusOK)
}

func isValidMove(currentX, currentY, targetX, targetY int) bool {
	// Check if the target coordinates are within the grid boundaries
	if targetX < 0 || targetY < 0 || targetX >= len(grid) || targetY >= len(grid[0]) {
		return false
	}

	// Check if the target cell is not a mountain cell
	if grid[targetX][targetY].Type != Empty {
		return false
	}

	// Check if the movement is a valid adjacent cell (horizontal or vertical only)
	if abs(currentX-targetX)+abs(currentY-targetY) == 1 {
		return true
	}

	return false
}

func sendMessageToCellHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, jwterr := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if jwterr != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Parse JSON payload
	var payload struct {
		X       int    `json:"x"`
		Y       int    `json:"y"`
		Message string `json:"message"`
	}
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&payload)
	if err != nil {
		http.Error(w, "Invalid JSON payload", http.StatusBadRequest)
		return
	}

	// Check if coordinates are within the grid bounds
	if payload.X < 0 || payload.Y < 0 || payload.X >= len(grid) || payload.Y >= len(grid[0]) {
		http.Error(w, "Coordinates out of bounds", http.StatusBadRequest)
		return
	}

	// Get the cell at the specified coordinates
	cell := grid[payload.X][payload.Y]

	// Send the message to all clients in the cell
	cell.Clients.Range(func(_, v interface{}) bool {
		cli := v.(*client)
		jsonMessage := map[string]string{"action": "cell_message", "message": payload.Message}
		sendJSON(cli.conn, jsonMessage)
		return true
	})
}

func mute(cli *client, args []string) {
	if len(args) < 2 {
		sendJSON(cli.conn, map[string]string{"type": "error", "message": "Usage: /mute <username>"})
		return
	}

	targetUsername := args[1]

	if _, ok := cli.mutedUsernames[targetUsername]; ok {
		sendJSON(cli.conn, map[string]string{"type": "error", "message": fmt.Sprintf("%s already exists in the muted users", targetUsername)})
	} else {
		cli.mutedUsernames[targetUsername] = true
		sendJSON(cli.conn, map[string]string{"type": "success", "message": fmt.Sprintf("Muted %s", targetUsername)})
	}
}

func unmute(cli *client, args []string) {
	if len(args) < 2 {
		sendJSON(cli.conn, map[string]string{"type": "error", "message": "Usage: /mute <username>"})
		return
	}

	targetUsername := args[1]

	if _, ok := cli.mutedUsernames[targetUsername]; ok {
		delete(cli.mutedUsernames, targetUsername)
		sendJSON(cli.conn, map[string]string{"type": "success", "message": fmt.Sprintf("Unmuted %s", targetUsername)})
	} else {
		sendJSON(cli.conn, map[string]string{"type": "error", "message": fmt.Sprintf("%s is not in the mute list to unmute", targetUsername)})
	}
}

func muteUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, err := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if err != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Parse JSON payload
	var payload struct {
		Username string `json:"username"`
	}
	decoder := json.NewDecoder(r.Body)
	perr := decoder.Decode(&payload)
	if perr != nil {
		http.Error(w, "Invalid JSON payload", http.StatusBadRequest)
		return
	}

	if payload.Username == "" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Missing username parameter"))
		return
	}

	var userFound bool

	clients.Range(func(_, v interface{}) bool {
		client := v.(*client)
		if client.username == payload.Username {
			client.muted = true
			userFound = true
			return false
		}
		return true
	})

	if userFound {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("User muted"))
	} else {
		w.WriteHeader(http.StatusNotFound)
		w.Write([]byte("User not found"))
	}
}

func saveMapHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, jwterr := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if jwterr != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	err := saveMap(grid, "map.json")
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(fmt.Sprintf("Error saving map: %v", err)))
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Map saved"))
}

func loadMapHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, jwterr := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if jwterr != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	newGrid, err := loadMap("map.json")
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(fmt.Sprintf("Error loading map: %v", err)))
		return
	}

	gridMutex.Lock()
	grid = newGrid
	gridMutex.Unlock()

	clients.Range(func(_, v interface{}) bool {
		client := v.(*client)

		// Check if the new cell is empty
		if grid[client.x][client.y].Type != Empty {
			// If not, find an adjacent empty cell
			adjacentEmpty := false
			for dx := -1; dx <= 1; dx++ {
				for dy := -1; dy <= 1; dy++ {
					newX, newY := client.x+dx, client.y+dy

					if newX >= 0 && newX < len(grid) && newY >= 0 && newY < len(grid[0]) && grid[newX][newY].Type == Empty {
						client.x, client.y = newX, newY
						adjacentEmpty = true
						break
					}
				}
				if adjacentEmpty {
					break
				}
			}
			// If no adjacent empty cell is found, notify the client
			if !adjacentEmpty {
				client.conn.Write([]byte("Your position could not be updated due to an obstacle. Please reconnect.\n"))
				client.conn.Close()
				return true
			}
		}

		announceMap(client)
		return true
	})

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Map loaded and announced to clients"))
}

func addCellHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, jwterr := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if jwterr != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	var req addCellRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid request payload"))
		return
	}

	gridMutex.Lock()
	defer gridMutex.Unlock()

	// Check if the cell already exists
	if req.X >= 0 && req.X < len(grid) && req.Y >= 0 && req.Y < len(grid[req.X]) {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Cell already exists"))
		return
	}

	// Extend the grid to accommodate the new cell
	if req.X >= len(grid) {
		for i := len(grid); i <= req.X; i++ {
			grid = append(grid, []*Cell{})
		}
	}

	for i := range grid {
		for j := len(grid[i]); j <= req.Y; j++ {
			grid[i] = append(grid[i], &Cell{
				Type:    Empty,
				Clients: sync.Map{},
			})
		}
	}

	// Add the new cell
	grid[req.X][req.Y] = &Cell{
		Type:    req.Type,
		Clients: sync.Map{},
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Cell added successfully"))
}

func findEmptyAdjacentCell(x, y int) (int, int) {
	directions := [][2]int{{0, 1}, {1, 0}, {0, -1}, {-1, 0}}
	for _, d := range directions {
		newX := x + d[0]
		newY := y + d[1]
		if newX >= 0 && newX < len(grid) && newY >= 0 && newY < len(grid[newX]) && grid[newX][newY].Type == Empty {
			return newX, newY
		}
	}
	return -1, -1
}

func deleteCellHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, jwterr := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if jwterr != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	var req deleteCellRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid request payload"))
		return
	}

	gridMutex.Lock()
	defer gridMutex.Unlock()

	if req.X < 0 || req.X >= len(grid) || req.Y < 0 || req.Y >= len(grid[req.X]) {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Cell does not exist"))
		return
	}

	cell := grid[req.X][req.Y]
	cell.Clients.Range(func(_, v interface{}) bool {
		client := v.(*client)
		newX, newY := findEmptyAdjacentCell(req.X, req.Y)
		if newX != -1 && newY != -1 {
			moveClient(client, newX, newY)
		} else {
			// If no empty adjacent cell is found, disconnect the client
			client.conn.Close()
		}
		return true
	})

	grid[req.X] = append(grid[req.X][:req.Y], grid[req.X][req.Y+1:]...)

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Cell deleted successfully"))
}

func kickUsersInCellHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	rpgAuthHeader := r.Header.Get("RPG_AUTH")
	if rpgAuthHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// Decode and verify the JWT
	token, jwterr := jwt.Parse(rpgAuthHeader, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(apijwtSecret), nil
	})

	if jwterr != nil || !token.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	var req kickUsersInCellRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Invalid request payload"))
		return
	}

	gridMutex.Lock()
	defer gridMutex.Unlock()

	if req.X < 0 || req.X >= len(grid) || req.Y < 0 || req.Y >= len(grid[req.X]) {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Cell does not exist"))
		return
	}

	cell := grid[req.X][req.Y]
	cell.Clients.Range(func(_, v interface{}) bool {
		client := v.(*client)
		client.conn.Close()
		return true
	})

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("All users in the cell have been kicked"))
}

func stopServer() {
    close(stopChan)
}

func announceEventJSON(cli *client, username, action, message string) {
	announcement := struct {
		Action  string `json:"action"`
		Username string `json:"username"`
		Message string `json:"message"`
	}{
		Action:  action,
		Username:  username,
		Message: message,
	}

	clients.Range(func(_, v interface{}) bool {
		otherClient := v.(*client)
		if otherClient != cli {
			sendJSON(otherClient.conn, announcement)
		}
		return true
	})
}

