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
local timer      = 0
local seconde    = 1000
local vehicle    = nil
local playerPed  = PlayerPedId()

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
		if IsControlJustReleased(0, Keys['F9']) and PlayerData.job ~= nil and PlayerData.job.name ~= 'police' then
			print("Appuier sur F9")---DEBUG
			if IsPedInAnyVehicle(playerPed, false) then
			else
				OpenMenu()
			end
		end
	end
end)

function OpenMenu()

    if PlayerData.job ~= nil and PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'concess'then
    local elements = {
      {label = _U('stolecar'), value = 'stolecar'}
    }

	if PlayerData.job ~= nil and PlayerData.job.name == 'concess' then
		table.insert(elements, {label = _U('resellcar'), value = 'resellcar'})
	end
	
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'car_robber_actions',
      {
        title    = _U('car_robber_menu'),
        align    = 'top-left',
        elements = elements
      },
      function(data, menu)
        if data.current.value == 'stolecar' then
          menu.close()
          StoleCar()
        end

        if data.current.value == 'resellcar' then
          menu.close()
		  --RACHETER UNE AUTO VOLER ICI
        end

      end,
      function(data, menu)
        menu.close()
      end
    )
  else
    ESX.ShowNotification(_U('not_experienced_enough'))
  end
end

function StoleCar()
print("Debut fonction StoleCar")---DEBUG
local coords    = GetEntityCoords(playerPed)
      vehicle   = ESX.Game.GetVehicleInDirection()


		if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
			TaskStartScenarioInPlace(playerPed, "prop_human_parking_meter", 0, true)
			ShowTimer()
			Citizen.Wait(timer/1.5)
			SetVehicleAlarm(vehicle, 1)
			StartVehicleAlarm(vehicle)
		end
end

function ShowTimer()
print("Debut fonction ShowTimer")---DEBUG
	timer = (60 * seconde)
	local stolecheck = false
	
	Citizen.CreateThread(function()
		while timer > 0 do
			Citizen.Wait(5)

			raw_seconds = timer/1000
			raw_minutes = raw_seconds/60
			minutes = stringsplit(raw_minutes, ".")[1]
			seconds = stringsplit(raw_seconds-(minutes*60), ".")[1]

			SetTextFont(4)
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
			local   succes     = math.random(1,2)

			ClearPedTasksImmediately(playerPed)
			print(succes)
			if vehicle == vehicle2 then
				if succes == 1 then
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					SetVehicleAlarm(vehicle, 1)
					StartVehicleAlarm(vehicle)
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