local function OnPlayerConnecting(name, _, deferrals)
    local player = source
	local isIdtypeAlreadyInUse = false
	local isIdtypeAlreadyInUse2 = false
    local idtype
	if Config.VerifyBoth then
		local idtype2
	end
    local identifiers = GetPlayerIdentifiers(player)

    deferrals.defer()

    Wait(0)

    deferrals.update(string.format('Checking Connection...', name))
	
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

    Wait(2500)

    deferrals.update(string.format('Checking if you are not already on the server...', name))

	if Config.VerifyBoth then
		isIdtypeAlreadyInUse = IsIdtypeInUse(idtype, 'steam')
	    isIdtypeAlreadyInUse2 = IsIdtypeInUse(idtype2, 'license')
	else
		isIdtypeAlreadyInUse = IsIdtypeInUse(idtype, Config.VerificationMethod)
	end

    Wait(2500)
	
	if Config.VerifyBoth then
		if isIdtypeAlreadyInUse or isIdtypeAlreadyInUse2 then
			deferrals.done('It looks like you are already on the server....')
			
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
			
			-- Add any additional defferals here you may need for example queue system!
		end	
	else
		if isIdtypeAlreadyInUse then
			deferrals.done('It looks like you are already on the server....')
			
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
			
			-- Add any additional defferals here you may need for example queue system!
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
