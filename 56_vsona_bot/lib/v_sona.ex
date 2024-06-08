
defmodule VSona do
  use Application

  @impl true
  def start(_type, _args) do
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    VSona.Supervisor.start_link(name: VSona.Supervisor)
  end
end

# https://discord.com/oauth2/authorize?client_id=CLIENT_ID_HERE&scope=bot+applications.commands&permissions=268437568

# Bot Permissions integer: 268437568
# Also, add "Manage Messages" and "Read Message History" to the Welcome channels or categories.
defmodule VSona.Supervisor do
  use Supervisor
  require Logger

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    Logger.error("INIT IS HAPPENING")
    children = [VSona.Module]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule VSona.Module do
  use Nostrum.Consumer
  require Logger

  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__);
  end

  def reset_slash_commands(guild_id) do
    admin_command_desc = %{
      name: "assign_welcome_message",
      description: "React to a welcome message to assign a role",
      default_permission: false,
      options: [
        %{
          # ApplicationCommandType::STRING
          type: 3,
          name: "message_id",
          description: "Message ID to react to",
          required: true
        },
        %{
          # ApplicationCommandType::STRING
          type: 3,
          name: "emoji",
          description: "Reaction Emoji",
          required: true
        },
        %{
          # ApplicationCommandType::ROLE
          type: 8,
          name: "role",
          description: "role to assign or remove",
          required: true
        }
      ]
    }

    #{:ok, guilds} = Api.get_current_user_guilds()
    #for guild_id <- guilds do
    tmpargs = inspect(admin_command_desc)
    Logger.debug("Creating command: #{tmpargs}")
    {res, cmd_result} = Api.create_guild_application_command(
      guild_id, admin_command_desc)
    if res == :ok do
      owner_id = Api.get_guild!(guild_id).owner_id
      permissions = [
        %{
            id: owner_id,
            type: 2,
            permission: true
        }
      ]
      Api.edit_application_command_permissions(guild_id, cmd_result.id, permissions)
    else
      Logger.error("failed to create slash command")
    end
    Logger.debug(inspect(cmd_result))
    #end
    # Api.create_global_application_command(command: )
  end

  def handle_event({:INTEGRATION_UPDATE, msg, _ws_state}) do
    reset_slash_commands(msg.guild_id)
  end

  def handle_event({:GUILD_AVAILABLE, msg, _ws_state}) do
    reset_slash_commands(msg.id)
  end

  def handle_event({:MESSAGE_REACTION_ADD, msg, _ws_state}) do
    emoji_name = Nostrum.Struct.Emoji.api_name(msg.emoji)
    me_id = Nostrum.Cache.Me.get().id
    Logger.debug("msg_react #{emoji_name}");
    Logger.debug(msg);
    channel_data = Api.get_channel!(msg.channel_id)
    topic = channel_data.topic
    if topic != nil and String.contains?(topic, "<@&") and String.contains?(topic, emoji_name) do
      role_id = String.to_integer(Enum.at(String.split(Enum.at(String.split(topic, "<@&"), 1), ">"), 0))
      Logger.debug(role_id)
      reactions = Api.get_reactions!(msg.channel_id, msg.message_id, emoji_name)
      Logger.debug(inspect(reactions))
      if Enum.find(reactions, fn user -> (user.id == me_id) end) != nil do
        for user <- reactions do
          if user.id != me_id do
            Api.delete_user_reaction(msg.channel_id, msg.message_id, emoji_name, user.id)
            Logger.debug("Would delete reaction for #{user.id}")
            Api.add_guild_member_role(msg.guild_id, user.id, role_id, "Reacted #{emoji_name} in #{channel_data.name}")
          end
        end
      end
      # Causes infinite recursion! Api.create_reaction!(....)
      # Api.delete_user_reaction!(msg.channel_id, msg.message_id, "\xf0\x9f\x91\x8d", msg.user_id) # Thumbs up
    end
  end

  def handle_event({:INTERACTION_CREATE, msg, _ws_state}) do
    Logger.debug("interactioncreate");
    Logger.debug(inspect(msg));
    case msg.data.name do
      "assign_welcome_message" ->
        role_id = Enum.find(msg.data.options, fn opt -> opt.name == "role" end).value
        emoji = Enum.find(msg.data.options, fn opt -> opt.name == "emoji" end).value
        msg_id_parts = String.split(Enum.find(msg.data.options, fn opt -> opt.name == "message_id" end).value, "/")
        {channel_id, message_id} = if length(msg_id_parts) > 4 do
          {String.to_integer(Enum.at(msg_id_parts, length(msg_id_parts)-2)), String.to_integer(Enum.at(msg_id_parts, length(msg_id_parts)-1))}
        else
          {msg.channel_id, String.to_integer(Enum.at(msg_id_parts, length(msg_id_parts)-1))}
        end
        {flags, resp} = if message_id == 0 do
          Logger.error("Invalid message_id #{message_id}")
          {64, "Could not find the message id"}
        else
          message = Api.get_channel_message(channel_id, message_id)
          Logger.debug(inspect(message))
          topic = Api.get_channel(channel_id).topic
          if String.contains?(topic, "<@&#{role_id}>") and String.contains?(topic, emoji) do
            res = Api.create_reaction(channel_id, message_id, emoji)
            if :ok = res do
              {64, "Success"}
            else
              {64, "Error: #{inspect(res)}"}
            end
          else
            {64, "Channel topic must contain \\<\\@\\&#{role_id}\\> and #{emoji}"}
          end
        end
        response = %{
          type: 4,
          data: %{
            flags: flags,
            content: resp
          }
        }
        Api.create_interaction_response(msg, response)

      "!ping" ->
        Api.create_message(msg.channel_id, "pong!")

      "!raise" ->
        # This won't crash the entire Consumer.
        raise "No problems here!"

      _ ->
        :ignore
    end
  end

  def handle_event({:MESSAGE_CREATE, _msg, _ws_state}) do
    :ignore # don't print out every message
  end

  def handle_event({:TYPING_START, _msg, _ws_state}) do
    :ignore # don't print out every typing
  end

  def handle_event({event_name, arg, _}) do
    args = inspect(arg)
    Logger.debug(fn -> "VSona would handle #{event_name} here: #{args}" end)
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  #def handle_event(_event) do
  #  :noop
  #end
end
