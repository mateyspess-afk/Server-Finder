--[[
    SERVER FINDER - RESPONSIVE EDITION

    Melhorias desta versão:
    - Escala automática baseada no tamanho real da tela.
    - Layout centrado, arrastável, minimizável e compatível com toque.
    - Loading renovado com progresso, animação e botão "entrar agora".
    - Liberação condicionada ao follow do criador, com verificação automática.
    - Abas Configs e Info com temas salvos, detalhes do script e acesso ao Discord.
    - Mantém busca de servidores, busca de usuário verificado e chatbot local.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PLACE_ID = 4924922222
local GUARD_VERSION = "v1"
local WRONG_GAME_MESSAGE = [[🇧🇷 você não está no jogo correto vá para o Brookhaven para usar o script
🇺🇸 You're not in the correct game. Go to Brookhaven to use the script.]]

local function isBrookhaven()
    return (tonumber(game.PlaceId) or -1) == PLACE_ID
end

local function kickFromWrongGame()
    warn("[Server-Finder " .. GUARD_VERSION .. "] Jogo incorreto. PlaceId: " .. tostring(game.PlaceId))
    pcall(function()
        if Player and Player.Parent then
            Player:Kick(WRONG_GAME_MESSAGE)
        end
    end)
    -- Segunda tentativa para executores que atrasam a primeira chamada.
    task.delay(0.25, function()
        pcall(function()
            if Player and Player.Parent then
                Player:Kick(WRONG_GAME_MESSAGE)
            end
        end)
    end)
end

if not isBrookhaven() then
    kickFromWrongGame()
    return
end

local BASE_WIDTH = 720
local BASE_HEIGHT = 460
local MIN_SCALE = 0.55
local MAX_SCALE = 1
local MAX_USER_SCALE = 1.35
local CREATOR_USERNAME = "mateus_15600"
local CREATOR_PROFILE_URL = "https://www.roblox.com/users/profile?username=" .. CREATOR_USERNAME
local DISCORD_INVITE = "https://discord.gg/RtfAn6zku8"
local DISCORD_INVITE_CODE = "RtfAn6zku8"

local Config = {
    botName = "NOVA",
    userName = Player.DisplayName or Player.Name,
    blacklistTime = 300,
    maxPages = 5,
    maxRegionChecks = 15,
    regionCacheTime = 600,
}

-- Preferências visuais ficam no diretório de arquivos do executor.
-- O script continua funcionando mesmo em executores sem readfile/writefile:
-- nesse caso o tema vale para a sessão atual e a interface informa o motivo.
local CONFIG_FILE = "ServerFinder_Config.json"
local Themes = {
    Midnight = {
        label = "Midnight",
        description = "Azul escuro com ciano",
        preview = Color3.fromRGB(35, 168, 205),
        colors = {
            window = Color3.fromRGB(15, 18, 27),
            header = Color3.fromRGB(25, 30, 44),
            sidebar = Color3.fromRGB(20, 24, 35),
            panel = Color3.fromRGB(23, 28, 41),
            panelAlt = Color3.fromRGB(20, 24, 36),
            deep = Color3.fromRGB(15, 19, 29),
            surface = Color3.fromRGB(28, 31, 42),
            popup = Color3.fromRGB(29, 32, 44),
            notice = Color3.fromRGB(29, 34, 47),
            discordCard = Color3.fromRGB(31, 35, 55),
            input = Color3.fromRGB(35, 38, 50),
            tab = Color3.fromRGB(40, 43, 57),
            tabHover = Color3.fromRGB(54, 60, 79),
            neutral = Color3.fromRGB(76, 82, 103),
            mutedButton = Color3.fromRGB(65, 70, 88),
            resize = Color3.fromRGB(42, 49, 67),
            overlay = Color3.fromRGB(8, 10, 17),
            loadingBar = Color3.fromRGB(37, 44, 62),
            infoButton = Color3.fromRGB(42, 57, 75),
            avatar = Color3.fromRGB(48, 52, 68),
            primary = Color3.fromRGB(0, 135, 190),
            success = Color3.fromRGB(0, 145, 75),
            successAlt = Color3.fromRGB(28, 118, 92),
            purple = Color3.fromRGB(120, 55, 190),
            warning = Color3.fromRGB(205, 115, 0),
            danger = Color3.fromRGB(190, 55, 65),
            discord = Color3.fromRGB(88, 101, 242),
            accent = Color3.fromRGB(75, 218, 225),
            accentStrong = Color3.fromRGB(0, 190, 230),
            border = Color3.fromRGB(70, 93, 125),
            text = Color3.fromRGB(245, 245, 250),
            textBright = Color3.fromRGB(245, 248, 255),
            textMuted = Color3.fromRGB(165, 170, 190),
            textDim = Color3.fromRGB(120, 145, 170),
            textAccent = Color3.fromRGB(185, 240, 240),
            textSuccess = Color3.fromRGB(145, 240, 180),
            textWarning = Color3.fromRGB(255, 215, 125),
            textDanger = Color3.fromRGB(240, 130, 130),
        },
    },
    Ocean = {
        label = "Ocean",
        description = "Azul profundo e turquesa",
        preview = Color3.fromRGB(39, 188, 214),
        colors = {
            window = Color3.fromRGB(8, 20, 34),
            header = Color3.fromRGB(11, 38, 58),
            sidebar = Color3.fromRGB(8, 30, 48),
            panel = Color3.fromRGB(12, 43, 63),
            panelAlt = Color3.fromRGB(10, 36, 55),
            deep = Color3.fromRGB(6, 24, 39),
            surface = Color3.fromRGB(16, 54, 72),
            popup = Color3.fromRGB(14, 47, 66),
            notice = Color3.fromRGB(18, 55, 70),
            discordCard = Color3.fromRGB(24, 48, 78),
            input = Color3.fromRGB(20, 59, 76),
            tab = Color3.fromRGB(17, 57, 76),
            tabHover = Color3.fromRGB(23, 79, 98),
            neutral = Color3.fromRGB(47, 78, 96),
            mutedButton = Color3.fromRGB(36, 66, 85),
            resize = Color3.fromRGB(20, 65, 87),
            overlay = Color3.fromRGB(4, 15, 27),
            loadingBar = Color3.fromRGB(19, 60, 80),
            infoButton = Color3.fromRGB(17, 65, 83),
            avatar = Color3.fromRGB(25, 67, 85),
            primary = Color3.fromRGB(0, 145, 190),
            success = Color3.fromRGB(0, 155, 125),
            successAlt = Color3.fromRGB(10, 126, 117),
            purple = Color3.fromRGB(74, 94, 190),
            warning = Color3.fromRGB(198, 119, 23),
            danger = Color3.fromRGB(178, 58, 78),
            discord = Color3.fromRGB(78, 105, 218),
            accent = Color3.fromRGB(55, 220, 225),
            accentStrong = Color3.fromRGB(0, 194, 225),
            border = Color3.fromRGB(46, 111, 139),
            text = Color3.fromRGB(235, 249, 255),
            textBright = Color3.fromRGB(240, 252, 255),
            textMuted = Color3.fromRGB(163, 201, 215),
            textDim = Color3.fromRGB(116, 161, 181),
            textAccent = Color3.fromRGB(169, 245, 242),
            textSuccess = Color3.fromRGB(143, 241, 202),
            textWarning = Color3.fromRGB(255, 215, 130),
            textDanger = Color3.fromRGB(255, 143, 150),
        },
    },
    Emerald = {
        label = "Emerald",
        description = "Verde escuro com aqua",
        preview = Color3.fromRGB(52, 201, 146),
        colors = {
            window = Color3.fromRGB(12, 25, 24),
            header = Color3.fromRGB(19, 45, 40),
            sidebar = Color3.fromRGB(13, 35, 31),
            panel = Color3.fromRGB(18, 50, 43),
            panelAlt = Color3.fromRGB(16, 43, 39),
            deep = Color3.fromRGB(9, 29, 28),
            surface = Color3.fromRGB(28, 61, 52),
            popup = Color3.fromRGB(22, 54, 47),
            notice = Color3.fromRGB(34, 64, 48),
            discordCard = Color3.fromRGB(32, 53, 67),
            input = Color3.fromRGB(28, 65, 55),
            tab = Color3.fromRGB(26, 61, 52),
            tabHover = Color3.fromRGB(38, 85, 69),
            neutral = Color3.fromRGB(59, 86, 78),
            mutedButton = Color3.fromRGB(48, 76, 68),
            resize = Color3.fromRGB(35, 76, 65),
            overlay = Color3.fromRGB(5, 19, 18),
            loadingBar = Color3.fromRGB(28, 69, 60),
            infoButton = Color3.fromRGB(30, 77, 70),
            avatar = Color3.fromRGB(38, 73, 64),
            primary = Color3.fromRGB(0, 155, 164),
            success = Color3.fromRGB(21, 164, 103),
            successAlt = Color3.fromRGB(29, 133, 93),
            purple = Color3.fromRGB(112, 78, 178),
            warning = Color3.fromRGB(191, 122, 22),
            danger = Color3.fromRGB(179, 58, 69),
            discord = Color3.fromRGB(77, 111, 207),
            accent = Color3.fromRGB(86, 222, 192),
            accentStrong = Color3.fromRGB(25, 202, 177),
            border = Color3.fromRGB(59, 111, 99),
            text = Color3.fromRGB(238, 250, 244),
            textBright = Color3.fromRGB(243, 255, 249),
            textMuted = Color3.fromRGB(166, 204, 187),
            textDim = Color3.fromRGB(119, 161, 145),
            textAccent = Color3.fromRGB(164, 244, 220),
            textSuccess = Color3.fromRGB(146, 242, 181),
            textWarning = Color3.fromRGB(255, 220, 132),
            textDanger = Color3.fromRGB(255, 145, 145),
        },
    },
    Sunset = {
        label = "Sunset",
        description = "Roxo quente e laranja",
        preview = Color3.fromRGB(236, 127, 87),
        colors = {
            window = Color3.fromRGB(29, 16, 28),
            header = Color3.fromRGB(54, 25, 43),
            sidebar = Color3.fromRGB(39, 20, 36),
            panel = Color3.fromRGB(59, 27, 47),
            panelAlt = Color3.fromRGB(49, 23, 43),
            deep = Color3.fromRGB(27, 14, 27),
            surface = Color3.fromRGB(72, 34, 54),
            popup = Color3.fromRGB(65, 29, 48),
            notice = Color3.fromRGB(76, 39, 47),
            discordCard = Color3.fromRGB(57, 32, 67),
            input = Color3.fromRGB(78, 36, 55),
            tab = Color3.fromRGB(70, 32, 55),
            tabHover = Color3.fromRGB(102, 46, 70),
            neutral = Color3.fromRGB(105, 62, 78),
            mutedButton = Color3.fromRGB(84, 48, 70),
            resize = Color3.fromRGB(91, 45, 68),
            overlay = Color3.fromRGB(19, 9, 19),
            loadingBar = Color3.fromRGB(81, 39, 61),
            infoButton = Color3.fromRGB(92, 44, 65),
            avatar = Color3.fromRGB(82, 44, 66),
            primary = Color3.fromRGB(191, 71, 135),
            success = Color3.fromRGB(196, 100, 53),
            successAlt = Color3.fromRGB(157, 79, 67),
            purple = Color3.fromRGB(148, 69, 190),
            warning = Color3.fromRGB(224, 111, 35),
            danger = Color3.fromRGB(195, 56, 73),
            discord = Color3.fromRGB(111, 83, 211),
            accent = Color3.fromRGB(239, 139, 112),
            accentStrong = Color3.fromRGB(235, 93, 119),
            border = Color3.fromRGB(132, 71, 103),
            text = Color3.fromRGB(255, 242, 246),
            textBright = Color3.fromRGB(255, 246, 239),
            textMuted = Color3.fromRGB(222, 178, 190),
            textDim = Color3.fromRGB(174, 126, 148),
            textAccent = Color3.fromRGB(255, 203, 184),
            textSuccess = Color3.fromRGB(191, 241, 174),
            textWarning = Color3.fromRGB(255, 215, 138),
            textDanger = Color3.fromRGB(255, 151, 157),
        },
    },
}

local ThemeBindings = {}
local ThemeButtons = {}
local TabButtons = {}
local TabIndicators = {}
local TabStrokes = {}
local ThemeStatus
local InfoTab
local currentThemeName = "Midnight"

local function isTheme(name)
    return type(name) == "string" and Themes[name] ~= nil
end

local function loadSavedTheme()
    if type(readfile) ~= "function" then
        return "Midnight"
    end

    local ok, raw = pcall(readfile, CONFIG_FILE)
    if not ok or type(raw) ~= "string" or raw == "" then
        return "Midnight"
    end

    local decodedOk, decoded = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if decodedOk and type(decoded) == "table" and isTheme(decoded.theme) then
        return decoded.theme
    end
    return "Midnight"
end

Config.theme = loadSavedTheme()
currentThemeName = Config.theme

local function saveTheme()
    if type(writefile) ~= "function" then
        return false, "Este executor não permite salvar arquivos."
    end

    local ok, errorMessage = pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            theme = Config.theme,
        }))
    end)
    if not ok then
        return false, tostring(errorMessage)
    end
    return true
