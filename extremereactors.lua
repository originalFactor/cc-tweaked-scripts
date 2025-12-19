-- Extreme Reactors 2 auto-control (CC:Tweaked)
-- Reactor is on "back"
-- Monitor is on "right"

-- ===== Config =====
local interval = 1.0
local maxEnergyStoredPercent = 80
local minEnergyStoredPercent = 30


local reactor = peripheral.wrap("back")
if not reactor then error("No reactor attached on 'back'") end

local mon = peripheral.wrap("right")
if not mon then error("No monitor attached on 'right'") end
term.redirect(mon)

mon.setTextScale(0.8)
local w, h = mon.getSize()

term.setBackgroundColor(colors.black)
term.clear()

term.setCursorPos(1, 1)
term.write("Reactor: ")
term.setCursorPos(1, 2)
term.write("Energy: ")
term.setCursorPos(1, 3)
term.write("Fuel: ")
term.setCursorPos(1, 4)
term.write("Waste: ")
term.setCursorPos(1, 5)
term.write("Casing Temp: ")
term.setCursorPos(1, 6)
term.write("Fuel Temp: ")
term.setCursorPos(1, 7)
term.write("Energy Produce: ")
term.setCursorPos(1, 8)
term.write("Fuel Consume: ")

reactor.setActive(true)

while true do
    local energyPercent = math.floor(reactor.getEnergyStored() * 100 / reactor.getEnergyCapacity())

    if reactor.getActive() then
        if energyPercent > maxEnergyStoredPercent then
            reactor.setActive(false)
        end
    else
        if energyPercent < minEnergyStoredPercent then
            reactor.setActive(true)
        end
    end

    local l = 10
    local r = w - 6
    local wt = r - l

    local function prepare(y, x)
        x = x or l
        paintutils.drawFilledBox(x, y, w, y, colors.black)
        term.setCursorPos(x, y)
    end

    local function drawBar(y, a, b)
        prepare(y)
        term.write("[" .. string.rep("#", math.ceil(wt * a / b)))
        term.setCursorPos(r, y)
        term.write("] " .. string.format("%d%%", math.ceil(100 * a / b)))
    end

    prepare(1)
    term.write(reactor.getActive() and "ON" or "OFF")
    drawBar(2, reactor.getEnergyStored(), reactor.getEnergyCapacity())
    drawBar(3, reactor.getFuelAmount(), reactor.getFuelAmountMax())
    drawBar(4, reactor.getWasteAmount(), reactor.getFuelAmountMax())
    prepare(5, 17)
    term.write(string.format("%d C", reactor.getCasingTemperature()))
    prepare(6, 17)
    term.write(string.format("%d C", reactor.getFuelTemperature()))
    prepare(7, 17)
    term.write(string.format("%d FE/t", reactor.getEnergyProducedLastTick()))
    prepare(8, 17)
    term.write(string.format("%d mB/t", reactor.getFuelConsumedLastTick()))

    sleep(interval)
end
