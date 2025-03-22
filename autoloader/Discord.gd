extends Node

func _ready():
	DiscordRPC.app_id = 1352762069946208362
	print("Discord working: " + str(DiscordRPC.get_is_discord_working()))
	
	DiscordRPC.details = "Main Menu"
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	update()

func change(prop:String,value:String):
	DiscordRPC.set(prop,value)

func update():#updating on every property change is stupid af
	DiscordRPC.refresh() 