end

local function colorKey(color)
    if typeof(color) ~= "Color3" then
        return nil
    end
    return string.format(
        "%d,%d,%d",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    )
end

local BackgroundRoles = {
    ["15,18,27"] = "window",
    ["25,30,44"] = "header",
    ["20,24,35"] = "sidebar",
    ["23,28,41"] = "panel",
    ["20,24,36"] = "panelAlt",
    ["15,19,29"] = "deep",
    ["28,31,42"] = "surface",
    ["29,32,44"] = "popup",
    ["29,34,47"] = "notice",
    ["31,35,55"] = "discordCard",
    ["35,38,50"] = "input",
    ["40,43,57"] = "tab",
    ["54,60,79"] = "tabHover",
    ["76,82,103"] = "neutral",
    ["65,70,88"] = "mutedButton",
    ["42,49,67"] = "resize",
    ["8,10,17"] = "overlay",
    ["37,44,62"] = "loadingBar",
    ["42,57,75"] = "infoButton",
    ["48,52,68"] = "avatar",
    ["0,135,190"] = "primary",
    ["0,145,75"] = "success",
    ["28,118,92"] = "successAlt",
    ["120,55,190"] = "purple",
    ["205,115,0"] = "warning",
    ["190,55,65"] = "danger",
    ["88,101,242"] = "discord",
}

local TextRoles = {
    ["245,245,250"] = "text",
    ["245,248,255"] = "textBright",
    ["240,240,245"] = "textBright",
    ["255,255,255"] = "textBright",
    ["215,218,230"] = "text",
    ["205,215,235"] = "text",
    ["165,170,190"] = "textMuted",
    ["155,190,205"] = "textMuted",
    ["145,148,165"] = "textMuted",
    ["185,190,210"] = "textMuted",
    ["175,180,200"] = "textMuted",
    ["120,145,170"] = "textDim",
    ["115,190,210"] = "textAccent",
    ["120,220,220"] = "textAccent",
    ["185,240,240"] = "textAccent",
    ["120,230,220"] = "textAccent",
    ["150,210,255"] = "textAccent",
    ["225,210,110"] = "textWarning",
    ["255,215,125"] = "textWarning",
    ["145,240,180"] = "textSuccess",
    ["170,240,185"] = "textSuccess",
    ["160,230,175"] = "textSuccess",
    ["240,130,130"] = "textDanger",
}

local StrokeRoles = {
    ["70,82,110"] = "border",
    ["70,93,125"] = "border",
    ["63,76,103"] = "border",
    ["78,93,122"] = "border",
    ["75,92,122"] = "border",
    ["98,105,135"] = "border",
    ["92,190,220"] = "accent",
    ["105,112,220"] = "purple",
    ["220,178,82"] = "warning",
    ["0,190,230"] = "accentStrong",
    ["255,255,255"] = "textBright",
}

local function inferThemeRole(className, property, value)
    local key = colorKey(value)
    if not key then
        return nil
    end
    if property == "BackgroundColor3" then
        return BackgroundRoles[key]
    end
    if property == "TextColor3" then
        return TextRoles[key]
    end
    if className == "UIStroke" and property == "Color" then
        return StrokeRoles[key]
    end
    return nil
end

local function applyTheme(name)
    if not isTheme(name) then
        name = "Midnight"
    end

    Config.theme = name
    currentThemeName = name
    local colors = Themes[name].colors
    for _, binding in ipairs(ThemeBindings) do
        if binding.object and binding.object.Parent and colors[binding.role] then
            pcall(function()
                binding.object[binding.property] = colors[binding.role]
            end)
        end
    end

    for _, themeButton in ipairs(ThemeButtons) do
        if themeButton.button and themeButton.button.Parent then
            local selected = themeButton.name == name
            themeButton.button.BackgroundColor3 = selected
                and colors.primary
                or colors.tab
            themeButton.button.TextColor3 = colors.textBright
            themeButton.button.Text = selected
                and "✓  " .. themeButton.label .. "\n" .. Themes[themeButton.name].description
                or themeButton.label .. "\n" .. Themes[themeButton.name].description
            if themeButton.preview and themeButton.preview.Parent then
                themeButton.preview.BackgroundColor3 = Themes[themeButton.name].preview
            end
        end
    end

    for tabName, button in pairs(TabButtons) do
        local activeColor = tabName == "Configs" and colors.purple or colors.primary
        button:SetAttribute("ActiveColor", activeColor)
        if TabIndicators[tabName] then
            TabIndicators[tabName].BackgroundColor3 = activeColor
        end
    end
    if InfoTab and InfoTab.Parent then
        InfoTab.BackgroundColor3 = InfoTab:GetAttribute("IsActive")
            and colors.primary
            or colors.infoButton
        InfoTab.TextColor3 = InfoTab:GetAttribute("IsActive")
            and colors.textBright
            or colors.textAccent
    end

    if ThemeStatus and ThemeStatus.Parent then
        ThemeStatus.Text = "Tema atual: " .. Themes[name].label
        ThemeStatus.TextColor3 = colors.textSuccess
    end
end

local blacklist = {}
local regionCache = {}
local regionApiUnavailable = false
local searching = false
local teleportFailed = false
local destroyed = false
local loadingConnection
local inputChangedConnection
local teleportInitFailedConnection
local creatorUserId
local followUnlocked = false
local followChecking = false
local followGateVisible = true
local FOLLOW_LOADING_MIN_SECONDS = 3
local followGateStartedAt = os.clock()
local currentScale = 1
local manualScale = 1
local SearchStatus

local function create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
        local role = inferThemeRole(className, property, value)
        if role then
            table.insert(ThemeBindings, {
                object = object,
                property = property,
                role = role,
            })
        end
    end
    object.Parent = parent
    return object
end

local function corner(object, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius)}, object)
end

local function stroke(object, color, thickness, transparency)
    return create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, object)
end

local function styleButton(button, color, hoverColor)
    button.AutoButtonColor = false
    stroke(button, Color3.fromRGB(255, 255, 255), 1, 0.82)
    local themeRole = inferThemeRole("TextButton", "BackgroundColor3", color)
    local function baseColor()
        return themeRole and Themes[currentThemeName].colors[themeRole] or color
    end
    local function hoverButtonColor()
        local selectedColor = baseColor()
        return Color3.new(
            math.min(selectedColor.R * 1.15 + 0.03, 1),
            math.min(selectedColor.G * 1.15 + 0.03, 1),
            math.min(selectedColor.B * 1.15 + 0.03, 1)
        )
    end
    button.MouseEnter:Connect(function()
        if button.Active ~= false then
            button.BackgroundColor3 = themeRole and hoverButtonColor() or (hoverColor or color)
        end
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = baseColor()
    end)
    return button
end

local function disableButton(button, color)
    button.Active = false
    button.Selectable = false
    button.AutoButtonColor = false
    button.BackgroundColor3 = color
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = color
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = color
    end)
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function setStatus(label, text, color)
    if label and label.Parent then
        label.Text = tostring(text)
        if color then
            label.TextColor3 = color
        end
    end
end

local function urlEncode(value)
    return tostring(value):gsub("([^%w%-_%.~])", function(character)
        return string.format("%%%02X", string.byte(character))
    end)
end

local function getRequester()
    if type(request) == "function" then
        return request
    end
    if type(syn) == "table" and type(syn.request) == "function" then
        return syn.request
    end
    if type(http) == "table" and type(http.request) == "function" then
        return http.request
    end
    if type(http_request) == "function" then
        return http_request
    end
    return nil
end

local HTTP_TIMEOUT = 12

local function responseBody(response)
    if type(response) == "string" then
        if response ~= "" then
            return response
        end
        error("Resposta HTTP vazia.")
    end
    if type(response) == "table" then
        local status = tonumber(response.StatusCode or response.Status) or 200
        if status >= 400 then
            error("Erro HTTP " .. tostring(status))
        end
        local body = response.Body or response.body
        if type(body) == "string" and body ~= "" then
            return body
        end
    end
    error("Resposta HTTP inválida ou vazia.")
end

local function httpGet(url)
    local lastError

    -- Muitos executores só conseguem consultar as APIs do Roblox via game:HttpGet.
    if type(game.HttpGet) == "function" then
        local ok, result = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and type(result) == "string" and result ~= "" then
            return result
        end
        lastError = ok and "A resposta HTTP veio vazia." or result
    end

    -- request é alternativa com timeout para executores sem HttpGet funcional.
    local requester = getRequester()
    if requester then
        local ok, response = pcall(requester, {
            Url = url,
            Method = "GET",
            Timeout = HTTP_TIMEOUT,
        })
        if not ok then
            error(lastError or response)
        end
        local bodyOk, body = pcall(responseBody, response)
        if bodyOk then
            return body
        end
        error(body)
    end

    error(lastError or "O executor não possui uma função HTTP.")
end

local function httpRequest(url, method, body)
    local requester = getRequester()
    if not requester then
        error("Este executor não possui request para POST.")
    end

    local response = requester({
        Url = url,
        Method = method or "GET",
        Headers = {
            ["Content-Type"] = "application/json",
        },
        Body = body,
        Timeout = HTTP_TIMEOUT,
    })
    return responseBody(response)
end

local function decodeJson(body, message)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if not ok or type(data) ~= "table" then
        error(message or "Resposta JSON inválida.")
    end
    return data
end

local function getServers(cursor)
    local url = "https://games.roblox.com/v1/games/"
        .. PLACE_ID
        .. "/servers/Public?sortOrder=Desc&limit=100"

    if cursor and cursor ~= "" then
        url = url .. "&cursor=" .. urlEncode(cursor)
    end

    for attempt = 1, 3 do
        local ok, body = pcall(function()
            return httpGet(url)
        end)
        if ok and body then
            local decoded, data = pcall(function()
                return decodeJson(body)
            end)
            if decoded and type(data.data) == "table" then
                return data
            end
        end
        task.wait(attempt * 0.5)
    end

    return nil
end

local function isAvailable(server)
    if type(server) ~= "table"
        or type(server.id) ~= "string"
        or server.id == game.JobId
        or type(server.playing) ~= "number"
        or type(server.maxPlayers) ~= "number"
        or server.playing >= server.maxPlayers then
        return false
    end

    if blacklist[server.id] then
        if os.time() >= blacklist[server.id] then
            blacklist[server.id] = nil
        else
            return false
        end
    end
    return true
end

local function collectServers(maxPages)
    local result = {}
    local known = {}
    local cursor = ""
    local pageLimit = maxPages or Config.maxPages

    for page = 1, pageLimit do
        if destroyed then
            return {}
        end

        local data = getServers(cursor)
        if not data then
            break
        end

        for _, server in ipairs(data.data) do
            if not known[server.id] and isAvailable(server) then
                known[server.id] = true
                table.insert(result, server)
            end
        end

        cursor = data.nextPageCursor or ""
        if cursor == "" then
            break
        end
        task.wait(0.2)
    end

    return result
end

