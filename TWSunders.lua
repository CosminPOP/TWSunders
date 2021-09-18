local TWSunders = CreateFrame("Frame")
local TWSunderChecker = CreateFrame("Frame")
TWSunderChecker:Hide()

TWSunderChecker.timerStart = 0
TWSunders:RegisterEvent("PLAYER_TARGET_CHANGED")
TWSunders:RegisterEvent("PLAYER_REGEN_DISABLED")
TWSunders:RegisterEvent("PLAYER_REGEN_ENABLED")

local sDev = false

TWSunders:SetScript("OnEvent", function()
    if event and (GetNumRaidMembers() > 0 or sDev) then
        if event == "PLAYER_REGEN_DISABLED" then
            if UnitExists('target') and UnitClassification('target') == 'worldboss' and (UnitIsEnemy('player', 'target') or sDev) then
                TWSunderChecker:Hide()
                if not TWSunders:checkFive() then
                    TWSunderChecker:Show()
                end
            end
        end
        if event == "PLAYER_REGEN_ENABLED" then
            TWSunderChecker:Hide()
        end
        if event == 'PLAYER_TARGET_CHANGED' and UnitExists('target') then
            if (UnitIsEnemy('player', 'target')  and UnitClassification('target') == 'worldboss' or sDev) and UnitAffectingCombat('player') and UnitAffectingCombat('target') then
                TWSunderChecker:Hide()
                if not TWSunders:checkFive() then
                    TWSunderChecker:Show()
                end
            end
        end
    end
end)

TWSunderChecker:SetScript("OnShow", function()
    this.startTime = GetTime()
    TWSunderChecker.timerStart = GetTime()
end)

TWSunderChecker:SetScript("OnUpdate", function()
    local plus = 0.1 --seconds
    local gt = GetTime() * 1000
    local st = (this.startTime + plus) * 1000
    if gt >= st then
        TWSunders:check_sunder()
        this.startTime = GetTime()
    end
end)

function TWSunders:sunderRound(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function TWSunders:checkFive()
    for i = 1, 16 do
        local debuff, count = UnitDebuff("target", i)
        if debuff and debuff == "Interface\\Icons\\Ability_Warrior_Sunder" then
            if count and count == 5 then
                return true
            end
        end
    end
    return false
end

function TWSunders:check_sunder()
    if UnitExists('target') and (UnitIsEnemy('player', 'target') or sDev) then
        local sunderTime = self:sunderRound(GetTime() - TWSunderChecker.timerStart, 1)
        if self:checkFive() and sunderTime > 1.6 then
            SendChatMessage("[" .. UnitName('target') .. "] 5 Sunders took " .. sunderTime .. "sec", "SAY")
            TWSunderChecker:Hide()
            return
        end
    end
end



