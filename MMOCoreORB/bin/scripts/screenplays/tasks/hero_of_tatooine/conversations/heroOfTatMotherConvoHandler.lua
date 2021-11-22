local ObjectManager = require("managers.object.object_manager")

heroOfTatMotherConvoHandler = conv_handler:new {}

function heroOfTatMotherConvoHandler:getInitialScreen(pPlayer, pNpc, pConvTemplate)
	local convoTemplate = LuaConversationTemplate(pConvTemplate)
	if (CreatureObject(pPlayer):hasScreenPlayState(1, "hero_of_tatooine_altruism") and not CreatureObject(pPlayer):hasScreenPlayState(2, "hero_of_tatooine_altruism")) then
		return convoTemplate:getScreen("intro")
	else
		return convoTemplate:getScreen("intro_noquest")
	end
end

function heroOfTatMotherConvoHandler:runScreenHandlers(pConvTemplate, pPlayer, pNpc, selectedOption, pConvScreen)
	local screen = LuaConversationScreen(pConvScreen)

	local screenID = screen:getScreenID()

	local pConvScreen = screen:cloneScreen()
	local clonedConversation = LuaConversationScreen(pConvScreen)
	if (screenID == "right_behind_you") then
		local daughterID = readData("hero_of_tat:farmerChildId")
		local pDaughter = getSceneObject(daughterID)

		if (pDaughter == nil or not SceneObject(pDaughter):isAiAgent() or not SceneObject(pNpc):isAiAgent()) then
			CreatureObject(pPlayer):sendSystemMessage("Error initiating escort. Please submit a bug report.")
			return
		end

		AiAgent(pDaughter):setFollowObject(pNpc)
		AiAgent(pDaughter):addCreatureFlag(AI_NOAIAGGRO)
		AiAgent(pDaughter):addCreatureFlag(AI_ESCORT)

		CreatureObject(pNpc):clearOptionBit(CONVERSABLE)

		AiAgent(pNpc):addCreatureFlag(AI_NOAIAGGRO)
		AiAgent(pNpc):addCreatureFlag(AI_ESCORT)
		AiAgent(pNpc):setFollowObject(pPlayer)
		AiAgent(pNpc):setMovementState(3)

		writeData("hero_of_tat:altruismEscortStatus", 1)
		writeData("hero_of_tat:altruismEscorterID", SceneObject(pPlayer):getObjectID())
		createEvent(2000, "HeroOfTatooineScreenPlay", "escortRangeCheckEvent", pPlayer, "")
	end

	return pConvScreen
end