local function isIpAddress(value)
    if type(value) ~= "string" then
        return false
    end
    local a, b, c, d = value:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
    return a
        and tonumber(a) <= 255
        and tonumber(b) <= 255
        and tonumber(c) <= 255
        and tonumber(d) <= 255
end

local function getServerIp(server)
    local body = httpRequest(
        "https://gamejoin.roblox.com/v1/join-game-instance",
        "POST",
        HttpService:JSONEncode({
            placeId = PLACE_ID,
            gameId = server.id,
            isTeleport = false,
        })
    )
    local data = decodeJson(body, "A API de região retornou um JSON inválido.")
    local joinScript = data.joinScript
    if type(joinScript) ~= "table" then
        return nil
    end

    local endpoints = joinScript.UdmuxEndpoints
    if type(endpoints) == "table" then
        for _, endpoint in ipairs(endpoints) do
            local address = type(endpoint) == "table" and endpoint.Address
            if isIpAddress(address) then
                return address
            end
        end
    end

    if isIpAddress(joinScript.MachineAddress) then
        return joinScript.MachineAddress
    end
    return nil
end

local function lookupIpRegion(ip)
    local urls = {
        "https://ipwho.is/" .. tostring(ip),
        "http://ip-api.com/json/" .. tostring(ip)
            .. "?fields=status,countryCode,country,city",
    }

    for _, url in ipairs(urls) do
        local ok, body = pcall(function()
            return httpGet(url)
        end)
        if ok and body then
            local decoded, data = pcall(function()
                return decodeJson(body)
            end)
            if decoded and type(data) == "table" then
                local countryCode = data.country_code or data.countryCode
                local country = data.country
                if data.success ~= false and data.status ~= "fail" and countryCode then
                    return {
                        countryCode = string.upper(tostring(countryCode)),
                        country = tostring(country or countryCode),
                        city = tostring(data.city or ""),
                    }
                end
            end
        end
    end
    return nil
end

local function getServerRegion(server)
    local cached = regionCache[server.id]
    if cached and os.time() - cached.time < Config.regionCacheTime then
        return cached.region
    end

    local ok, result = pcall(function()
        local ip = getServerIp(server)
        if not ip then
            return nil
        end
        return lookupIpRegion(ip)
    end)
    local region
    if ok then
        region = result
    else
        local message = string.lower(tostring(result))
        if message:find("401", 1, true)
            or message:find("403", 1, true)
            or message:find("não possui request", 1, true) then
            regionApiUnavailable = true
        end
        region = nil
    end

    regionCache[server.id] = {
        time = os.time(),
        region = region,
    }
    return region
end

local function serverScore(server, mode)
    local playing = tonumber(server.playing) or 0
    local maximum = tonumber(server.maxPlayers) or 1
    local free = maximum - playing
    local occupancy = playing / math.max(1, maximum)
    local score = occupancy * 1000 - free

    if mode == "full" and (playing < 6 or free < 2) then
        return -math.huge
    end
    return score
end

local function chooseServer(mode)
    local servers = collectServers(mode == "brazil" and 1 or nil)
    if #servers == 0 then
        return nil, "Nenhum servidor disponível foi encontrado."
    end

    if mode == "brazil" then
        if regionApiUnavailable then
            return nil, "A API de região do Roblox bloqueou a consulta. O executor precisa permitir essa consulta autenticada; o servidor BR não pode ser confirmado com segurança."
        end
        local brazilServers = {}
        local checked = 0
        for _, server in ipairs(servers) do
            if checked >= Config.maxRegionChecks then
                break
            end
            if regionApiUnavailable then
                return nil, "A API de região do Roblox bloqueou a consulta. O servidor BR não pode ser confirmado com segurança."
            end
            checked = checked + 1
            setStatus(
                SearchStatus,
                "Localizando servidores brasileiros... " .. checked .. "/" .. Config.maxRegionChecks,
                Color3.fromRGB(225, 210, 110)
            )
            local region = getServerRegion(server)
            if region and region.countryCode == "BR" then
                table.insert(brazilServers, server)
            end
            task.wait(0.05)
        end
        if #brazilServers == 0 then
            return nil,
                "Não encontrei um servidor brasileiro. A API de região pode estar bloqueada ou sem resultados."
        end
        servers = brazilServers
    end

    if mode == "random" then
        return servers[math.random(1, #servers)], nil
    end

    local selected
    local bestScore = -math.huge

    for _, server in ipairs(servers) do
        local score = serverScore(server, mode)

        if score > bestScore then
            selected = server
            bestScore = score
        end
    end

    return selected or servers[1], nil
end

-- Localização da GUI.
local parent
if type(gethui) == "function" then
    local ok, result = pcall(gethui)
    if ok then
        parent = result
    end
end
parent = parent or CoreGui

local old = parent:FindFirstChild("ServerFinderResponsive")
if old then
    old:Destroy()
end

local Gui = create("ScreenGui", {
    Name = "ServerFinderResponsive",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, nil)

local guiAttached = pcall(function()
    Gui.Parent = parent
end)
if not guiAttached or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

-- Destruir/reexecutar a interface encerra conexões globais e tarefas desta instância.
Gui.Destroying:Connect(function()
    destroyed = true
    for _, connection in pairs({loadingConnection, inputChangedConnection, teleportInitFailedConnection}) do
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
    end
end)

local Window = create("Frame", {
    Size = UDim2.fromOffset(BASE_WIDTH, BASE_HEIGHT),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(15, 18, 27),
    BorderSizePixel = 0,
}, Gui)
corner(Window, 14)
stroke(Window, Color3.fromRGB(70, 82, 110), 1, 0.45)
create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(21, 27, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 15, 23)),
    }),
    Rotation = 90,
}, Window)

local WindowScale = create("UIScale", {
    Scale = 1,
}, Window)

local function getViewport()
    local camera = workspace.CurrentCamera
    if camera then
        return camera.ViewportSize
    end
    return Vector2.new(BASE_WIDTH + 30, BASE_HEIGHT + 30)
end

local function applyResponsiveScale()
    if destroyed or not Window.Parent then
        return
    end

    local viewport = getViewport()
    local widthScale = (viewport.X - 24) / BASE_WIDTH
    local heightScale = (viewport.Y - 24) / BASE_HEIGHT
    local fitScale = math.min(widthScale, heightScale)
    local responsiveScale = clamp(fitScale, MIN_SCALE, MAX_SCALE)
    local maximumAllowed = math.max(MIN_SCALE, math.min(MAX_USER_SCALE, fitScale))
    currentScale = clamp(responsiveScale * manualScale, MIN_SCALE, maximumAllowed)
    WindowScale.Scale = currentScale
end

local function clampWindowToViewport()
    if destroyed or not Window.Parent then
        return
    end

    local viewport = getViewport()
    local absoluteSize = Window.AbsoluteSize
    local windowWidth = math.max(1, absoluteSize.X)
    local windowHeight = math.max(1, absoluteSize.Y)
    local margin = 6
    local position = Window.Position

    local positionX = viewport.X * position.X.Scale + position.X.Offset
    local positionY = viewport.Y * position.Y.Scale + position.Y.Offset
    local minimumX = windowWidth / 2 + margin
    local maximumX = viewport.X - windowWidth / 2 - margin
    local minimumY = windowHeight / 2 + margin
    local maximumY = viewport.Y - windowHeight / 2 - margin

    local clampedX = minimumX <= maximumX
        and clamp(positionX, minimumX, maximumX)
        or viewport.X / 2
    local clampedY = minimumY <= maximumY
        and clamp(positionY, minimumY, maximumY)
        or viewport.Y / 2

    Window.Position = UDim2.new(
        position.X.Scale,
        clampedX - viewport.X * position.X.Scale,
        position.Y.Scale,
        clampedY - viewport.Y * position.Y.Scale
    )
end

local Header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Color3.fromRGB(25, 30, 44),
    BorderSizePixel = 0,
}, Window)
corner(Header, 14)
create("Frame", {
    Size = UDim2.new(1, 0, 0, 15),
    Position = UDim2.new(0, 0, 1, -15),
    BackgroundColor3 = Color3.fromRGB(25, 30, 44),
    BorderSizePixel = 0,
}, Header)
create("Frame", {
    Size = UDim2.new(1, -24, 0, 2),
    Position = UDim2.fromOffset(12, 46),
    BackgroundColor3 = Color3.fromRGB(75, 218, 225),
    BorderSizePixel = 0,
}, Header)

local OwnerAvatar = create("ImageLabel", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.fromOffset(12, 7),
    BackgroundColor3 = Color3.fromRGB(48, 52, 68),
    BorderSizePixel = 0,
    Image = "",
}, Header)
corner(OwnerAvatar, 17)

local HubTitle = create("TextLabel", {
    Size = UDim2.new(1, -235, 0, 23),
    Position = UDim2.fromOffset(56, 3),
    BackgroundTransparency = 1,
    Text = "SERVER FINDER",
    TextColor3 = Color3.fromRGB(255, 218, 120),
    TextStrokeColor3 = Color3.fromRGB(126, 72, 18),
    TextStrokeTransparency = 0.32,
    TextSize = 16,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

local TitleShine = create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 82, 18)),
        ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 202, 83)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 248, 190)),
        ColorSequenceKeypoint.new(0.72, Color3.fromRGB(255, 202, 83)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 82, 18)),
    }),
    Offset = Vector2.new(-1, 0),
    Rotation = 0,
}, HubTitle)

-- Reflexo animado para o dourado parecer metálico, sem perder legibilidade.
task.spawn(function()
    while not destroyed and TitleShine.Parent do
        for offset = -1, 1, 0.035 do
            if destroyed or not TitleShine.Parent then
                return
            end
            TitleShine.Offset = Vector2.new(offset, 0)
            task.wait(0.035)
        end
        task.wait(0.65)
    end
end)

create("TextLabel", {
    Size = UDim2.new(1, -235, 0, 17),
    Position = UDim2.fromOffset(57, 25),
    BackgroundTransparency = 1,
    Text = "by mateus_15600",
    TextColor3 = Color3.fromRGB(145, 220, 180),
    TextSize = 11,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

local Minimize = create("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -72, 0, 9),
    BackgroundColor3 = Color3.fromRGB(75, 80, 100),
    Text = "—",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 18,
    Font = Enum.Font.SourceSansBold,
}, Header)
corner(Minimize, 7)

local Close = create("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -38, 0, 9),
    BackgroundColor3 = Color3.fromRGB(190, 55, 65),
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
}, Header)
corner(Close, 7)

local Sidebar = create("Frame", {
    Size = UDim2.new(0, 132, 1, -60),
    Position = UDim2.fromOffset(10, 56),
    BackgroundColor3 = Color3.fromRGB(20, 24, 35),
    BorderSizePixel = 0,
}, Window)
corner(Sidebar, 10)
stroke(Sidebar, Color3.fromRGB(78, 93, 122), 1, 0.68)

create("TextLabel", {
    Size = UDim2.new(1, -16, 0, 15),
    Position = UDim2.fromOffset(8, 4),
    BackgroundTransparency = 1,
    Text = "NAVEGAÇÃO",
    TextColor3 = Color3.fromRGB(115, 190, 210),
    TextSize = 9,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Sidebar)

local Main = create("Frame", {
    Size = UDim2.new(1, -162, 1, -60),
    Position = UDim2.fromOffset(152, 56),
    BackgroundTransparency = 1,
}, Window)

local ResizeGrip = create("TextButton", {
    Size = UDim2.fromOffset(22, 22),
    Position = UDim2.new(1, -7, 1, -7),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundColor3 = Color3.fromRGB(42, 49, 67),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Text = "◢",
    TextColor3 = Color3.fromRGB(90, 210, 230),
    TextSize = 14,
    Font = Enum.Font.SourceSansBold,
    AutoButtonColor = false,
    ZIndex = 30,
}, Window)
corner(ResizeGrip, 6)
stroke(ResizeGrip, Color3.fromRGB(90, 210, 230), 1, 0.25)

local Pages = {}

local function makePage(name)
    local page = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
    }, Main)
    Pages[name] = page
    return page
end

