-- Players cannot throw items on teleports if set to true
local blockTeleportTrashing = false

function Player:onBrowseField(position)
	return true
end

function Player:onLook(thing, position, distance)
	local description = 'You see '
	if thing:isItem() then
		if thing.actionid == 5640 then
			description = description .. 'a honeyflower patch.'
		elseif thing.actionid == 5641 then
			description = description .. 'a banana palm.'
		else
			description = description .. thing:getDescription(distance)
		end
	else
		description = description .. thing:getDescription(distance)
	end

	if self:getGroup():getAccess() then
		if thing:isItem() then
			description = string.format('%s\nItemID: [%d]', description, thing.itemid)

			local actionId = thing.actionid
			if actionId ~= 0 then
				description = string.format('%s, ActionID: [%d]', description, actionId)
			end

			local uniqueId = thing:getAttribute(ITEM_ATTRIBUTE_UNIQUEID)
			if uniqueId > 0 and uniqueId < 65536 then
				description = string.format('%s, UniqueId: [%d]', description, uniqueId)
			end

			description = description .. '.'
			local itemType = thing:getType()

			local transformEquipId = itemType:getTransformEquipId()
			local transformDeEquipId = itemType:getTransformDeEquipId()
			if transformEquipId ~= 0 then
				description = string.format('%s\nTransformTo: [%d] (onEquip).', description, transformEquipId)
			elseif transformDeEquipId ~= 0 then
				description = string.format('%s\nTransformTo: [%d] (onDeEquip).', description, transformDeEquipId)
			end

			local decayId = itemType:getDecayId()
			if decayId ~= -1 then
				description = string.format('%s\nDecayTo: [%d]', description, decayId)
			end
		elseif thing:isCreature() then
			local str = '%s\nHealth: [%d / %d]'
			if thing:getMaxMana() > 0 then
				str = string.format('%s, Mana: [%d / %d]', str, thing:getMana(), thing:getMaxMana())
			end
			description = string.format(str, description, thing:getHealth(), thing:getMaxHealth()) .. '.'
		end

		local position = thing:getPosition()
		description = string.format(
			'%s\nPosition: [X: %d] [Y: %d] [Z: %d].',
			description, position.x, position.y, position.z
		)

		if thing:isCreature() and thing:isPlayer() then
			description = string.format('%s\nIP: [%s].', description, Game.convertIpToString(thing:getIp()))
		end
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onLookInBattleList(creature, distance)
	local description = 'You see ' .. creature:getDescription(distance)
	if self:getGroup():getAccess() then
		local str = '%s\nHealth: [%d / %d]'
		if creature:getMaxMana() > 0 then
			str = string.format('%s, Mana: [%d / %d]', str, creature:getMana(), creature:getMaxMana())
		end
		description = string.format(str, description, creature:getHealth(), creature:getMaxHealth()) .. '.'

		local position = creature:getPosition()
		description = string.format(
			'%s\nPosition: [X: %d] [Y: %d] [Z: %d].',
			description, position.x, position.y, position.z
		)

		if creature:isPlayer() then
			description = string.format('%s\nIP: [%s].', description, Game.convertIpToString(creature:getIp()))
		end
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onLookInTrade(partner, item, distance)
	self:sendTextMessage(MESSAGE_INFO_DESCR, 'You see ' .. item:getDescription(distance))
end

function Player:onLookInShop(itemType, count)
	return true
end

function Player:onMoveItem(item, count, fromPosition, toPosition)
	if blockTeleportTrashing and toPosition.x ~= CONTAINER_POSITION then
		local thing = Tile(toPosition):getItemByType(ITEM_TYPE_TELEPORT)
		if thing then
			self:sendCancelMessage('Sorry, not possible.')
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

	if isInArray({1714, 1715, 1716, 1717, 1738, 1740, 1741, 1747, 1748, 1749}, item.itemid) and item.actionid > 0 or item.actionid == 5640 then
		self:sendCancelMessage('You cannot move this object.')
		return false
	elseif item.itemid == 7466 then
		self:sendCancelMessage('You cannot move this object.')
		return false
	end

	if fromPosition.x == CONTAINER_POSITION and toPosition.x == CONTAINER_POSITION
			and item.itemid == 8710 and self:getItemCount(8710) == 2 and self:getStorageValue(Storage.RookgaardTutorialIsland.cockroachLegsMsgStorage) ~= 1 then
		self:sendTextMessage(MESSAGE_INFO_DESCR, 'Well done, you have enough cockroach legs! You should head back to Santiago with them. Climb the ladder to the north to exit.')
		self:setStorageValue(Storage.RookgaardTutorialIsland.cockroachLegsMsgStorage, 1)
		self:setStorageValue(Storage.RookgaardTutorialIsland.SantiagoNpcGreetStorage, 6)
	end
	return true
end

function Player:onMoveCreature(creature, fromPosition, toPosition)
	return true
end

function Player:onTurn(direction)
	return true
end

function Player:onTradeRequest(target, item)
	if isInArray({1738, 1740, 1747, 1748, 1749, 8766}, item.itemid) and item.actionid > 0 or item.actionid == 5640 then
		self:sendCancelMessage('Sorry, not possible.')
		return false
	end
	return true
end

function Player:onTradeAccept(target, item, targetItem)
	return true
end

local soulCondition = Condition(CONDITION_SOUL, CONDITIONID_DEFAULT)
soulCondition:setTicks(4 * 60 * 1000)
soulCondition:setParameter(CONDITION_PARAM_SOULGAIN, 1)

function Player:onGainExperience(source, exp, rawExp)
	local vocation = self:getVocation()
	if self:getSoul() < vocation:getMaxSoul() and exp >= self:getLevel() then
		soulCondition:setParameter(CONDITION_PARAM_SOULTICKS, vocation:getSoulGainTicks() * 1000)
		self:addCondition(soulCondition)
	end

	return exp
end

function Player:onLoseExperience(exp)
	return exp
end

function Player:onGainSkillTries(skill, tries)
	if skill == SKILL_MAGLEVEL then
		return tries * configManager.getNumber(configKeys.RATE_MAGIC)
	end
	return tries * configManager.getNumber(configKeys.RATE_SKILL)
end
