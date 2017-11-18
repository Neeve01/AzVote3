AzVote.Config = {} 

local cfg = AzVote.Config
cfg.DisableTime = 5

cfg.Gamemodes = {}
cfg.Gamemodes.sandbox = {
	Prefixes = { "gm_" },
	PrintName = "Sandbox"
}
cfg.Gamemodes.terrortown = {
	Prefixes = { "ttt_" },
	PrintName = "Trouble in CS:S"
}
cfg.Gamemodes.prophunters = {
	Prefixes = { "ph_" },
	PrintName = "Pophunters"
}

-- Voting time
cfg.VotingTime = 5

-- RTV cleanse time
cfg.CleanseTime = 40

-- Max maps to be displayed in vote menu
cfg.MaxMaps = 15

-- Max gamemodes to be displayed
cfg.MaxGamemodes = 5

-- Vote licktime after level change
cfg.SleepTime = 300

-- Time before map will change after a successful vote
cfg.TimeToChange = 10

-- Vote locktime after unsuccessful vote
cfg.DisableTime = 5

cfg.RTVKeywords = {
	"rtv",
	"!rtv",
	"-rtv",
	"/rtv",
	"кем",
	"!кем"
}

cfg.GamemodeRTVKeywords = {
	"grtv",
	"!grtv",
	"-grtv",
	"/grtv",
	"grtv",
	"!пкем"
}

cfg.RTVRatio = 0.1
cfg.GamemodeRTVRatio = 0.5

cfg.WinRatio = 0.1