function onUse(player, item, fromPosition, itemEx, toPosition, isHotkey)

	if player:getStorageValue(Storage.hiddenCityOfBeregar.JusticeForAll) == 3 then
		player:addItem(14348, 1)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have found Rerun's ring.")
		player:setStorageValue(Storage.hiddenCityOfBeregar.JusticeForAll, 4)
	end
	return true
end
