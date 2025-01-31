local addonname, LUI = ...
local script = LUI:NewScript("AutoInvite", "AceEvent-3.0")

local STATICPOPUP_NUMDIALOGS = _G.STATICPOPUP_NUMDIALOGS

local BNFeaturesEnabledAndConnected = _G.BNFeaturesEnabledAndConnected
local GetNumSubgroupMembers = _G.GetNumSubgroupMembers
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local GetNumGuildMembers = _G.GetNumGuildMembers
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local BNGetNumFriends = _G.BNGetNumFriends
local IsInGuild = _G.IsInGuild

local C_FriendList = C_FriendList
local C_BattleNet = C_BattleNet

local function isFriend(name)
	for i = 1, C_FriendList.GetNumFriends() do
		if C_FriendList.GetFriendInfoByIndex(i).name == name then
			return true
		end
	end
end

local function isGuildmate(name)
	--[[ NOTES:
	GetGuildRosterInfo() returns name as Name-Realm since 5.4.2 so we need to handle that when checking for guild membership.
	Removed reliance on strsplit as it seemed to be causing random issues - and I think this provides a much more robust system.
	]]--
	if not IsInGuild() then return end

	if string.find(name, "-") then
		-- Name with realm, so either an off realm person or
		-- somebody in guild from a connected realm
		name = name:gsub("%-", ".-")
	else
		-- Name without a realm, so they are from my realm
		name = string.format("%s.-", name)
	end
	for i = 1, GetNumGuildMembers() do
		local fullName = GetGuildRosterInfo(i)
		if string.match(fullName, name) then
			return true
		end
	end
end

local function isBNFriend(name)
	if not BNFeaturesEnabledAndConnected() then return end

	for i = 1, BNGetNumFriends() do
		local friend = C_BattleNet.GetFriendAccountInfo(i)
		local toon = friend.gameAccountInfo
		if toon.isOnline and toon.clientProgram == "WoW" then
			if toon.characterName == name then
				return true
			end
		end
	end
end

function LUI:InviteCmd()
	LUI.db.AutoInvite = not LUI.db.AutoInvite
	script:SetAutoInvite()
	LUI:Print("AutoInvite |cff"..(LUI.db.AutoInvite and "00FF00Enabled|r" or "FF0000Disabled|r"))
	if LibStub("AceConfigDialog-3.0").OpenFrames[addonname] then
		LibStub("AceConfigRegistry-3.0"):NotifyChange(addonname)
	end
end


function script:SetAutoAccept()
	self[LUI.db.AutoAcceptInvite and "RegisterEvent" or "UnregisterEvent"](self, "PARTY_INVITE_REQUEST")
end

function script:SetAutoInvite()
	self[LUI.db.AutoInvite and "RegisterEvent" or "UnregisterEvent"](self, "CHAT_MSG_WHISPER")
end


function script:PARTY_INVITE_REQUEST(event, sender)
	if not sender then return end

	if isFriend(sender) or isGuildmate(sender) or isBNFriend(sender) then
		for i = 1, STATICPOPUP_NUMDIALOGS do
			local popup = _G["StaticPopup"..i]
			if popup.which == "PARTY_INVITE" then
				return popup.button1:GetScript("OnClick")(popup.button1)
			end
		end
	end
end

function script:CHAT_MSG_WHISPER(event, message, sender)
	if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or (GetNumSubgroupMembers() == 0)) and strlower(message):match(strlower(LUI.db.AutoInviteKeyword)) then
		if LUI.db.AutoInviteOnlyFriend == false or (isFriend(sender) or isGuildmate(sender) or isBNFriend(sender)) then
			C_PartyInfo.InviteUnit(sender)
		end
	end
end

function script:PLAYER_ENTERING_WORLD(event)
	LUI.Profiler.TraceScope(script, "AutoInvite", "LUI", 2)
	script:SetAutoInvite()
	script:SetAutoAccept()
end

script:RegisterEvent("PLAYER_ENTERING_WORLD")

LUI.cmdList["invite"] = "InviteCmd"
LUI.cmdList["inv"] = "InviteCmd"