local function makeTab(name, text, order, color)
    local button = create("TextButton", {
        Size = UDim2.new(1, -16, 0, 42),
        Position = UDim2.new(0, 8, 0, 26 + (order - 1) * 50),
        BackgroundColor3 = Color3.fromRGB(40, 43, 57),
        Text = text,
        TextColor3 = Color3.fromRGB(215, 218, 230),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansBold,
        AutoButtonColor = false,
    }, Sidebar)
    button:SetAttribute("ActiveColor", color or Color3.fromRGB(0, 135, 190))
    corner(button, 8)
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 15),
    }, button)
    TabStrokes[name] = stroke(button, Color3.fromRGB(255, 255, 255), 1, 0.9)
    local indicator = create("Frame", {
        Size = UDim2.fromOffset(4, 26),
        Position = UDim2.fromOffset(5, 8),
        BackgroundColor3 = color or Color3.fromRGB(0, 135, 190),
        BorderSizePixel = 0,
        Visible = false,
        Active = false,
    }, button)
    corner(indicator, 2)
    TabIndicators[name] = indicator
    button.MouseEnter:Connect(function()
        if not button:GetAttribute("IsActive") then
            button.BackgroundColor3 = Themes[currentThemeName].colors.tabHover
            if TabStrokes[name] then
                TabStrokes[name].Transparency = 0.55
            end
        end
    end)
    button.MouseLeave:Connect(function()
        if not button:GetAttribute("IsActive") then
            button.BackgroundColor3 = Themes[currentThemeName].colors.tab
            if TabStrokes[name] then
                TabStrokes[name].Transparency = 0.9
            end
        end
    end)
    TabButtons[name] = button
    return button
end

local SearchPage = makePage("Buscar")
local ChatPage = makePage("Chat")
local ScriptsPage = makePage("Scripts")
local ConfigsPage = makePage("Configs")
local InfoPage = makePage("Info")

local SearchTab = makeTab("Buscar", "⌂  BUSCAR", 1)
local ChatTab = makeTab("Chat", "☵  CHAT BOT", 2)
local ScriptsTab = makeTab("Scripts", "▤  SCRIPTS", 3)
local ConfigsTab = makeTab("Configs", "⚙  CONFIGS", 4, Color3.fromRGB(112, 78, 178))

InfoTab = create("TextButton", {
    Size = UDim2.fromOffset(52, 30),
    Position = UDim2.new(1, -132, 0, 9),
    BackgroundColor3 = Color3.fromRGB(42, 57, 75),
    Text = "INFO",
    TextColor3 = Color3.fromRGB(185, 240, 240),
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
    AutoButtonColor = false,
}, Header)
corner(InfoTab, 7)
stroke(InfoTab, Color3.fromRGB(95, 220, 225), 1, 0.35)
InfoTab.MouseEnter:Connect(function()
    InfoTab.BackgroundColor3 = Themes[currentThemeName].colors.tabHover
end)
InfoTab.MouseLeave:Connect(function()
    InfoTab.BackgroundColor3 = Themes[currentThemeName].colors.infoButton
end)

local function showPage(name)
    local colors = Themes[currentThemeName].colors
    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end
    for tabName, button in pairs(TabButtons) do
        local activeColor = button:GetAttribute("ActiveColor") or colors.primary
        local isActive = tabName == name
        button:SetAttribute("IsActive", isActive)
        button.BackgroundColor3 = isActive and activeColor or colors.tab
        if TabIndicators[tabName] then
            TabIndicators[tabName].Visible = isActive
            TabIndicators[tabName].BackgroundColor3 = activeColor
        end
        if TabStrokes[tabName] then
            TabStrokes[tabName].Color = isActive and activeColor or colors.border
            TabStrokes[tabName].Transparency = isActive and 0.25 or 0.9
        end
    end
    InfoTab:SetAttribute("IsActive", name == "Info")
    InfoTab.BackgroundColor3 = name == "Info" and colors.primary or colors.infoButton
    InfoTab.TextColor3 = name == "Info" and colors.textBright or colors.textAccent
end

SearchTab.MouseButton1Click:Connect(function()
    showPage("Buscar")
end)
ChatTab.MouseButton1Click:Connect(function()
    showPage("Chat")
end)
ScriptsTab.MouseButton1Click:Connect(function()
    showPage("Scripts")
end)
ConfigsTab.MouseButton1Click:Connect(function()
    showPage("Configs")
end)
InfoTab.MouseButton1Click:Connect(function()
    showPage("Info")
end)

-- Página Buscar.
local SearchCard = create("Frame", {
    Size = UDim2.new(1, 0, 0, 238),
    Position = UDim2.fromOffset(0, 0),
    BackgroundColor3 = Color3.fromRGB(23, 28, 41),
    BorderSizePixel = 0,
}, SearchPage)
corner(SearchCard, 11)
stroke(SearchCard, Color3.fromRGB(70, 93, 125), 1, 0.72)

create("Frame", {
    Size = UDim2.fromOffset(4, 72),
    Position = UDim2.fromOffset(0, 18),
    BackgroundColor3 = Color3.fromRGB(75, 218, 225),
    BorderSizePixel = 0,
}, SearchCard)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 34),
    Position = UDim2.fromOffset(16, 15),
    BackgroundTransparency = 1,
    Text = "Troca inteligente de servidor",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 19,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, SearchPage)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 36),
    Position = UDim2.fromOffset(16, 49),
    BackgroundTransparency = 1,
    Text = "BR verifica a região antes de teleportar; aleatório usa a lista pública do Roblox.",
    TextColor3 = Color3.fromRGB(165, 170, 190),
    TextSize = 12,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, SearchPage)

SearchStatus = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 48),
    Position = UDim2.new(0, 0, 1, -58),
    BackgroundColor3 = Color3.fromRGB(28, 31, 42),
    Text = "Pronto para buscar.",
    TextColor3 = Color3.fromRGB(225, 210, 110),
    TextSize = 12,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
}, SearchPage)
corner(SearchStatus, 8)
stroke(SearchStatus, Color3.fromRGB(98, 105, 135), 1, 0.72)

local function searchButton(text, position, color)
    local button = create("TextButton", {
        Size = UDim2.fromOffset(205, 46),
        Position = position,
        BackgroundColor3 = color,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.SourceSansBold,
    }, SearchPage)
    corner(button, 9)
    styleButton(button, color, Color3.fromRGB(
        math.min(color.R * 1.16 + 0.03, 1),
        math.min(color.G * 1.16 + 0.03, 1),
        math.min(color.B * 1.16 + 0.03, 1)
    ))
    return button
end

local BRButton = searchButton("Servidor BR", UDim2.fromOffset(0, 88), Color3.fromRGB(0, 145, 75))
local ENButton = searchButton("English Server", UDim2.fromOffset(220, 94), Color3.fromRGB(65, 70, 88))
disableButton(ENButton, Color3.fromRGB(65, 70, 88))
create("TextLabel", {
    Size = UDim2.fromOffset(205, 18),
    Position = UDim2.fromOffset(220, 70),
    BackgroundTransparency = 1,
    Text = "DESATIVADO",
    TextColor3 = Color3.fromRGB(245, 190, 105),
    TextSize = 10,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
}, SearchPage)
local VerifiedButton = searchButton(
    "Procurar usuário verificado",
    UDim2.fromOffset(0, 148),
    Color3.fromRGB(120, 55, 190)
)
local RandomButton = searchButton("Servidor aleatório", UDim2.fromOffset(220, 148), Color3.fromRGB(205, 115, 0))

local VerifiedPopup = create("Frame", {
    Size = UDim2.fromOffset(390, 185),
    Position = UDim2.new(0.5, -195, 0.5, -92),
    BackgroundColor3 = Color3.fromRGB(29, 32, 44),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 20,
}, Window)
corner(VerifiedPopup, 12)
stroke(VerifiedPopup, Color3.fromRGB(100, 115, 145), 1, 0.25)

create("TextLabel", {
    Size = UDim2.new(1, -55, 0, 34),
    Position = UDim2.fromOffset(15, 12),
    BackgroundTransparency = 1,
    Text = "Procurar usuário com selo azul",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 16,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 21,
}, VerifiedPopup)

local VerifiedClose = create("TextButton", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -38, 0, 10),
    BackgroundColor3 = Color3.fromRGB(190, 55, 65),
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 18,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 21,
}, VerifiedPopup)
corner(VerifiedClose, 7)

local VerifiedInput = create("TextBox", {
    Size = UDim2.new(1, -130, 0, 38),
    Position = UDim2.fromOffset(15, 62),
    BackgroundColor3 = Color3.fromRGB(40, 43, 57),
    PlaceholderText = "Username do jogador",
    Text = "",
    TextColor3 = Color3.fromRGB(240, 240, 245),
    PlaceholderColor3 = Color3.fromRGB(145, 148, 165),
    TextSize = 13,
    Font = Enum.Font.SourceSans,
    ClearTextOnFocus = false,
    ZIndex = 21,
}, VerifiedPopup)
corner(VerifiedInput, 8)

local VerifiedSearch = create("TextButton", {
    Size = UDim2.fromOffset(100, 38),
    Position = UDim2.new(1, -115, 0, 62),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    Text = "Verificar",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 13,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 21,
}, VerifiedPopup)
corner(VerifiedSearch, 8)

local VerifiedStatus = create("TextLabel", {
    Size = UDim2.new(1, -30, 0, 55),
    Position = UDim2.fromOffset(15, 112),
    BackgroundTransparency = 1,
    Text = "Informe um username. O filtro só funciona se o jogador estiver online no Brookhaven.",
    TextColor3 = Color3.fromRGB(185, 190, 210),
    TextSize = 11,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 21,
}, VerifiedPopup)

local TeleportConfirmPopup = create("Frame", {
    Size = UDim2.fromOffset(410, 210),
    Position = UDim2.new(0.5, -205, 0.5, -105),
    BackgroundColor3 = Color3.fromRGB(29, 32, 44),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 60,
}, Window)
corner(TeleportConfirmPopup, 12)
stroke(TeleportConfirmPopup, Color3.fromRGB(92, 190, 220), 1, 0.2)

create("TextLabel", {
    Size = UDim2.new(1, -30, 0, 34),
    Position = UDim2.fromOffset(15, 14),
    BackgroundTransparency = 1,
    Text = "Servidor encontrado",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 18,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 61,
}, TeleportConfirmPopup)

local TeleportConfirmMessage = create("TextLabel", {
    Size = UDim2.new(1, -30, 0, 82),
    Position = UDim2.fromOffset(15, 55),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Color3.fromRGB(205, 215, 230),
    TextSize = 13,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 61,
}, TeleportConfirmPopup)

local TeleportCancelButton = create("TextButton", {
    Size = UDim2.fromOffset(150, 38),
    Position = UDim2.new(0, 15, 1, -53),
    BackgroundColor3 = Color3.fromRGB(76, 82, 103),
    Text = "CANCELAR",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 61,
}, TeleportConfirmPopup)
corner(TeleportCancelButton, 8)
styleButton(TeleportCancelButton, Color3.fromRGB(76, 82, 103), Color3.fromRGB(94, 102, 128))

local TeleportContinueButton = create("TextButton", {
    Size = UDim2.fromOffset(210, 38),
    Position = UDim2.new(1, -225, 1, -53),
    BackgroundColor3 = Color3.fromRGB(0, 145, 185),
    Text = "CONTINUAR",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 61,
}, TeleportConfirmPopup)
corner(TeleportContinueButton, 8)
styleButton(TeleportContinueButton, Color3.fromRGB(0, 145, 185), Color3.fromRGB(25, 175, 215))

local teleportDecision
local function askTeleportConfirmation(server, context)
    local playing = tonumber(server and server.playing)
    local maximum = tonumber(server and server.maxPlayers)
    local occupancy = playing and maximum and (tostring(playing) .. "/" .. tostring(maximum)) or "disponível"
    local target = context or "um novo servidor"

    TeleportConfirmMessage.Text = "Encontrei " .. target .. " (" .. occupancy .. ").\n"
        .. "Você quer sair deste servidor e continuar para o destino encontrado?"
    teleportDecision = nil
    TeleportConfirmPopup.Visible = true

    while teleportDecision == nil and not destroyed do
        task.wait()
    end

    local accepted = teleportDecision == true and not destroyed
    teleportDecision = nil
    if TeleportConfirmPopup.Parent then
        TeleportConfirmPopup.Visible = false
    end
    return accepted
