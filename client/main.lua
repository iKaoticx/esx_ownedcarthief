local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX              = nil
local PlayerData = {}
local seconde    = 1000
local vehicle    = nil
local cops       = 0
local callcops   = 0
local carblips   = {}
local timer      = 0
local stolecheck = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()

end)


Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)
		if timer > (15*seconde) then
			Citizen.Wait(12 * seconde)
			TaskStartScenarioInPlace(playerPed, "prop_human_parking_meter", 0, true)
		end
	end
end)

RegisterNetEvent('esx_ownedcarthief:howmanycops2')
AddEventHandler('esx_ownedcarthief:howmanycops2', function(data)
  cops = data
end)

RegisterNetEvent('esx_ownedcarthief:911')
AddEventHandler('esx_ownedcarthief:911', function(gx, gy, gz)
	if PlayerData.job ~= nil then
	  if PlayerData.job.name == 'police' or PlayerData.job.name == 'sheriff' or PlayerData.job.name == 'fbi' then
		if Config.AlertPolice then
			local transG = 250
			local crimeBlip = AddBlipForCoord(gx, gy, gz)
			SetBlipSprite(crimeBlip , 161) -- Blips qui flash bleu
			SetBlipScale(crimeBlip , 2.0) -- Blips qui flash bleu
			SetBlipColour(crimeBlip, 3) -- Blips qui flash bleu
			PulseBlip(crimeBlip) -- Blips qui flash bleu
			while transG ~= 0 do
				Wait(Config.BlipTime * 4)
				transG = transG - 1
				if transG == 0 then
					SetBlipSprite(crimeBlip,  2)
					return
				end
			end
		   
		end
	  end
	end
end)

RegisterNetEvent('esx_ownedcarthief:stealcar')
AddEventHandler('esx_ownedcarthief:stealcar', function(item)

print("Debut fonction StoleCar")--DEBUG

    vehicle    = ESX.Game.GetVehicleInDirection()
    stolecheck = false
    timer      = 0
local playerPed       = PlayerPedId()
local coords          = GetEntityCoords(playerPed)
local vehicleData     = ESX.Game.GetVehicleProperties(vehicle)
local CheckOwnedPlate = false
local itemused        = item
local plyPos          = GetEntityCoords(playerPed,  true)


	TriggerServerEvent('esx_ownedcarthief:howmanycops')
print(vehicleData.plate)--DEBUG
	if Config.OnlyPlayerCar then
	   ESX.TriggerServerCallback('esx_ownedcarthief:isPlateTaken', function (isPlateTaken)
            if isPlateTaken then
				ESX.TriggerServerCallback('esx_ownedcarthief:alarminstall', function (alarmsystem)
					if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
						if itemused == "hammerwirecutter" then
							timer = (60 * seconde)
							callcops = 1
							TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_HAMMERING", 0, true)
							Citizen.Wait(5 * seconde)
							TaskStartScenarioInPlace(playerPed, "prop_human_parking_meter", 0, true)
							print("hammerwirecutter")
						elseif itemused == "unlockingtool" then
							timer = (30 * seconde)
							callcops = math.random(1,101)	
							TaskStartScenarioInPlace(playerPed, "prop_human_parking_meter", 0, true)
							print("unlockingtool")
						end
						if timer > (31 * seconde) then
							ShowTimer()
							Citizen.Wait(30 * seconde)
							TaskStartScenarioInPlace(playerPed, "prop_human_parking_meter", 0, true)
						else
							ShowTimer()
						end
							if callcops <= Config.CallCopsChance then
								if alarmsystem == 1 then
									SetVehicleAlarm(vehicle, 1)
									StartVehicleAlarm(vehicle)
								elseif alarmsystem == 2 then
									SetVehicleAlarm(vehicle, 1)
									StartVehicleAlarm(vehicle)
									TriggerServerEvent('esx_ownedcarthief:callcops', plyPos.x, plyPos.y, plyPos.z)
								elseif alarmsystem == 3 then
									SetVehicleAlarm(vehicle, 1)
									StartVehicleAlarm(vehicle)
									TriggerServerEvent('esx_ownedcarthief:callcops', plyPos.x, plyPos.y, plyPos.z)
									TriggerServerEvent('esx_ownedcarthief:alarmgps')
								else
									SetVehicleAlarm(vehicle, 0)
								end
							end

					end
			  end, vehicleData.plate)
			else
				ESX.ShowNotification(_U('not_work_with_npc'))
            end
        end, vehicleData.plate)

	elseif IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
		TaskStartScenarioInPlace(playerPed, "prop_human_parking_meter", 0, true)
		ShowTimer()
		Citizen.Wait(timer/1.5)
		TaskStartScenarioInPlace(playerPed, "prop_human_parking_meter", 0, true)
		callcops = math.random(1,101)
		if callcops <= Config.CallCopsChance then
			local plyPos = GetEntityCoords(playerPed,  true)
			SetVehicleAlarm(vehicle, 1)
			StartVehicleAlarm(vehicle)
			TriggerServerEvent('esx_ownedcarthief:callcops', plyPos.x, plyPos.y, plyPos.z)
		end
	end
end)

