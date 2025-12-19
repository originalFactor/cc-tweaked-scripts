-- Flux network flux dust automation (partial)

while (true) do
    if rs.getInput("bottom") then
        goto continue
    end
    if turtle.detect() then
        turtle.dig()
    else
        local slot = 0
        for i = 1, 9 do
            if turtle.getItemCount(i) > 0 then
                slot = i
                break
            end
        end
        if slot > 0 then
            turtle.select(slot)
            turtle.drop()
        else
            turtle.suckUp()
        end
    end
    ::continue::
    sleep(1)
end
