local ConnectingIds = {}
local CONNECT_TIMEOUT = 30

local function OnPlayerConnecting(name, _, deferrals)
    local player = source
	local isIdtypeAlreadyInUse = false
	local isIdtypeAlreadyInUse2 = false
    local idtype
	local idtype2
    local identifiers = GetPlayerIdentifiers(player)

    deferrals.defer()
    Wait(0)
 
	deferrals.update('Checking Connection...')
	
	if Config.VerifyBoth then
		for _, v in pairs(identifiers) do
			if string.find(v, 'steam') then
				idtype = v
				break
			end
		end
		
		for _, v in pairs(identifiers) do
			if string.find(v, 'license') then
				idtype2 = v
				break
			end
		end
	else
		for _, v in pairs(identifiers) do
			if string.find(v, Config.VerificationMethod) then
				idtype = v
				break
			end
		end
	end

	local now = os.time()

    for id, time in pairs(ConnectingIds) do
        if now - time > CONNECT_TIMEOUT then
            ConnectingIds[id] = nil
        end
    end

    if Config.VerifyBoth then
        if (idtype and ConnectingIds[idtype] and (now - ConnectingIds[idtype] < CONNECT_TIMEOUT)) or
           (idtype2 and ConnectingIds[idtype2] and (now - ConnectingIds[idtype2] < CONNECT_TIMEOUT)) then

            deferrals.done('You are already connecting to the server...')
            return
        end
    else
        if idtype and ConnectingIds[idtype] and (now - ConnectingIds[idtype] < CONNECT_TIMEOUT) then
            deferrals.done('You are already connecting to the server...')
            return
        end
    end

    if Config.VerifyBoth then
        if idtype then ConnectingIds[idtype] = now end
        if idtype2 then ConnectingIds[idtype2] = now end
    else
        if idtype then ConnectingIds[idtype] = now end
    end

    Wait(500)

    deferrals.update('Checking if you are not already on the server...')

	if Config.VerifyBoth then
		isIdtypeAlreadyInUse = IsIdtypeInUse(idtype, 'steam')
	    isIdtypeAlreadyInUse2 = IsIdtypeInUse(idtype2, 'license')
	else
		isIdtypeAlreadyInUse = IsIdtypeInUse(idtype, Config.VerificationMethod)
	end

    Wait(500)
	
	if Config.VerifyBoth then
		if isIdtypeAlreadyInUse or isIdtypeAlreadyInUse2 then
			
			deferrals.done('It looks like you are already on the server....')

			if idtype then ConnectingIds[idtype] = nil end
            if idtype2 then ConnectingIds[idtype2] = nil end
			
			if Config.EnableDiscordLogs then
				local dcsend = {
					{
						['title']= Config.DiscordTitle,
						['color'] = Config.DiscordColor,
						['description'] = 'Player Identifiers: **'..idtype..' / '..idtype2..'**',
						['footer']=  {
							['text']= 'bulgar_dconnect_block',
						},
					}
				}
				
				PerformHttpRequest(Config.DiscordWebhookLink, function(err, text, headers) end, 'POST', json.encode({ username = Config.DiscordUserName, embeds = dcsend}), { ['Content-Type'] = 'application/json' })
			end
			
		else
			deferrals.done()
		end
		
	else
		
		if isIdtypeAlreadyInUse then
			
			deferrals.done('It looks like you are already on the server....')

			if idtype then ConnectingIds[idtype] = nil end
			
			if Config.EnableDiscordLogs then
				local dcsend = {
					{
						['title']= Config.DiscordTitle,
						['color'] = Config.DiscordColor,
						['description'] = 'Player Identifier: **'..idtype..'**',
						['footer']=  {
							['text']= 'bulgar_dconnect_block',
						},
					}
				}
				
				PerformHttpRequest(Config.DiscordWebhookLink, function(err, text, headers) end, 'POST', json.encode({ username = Config.DiscordUserName, embeds = dcsend}), { ['Content-Type'] = 'application/json' })
			end
			
		else
			deferrals.done()
		end
		
	end
end

AddEventHandler('playerConnecting', OnPlayerConnecting)

function IsIdtypeInUse(idtype, vmethod)
    local players = GetPlayers()
	
    for _, player in pairs(players) do
        local identifiers = GetPlayerIdentifiers(player)
		
        for _, id in pairs(identifiers) do
            if string.find(id, vmethod) then
                local playerIdtype = id
				
                if playerIdtype == idtype then
                    return true
                end
            end
        end
    end
    return false
end

AddEventHandler('playerDropped', function()
    local identifiers = GetPlayerIdentifiers(source)
		
    for _, id in pairs(identifiers) do
        if ConnectingIds[id] then
            ConnectingIds[id] = nil
        end
    end
end)
