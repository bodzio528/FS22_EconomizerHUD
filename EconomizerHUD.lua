-- Economizer HUD for FS22
--
-- Small HUD that shows current engine fuel usage.
--
-- Author: Bodzio528

EconomizerHUD = {
    REFRESH_PERIOD = 250.0 -- milliseconds
}

EconomizerHUD.time = 0
EconomizerHUD.instantaneous = 0
EconomizerHUD.display = false

-- call it only on multiplayer client
function EconomizerHUD:updateConsumers(vehicle, dt)
    local spec = vehicle.spec_motorized
    local idleFactor = 0.5
    local rpmPercentage = (spec.motor.lastMotorRpm - spec.motor.minRpm) / (spec.motor.maxRpm - spec.motor.minRpm)
    local rpmFactor = idleFactor + rpmPercentage * (1 - idleFactor)
    local loadFactor = math.max(spec.smoothedLoadPercentage * rpmPercentage, 0)
    local motorFactor = 0.5 * (0.2 * rpmFactor + 1.8 * loadFactor)
    local usageFactor = 1.5

    if g_currentMission.missionInfo.fuelUsage == 1 then
        usageFactor = 1
    elseif g_currentMission.missionInfo.fuelUsage == 3 then
        usageFactor = 2.5
    end

    local damage = vehicle:getVehicleDamage()

    if damage > 0 then
        usageFactor = usageFactor * (1 + damage * Motorized.DAMAGED_USAGE_INCREASE)
    end

    local consumer = spec.consumersByFillTypeName.DIESEL
    if consumer.permanentConsumption and consumer.usage > 0 then
        local used = usageFactor * motorFactor * consumer.usage * dt

        spec.lastFuelUsage = used / dt * 1000 * 60 * 60 -- liters per hour
    end
end

function EconomizerHUD:update(dt)
    if g_client ~= nil and g_currentMission.hud.isVisible and g_currentMission.controlledVehicle ~= nil then
        EconomizerHUD.time = EconomizerHUD.time + dt
        if EconomizerHUD.time > EconomizerHUD.REFRESH_PERIOD then
            EconomizerHUD.time = EconomizerHUD.time - EconomizerHUD.REFRESH_PERIOD

            local vehicle = g_currentMission.controlledVehicle.rootVehicle

            local isDieselMotor = (vehicle:getConsumerFillUnitIndex(FillType.DIESEL) ~= nil)
            if isDieselMotor then
                local spec = vehicle.spec_motorized -- vehicle.spec_economizer
                if spec == nil then
                    return -- no economizer!
                end

                if not vehicle.isServer then
                    self:updateConsumers(vehicle, dt)
                end

                local value = spec.lastFuelUsage or 0.0
                if not spec.isMotorStarted then
                    value = 0.0
                end

                EconomizerHUD.instantaneous = string.format("%.1f l/h", value)
                EconomizerHUD.display = true
            else
                EconomizerHUD.display = false
            end
        end
    else
        EconomizerHUD.display = false
    end
end

function EconomizerHUD:draw()
    if g_client ~= nil and EconomizerHUD.display then
        -- calculate gauge position -> take it from speed'o'meter hud display
        local baseX, baseY = g_currentMission.inGameMenu.hud.speedMeter:getBasePosition()
        local posX, posY = getNormalizedScreenValues(unpack(SpeedMeterDisplay.POSITION.FUEL_LEVEL_ICON))

        local size = 0.013 * g_gameSettings.uiScale

        -- render
        setTextColor(1,1,1,1)
        setTextAlignment(RenderText.ALIGN_RIGHT)
        setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
        setTextBold(false)
        renderText(baseX + posX, baseY + posY, size, EconomizerHUD.instantaneous)

        -- Back to defaults
        setTextColor(1,1,1,1)
        setTextAlignment(RenderText.ALIGN_LEFT)
        setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
        setTextBold(false)
    end
end

addModEventListener(EconomizerHUD)
