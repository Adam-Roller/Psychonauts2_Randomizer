local M = {}
M["LOBO_C"] = {}
M["HQIN_C"] = {}
M["COLU_C"] = {}
M["HOLL_CLASS_C"] = {
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_100_ChangeMind.QUEST_HOLL_CLASS_100_ChangeMind"] = "active",
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_110_WatchClassIntros.QUEST_HOLL_CLASS_110_WatchClassIntros"] = true,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_120_EquipMentalConnection.QUEST_HOLL_CLASS_120_EquipMentalConnection"] = true,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_125_ConnectToThought.QUEST_HOLL_CLASS_125_ConnectToThought"] = true,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_150_MakeAConnection.QUEST_HOLL_CLASS_150_MakeAConnection"] = true,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_175_MakeHollisHateCilantro.QUEST_HOLL_CLASS_175_MakeHollisHateCilantro"] = true,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_180_ArriveAtUpperClass.QUEST_HOLL_CLASS_180_ArriveAtUpperClass"] = true,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_190_BreakMentalBarrier.QUEST_HOLL_CLASS_190_BreakMentalBarrier"] = true,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_200_EscapeClassroom.QUEST_HOLL_CLASS_200_EscapeClassroom"] = true,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_300_ExitAmbulance.QUEST_HOLL_CLASS_300_ExitAmbulance"] = "active",
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_400_EnterHospital.QUEST_HOLL_CLASS_400_EnterHospital"] = false,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_410_ParkingLotFight.QUEST_HOLL_CLASS_410_ParkingLotFight"] = false,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_420_GetToXRay.QUEST_HOLL_CLASS_420_GetToXRay"] = false,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_500_XRay.QUEST_HOLL_CLASS_500_XRay"] = false,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_600_FindHollis.QUEST_HOLL_CLASS_600_FindHollis"] = false,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_625_OpenMorgueDoor.QUEST_HOLL_CLASS_625_OpenMorgueDoor"] = false,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_650_EnterChapel.QUEST_HOLL_CLASS_650_EnterChapel"] = false,
    ["/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_700_RewireHollis.QUEST_HOLL_CLASS_700_RewireHollis"] = false,
}
M.QuestOrder = {
    ["LOBO_C"] = {},
    ["HQIN_C"] = {},
    ["COLU_C"] = {},
    ["HOLL_CLASS_C"] = {
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_100_ChangeMind.QUEST_HOLL_CLASS_100_ChangeMind",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_110_WatchClassIntros.QUEST_HOLL_CLASS_110_WatchClassIntros",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_120_EquipMentalConnection.QUEST_HOLL_CLASS_120_EquipMentalConnection",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_125_ConnectToThought.QUEST_HOLL_CLASS_125_ConnectToThought",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_150_MakeAConnection.QUEST_HOLL_CLASS_150_MakeAConnection",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_175_MakeHollisHateCilantro.QUEST_HOLL_CLASS_175_MakeHollisHateCilantro",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_180_ArriveAtUpperClass.QUEST_HOLL_CLASS_180_ArriveAtUpperClass",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_190_BreakMentalBarrier.QUEST_HOLL_CLASS_190_BreakMentalBarrier",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_200_EscapeClassroom.QUEST_HOLL_CLASS_200_EscapeClassroom",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_300_ExitAmbulance.QUEST_HOLL_CLASS_300_ExitAmbulance",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_400_EnterHospital.QUEST_HOLL_CLASS_400_EnterHospital",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_410_ParkingLotFight.QUEST_HOLL_CLASS_410_ParkingLotFight",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_420_GetToXRay.QUEST_HOLL_CLASS_420_GetToXRay",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_500_XRay.QUEST_HOLL_CLASS_500_XRay",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_600_FindHollis.QUEST_HOLL_CLASS_600_FindHollis",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_625_OpenMorgueDoor.QUEST_HOLL_CLASS_625_OpenMorgueDoor",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_650_EnterChapel.QUEST_HOLL_CLASS_650_EnterChapel",
        "/Game/Gameplay/Quests/HOLL/HOLL_CLASS/QUEST_HOLL_CLASS_700_RewireHollis.QUEST_HOLL_CLASS_700_RewireHollis",
    },
}
M.AlwaysCompleteQuests = {
    ["/Game/Gameplay/Quests/HUB1/QUEST_HUB1_1005_CheckinFrontDesk.QUEST_HUB1_1005_CheckinFrontDesk"] = true,
    --["/Game/Gameplay/Quests/HUB1/QUEST_HUB1_1020_EscapeTheClosetWrapper.QUEST_HUB1_1020_EscapeTheClosetWrapper"] = true,
    --["/Game/Gameplay/Quests/HUB1/QUEST_HUB1_1030_EnterBuilding.QUEST_HUB1_1030_EnterBuilding"] = true,
    --["/Game/Gameplay/Quests/HUB1/QUEST_HUB1_1040_InternResume.QUEST_HUB1_1040_InternResume"] = true,
}

function M:CompleteAndAdvanceQuest(level, quest)
    local foundIndex = -1
    for i,v in ipairs(self.QuestOrder[level]) do
        if v == quest then
            foundIndex = i
            self[level][v] = true
            print(string.format("Completing quest: %s\n", v))
        end
        if i == (foundIndex + 1) then
            if self[level][v] ~= false then
                print(string.format("Next quest already active or complete, attempting to slide: %s\n", v))
                foundIndex = i
            else
                self[level][v] = "active"
                print(string.format("Setting Active Quest: %s\n", v))
                break
            end
        end
    end
end

return M