function ShowTimer()
print("Debut fonction ShowTimer")--DEBUG

	Citizen.CreateThread(function()
		while timer > 0 do
			Citizen.Wait(5)

			raw_seconds = timer/1000
			raw_minutes = raw_seconds/60
			minutes = stringsplit(raw_minutes, ".")[1]
			seconds = stringsplit(raw_seconds-(minutes*60), ".")[1]

			SetTextFont(7)
			SetTextProportional(0)
			SetTextScale(0.0, 0.5)
			SetTextColour(255, 255, 255, 255)
			SetTextDropshadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()

			local text = _U('please_wait', minutes, seconds)

			SetTextCentre(true)
			BeginTextCommandDisplayText("STRING")
			AddTextComponentSubstringPlayerName(text)
			EndTextCommandDisplayText(0.5, 0.8)

			timer = timer - 20
			stolecheck = true
		end
		
		while timer == 0 and stolecheck do
			        stolecheck = false
			local 	vehicle2   = ESX.Game.GetVehicleInDirection()
			local   playerPed  = PlayerPedId()
			local   succes     = math.random(1,101)

			ClearPedTasksImmediately(playerPed)
			print(succes)
			if vehicle == vehicle2 then
				if succes <= Config.SuccesChance then
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					if callcops <= Config.CallCopsChance then
						SetVehicleAlarm(vehicle, 1)
						StartVehicleAlarm(vehicle)
					end
					ESX.ShowNotification(_U('vehicle_unlocked'))
				else
					ESX.ShowNotification(_U('vehicle_notunlocked'))
				end
			end
		end
	end)
end

function stringsplit(inputstr, sep)
  if sep == nil then
      sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      t[i] = str
      i = i + 1
  end
  return t
end

function OpenPawnshopMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'pawnshop',
	{
		title    = _U('pawnshop_menu_title'),
		align    = 'left',
		elements = {
			{label = _U('pawnshop_resell'),  value = 'pawnshop_resell'},
			{label = _U('pawnshop_rebuy'),  value = 'pawnshop_rebuy'},
			{label = _U('pawnshop_buyitem'),  value = 'pawnshop_buyitem'}
		},
	}, function(data, menu)
	  menu.close()
	  if (isNear(Config.Zones.PawnShop.Pos)) then
		if data.current.value == 'pawnshop_resell' then

			--ICI ON VEND UN VEHICULE VOLÉ
			ESX.ShowNotification("In Build")
		end
	 else
	 ESX.ShowNotification(_U('warning'))
	 ESX.UI.Menu.CloseAll()
	 end
	 
	  if (isNear(Config.Zones.PawnShop.Pos)) then
		if data.current.value == 'pawnshop_rebuy' then

			--ICI ON RACHETE UN VEHICULE QUI A ÉTÉ VOLÉ
			ESX.ShowNotification("In Build")
		end
	  else
		ESX.ShowNotification(_U('warning'))
		ESX.UI.Menu.CloseAll()
	 end
	  
	  if (isNear(Config.Zones.PawnShop.Pos)) then
		if data.current.value == 'pawnshop_buyitem' then
			OpenPawnshopMenu2()
		end
	  else
		ESX.ShowNotification(_U('warning'))
		ESX.UI.Menu.CloseAll()
	 end
		
	end, function(data, menu)
		menu.close()
	 end
	
	)
