-- Economizer HUD for FS22
--
-- Small HUD that shows current engine fuel usage.
--
-- Author: Bodzio528

EconomizerHUD = {}

EconomizerHUD.REFRESH_PERIOD = 250.0 -- milliseconds

EconomizerHUD.time = 0
EconomizerHUD.instantaneous = 0
EconomizerHUD.display = false

function EconomizerHUD:update(dt)
    if g_client ~= nil and g_currentMission.hud.isVisible and g_currentMission.controlledVehicle ~= nil then
        EconomizerHUD.time = EconomizerHUD.time + dt
        if EconomizerHUD.time > EconomizerHUD.REFRESH_PERIOD then
            EconomizerHUD.time = EconomizerHUD.time - EconomizerHUD.REFRESH_PERIOD
            
            EconomizerHUD.display = false

            local vehicle = g_currentMission.controlledVehicle.rootVehicle

            local isDieselMotor = (vehicle:getConsumerFillUnitIndex(FillType.DIESEL) ~= nil)
            if isDieselMotor then
                local spec = vehicle.spec_motorized
                if spec == nil then
                    return -- no motor!
                end
                
                local value = spec.lastFuelUsage
                if not spec.isMotorStarted then
                    value = 0.0
                end

                EconomizerHUD.instantaneous = string.format("%.1f l/h", value)
                EconomizerHUD.display = true
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
