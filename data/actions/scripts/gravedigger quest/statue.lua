function onUse(player, item, fromPosition, itemEx, toPosition, isHotkey)
	if itemEx.actionid == 4636 then
		if player:getStorageValue(Storage.GravediggerOfDrefia.Mission24) == 1 and player:getStorageValue(Storage.GravediggerOfDrefia.Mission25) < 1 then
			player:setStorageValue(Storage.GravediggerOfDrefia.Mission25,1)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, '<BOOOOOOOONGGGGGG> A slow throbbing, like blood pulsing, runs through the floor.')
			player:getPosition():sendMagicEffect(CONST_ME_SOUND_GREEN)
		end
	end
	return true
end