end

function OpenPawnshopMenu2()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'pawnshop2',
	{
		title    = _U('pawnshop_menu_title'),
		align    = 'left',
		elements = {
			{label = _U('pawnshop_buy') .. ' ' .. _('hammerwirecutter'),  value = 'hammerwirecutter'},
			{label = _U('pawnshop_buy') .. ' ' .. _('jammer'),  value = 'jammer'},
			{label = _U('pawnshop_buy') .. ' ' .. _('unlockingtool'),  value = 'unlockingtool'}
		},
	}, function(data, menu)
		
	  if (isNear(Config.Zones.PawnShop.Pos)) then

			TriggerServerEvent('esx_ownedcarthief:buyitem', data.current.value)
	  else
		ESX.ShowNotification(_U('warning'))
		ESX.UI.Menu.CloseAll()
	 end
	end, function(data, menu)
		ESX.UI.Menu.CloseAll()
	end
	)
end

function Info(text, loop)
			SetTextComponentFormat("STRING")
			AddTextComponentString(text)
			DisplayHelpTextFromStringLabel(0, loop, 1, 0)
end

function isNear(tabl)
local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),tabl.x,tabl.y,tabl.z, true)

if(distance<3) then
	return true
	end
		return false
end

-- Create blip on stolen car --IN BUILD
function createBlip(id)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipNameToPlayerName(blip, id) -- update blip name
		SetBlipScale(blip, 0.85) -- set scale
		SetBlipAsShortRange(blip, true)
		
		table.insert(carblips, blip) -- add blip to array so we can remove it later
	end
end

RegisterNetEvent('esx_ownedcarthief:addBlip') --IN BUILD
AddEventHandler('esx_ownedcarthief:addBlip', function(data)
	local id = data
print("addblipgps")--DEBUG

	-- Is the player a cop? In that case show all the blips for stolen car
	if PlayerData.job ~= nil and PlayerData.job.name == 'police' then
			if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
				createBlip(id)
			end
	end

end)

RegisterNetEvent('esx_ownedcarthief:removeBlip')
AddEventHandler('esx_ownedcarthief:removeBlip', function(data)
	local id = data
print("remblipgps")--DEBUG
	-- Refresh all blips
	for k, existingBlip in pairs(carblips) do
		RemoveBlip(existingBlip)
	end
end)

Citizen.CreateThread(function()
		local blip = AddBlipForCoord(Config.Zones.PawnShop.Pos.x, Config.Zones.PawnShop.Pos.y, Config.Zones.PawnShop.Pos.z)
		SetBlipSprite (blip, 488)
		SetBlipDisplay(blip, 4)
		SetBlipColour (blip, 1)
		SetBlipScale  (blip, 1.2)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('pawn_shop_blip'))
		EndTextCommandSetBlipName(blip)
		
		while true do
		Citizen.Wait(0)
			DrawMarker(1,Config.Zones.PawnShop.Pos.x,Config.Zones.PawnShop.Pos.y,Config.Zones.PawnShop.Pos.z-1,0,0,0,0,0,0,5.001,5.0001,0.5001,255,0,0,200,0,0,0,0)
			
			
			if(isNear(Config.Zones.PawnShop.Pos)) then
				Info(_U('pawn_shop_menu'))
				if(IsControlJustPressed(1, 38)) then
				OpenPawnshopMenu()
				end
			end
			
		end

end)