end

TeleportCancelButton.MouseButton1Click:Connect(function()
    teleportDecision = false
end)
TeleportContinueButton.MouseButton1Click:Connect(function()
    teleportDecision = true
end)

VerifiedButton.MouseButton1Click:Connect(function()
    VerifiedPopup.Visible = true
    VerifiedInput:CaptureFocus()
end)
VerifiedClose.MouseButton1Click:Connect(function()
    VerifiedPopup.Visible = false
end)

-- Página Scripts.
local ScriptsCard = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.fromOffset(0, 0),
    BackgroundColor3 = Color3.fromRGB(23, 28, 41),
    BorderSizePixel = 0,
}, ScriptsPage)
corner(ScriptsCard, 11)
stroke(ScriptsCard, Color3.fromRGB(70, 93, 125), 1, 0.72)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 40),
    Position = UDim2.new(0, 14, 0.5, -20),
    BackgroundTransparency = 1,
    Text = "Scripts personalizados em breve",
    TextColor3 = Color3.fromRGB(245, 248, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
}, ScriptsCard)

-- Página Configs.
local ConfigsCard = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.fromOffset(0, 0),
    BackgroundColor3 = Color3.fromRGB(23, 28, 41),
    BorderSizePixel = 0,
}, ConfigsPage)
corner(ConfigsCard, 11)
stroke(ConfigsCard, Color3.fromRGB(70, 93, 125), 1, 0.72)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 30),
    Position = UDim2.fromOffset(14, 12),
    BackgroundTransparency = 1,
    Text = "Configurações do script",
    TextColor3 = Color3.fromRGB(245, 248, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, ConfigsCard)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 28),
    Position = UDim2.fromOffset(14, 43),
    BackgroundTransparency = 1,
    Text = "Escolha o tema da interface. A seleção é salva automaticamente.",
    TextColor3 = Color3.fromRGB(165, 170, 190),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, ConfigsCard)

ThemeStatus = create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 24),
    Position = UDim2.fromOffset(14, 72),
    BackgroundTransparency = 1,
    Text = "Tema atual: " .. Themes[Config.theme].label,
    TextColor3 = Color3.fromRGB(145, 240, 180),
    TextSize = 12,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, ConfigsCard)

local function themeOption(name, position)
    local theme = Themes[name]
    local button = create("TextButton", {
        Size = UDim2.fromOffset(188, 62),
        Position = position,
        BackgroundColor3 = Color3.fromRGB(40, 43, 57),
        Text = theme.label .. "\n" .. theme.description,
        TextColor3 = Color3.fromRGB(245, 248, 255),
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Font = Enum.Font.SourceSansBold,
        AutoButtonColor = false,
    }, ConfigsCard)
    corner(button, 9)
    stroke(button, Color3.fromRGB(70, 93, 125), 1, 0.45)

    local preview = create("Frame", {
        Size = UDim2.fromOffset(10, 40),
        Position = UDim2.new(1, -20, 0.5, -20),
        BackgroundColor3 = theme.preview,
        BorderSizePixel = 0,
    }, button)
    corner(preview, 5)

    table.insert(ThemeButtons, {
        name = name,
        label = theme.label,
        button = button,
        preview = preview,
    })

    button.MouseEnter:Connect(function()
        if name ~= currentThemeName then
            button.BackgroundColor3 = Themes[currentThemeName].colors.tabHover
        end
    end)
    button.MouseLeave:Connect(function()
        if name ~= currentThemeName then
            button.BackgroundColor3 = Themes[currentThemeName].colors.tab
        end
    end)
    button.MouseButton1Click:Connect(function()
        applyTheme(name)
        local saved, errorMessage = saveTheme()
        if saved then
            ThemeStatus.Text = "✓ " .. theme.label .. " selecionado e salvo."
            ThemeStatus.TextColor3 = Themes[name].colors.textSuccess
        else
            ThemeStatus.Text = theme.label .. " selecionado. " .. tostring(errorMessage)
            ThemeStatus.TextColor3 = Themes[name].colors.textWarning
        end
    end)
end

themeOption("Midnight", UDim2.fromOffset(14, 102))
themeOption("Ocean", UDim2.fromOffset(211, 102))
themeOption("Emerald", UDim2.fromOffset(14, 174))
themeOption("Sunset", UDim2.fromOffset(211, 174))

local ConfigSaveButton = create("TextButton", {
    Size = UDim2.fromOffset(188, 38),
    Position = UDim2.fromOffset(14, 252),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    Text = "SALVAR CONFIGURAÇÃO",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
}, ConfigsCard)
corner(ConfigSaveButton, 8)
styleButton(ConfigSaveButton, Color3.fromRGB(0, 135, 190), Color3.fromRGB(25, 165, 215))
ConfigSaveButton.MouseButton1Click:Connect(function()
    local saved, errorMessage = saveTheme()
    if saved then
        ThemeStatus.Text = "✓ Tema " .. Themes[Config.theme].label .. " salvo neste executor."
        ThemeStatus.TextColor3 = Themes[Config.theme].colors.textSuccess
    else
        ThemeStatus.Text = tostring(errorMessage)
        ThemeStatus.TextColor3 = Themes[Config.theme].colors.textWarning
    end
end)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 58),
    Position = UDim2.fromOffset(14, 306),
    BackgroundTransparency = 1,
    Text = "O arquivo ServerFinder_Config.json é criado na pasta do executor. "
        .. "Ao executar o script novamente, o último tema salvo será carregado.",
    TextColor3 = Color3.fromRGB(120, 145, 170),
    TextSize = 11,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, ConfigsCard)

-- Página Chat.
local ChatCard = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.fromOffset(0, 0),
    BackgroundColor3 = Color3.fromRGB(20, 24, 36),
    BorderSizePixel = 0,
}, ChatPage)
corner(ChatCard, 11)
stroke(ChatCard, Color3.fromRGB(70, 93, 125), 1, 0.72)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 32),
    Position = UDim2.fromOffset(14, 12),
    BackgroundTransparency = 1,
    Text = Config.botName .. "  •  assistente de sessão",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, ChatPage)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 24),
    Position = UDim2.fromOffset(14, 44),
    BackgroundTransparency = 1,
    Text = "Online nesta sessão  •  conversa privada local",
    TextColor3 = Color3.fromRGB(120, 220, 165),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, ChatPage)

local ChatLog = create("ScrollingFrame", {
    Size = UDim2.new(1, -28, 1, -176),
    Position = UDim2.fromOffset(14, 94),
    BackgroundColor3 = Color3.fromRGB(15, 19, 29),
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 5,
}, ChatPage)
corner(ChatLog, 10)
stroke(ChatLog, Color3.fromRGB(63, 76, 103), 1, 0.76)

local ChatLayout = create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, ChatLog)

local ChatInput = create("TextBox", {
    Size = UDim2.new(1, -112, 0, 42),
    Position = UDim2.new(0, 14, 1, -44),
    BackgroundColor3 = Color3.fromRGB(35, 38, 50),
    PlaceholderText = "Converse ou diga: buscar servidor",
    Text = "",
    TextColor3 = Color3.fromRGB(240, 240, 245),
    PlaceholderColor3 = Color3.fromRGB(145, 148, 165),
    TextSize = 13,
    Font = Enum.Font.SourceSans,
    ClearTextOnFocus = false,
}, ChatPage)
corner(ChatInput, 9)
stroke(ChatInput, Color3.fromRGB(75, 92, 122), 1, 0.7)

local SendButton = create("TextButton", {
    Size = UDim2.fromOffset(90, 42),
    Position = UDim2.new(1, -104, 1, -44),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    Text = "Enviar",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 13,
    Font = Enum.Font.SourceSansBold,
}, ChatPage)
corner(SendButton, 9)
styleButton(SendButton, Color3.fromRGB(0, 135, 190), Color3.fromRGB(25, 165, 215))

local ChatMessages = {}
local MAX_CHAT_MESSAGES = 80

local function addMessage(author, text, color)
    local message = create("TextLabel", {
        Size = UDim2.new(1, -18, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(35, 38, 50),
        Text = "  " .. author .. "\n  " .. tostring(text),
        TextColor3 = color,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSans,
    }, ChatLog)
    corner(message, 8)
    table.insert(ChatMessages, message)
    if #ChatMessages > MAX_CHAT_MESSAGES then
        local oldest = table.remove(ChatMessages, 1)
        if oldest and oldest.Parent then
            oldest:Destroy()
        end
    end
end

local function clearChat()
    for _, child in ipairs(ChatLog:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    ChatMessages = {}
end

ChatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ChatLog.CanvasSize = UDim2.new(0, 0, 0, ChatLayout.AbsoluteContentSize.Y + 14)
    ChatLog.CanvasPosition = Vector2.new(0, math.max(0, ChatLayout.AbsoluteContentSize.Y))
end)

local Suggestions = create("Frame", {
    Size = UDim2.new(1, 0, 0, 28),
    Position = UDim2.fromOffset(0, 60),
    BackgroundTransparency = 1,
}, ChatPage)

local function suggestion(text, position)
    local button = create("TextButton", {
        Size = UDim2.fromOffset(128, 26),
        Position = position,
        BackgroundColor3 = Color3.fromRGB(42, 47, 63),
        Text = text,
        TextColor3 = Color3.fromRGB(205, 215, 235),
        TextSize = 11,
        Font = Enum.Font.SourceSansBold,
    }, Suggestions)
    corner(button, 7)
    styleButton(button, Color3.fromRGB(42, 47, 63), Color3.fromRGB(59, 68, 91))
    return button
end

local SuggestTalk = suggestion("Vamos conversar", UDim2.fromOffset(0, 0))
local SuggestAbout = suggestion("Fale sobre você", UDim2.fromOffset(138, 0))
local SuggestClear = suggestion("Limpar conversa", UDim2.fromOffset(276, 0))

local ChatState = {
    lastIntent = nil,
    lastMode = nil,
    turnCount = 0,
}
local runSearch

local function hasAny(text, words)
    local normalizedText = " " .. text:gsub("[%c%p]", " ") .. " "
    for _, word in ipairs(words) do
        local normalizedWord = word:gsub("[%c%p]", " ")
        if #normalizedWord <= 3 then
            if normalizedText:find(" " .. normalizedWord .. " ", 1, true) then
                return true
            end
        elseif text:find(normalizedWord, 1, true) then
            return true
        end
    end
    return false
end

local function answer(rawMessage)
    local original = tostring(rawMessage)
    local text = string.lower(original)
    ChatState.turnCount = ChatState.turnCount + 1

    local name = text:match("meu nome é%s+(.+)")
        or text:match("meu nome e%s+(.+)")
    if name and #name > 1 then
        Config.userName = name:gsub("^%s+", ""):gsub("%s+$", "")
        ChatState.lastIntent = "profile"
        return "Fechado. Vou chamar você de " .. Config.userName .. " nesta sessão."
    end

    if hasAny(text, {"limpar conversa", "apagar conversa", "limpa chat"}) then
        clearChat()
        ChatState.lastIntent = "clear"
        return "Conversa limpa. Podemos começar de novo."
    end
    if hasAny(text, {"qual seu nome", "seu nome"}) then
        ChatState.lastIntent = "identity"
        return "Eu sou " .. Config.botName .. ". Fui configurado para ajudar com esta interface."
    end
    if hasAny(text, {"oi", "ola", "olá", "bom dia", "boa tarde", "boa noite"}) then
        ChatState.lastIntent = "greeting"
        return "Oi, " .. Config.userName .. ". Quer conversar ou quer que eu encontre um servidor?"
    end
    if hasAny(text, {"o que você faz", "o que voce faz", "como funciona", "capacidades"}) then
        ChatState.lastIntent = "capabilities"
        return "Posso explicar a interface, lembrar o contexto desta sessão e iniciar uma busca quando você pedir."
    end
    if hasAny(text, {"erro", "falhou", "não funciona", "nao funciona", "problema"}) then
        ChatState.lastIntent = "troubleshooting"
        return "Me diga o texto exato do erro. Assim separo falha HTTP, teleporte recusado ou bloqueio do executor."
    end
    if hasAny(text, {"idioma", "brasil", "br", "english", "inglês"}) then
        ChatState.lastIntent = "language"
        return "O botão Servidor BR verifica a região por uma API de junção do Roblox. Se o executor bloquear POST, ele avisa em vez de mandar você para uma região aleatória."
    end
    if hasAny(text, {"servidor aleatório", "servidor aleatorio", "qualquer servidor"}) then
        ChatState.lastIntent = "search"
        ChatState.lastMode = "random"
        task.defer(function()
            runSearch("random", "servidor aleatório")
        end)
        return "Vou procurar um servidor aleatório agora."
    end
    if hasAny(text, {"buscar servidor", "trocar servidor", "servidor cheio", "melhor servidor"}) then
        ChatState.lastIntent = "search"
        ChatState.lastMode = "full"
        task.defer(function()
            runSearch("full", "servidor")
        end)
        return "Vou procurar um servidor com bastante movimento."
    end
    if hasAny(text, {"fale sobre você", "quem é você"}) then
        ChatState.lastIntent = "about"
        return "Sou um assistente local. Não envio a conversa para uma API externa."
    end

    ChatState.lastIntent = "fallback"
    return "Entendi. Posso conversar, explicar a interface ou buscar um servidor."
end

local function sendChat(message)
    local text = message or ChatInput.Text
    if not text or text:gsub("%s+", "") == "" then
        return
    end
    ChatInput.Text = ""
    addMessage(Config.userName, text, Color3.fromRGB(150, 210, 255))
    task.wait(0.2)
    addMessage(Config.botName, answer(text), Color3.fromRGB(170, 240, 185))
end

SendButton.MouseButton1Click:Connect(sendChat)
ChatInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendChat()
    end
end)
SuggestTalk.MouseButton1Click:Connect(function()
    sendChat("Oi, quero conversar")
end)
SuggestAbout.MouseButton1Click:Connect(function()
    sendChat("Fale sobre você")
end)
SuggestClear.MouseButton1Click:Connect(function()
    sendChat("Limpar conversa")
end)

