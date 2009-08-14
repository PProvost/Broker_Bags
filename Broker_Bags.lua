--[[
Name: Broker_Bags\Broker_Bags.lua
Description: Keeps track of your favorite things to say

Copyright 2008 Quaiche

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local GetInventoryItemLink = GetInventoryItemLink
local ContainerIDToInventory = ContainerIDToInventory
local GetItemInfo = GetItemInfo
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots

local playerName
local playerRealm

local Bags = CreateFrame("Frame", "Broker_Bags")
Bags.obj = LibStub("LibDataBroker-1.1"):NewDataObject("Bags", {
	type = "data source",
	icon = [[Interface\Icons\INV_Misc_Bag_11]],
	text = "0/0",
	OnClick = function()
		ToggleBackpack()
	end
})

local tip = LibStub("tektip-1.0").new(2, "LEFT", "RIGHT")
Bags.obj.OnLeave = function() tip:Hide() end
Bags.obj.OnEnter = function(self)
	tip:AnchorTo(self)
	tip:AddLine("Characters on " .. playerRealm)
	for k,v in pairs(Broker_BagsDB[playerRealm]) do
		tip:AddMultiLine(k, v, 1,1,1, 1,1,1)
	end
	tip:Show()
end

Bags:SetScript("OnEvent", function(_,event) Bags[event](Bags) end)
Bags:RegisterEvent("PLAYER_LOGIN")
Bags:RegisterEvent("ADDON_LOADED")

function Bags:PLAYER_LOGIN()
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

function Bags:ADDON_LOADED()
	playerName = UnitName("player")
	playerRealm = GetRealmName()
	if not Broker_BagsDB then Broker_BagsDB = {} end
	if not Broker_BagsDB[playerRealm] then Broker_BagsDB[playerRealm] = {} end	
end

local function UpdateText()
	local totalSlots = 0
	local freeSlots = 0
	for i = 0,NUM_BAG_SLOTS do
		local isBag = true
		if i > 0 then
			local itemLink = GetInventoryItemLink("player", ContainerIDToInventoryID(i))
			if itemLink then
				local subtype = select(7, GetItemInfo(itemLink))
				if (subtype == "Soul Bag") or (subtype == "Ammo Pouch") or (subtype == "Quiver") then
					isBag = false
				end
			end
		end
		if isBag then
			totalSlots = totalSlots + GetContainerNumSlots(i)
			freeSlots = freeSlots + GetContainerNumFreeSlots(i)
		end
	end

	Bags.obj.text = string.format("%d/%d", totalSlots - freeSlots, totalSlots)
	Broker_BagsDB[playerRealm][playerName] = Bags.obj.text
end

function Bags:BAG_UPDATE()
	UpdateText()
end
Bags.UNIT_INVENTORY_CHANGED = Bags.BAG_UPDATE

