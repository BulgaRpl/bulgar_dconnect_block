local function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source
    local idtype
    local identifiers = GetPlayerIdentifiers(player)

    deferrals.defer()

    Wait(0)

    deferrals.update(string.format('Checking Connection...', name))

    for _, v in pairs(identifiers) do
        if string.find(v, Config.VerificationMethod) then
            idtype = v
            break
        end
    end

    Wait(500)

    deferrals.update(string.format('Checking if you are not already on the server...', name))

    local isIdtypeAlreadyInUse = IsIdtypeInUse(idtype)

    Wait(500)

    if isIdtypeAlreadyInUse then
        deferrals.done('It looks like you are already on the server....')
		DropPlayer(player, string.format('It looks like you are already on the server....'))
    else
        deferrals.done()
    end
end

AddEventHandler('playerConnecting', OnPlayerConnecting)

function IsIdtypeInUse(idtype)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local identifiers = GetPlayerIdentifiers(player)
        for _, id in pairs(identifiers) do
            if string.find(id, Config.VerificationMethod) then
                local playerIdtype = id
                if playerIdtype == idtype then
                    return true
                end
            end
        end
    end
    return false
end