-- Página Info, acessível pelo botão no topo.
create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundTransparency = 1,
    Text = "Sobre o Server Finder",
    TextColor3 = Color3.fromRGB(245, 248, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, InfoPage)

create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 32),
    Position = UDim2.fromOffset(0, 34),
    BackgroundTransparency = 1,
    Text = "Tudo o que você precisa saber antes de iniciar uma busca.",
    TextColor3 = Color3.fromRGB(155, 190, 205),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, InfoPage)

local InfoCard = create("Frame", {
    Size = UDim2.new(1, 0, 0, 128),
    Position = UDim2.fromOffset(0, 78),
    BackgroundColor3 = Color3.fromRGB(25, 31, 45),
    BorderSizePixel = 0,
}, InfoPage)
corner(InfoCard, 10)
stroke(InfoCard, Color3.fromRGB(70, 191, 210), 1, 0.68)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 25),
    Position = UDim2.fromOffset(14, 12),
    BackgroundTransparency = 1,
    Text = "Como usar",
    TextColor3 = Color3.fromRGB(120, 230, 220),
    TextSize = 15,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, InfoCard)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 78),
    Position = UDim2.fromOffset(14, 39),
    BackgroundTransparency = 1,
    Text = "• O Server Finder é um script Lua para Roblox/Brookhaven.\n"
        .. "• Ele busca servidores públicos, tenta teleportar e verifica usuários.\n"
        .. "• O chat da NOVA funciona localmente, sem enviar a conversa para uma API.",
    TextColor3 = Color3.fromRGB(215, 222, 235),
    TextSize = 12,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, InfoCard)

local function copyToClipboard(text)
    local clipboardFunctions = {}
    if type(setclipboard) == "function" then
        table.insert(clipboardFunctions, setclipboard)
    end
    if type(toclipboard) == "function" then
        table.insert(clipboardFunctions, toclipboard)
    end
    if type(set_clipboard) == "function" then
        table.insert(clipboardFunctions, set_clipboard)
    end
    for _, clipboardFunction in ipairs(clipboardFunctions) do
        local ok = pcall(clipboardFunction, text)
        if ok then
            return true
        end
    end
    return false
end

local Toast = create("Frame", {
    Size = UDim2.fromOffset(224, 54),
    Position = UDim2.new(1, 12, 0, 62),
    BackgroundColor3 = Color3.fromRGB(28, 118, 92),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 80,
}, Window)
corner(Toast, 9)
stroke(Toast, Color3.fromRGB(135, 255, 205), 1, 0.35)

local ToastMessage = create("TextLabel", {
    Size = UDim2.new(1, -24, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Color3.fromRGB(240, 255, 248),
    TextSize = 12,
    TextWrapped = true,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    ZIndex = 81,
}, Toast)

local toastId = 0
local function showToast(message, color)
    toastId = toastId + 1
    local currentToastId = toastId
    Toast.BackgroundColor3 = color or Color3.fromRGB(28, 118, 92)
    ToastMessage.Text = message
    Toast.Visible = true
    task.delay(2.8, function()
        if currentToastId == toastId and Toast.Parent then
            Toast.Visible = false
        end
    end)
end

local DiscordCard = create("Frame", {
    Size = UDim2.new(1, 0, 0, 64),
    Position = UDim2.fromOffset(0, 308),
    BackgroundColor3 = Color3.fromRGB(31, 35, 55),
    BorderSizePixel = 0,
}, InfoPage)
corner(DiscordCard, 10)
stroke(DiscordCard, Color3.fromRGB(105, 112, 220), 1, 0.62)

local DiscordIconFallback = create("TextLabel", {
    Size = UDim2.fromOffset(40, 40),
    Position = UDim2.fromOffset(10, 12),
    BackgroundColor3 = Color3.fromRGB(88, 101, 242),
    Text = "☁",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 22,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
}, DiscordCard)
corner(DiscordIconFallback, 20)

local DiscordIcon = create("ImageLabel", {
    Size = UDim2.fromOffset(40, 40),
    Position = UDim2.fromOffset(10, 12),
    BackgroundTransparency = 1,
    Image = "",
    ImageTransparency = 1,
}, DiscordCard)
corner(DiscordIcon, 20)

local DiscordName = create("TextLabel", {
    Size = UDim2.new(1, -176, 0, 22),
    Position = UDim2.fromOffset(60, 8),
    BackgroundTransparency = 1,
    Text = "Meu servidor no Discord",
    TextColor3 = Color3.fromRGB(240, 242, 255),
    TextSize = 13,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, DiscordCard)

create("TextLabel", {
    Size = UDim2.new(1, -176, 0, 20),
    Position = UDim2.fromOffset(60, 31),
    BackgroundTransparency = 1,
    Text = "discord.gg/RtfAn6zku8",
    TextColor3 = Color3.fromRGB(165, 175, 215),
    TextSize = 11,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, DiscordCard)

local CopyDiscordButton = create("TextButton", {
    Size = UDim2.fromOffset(104, 36),
    Position = UDim2.new(1, -114, 0, 14),
    BackgroundColor3 = Color3.fromRGB(88, 101, 242),
    Text = "COPIAR LINK",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
}, DiscordCard)
corner(CopyDiscordButton, 8)
styleButton(CopyDiscordButton, Color3.fromRGB(88, 101, 242), Color3.fromRGB(111, 123, 255))

CopyDiscordButton.MouseButton1Click:Connect(function()
    if copyToClipboard(DISCORD_INVITE) then
        showToast("✓ Link do Discord copiado!", Color3.fromRGB(28, 118, 92))
    else
        showToast("Não foi possível copiar neste executor.", Color3.fromRGB(145, 78, 64))
    end
end)

local function loadDiscordIcon(iconUrl, guildId)
    local assetLoaders = {}
    if type(getcustomasset) == "function" then
        table.insert(assetLoaders, getcustomasset)
    end
    if type(getsynasset) == "function" then
        table.insert(assetLoaders, getsynasset)
    end

    if type(writefile) == "function" and #assetLoaders > 0 then
        local fileName = "ServerFinder_DiscordIcon_" .. tostring(guildId) .. ".png"
        local fileReady = false
        local prepared = pcall(function()
            if type(isfile) == "function" then
                local existsOk, exists = pcall(isfile, fileName)
                fileReady = existsOk and exists == true
            end

            if not fileReady then
                local imageBody = httpGet(iconUrl)
                if type(imageBody) ~= "string" or imageBody == "" then
                    error("O Discord não retornou uma imagem válida.")
                end
                writefile(fileName, imageBody)
                fileReady = true
            end
        end)

        if prepared and fileReady then
            for _, assetLoader in ipairs(assetLoaders) do
                local assetOk, asset = pcall(assetLoader, fileName)
                if assetOk and type(asset) == "string" and asset ~= "" then
                    return asset, true
                end
            end
        end
    end

    -- Alguns executores aceitam a URL diretamente; outros só aceitam rbxasset.
    return iconUrl, false
end

task.spawn(function()
    local ok, body = pcall(function()
        return httpGet(
            "https://discord.com/api/v10/invites/"
                .. DISCORD_INVITE_CODE
                .. "?with_counts=true"
        )
    end)
    if not ok or not body then
        return
    end

    local decoded, invite = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    local guild = decoded and invite and invite.guild
    if not guild then
        return
    end

    if guild.name and DiscordName.Parent then
        DiscordName.Text = tostring(guild.name)
    end

    if guild.id and guild.icon and DiscordIcon.Parent then
        -- PNG também funciona para ícones animados como uma imagem estática.
        local iconUrl = "https://cdn.discordapp.com/icons/"
            .. tostring(guild.id)
            .. "/"
            .. tostring(guild.icon)
            .. ".png"
            .. "?size=128"
        local iconSource, isLocalAsset = loadDiscordIcon(
            iconUrl,
            tostring(guild.id) .. "_" .. tostring(guild.icon)
        )
        local imageOk = pcall(function()
            DiscordIcon.Image = iconSource
            DiscordIcon.ImageTransparency = 0
        end)
        if imageOk and isLocalAsset then
            DiscordIconFallback.Visible = false
        end
    end
end)

local InfoNotice = create("Frame", {
    Size = UDim2.new(1, 0, 0, 82),
    Position = UDim2.fromOffset(0, 212),
    BackgroundColor3 = Color3.fromRGB(29, 34, 47),
    BorderSizePixel = 0,
}, InfoPage)
corner(InfoNotice, 10)
stroke(InfoNotice, Color3.fromRGB(220, 178, 82), 1, 0.72)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 22),
    Position = UDim2.fromOffset(14, 11),
    BackgroundTransparency = 1,
    Text = "Aviso importante",
    TextColor3 = Color3.fromRGB(255, 215, 125),
    TextSize = 14,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, InfoNotice)

create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 44),
    Position = UDim2.fromOffset(14, 34),
    BackgroundTransparency = 1,
    Text = "A API pública não informa a região do servidor.\n"
        .. "O botão English Server está desativado até existir um filtro confiável.",
    TextColor3 = Color3.fromRGB(210, 215, 225),
    TextSize = 11,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, InfoNotice)

local InfoVersion = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    Position = UDim2.new(0, 0, 1, -28),
    BackgroundTransparency = 1,
    Text = "Server Finder  •  " .. GUARD_VERSION .. "  •  interface responsiva",
    TextColor3 = Color3.fromRGB(120, 145, 170),
    TextSize = 11,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, InfoPage)

-- Loading renovado.
local Loading = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(8, 10, 17),
    BackgroundTransparency = 0.03,
    Visible = true,
    Active = true,
    ZIndex = 50,
}, Window)
corner(Loading, 14)
stroke(Loading, Color3.fromRGB(0, 190, 230), 1, 0.35)

