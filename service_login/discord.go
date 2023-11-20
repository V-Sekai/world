package main

import (
	"fmt"
	"os"

	"github.com/bwmarrin/discordgo"
)

// DiscordBot represents an interface for Discord bot operations
type DiscordBot interface {
	Launch() error
	Connect() error
	RegisterEventHandlers()
}

// DiscordBotImpl is the implementation of the DiscordBot interface
type DiscordBotImpl struct {
	session *discordgo.Session
}

// NewDiscordBot returns a new instance of the DiscordBot
func NewDiscordBot() DiscordBot {
	return &DiscordBotImpl{}
}

// Launch initializes and returns the Discord session
func (bot *DiscordBotImpl) Launch() error {
	token := os.Getenv("DISCORD_BOT_TOKEN")
	dg, err := discordgo.New("Bot " + token)
	if err != nil {
		return fmt.Errorf("error creating Discord session: %w", err)
	}
	bot.session = dg
	return nil
}

// Connect opens a websocket connection to Discord
func (bot *DiscordBotImpl) Connect() error {
	if bot.session == nil {
		return fmt.Errorf("discord session not initialized")
	}

	err := bot.session.Open()
	if err != nil {
		return fmt.Errorf("error opening Discord websocket connection: %w", err)
	}
	return nil
}

// RegisterEventHandlers registers event handlers for the Discord bot
func (bot *DiscordBotImpl) RegisterEventHandlers() {
	if bot.session == nil {
		fmt.Println("discord session not initialized")
		return
	}

	// Message Creation Event
	bot.session.AddHandler(func(s *discordgo.Session, m *discordgo.MessageCreate) {
		if m.Author.ID == s.State.User.ID {
			return
		}
		if m.Content == "!ping" {
			s.ChannelMessageSend(m.ChannelID, "Pong!")
		}
	})

	// Member Joined Event
	bot.session.AddHandler(func(s *discordgo.Session, m *discordgo.GuildMemberAdd) {
		fmt.Printf("Member %s joined the guild %s\n", m.Member.User.Username, m.GuildID)
		// You can also send a welcome message or any other action upon a new member joining.
		// Example: s.ChannelMessageSend(welcomeChannelID, fmt.Sprintf("Welcome %s!", m.Member.User.Username))
	})

	// Member Parted Event
	bot.session.AddHandler(func(s *discordgo.Session, m *discordgo.GuildMemberRemove) {
		fmt.Printf("Member %s left the guild %s\n", m.Member.User.Username, m.GuildID)
		// You can also send a farewell message or any other action upon a member leaving.
		// Example: s.ChannelMessageSend(farewellChannelID, fmt.Sprintf("Goodbye %s!", m.Member.User.Username))
	})

	// ... Add other event handlers as required
}
