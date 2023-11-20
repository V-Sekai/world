# Websocket Authentication with Google and Discord

This is a sample Go application that demonstrates the use of websockets for client authentication with Google and Discord OAuth2.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [Go](https://golang.org/dl/)
- [A Google Cloud Platform account](https://cloud.google.com/)
- [A Discord Developer account](https://discord.com/developers/)

### Installing

1. Clone the repository:
```
git clone https://github.com/Bioblaze/2dgodot_mmo_login_service.git
```
2. Navigate to the project directory:
```
cd ./2dgodot_mmo_login_service
```
3. Install the required dependencies:
```
go mod download
```
4. Create a `.env` file in the project directory with the following variables:
```
GOOGLE_CLIENT_ID=<your-google-client-id>
GOOGLE_CLIENT_SECRET=<your-google-client-secret>
GOOGLE_REDIRECT_URI=<your-google-redirect-uri>
CLIENT_ID=<your-discord-client-id>
CLIENT_SECRET=<your-discord-client-secret>
REDIRECT_URI=<your-discord-redirect-uri>
JWT_SECRET=<your-jwt-secret>
```
5. Build the application:
```
go build
```
6. Run the application:
```
./2dgodot_mmo_login_service
```