-- O overlay cobre o cabeçalho; este X mantém a tela fechável durante a verificação.
local LoadingClose = create("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -42, 0, 10),
    BackgroundColor3 = Color3.fromRGB(190, 55, 65),
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 55,
}, Loading)
corner(LoadingClose, 7)
styleButton(LoadingClose, Color3.fromRGB(190, 55, 65), Color3.fromRGB(225, 70, 80))

local LoadingAccent = create("Frame", {
    Size = UDim2.new(0, 4, 1, -84),
    Position = UDim2.fromOffset(24, 42),
    BackgroundColor3 = Color3.fromRGB(0, 190, 230),
    BorderSizePixel = 0,
    ZIndex = 51,
}, Loading)
corner(LoadingAccent, 3)

local LoadingAvatar = create("ImageLabel", {
    Size = UDim2.fromOffset(76, 76),
    Position = UDim2.new(0.5, -38, 0, 54),
    BackgroundColor3 = Color3.fromRGB(35, 40, 58),
    BorderSizePixel = 0,
    Image = "",
    ZIndex = 52,
}, Loading)
corner(LoadingAvatar, 38)
local LoadingAvatarStroke = stroke(LoadingAvatar, Color3.fromRGB(0, 190, 230), 2, 0.15)

local LoadingBrand = create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 24),
    Position = UDim2.new(0, 40, 0, 140),
    BackgroundTransparency = 1,
    Text = "SERVER FINDER",
    TextColor3 = Color3.fromRGB(245, 248, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 52,
}, Loading)

create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 18),
    Position = UDim2.new(0, 40, 0, 165),
    BackgroundTransparency = 1,
    Text = "by mateus_15600",
    TextColor3 = Color3.fromRGB(120, 220, 220),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 52,
}, Loading)

local LoadingTitle = create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 32),
    Position = UDim2.new(0, 40, 0, 208),
    BackgroundTransparency = 1,
    Text = "Preparando seu painel...",
    TextColor3 = Color3.fromRGB(240, 240, 250),
    TextSize = 18,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 51,
}, Loading)

local LoadingDetail = create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 24),
    Position = UDim2.new(0, 40, 0, 248),
    BackgroundTransparency = 1,
    Text = "Ajustando a interface à sua tela...",
    TextColor3 = Color3.fromRGB(175, 180, 200),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 51,
}, Loading)

local LoadingBarBack = create("Frame", {
    Size = UDim2.new(0, 300, 0, 7),
    Position = UDim2.new(0.5, -150, 0, 294),
    BackgroundColor3 = Color3.fromRGB(37, 44, 62),
    BorderSizePixel = 0,
    ZIndex = 51,
}, Loading)
corner(LoadingBarBack, 4)

local LoadingBarFill = create("Frame", {
    Size = UDim2.new(0.12, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 190, 230),
    BorderSizePixel = 0,
    ZIndex = 52,
}, LoadingBarBack)
corner(LoadingBarFill, 4)
create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 235, 205)),
    }),
}, LoadingBarFill)

local LoadingHint = create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 18),
    Position = UDim2.new(0, 40, 0, 316),
    BackgroundTransparency = 1,
    Text = "Siga o criador para liberar o painel.",
    TextColor3 = Color3.fromRGB(125, 135, 160),
    TextSize = 11,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 51,
}, Loading)

local LoadingContinue = create("TextButton", {
    Size = UDim2.fromOffset(150, 32),
    Position = UDim2.new(0.5, -75, 0, 402),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    BorderSizePixel = 0,
    Text = "ENTRAR AGORA",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    Font = Enum.Font.SourceSansBold,
    Visible = false,
    ZIndex = 52,
}, Loading)
corner(LoadingContinue, 8)

local FollowStatus = create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 38),
    Position = UDim2.new(0, 40, 0, 338),
    BackgroundTransparency = 1,
    Text = "Siga @" .. CREATOR_USERNAME .. " para liberar o script.",
    TextColor3 = Color3.fromRGB(255, 215, 125),
    TextSize = 11,
    TextWrapped = true,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    ZIndex = 52,
}, Loading)

local FollowOpen = create("TextButton", {
    Size = UDim2.fromOffset(132, 32),
    Position = UDim2.new(0.5, -140, 0, 374),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    BorderSizePixel = 0,
    Text = "ABRIR PERFIL",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 52,
}, Loading)
corner(FollowOpen, 8)
styleButton(FollowOpen, Color3.fromRGB(0, 135, 190), Color3.fromRGB(0, 170, 215))

local FollowCheck = create("TextButton", {
    Size = UDim2.fromOffset(132, 32),
    Position = UDim2.new(0.5, 8, 0, 374),
    BackgroundColor3 = Color3.fromRGB(28, 118, 92),
    BorderSizePixel = 0,
    Text = "JÁ SEGUI — VERIFICAR",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 10,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 52,
}, Loading)
corner(FollowCheck, 8)
styleButton(FollowCheck, Color3.fromRGB(28, 118, 92), Color3.fromRGB(38, 150, 112))

task.spawn(function()
    local ok, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(CREATOR_USERNAME)
    end)
    if not ok or not userId then
        return
    end
    creatorUserId = userId
    local thumbOk, thumbnail = pcall(function()
        return Players:GetUserThumbnailAsync(
            userId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)
    if thumbOk and thumbnail and OwnerAvatar.Parent then
        OwnerAvatar.Image = thumbnail
        LoadingAvatar.Image = thumbnail
    end
end)

local loadingProgress = 0.12
local loadingMessage = "Ajustando a interface à sua tela..."
local loadingFinishing = false

local function hideLoading(instant)
    if Loading and Loading.Parent then
        if followGateVisible and not followUnlocked and not instant then
            return
        end
        if instant then
            loadingFinishing = false
            Loading.Visible = false
            return
        end

        if not Loading.Visible or loadingFinishing then
            return
        end

        loadingFinishing = true
        loadingProgress = 1
        LoadingBarFill.Size = UDim2.new(1, 0, 1, 0)
        LoadingHint.Text = "Carregamento concluído."
        task.wait(0.18)

        if not Loading.Parent then
            return
        end
        Loading.Visible = false
        loadingFinishing = false
    end
end

local function showLoading(text)
    if followGateVisible and not followUnlocked then
        return
    end
    loadingMessage = text or "Processando..."
    LoadingDetail.Text = loadingMessage
    LoadingTitle.Text = "Aguarde um momento..."
    LoadingHint.Text = "Você pode continuar e fechar esta tela quando quiser."
    -- Busca e teleporte usam a mesma camada visual, mas não devem parecer a tela de follow.
    FollowStatus.Visible = false
    FollowOpen.Visible = false
    FollowCheck.Visible = false
    LoadingContinue.Visible = false
    loadingFinishing = false
    loadingProgress = 0.08
    LoadingBarFill.Size = UDim2.new(loadingProgress, 0, 1, 0)
    Loading.Visible = true
end

local function parseFollowResponse(body)
    if type(body) == "boolean" then
        return body
    end
    if type(body) ~= "string" then
        return nil
    end

    local normalized = body:match("^%s*(.-)%s*$")
    if normalized == "true" then
        return true
    end
    if normalized == "false" then
        return false
    end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(normalized)
    end)
    if not ok then
        return nil
    end
    if type(decoded) == "boolean" then
        return decoded
    end
    if type(decoded) == "table" then
        if decoded.isFollowing ~= nil then
            return decoded.isFollowing == true
        end
        if decoded.following ~= nil then
            return decoded.following == true
        end
    end
    return nil
end

local function resolveCreatorUserId()
    if creatorUserId then
        return creatorUserId
    end

    local ok, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(CREATOR_USERNAME)
    end)
    if ok and userId then
        creatorUserId = userId
        return userId
    end
    error("Não foi possível localizar o perfil do criador.")
end

local function queryCreatorFollow()
    local creatorId = resolveCreatorUserId()
    local cursor

    -- Esta rota pública não exige cookie do Roblox. A consulta paginada
    -- evita depender de /user/following-exists, que exige autenticação web.
    for page = 1, 50 do
        if destroyed then
            error("Verificação cancelada.")
        end
        if not followUnlocked and FollowStatus and FollowStatus.Parent then
            FollowStatus.Text = "Verificando sua lista de follows... " .. page .. "/50"
        end
        local url = "https://friends.roblox.com/v1/users/"
            .. tostring(Player.UserId)
            .. "/followings?sortOrder=Asc&limit=100"
        if cursor and cursor ~= "" then
            url = url .. "&cursor=" .. urlEncode(cursor)
        end

        local data = decodeJson(httpGet(url), "Resposta de follow inválida.")
        if type(data.data) ~= "table" then
            error("A API não retornou a lista de followings.")
        end

        for _, followedUser in ipairs(data.data) do
            if type(followedUser) == "table"
                and tonumber(followedUser.id or followedUser.userId) == tonumber(creatorId) then
                return true
            end
        end

        cursor = data.nextPageCursor
        if not cursor or cursor == "" then
            return false
        end
    end

    error("A lista de followings excedeu o limite de páginas.")
end

local function lockFollowGate(statusText)
    local wasVisible = followGateVisible
    followUnlocked = false
    followGateVisible = true
    if not wasVisible then
        followGateStartedAt = os.clock()
    end
    if not Loading or not Loading.Parent then
        return
    end

    loadingFinishing = false
    Loading.Visible = true
    LoadingClose.Visible = true
    loadingProgress = 0.08
    LoadingBarFill.Size = UDim2.new(loadingProgress, 0, 1, 0)
    LoadingTitle.Text = "Follow necessário"
    LoadingDetail.Text = "Siga @" .. CREATOR_USERNAME .. " para continuar."
    LoadingHint.Text = "O painel será liberado automaticamente quando o follow for confirmado."
    FollowStatus.Visible = true
    FollowStatus.Text = statusText or "Siga @" .. CREATOR_USERNAME .. " para liberar o script."
    FollowStatus.TextColor3 = Color3.fromRGB(255, 215, 125)
    FollowOpen.Visible = true
    FollowCheck.Visible = true
    FollowOpen.Active = true
    FollowCheck.Active = true
    LoadingContinue.Visible = false
end

local function unlockFollowGate()
    local shouldHide = followGateVisible
    local minimumRemaining = math.max(0, FOLLOW_LOADING_MIN_SECONDS - (os.clock() - followGateStartedAt))
    followUnlocked = true
    followGateVisible = false
    followChecking = false
    FollowStatus.Text = "✓ Follow confirmado. O painel foi liberado."
    FollowStatus.TextColor3 = Color3.fromRGB(145, 240, 180)
    FollowOpen.Visible = false
    FollowCheck.Visible = false
    LoadingContinue.Visible = false
    LoadingClose.Visible = true
    LoadingTitle.Text = "Acesso liberado!"
    LoadingDetail.Text = "Obrigado por seguir o criador."
    LoadingHint.Text = "Abrindo o painel automaticamente..."
    LoadingBarFill.Size = UDim2.new(1, 0, 1, 0)

    if shouldHide then
        task.spawn(function()
            task.wait(minimumRemaining)
            if not destroyed and Loading.Parent then
                hideLoading(true)
            end
        end)
    end
end

local function checkFollowGate(silent)
    if destroyed or followChecking then
        return
    end
    if followUnlocked and not silent then
        return
    end

    followChecking = true
    if not silent or not followUnlocked then
        Loading.Visible = true
        LoadingClose.Visible = true
        LoadingTitle.Text = "Verificando follow..."
        LoadingDetail.Text = "Consultando o perfil do criador."
        FollowStatus.Text = "Aguarde, verificando..."
        FollowStatus.TextColor3 = Color3.fromRGB(225, 210, 110)
        FollowOpen.Active = false
        FollowCheck.Active = false
    end

    task.spawn(function()
        local ok, isFollowing = pcall(queryCreatorFollow)
        if destroyed or not Loading.Parent then
            return
        end

        followChecking = false
        if ok and isFollowing == true then
            unlockFollowGate()
            return
        end

        if ok and isFollowing == false then
            if searching and followUnlocked then
                return
            end
            lockFollowGate("Ainda não encontrei o follow. Siga o criador; o painel abrirá sozinho quando confirmar.")
        elseif not followUnlocked then
            Loading.Visible = true
            LoadingClose.Visible = true
            FollowOpen.Active = true
            FollowCheck.Active = true
            local reason = tostring(isFollowing or "erro desconhecido"):gsub("[%c]+", " ")
            if #reason > 90 then
                reason = reason:sub(1, 90) .. "..."
            end
            FollowStatus.Text = "Falha ao verificar follow: " .. reason
            FollowStatus.TextColor3 = Color3.fromRGB(240, 130, 130)
            LoadingTitle.Text = "Follow necessário"
            LoadingDetail.Text = "Confira o HTTP do executor e tente verificar novamente."
        end
    end)
