function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayWeapon(weapon,distance,flag)
    local cameraRotation = GetGameplayCamRot()

    local weapCoord = GetEntityCoords(weapon)

    local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =  vector3(cameraCoord.x + direction.x * distance,
		cameraCoord.y + direction.y * distance,
		cameraCoord.z + direction.z * distance
    )
    if not flag then
        flag = 1
    end

	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(weapCoord.x, weapCoord.y, weapCoord.z, destination.x, destination.y, destination.z, flag, -1, 1))
	return b, c, e, destination
end

function RayCastGamePlayCamera(distance,flag)
    local cameraRotation = GetGameplayCamRot()

    local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =  vector3(cameraCoord.x + direction.x * distance,
		cameraCoord.y + direction.y * distance,
		cameraCoord.z + direction.z * distance
    )
    if not flag then
        flag = 1
    end

	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, flag, -1, 1))
	return b, c, e, destination
end

local function Draw3DText(text)

        SetTextScale(0.3, 0.3)
        SetTextFont(0)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(0.5,0.5)

end


local loopRunning = false

local showText = Config.All['displaytext'] and Config.All['text'] ~= nil
local textToShow = Config.All['text'] or "Blocked"

local function runLoop()
    if loopRunning then return end
    loopRunning = true
    CreateThread(function()
        local weapon, sleep
        while loopRunning do
            sleep = 500
            weapon = GetCurrentPedWeaponEntityIndex(cache.ped)

            if weapon > 0 and IsPlayerFreeAiming(cache.playerId) then
                local hitW, coordsW, entityW = RayCastGamePlayWeapon(weapon, 15.0, 1)
                local _, coordsC = RayCastGamePlayCamera(1000.0, 1)
                -- local _, _, coordsC = lib.raycast.fromCamera(1000.0, 1)
                if hitW > 0 and entityW > 0 and math.abs(#coordsW-#coordsC) > 1 then
                    sleep = 0
                    if showText then
                        Draw3DText(textToShow)
                    end
                    DisablePlayerFiring(cache.ped, true)
                    DisableControlAction(0, 106, true)
                end
            else
                Wait(1000)
            end
            Wait(sleep)
        end
    end)
end

lib.onCache('weapon', function(weapon)
    if weapon then
        runLoop()
    else
        loopRunning = false
    end
end)

if cache.weapon then
    runLoop()
end