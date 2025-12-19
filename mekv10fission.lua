-- Mekanism V10 Fission Reactor Auto Controller for CC:Tweaked
-- Reactor is on "back"
-- Monitor is on "right"

-- ===== Config =====
local reactor = peripheral.wrap("back")
if not reactor then error("No reactor attached on 'back'") end

local mon = peripheral.wrap("left")
if not mon then error("No monitor attached on 'right'") end
term.redirect(mon)

mon.setTextScale(1)

local w, h, r

local function write(y, x, text)
    term.setCursorPos(x, y)
    term.write(text .. string.rep(" ", w - string.len(text)))
end

local function drawBar(y, x, percent)
    write(y, x, "[" .. string.rep("#", math.ceil((r - x) * percent / 100)))
    write(y, r, "] " .. string.format("%d%%", math.ceil(percent)))
end

local function initialize()
    term.setBackgroundColor(colors.black)
    term.clear()

    w, h = term.getSize()
    r = w - 6

    write(1, 1, "Reactor: ")
    write(2, 1, "Fuel: ")
    write(3, 1, "Water: ")
    write(4, 1, "Waste: ")
    write(5, 1, "Steam: ")
    write(6, 1, "Burn Rate: ")
    write(7, 1, "Heat Rate: ")
    write(8, 1, "Temperature: ")
    write(9, 1, "Damage: ")
end

initialize()

function monitorResize()
    while true do
        local event, side = os.pullEvent("monitor_resize")
        initialize()
    end
end

function mainLoop()
    while true do
        local coolantPercent = reactor.getCoolantFilledPercentage() * 100

        if reactor.getStatus() then
            if coolantPercent < 75 then
                reactor.scram()
            end
        else
            if coolantPercent > 95 then
                reactor.activate()
            end
        end

        write(1, 10, reactor.getStatus() and "ON" or "OFF")
        drawBar(2, 8, reactor.getFuelFilledPercentage() * 100)
        drawBar(3, 8, reactor.getCoolantFilledPercentage() * 100)
        drawBar(4, 8, reactor.getWasteFilledPercentage() * 100)
        drawBar(5, 8, reactor.getHeatedCoolantFilledPercentage() * 100)
        write(6, 12, string.format("%.2f mB/t", reactor.getActualBurnRate()))
        write(7, 12, string.format("%.2f mB/t", reactor.getHeatingRate()))
        write(8, 14, string.format("%.2f K", reactor.getTemperature()))
        drawBar(9, 9, reactor.getDamagePercent() * 100)

        sleep(1.0)
    end
end

parallel.waitForAny(mainLoop, monitorResize)
