local onDuty = false
local infoShown = false
local delieveryShown = false
local activePassenger = false
local taxiBlip
local taxiPickups = {}
local taxiBlips = {}

----------------------- TAXI THREADS -----------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if onDuty and not activePassenger then
			for k,v in pairs(taxiPickups) do
				local pickupCoords = v.pickup
	
				while #(GetEntityCoords(PlayerPedId()) - pickupCoords) <= 15.0 do
					Citizen.Wait(0)
					ShowHelpText('Press ~INPUT_VEH_HORN~ to pickup the passenger')
					if IsControlJustReleased(0, 86) then
						--Unfreeze position
						FreezeEntityPosition(v.id, false)
	
						--Get player vehicle
						local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	
						--Notify
						if not infoShown then
							SuccessMessage('Passenger is entering your vehicle')
	
							--Make the ped walk to the vehicle
							SetPedIntoVehicle(v.id, playerVehicle, 2)
	
							-- Get street name
							local streetNameHash = GetStreetNameAtCoord(v.pickup.x, v.pickup.y, v.pickup.z)
							local streetName = GetStreetNameFromHashKey(streetNameHash)
	
							-- Show notification
							InfoMessage('Drive to ~b~' .. streetName)
	
							-- Set waypoint
							SetActiveWaypoint(v.dropoff.x, v.dropoff.y, v.dropoff.z)
	
							-- Set info shown to true
							infoShown = true
							delieveryShown = false
							activePassenger = true
						end
					end
				end
	
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if onDuty and activePassenger then
			for k,v in pairs(taxiPickups) do
				while #(GetEntityCoords(PlayerPedId()) - v.dropoff) <= 15.0 do
					Citizen.Wait(0)
					ShowHelpText('Press ~INPUT_VEH_HORN~ to drop the passenger off')
					if IsControlJustReleased(0, 86) then
						--Delete Entity
						DeleteEntity(v.id)
	
						--Show message
						if not delieveryShown then
							SuccessMessage('Delievery Complete!')
							delieveryShown = true
						end

						--Delete taxi blip
						RemoveBlip(taxiBlip)
	
						--Set info shown to false
						infoShown = false
						activePassenger = false
					end
				end
			end
		end
	end
end)

----------------------- EVENTS -----------------------
RegisterNetEvent('TaxiJob:Error')
AddEventHandler('TaxiJob:Error', function(errorDetails)
	ErrorMessage(errorDetails)
end)

RegisterNetEvent('TaxiJob:SetActiveDriver')
AddEventHandler('TaxiJob:SetActiveDriver', function()
	if onDuty then
		-- Go off duty
		InfoMessage('You are no longer a taxi driver!')

		-- Set the player job
		onDuty = false

		-- Delete the taxi items
		DeleteTaxiPickups()
		DeleteTaxiBlips()
	else
		-- Show success message
		SuccessMessage('You are now a taxi driver!')

		-- Set player job
		onDuty = true

		-- Run the Create Pickups Function
		CreateTaxiBlips()
		CreateTaxiPickups()
	end
end)

----------------------- FUNCTIONS -----------------------
function ShowHelpText(message)
	BeginTextCommandDisplayHelp("THREESTRINGS")
	AddTextComponentSubstringPlayerName(message)
    -- shape (always 0), loop (bool), makeSound (bool), duration (0 for loop)
    EndTextCommandDisplayHelp(0, false, false, 500)
end

function DrawGroundMarker(x, y, z)
	DrawMarker(25, x, y, z - 1, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 5.0, 5.0, 5.0, 3, 15, 250, 75, false, true, 2, nil, nil, false)
end

function sendChatMessage(message)
	TriggerEvent("chatMessage", "", {0, 0, 0}, "^7" .. message)
end

function SuccessMessage(successMessage)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName('~g~[SUCCESS]~w~ ' .. successMessage)
	DrawNotification(false, true)
end

function ErrorMessage(errorMessage)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName('~r~[ERROR]~w~ ' .. errorMessage)
	DrawNotification(false, true)
end

function InfoMessage(message)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName('~y~[INFO]~w~ ' .. message)
	DrawNotification(false, true)
end

function SetActiveWaypoint(x, y, z)
	taxiBlip = AddBlipForCoord(x,  y,  z)
	SetBlipRoute(taxiBlip, true) 
end

function CreateTaxiBlips()
	for k,v in pairs(Config.TaxiJob) do
		local blip = AddBlipForCoord(v.pickupCoord.x, v.pickupCoord.y, v.pickupCoord.z)
		SetBlipSprite(blip, 280)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 1.0)
		SetBlipColour(blip, 5)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Taxi Passenger')
		EndTextCommandSetBlipName(blip)
		table.insert(taxiBlips, blip)
	end
end

function CreateTaxiPickups()
	for k,v in pairs(Config.TaxiJob) do
		--Get player ped
		local playerPed = PlayerPedId()

		--Create random ped
		RequestModel('a_m_m_bevhills_01')

		-- Wait for driver model to load
		while not HasModelLoaded('a_m_m_bevhills_01') do
			Wait(500)
		end

		-- Get hash key
		local pickupPedHash = GetHashKey('a_m_m_bevhills_01')

		-- Create ped
		pickupPed = CreatePed(4, pickupPedHash, v.pickupCoord.x, v.pickupCoord.y, v.pickupCoord.z, GetEntityHeading(playerPed), true, true)

		--Add the ped to a table
		table.insert(taxiPickups,{name = v.name --[[STRING]], id = pickupPed --[[INT]], pickup = v.pickupCoord --[[VECTOR3]], dropoff = v.dropoffCoord --[[VECTOR3]]})

		--Set them as persistent
		SetEntityAsMissionEntity(pickupPed, true, true)

		--Wait
		Wait(5000)

		--Freeze their position
		FreezeEntityPosition(pickupPed, true)
	end
end

function DeleteTaxiPickups()
	for k,v in pairs(taxiPickups) do
		DeleteEntity(v.id)
	end
end

function DeleteTaxiBlips()
	for k,v in pairs(taxiBlips) do
		RemoveBlip(v)
	end
end