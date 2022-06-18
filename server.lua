local function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source
    local steamhex
    local identifiers = GetPlayerIdentifiers(player)

    deferrals.defer()

    Wait(0)

    deferrals.update(string.format('Checking Connection...', name))

    for _, v in pairs(identifiers) do
        if string.find(v, 'steam') then
            steamhex = v
            break
        end
    end

    Wait(500)

    deferrals.update(string.format('Checking if you are not already on the server...', name))

    local isHexAlreadyInUse = IsHexInUse(steamhex)

    Wait(500)

    if isHexAlreadyInUse then
        deferrals.done('Someone with the same steam id is already on the server...')
		    DropPlayer(player, string.format('Someone with the same steam id is already on the server...'))
    else
        deferrals.done()
    end
end

AddEventHandler('playerConnecting', OnPlayerConnecting)

function IsHexInUse(steamhex)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local identifiers = GetPlayerIdentifiers(player)
        for _, id in pairs(identifiers) do
            if string.find(id, 'steam') then
                local playerHex = id
                if playerHex == steamhex then
                    return true
                end
            end
        end
    end
    return false
end