end

FollowOpen.MouseButton1Click:Connect(function()
    local opened = false
    local openers = {}
    if type(open_url) == "function" then
        table.insert(openers, open_url)
    end
    if type(syn) == "table" and type(syn.open_url) == "function" then
        table.insert(openers, syn.open_url)
    end

    for _, opener in ipairs(openers) do
        local ok = pcall(opener, CREATOR_PROFILE_URL)
        if ok then
            opened = true
            break
        end
    end

    if opened then
        FollowStatus.Text = "Perfil aberto. Siga o criador e clique em verificar."
    elseif copyToClipboard(CREATOR_PROFILE_URL) then
        FollowStatus.Text = "Link do perfil copiado. Siga o criador e clique em verificar."
    else
        FollowStatus.Text = CREATOR_PROFILE_URL
    end
    FollowStatus.TextColor3 = Color3.fromRGB(165, 215, 240)
end)

FollowCheck.MouseButton1Click:Connect(checkFollowGate)

LoadingContinue.MouseButton1Click:Connect(function()
    if followUnlocked then
        hideLoading(true)
    else
        checkFollowGate()
    end
end)

LoadingClose.MouseButton1Click:Connect(function()
    destroyed = true
    if Gui and Gui.Parent then
        Gui:Destroy()
    end
end)

-- Mantém o estado sincronizado: seguir libera sozinho; deixar de seguir mostra o bloqueio.
task.spawn(function()
    while not destroyed do
        task.wait(8)
        if not destroyed and not searching then
            checkFollowGate(true)
        end
    end
end)

local lastViewport
loadingConnection = RunService.RenderStepped:Connect(function(delta)
    if destroyed then
        loadingConnection:Disconnect()
        return
    end
    local viewport = getViewport()
    if not lastViewport or viewport.X ~= lastViewport.X or viewport.Y ~= lastViewport.Y then
        lastViewport = viewport
        applyResponsiveScale()
        clampWindowToViewport()
    end
    if Loading.Visible and not loadingFinishing and not followChecking and not followUnlocked then
        loadingProgress = math.min(1, loadingProgress + delta * 0.18)
        LoadingBarFill.Size = UDim2.new(loadingProgress, 0, 1, 0)
        LoadingTitle.Text = "Preparando seu painel" .. string.rep(".", math.floor(os.clock() * 2) % 4)
    end
end)

-- Teleporte e busca verificada.
local function teleport(server)
    local instanceId = type(server) == "table" and (server.id or server.gameId)
    if type(instanceId) ~= "string" or instanceId == "" then
        setStatus(SearchStatus, "O servidor selecionado não possui um ID válido.", Color3.fromRGB(240, 130, 130))
        return false
    end

    blacklist[instanceId] = os.time() + Config.blacklistTime
    teleportFailed = false
    local teleportStarted = false
    local teleportStartedAt
    local attemptConnection
    pcall(function()
        attemptConnection = Player.OnTeleport:Connect(function(state)
            local stateName = tostring(state)
            if stateName:find("Started", 1, true)
                or stateName:find("WaitingForServer", 1, true)
                or stateName:find("InProgress", 1, true) then
                teleportStarted = true
                teleportStartedAt = teleportStartedAt or os.clock()
            elseif stateName:find("Failed", 1, true) then
                teleportFailed = true
            end
        end)
    end)

    local ok, errorMessage = pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, instanceId, Player)
    end)
    if not ok then
        if attemptConnection then
            attemptConnection:Disconnect()
        end
        setStatus(SearchStatus, "Falha ao iniciar: " .. tostring(errorMessage), Color3.fromRGB(240, 130, 130))
        return false
    end

    if not attemptConnection then
        task.wait(8)
        return not teleportFailed
    end

    local deadline = os.clock() + 12
    while not teleportFailed and not destroyed and os.clock() < deadline do
        local startupConfirmed = teleportStarted
            and teleportStartedAt
            and os.clock() - teleportStartedAt >= 1.5
        if startupConfirmed then
            break
        end
        task.wait(0.1)
    end
    attemptConnection:Disconnect()

    if teleportStarted and not teleportFailed then
        return true
    end
    if not teleportFailed and not destroyed then
        setStatus(SearchStatus, "O teleporte não começou dentro do tempo esperado. Tente outro servidor.", Color3.fromRGB(240, 130, 130))
    end
    return false
end

pcall(function()
    teleportInitFailedConnection = TeleportService.TeleportInitFailed:Connect(function(player, result)
        if player == Player then
            teleportFailed = true
            setStatus(SearchStatus, "Teleporte recusado: " .. tostring(result), Color3.fromRGB(240, 130, 130))
        end
    end)
end)

local function searchVerifiedUser()
    if not followUnlocked then
        setStatus(VerifiedStatus, "Siga o criador para liberar o script.", Color3.fromRGB(225, 210, 110))
        return
    end
    local username = VerifiedInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if username == "" then
        setStatus(VerifiedStatus, "Digite um username.", Color3.fromRGB(240, 130, 130))
        return
    end
    if searching then
        setStatus(VerifiedStatus, "Aguarde a busca atual terminar.", Color3.fromRGB(225, 210, 110))
        return
    end

    searching = true
    setStatus(VerifiedStatus, "Consultando o perfil...", Color3.fromRGB(225, 210, 110))
    showLoading("Verificando o usuário...")

    task.spawn(function()
        local ok, result = pcall(function()
            local lookupResponse = httpRequest(
                "https://users.roblox.com/v1/usernames/users",
                "POST",
                HttpService:JSONEncode({
                    usernames = {username},
                    excludeBannedUsers = true,
                })
            )
            local lookupData = HttpService:JSONDecode(lookupResponse)
            local userData = lookupData.data and lookupData.data[1]
            if not userData or not userData.id then
                error("Usuário não encontrado.")
            end

            local profileResponse = httpGet("https://users.roblox.com/v1/users/" .. tostring(userData.id))
            local profile = HttpService:JSONDecode(profileResponse)
            if profile.hasVerifiedBadge ~= true then
                error("Esse usuário não possui o selo de verificação.")
            end

            local presenceResponse = httpRequest(
                "https://presence.roblox.com/v1/presence/users",
                "POST",
                HttpService:JSONEncode({userIds = {userData.id}})
            )
            local presenceData = HttpService:JSONDecode(presenceResponse)
            local presence = presenceData.userPresences and presenceData.userPresences[1]

            if not presence
                or presence.userPresenceType ~= 2
                or not presence.gameId then
                error("O usuário verificado não está em um servidor agora.")
            end

            if tonumber(presence.placeId) ~= PLACE_ID then
                error("O usuário verificado não está no Brookhaven.")
            end

            return {
                id = presence.gameId,
                username = userData.name or username,
            }
        end)

        if not ok then
            setStatus(VerifiedStatus, tostring(result), Color3.fromRGB(240, 130, 130))
            searching = false
            hideLoading()
            return
        end

        setStatus(VerifiedStatus, "Servidor encontrado. Aguardando confirmação...", Color3.fromRGB(225, 210, 110))
        VerifiedPopup.Visible = false
        if not askTeleportConfirmation(result, "o servidor do usuário " .. result.username) then
            searching = false
            hideLoading()
            setStatus(VerifiedStatus, "Teleporte cancelado.", Color3.fromRGB(225, 210, 110))
            return
        end
        setStatus(VerifiedStatus, "Entrando no servidor confirmado...", Color3.fromRGB(160, 230, 175))
        local joined = teleport(result)
        searching = false
        hideLoading()
        if not joined then
            setStatus(VerifiedStatus, "O teleporte para o servidor falhou.", Color3.fromRGB(240, 130, 130))
        end
    end)
end

VerifiedSearch.MouseButton1Click:Connect(searchVerifiedUser)

runSearch = function(mode, label)
    if not followUnlocked then
        setStatus(SearchStatus, "Siga o criador para liberar o script.", Color3.fromRGB(225, 210, 110))
        return
    end
    if searching then
        return
    end

    searching = true
    showLoading("Buscando " .. label .. "...")

    task.spawn(function()
        local connected = false
        local cancelled = false
        local failureMessage
        local ok, searchError = pcall(function()
            local maxAttempts = mode == "brazil" and 2 or 5
            for attempt = 1, maxAttempts do
                if destroyed then
                    break
                end
                setStatus(
                    SearchStatus,
                    label .. " • tentativa " .. attempt .. "/" .. maxAttempts,
                    Color3.fromRGB(225, 210, 110)
                )
                local server, selectionError = chooseServer(mode)
                if server then
                    setStatus(
                        SearchStatus,
                        "Selecionado: " .. server.playing .. "/" .. server.maxPlayers,
                        Color3.fromRGB(165, 215, 240)
                    )
                    if askTeleportConfirmation(server, label) then
                        showLoading("Conectando ao servidor...")
                        if teleport(server) then
                            connected = true
                            break
                        end
                    else
                        cancelled = true
                        setStatus(SearchStatus, "Teleporte cancelado.", Color3.fromRGB(225, 210, 110))
                        break
                    end
                else
                    failureMessage = selectionError
                    setStatus(
                        SearchStatus,
                        failureMessage or "Não foi possível encontrar um servidor.",
                        Color3.fromRGB(240, 130, 130)
                    )
                    break
                end
                task.wait(1)
            end
        end)

        if not ok then
            failureMessage = "A busca foi interrompida: " .. tostring(searchError)
        end
        searching = false
        hideLoading()
        if not connected and not cancelled then
            setStatus(
                SearchStatus,
                failureMessage or "Não foi possível trocar de servidor.",
                Color3.fromRGB(240, 130, 130)
            )
        end
    end)
end
BRButton.MouseButton1Click:Connect(function()
    runSearch("brazil", "servidor BR")
end)
RandomButton.MouseButton1Click:Connect(function()
    runSearch("random", "servidor aleatório")
end)

-- Arrastar janela.
local dragging = false
local dragStart
local startPosition
local resizing = false
local resizeStart
local resizeStartScale

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Window.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ResizeGrip.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        resizeStartScale = manualScale
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
    local isPointerMove = input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    if dragging and isPointerMove then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
        clampWindowToViewport()
    end

    if resizing and isPointerMove then
        local delta = input.Position - resizeStart
        local horizontalChange = delta.X / BASE_WIDTH
        local verticalChange = delta.Y / BASE_HEIGHT
        local scaleChange = math.max(horizontalChange, verticalChange)
        manualScale = clamp(resizeStartScale + scaleChange, MIN_SCALE, MAX_USER_SCALE)
        applyResponsiveScale()
        clampWindowToViewport()
    end
end)

local minimized = false
Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    Sidebar.Visible = not minimized
    Main.Visible = not minimized
    Window.Size = minimized
        and UDim2.new(0, 720, 0, 48)
        or UDim2.new(0, 720, 0, 460)
    Minimize.Text = minimized and "+" or "—"
    applyResponsiveScale()
    clampWindowToViewport()
end)

Close.MouseButton1Click:Connect(function()
    destroyed = true
    Gui:Destroy()
end)

-- Aplica o tema salvo somente depois de toda a interface estar registrada.
applyTheme(Config.theme)
showPage("Buscar")
addMessage(Config.botName, "Olá, " .. Config.userName .. ". A interface foi ajustada para a sua tela.")

task.spawn(function()
    task.wait(0.4)
    if not destroyed then
        checkFollowGate()
    end
end)

applyResponsiveScale()