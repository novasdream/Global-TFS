function onUse(player, item, fromPosition, itemEx, toPosition, isHotkey)
	if item.actionid == 7814 then
		if player:getStorageValue (Storage.TheIceIslands.Questline) >= 40 then
			if item.itemid == 7036 then
				player:teleportTo(toPosition, true)
				Item(item.uid):transform(item.itemid + 1)
			end
		else
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The door seems to be sealed against unwanted intruders.")
		end
	end
	return true
end
