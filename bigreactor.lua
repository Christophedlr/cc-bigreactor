-- Big Reactor Manager
-- By Christophe Daloz - De Los Rios <christophedlr@gmail.com>
-- This file is under MIT License, see the LICENSE in github project

local reactor = peripheral.wrap("back")
local mon = peripheral.wrap("top")
local input = nil
local settings = {}
local commandActivate=false

--Write text in monitor with selected color and place cursor in new line
function writeln(text, color)
	color = color or colors.white
	local x, y = mon.getCursorPos()
	
	mon.setTextColor(color)
	mon.write(text)
	mon.setCursorPos(1, y+1)
end

--Write text in monitor with selected color
function write(text, color)
	color = color or colors.white
	
	mon.setTextColor(color)
	mon.write(text)
end

--Format number
function commavalue(amount)
  local formatted = amount
    while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

--Split string in table
function split(inputStr, separator)
        local t={}
        separator = separator or "%s"

        for str in string.gmatch(inputStr, "([^"..separator.."]+)") do
                table.insert(t, str)
        end

        return t
end

--Round number with selected decimal
function round(val, decimal)
  if (decimal) then
    return math.floor( (val*10^decimal)+0.5)/(10^decimal)
  else
    return math.floor(val+0.5)
  end
end

--Format number with decimal, separator and suffix
function formatNumber(number, decimal, separator, suffix)
	decimal = decimal or 2
	separator = separator or false
	suffix = suffix or ""
	local newNumber = round(number, decimal)

	if (separator == true) then
		newNumber = commavalue(newNumber)
	end

	return newNumber.." "..suffix
end

--Get global level of fuel rod
function getFuelRodLevel()
	local nbFuelRod = reactor.getNumberOfControlRods()
	local nb = 0

	for i=0,nbFuelRod-1 do
		nb = nb+reactor.getControlRodLevel(i)
	end

	return nb/nbFuelRod
end

--Get color for display energy stored
function getEnergyColor()
	local energyAmount = reactor.getEnergyStored()

	if (energyAmount <= 1000000) then
		return colors.red
	elseif (energyAmount <= 2500000) then
		return colors.magenta
	elseif (energyAmount <= 5000000) then
		return colors.orange
	elseif (energyAmount <= 7500000) then
		return colors.lime
	elseif (energyAmount <= 9500000) then
		return colors.purple
	else
		return colors.red
	end
end

--Load configuration
function loadConfig()
	if (fs.exists("reactor.cfg") == false) then
		return
	end

	local file = fs.open("reactor.cfg", "r")
	settings = textutils.unserialize(file.readAll())
	file.close()
end

--Apply configuration
function applyConfig()
	if (settings["energy.level.stop"] ~= nil and reactor.getEnergyStored() >= tonumber(settings["energy.level.stop"]) and commandActivate == false) then
		reactor.setActive(false)
	end

	if (settings["energy.level.start"] ~= nil and reactor.getEnergyStored() <= tonumber(settings["energy.level.start"]) and commandActivate == false) then
		reactor.setActive(true)
	end
end

--Menu
function startMenu()
	while true do
		local state = reactor.getActive()

		mon.clear()
		mon.setCursorPos(1, 1)

		if (reactor.getConnected() ~= true) then
			writeln("Reactor not found")
			return
		end

		write("State: ")
		
		if (state) then writeln("active", colors.green)
		else writeln("inactive", colors.red)
		end

		write("Energy stored: ")
		writeln(formatNumber(reactor.getEnergyStored(), 2, true, "RF"), getEnergyColor())
		writeln("Fuel: "..formatNumber(reactor.getFuelAmount(), 2, true, "mB").."/"..formatNumber(reactor.getFuelAmountMax(), 2, true, "mB"))
		writeln("Production: "..formatNumber(reactor.getEnergyProducedLastTick(), 2, true, "RF/t"))
		writeln("Fuel rod control: "..formatNumber(getFuelRodLevel(), 0, false, "%"))

		applyConfig()

		sleep(1)
	end
end

--Read text in computer input
function events()
	term.write("> ")
	input = read()
end

term.clear()
term.setCursorPos(1, 1)
loadConfig()
print("Big reactor Manager v1.0")

while true do
	parallel.waitForAny(startMenu, events)

	if (input == "end") then
		mon.clear()
		mon.setCursorPos(1, 1)
		
		term.clear()
		term.setCursorPos(1, 1)
		break
	elseif (input == "start") then
		if (reactor.getActive() == false) then
			reactor.setActive(true)
			commandActivate = true
		else
			print("Reactor is being activated")
		end
	elseif (input == "stop") then
		if (reactor.getActive() == true) then
			reactor.setActive(false)
			commandActivate = true
		else
			print("Reactor is being deactivated")
		end
	elseif (input == "insertion") then
		print("Insertion fuel rod")
		events()
		reactor.setAllControlRodLevels(tonumber(input))
		print("Insertion end, display prompt")
	elseif (input == "settings") then
		print("Settings")
		while true do
			events()

			if (input == "energy.level.stop") then
				print("Energy stop level:")
				events()
				settings["energy.level.stop"] = tonumber(input)
				print("Energy stop level end")
			elseif (input == "energy.level.start") then
				print("Energy start level:")
				events()
				settings["energy.level.start"] = tonumber(input)
				print("Energy start level end")
			elseif (input == "save") then
				print("Save config")
				local file = fs.open("reactor.cfg", "w")
				file.write(textutils.serialize(settings))
				file.close()
			elseif (input == "load" or input == "reload") then
				print("Reload config")
				local file = fs.open("reactor.cfg", "r")
				settings = textutils.unserialize(file.readAll())
				file.close()
			elseif (input == "end") then
				print("End of settings")
				break
			else
				print("Invalid setting")
			end
		end
	elseif (input == "reinit") then
		commandActivate = false
	end
end
