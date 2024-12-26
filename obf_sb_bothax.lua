local webhook_url = "https://wb-sb-marsh-brandeds-projects.vercel.app/api/webhook"

local function sendWebhookUpdate(status_message)
    local data = "status=" .. status_message
    local response = MakeRequest(webhook_url, "POST", nil, data)
end 

local duration = Setting.Counter.Time_SB * 60
local endTime = os.time() + duration
local timetosb = 0
local killua = false
local used_gems = 0
local count_sb = 0
local remainingTime = endTime - os.time()
local minutes = math.floor(remainingTime / 60)
local startTime = os.date("%H:%M", endTime - duration)
local endTimeFormatted = os.date("%H:%M", endTime)

input=function(txt)
    SendPacket(2, "action|input\n|text|" .. txt)
end

FormatNumber=function(num)
    num = math.floor(num + 0.5)
    local formatted = tostring(num)
    local k = 3
    while k < #formatted do
        formatted = formatted:sub(1, #formatted - k) .. "," .. formatted:sub(#formatted - k + 1)
        k = k + 4
    end
    return formatted
end

layers=function(str) 
vars = {
            [0] = "OnTextOverlay", 
            [1] = str, 
        }
        SendVariantList(vars)
        end

AddHook("onvariant", "dontchange", function(var)
    if var[0] == "OnConsoleMessage" then
        if var[1]:find("`oBroadcasting to ALL!") then
            local m, s = var[1]:match("mod added, `%$(%d+) min, (%d+) secs")
            if m and s then
                modstime = tonumber(m) * 60 + tonumber(s)
            end
        end
        if var[1]:find("has been queued") then
            local min, sec = var[1]:match("Appears in ~(%d+) min[s]?, (%d+) sec[s]?")
            if min and sec then
                queuetime = tonumber(min) * 60 + tonumber(sec)
            else
                local mins = var[1]:match("Appears in ~(%d+) min[s]?")
                local secs = var[1]:match("Appears in ~(%d+) sec[s]?")
                if mins then
                    queuetime = tonumber(mins) * 60
                elseif secs then
                    queuetime = tonumber(secs)
                end
            end
            if queuetime and modstime and queuetime > modstime then
                timetosb = os.time() + queuetime + 2
            else
                timetosb = os.time() + modstime + 2
            end
            killua = true
        end
        if var[1]:find("sent. Used") then
            local gems = tonumber(var[1]:match("(%d+) Gems."))
            if gems then
                used_gems = used_gems + gems
            end
        end
        if var[1]:find("World Locked") then
        CheckPath(Position_SB.x, Position_SB.y)
        FindPath(Position_SB.x, Position_SB.y)
        end
    end
    if var[0] == "OnRequestWorldSelectMenu" then
        layers("Welcome back! You've rejoined the world!")
        RequestJoinWorld(Setting.World.Name)
        return true
    end    
    if var[0] == "OnSDBroadcast" then
    layers("`$[`4Block `3SDB`$]")
        return true
    end    
    return false
end)

getCountSB=function()
    if Setting.Mode.Use_Time then
        return count_sb .. " / 99999"
    elseif Setting.Mode.Use_Amount then
        return count_sb .. " / " .. Setting.Counter.Amount_SB
    end
end

getTimeSB=function()
	if Setting.Mode.Use_Time then
		return startTime .. " WIB / " .. endTimeFormatted .." WIB"
	elseif Setting.Mode.Use_Amount then
		return "Not Use Time"
	end
end

getModeCount=function()
	if Setting.Mode.Use_Time then
		return "Use Time"
	elseif Setting.Mode.Use_Amount then
		return "Use Amount"
	end
end

removeColorAndSymbols=function(str)
    cleanedStr = string.gsub(str, "`(%S)", '')
    cleanedStr = string.gsub(cleanedStr, "`{2}|(~{2})", '')
    return cleanedStr
end

local function updateStatus()
    local localPlayer = GetLocal()
    local world = GetWorld()
    if localPlayer == nil or world == nil then
        return
    end
    local playerName = localPlayer.name
    local cleanedName = removeColorAndSymbols(playerName)

    local status_message = 
        "<a:sccrowns:1319344571519471658>** PROFILE PLAYER** <a:sccrowns:1319344571519471658>\n" ..
        "<:sccs:1319343611376173156> **Username:** " .. cleanedName .. "\n" ..
        "<a:scwrldx:1319347904607031419> **Current World:** " .. world.name .. "\n" ..
        "<a:scgems:1319345793886457977> **Current Gems:** " .. FormatNumber(GetPlayerItems().gems) .. "\n\n" .. 
        "<a:sctoaa:1321319065805127731> **SB INFORMATION** <a:sctoaa:1321319065805127731>\n" ..
        "<:scgemsup:1321312856096112753> **Used Gems:** " .. FormatNumber(used_gems) .. "\n" ..
        "<a:scmp:1292067513076547749> **SB Count:** " .. getCountSB() .. "\n" ..
        "<a:scclock:1319636602091208765> **Time Count SB:** " .. getTimeSB() .. "\n" ..
        "<a:scload:1303962330362544150> **Mode Count SB:** " .. getModeCount() .. "\n" ..
        "<a:scbook:1319514312112341033> **Text SB:** " .. removeColorAndSymbols(Setting.Text_SB) .. "\n"
    sendWebhookUpdate(status_message)
    Sleep(1000)
end

sb=function()
    input("/sb " .. Setting.Text_SB .. " `$[`cMasD`b#`5SB`$]")
    Sleep(2500)

    if Setting.Mode.Use_Amount then
    input("`5SuperBroadcast (megaphone) `$sent `2successfully (cool)")
    Sleep(2500)
    count_sb = count_sb + 1
        input("`5SuperBroadcast (megaphone) `$[`cSB Count`$]: `2" .. count_sb .. " `$/ `4" .. Setting.Counter.Amount_SB .. "  `$[`cTotal Used Gems`$]: " .. FormatNumber(used_gems) .. " (gems)")
    end
    if Setting.Mode.Use_Time then
    input("`5SuperBroadcast (megaphone) `$sent `2successfully (cool)")
    Sleep(2500)
    count_sb = count_sb + 1
    input("`5SuperBroadcast (megaphone) `2Start: " .. startTime .. " `$/ `4End: " .. endTimeFormatted .. " `$[`1Time Left: `9" .. minutes .. " minutes`$]")
    Sleep(3000)
    input("`5SuperBroadcast (megaphone) `$[`cSB Count`$]: `2" .. count_sb .. " `$/ `499999 `$[`cTotal Used Gems`$]: " .. FormatNumber(used_gems) .. " (gems)")
end
updateStatus()
end

local success, allowed_ids = pcall(load(MakeRequest("https://raw.githubusercontent.com/marshget/allowed-ids/refs/heads/main/idsb.lua", "GET").content)) 
if success then
    local local_id = GetLocal().userid
    local isAllowed = false
    for _, id in ipairs(allowed_ids) do
        if local_id == id then
            isAllowed = true
            break
        end
    end
if isAllowed then
SendPacket(2, "action|input\n|text|`1Script `5SuperBroadcast `2Activated")
Sleep(1500)
SendPacket(2, "action|input\n|text|`1D`3i`1s`3c`1o`3r`1d `3: `1S`3c`1r`3i`1p`3t`1i`3n`1g `3C`1r`3e`1a`3t`1i`3v`1e`3P`1S")
Sleep(1500)
SendPacket(2, "action|input\n|text|/me Script Anti Crash Hanya di Discord: masd_16")
Sleep(2500)
sb()

while true do
    Sleep(100)
    if (Setting.Mode.Use_Time and os.time() > endTime) or (Setting.Mode.Use_Amount and count_sb >= Setting.Counter.Amount_SB) then
    Sleep(2500)
        input("`5SuperBroadcast (megaphone) `2session ended successfully (agree)")
        Sleep(2500)
       input("`^Thank you for trusting our SuperBroadcast service! We look forward to working with you again (love)")
       Sleep(3500)
       input("`3Want to buy scripts? `1Discord: masd_16")
       Sleep(3500)
        break
    end
    if os.time() > timetosb and killua then
        sb()
    end
    if GetWorld() and GetWorld().name ~= Setting.World.Name then
   	 if Setting.World.Name then
        layers("`4Invalid world! `9Warping back To `2" .. Setting.World.Name)
        Sleep(500)
        RequestJoinWorld(Setting.World.Name)
        Sleep(500)
        rept = true
    else
        LogToConsole("Error: Setting.World.Name is nil")
   	 end
	end
end
else
        wtrmk("`4ID anda tidak terdaftar")
    end
else
    wtrmk("Gagal memuat daftar ID")
end
