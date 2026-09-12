--[[
    SERVER FINDER - RESPONSIVE EDITION

    Melhorias desta versão:
    - Escala automática baseada no tamanho real da tela.
    - Layout centrado, arrastável, minimizável e compatível com toque.
    - Loading renovado com progresso, animação e botão "entrar agora".
    - Aba Admin criada somente para o usuário mateus_15600.
    - Mantém busca de servidores, busca de usuário verificado e chatbot local.

    Observação:
    A autorização do painel Admin é local, porque este é um script de cliente.
    Ela controla a interface, mas não substitui uma validação no servidor.
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

local ADMIN_USERNAME = "mateus_15600"
local IS_ADMIN = string.lower(Player.Name) == string.lower(ADMIN_USERNAME)

local BASE_WIDTH = 720
local BASE_HEIGHT = 460
local MIN_SCALE = 0.55
local MAX_SCALE = 1
local MAX_USER_SCALE = 1.35

local Config = {
    botName = "NOVA",
    userName = Player.DisplayName or Player.Name,
    blacklistTime = 300,
    maxPages = 5,
}

local blacklist = {}
local searching = false
local teleportFailed = false
local destroyed = false
local currentScale = 1
local manualScale = 1

local function create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
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

local function httpGet(url)
    if type(game.HttpGet) == "function" then
        local ok, result = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and type(result) == "string" and result ~= "" then
            return result
        end
    end

    local requester = getRequester()
    if not requester then
        error("O executor não possui uma função HTTP.")
    end

    local response = requester({
        Url = url,
        Method = "GET",
    })

    if type(response) == "string" then
        return response
    end
    if type(response) == "table" then
        local status = tonumber(response.StatusCode or response.Status) or 200
        if status >= 400 then
            error("Erro HTTP " .. tostring(status))
        end
        return response.Body or response.body
    end
    error("Resposta HTTP inválida.")
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
    })

    if type(response) == "string" then
        return response
    end
    if type(response) == "table" then
        local status = tonumber(response.StatusCode or response.Status) or 200
        if status >= 400 then
            error("Erro HTTP " .. tostring(status))
        end
        return response.Body or response.body
    end
    error("Resposta HTTP inválida.")
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
                return HttpService:JSONDecode(body)
            end)
            if decoded and type(data) == "table" and type(data.data) == "table" then
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

local function collectServers()
    local result = {}
    local known = {}
    local cursor = ""

    for page = 1, Config.maxPages do
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

local function chooseServer(mode)
    local servers = collectServers()
    if #servers == 0 then
        return nil
    end

    if mode == "random" then
        return servers[math.random(1, #servers)]
    end

    local selected
    local bestScore = -math.huge

    for _, server in ipairs(servers) do
        local free = server.maxPlayers - server.playing
        local occupancy = server.playing / server.maxPlayers
        local score = occupancy * 1000 - free

        if mode == "full" and (server.playing < 6 or free < 2) then
            score = -math.huge
        end

        if score > bestScore then
            selected = server
            bestScore = score
        end
    end

    return selected or servers[1]
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

local Window = create("Frame", {
    Size = UDim2.fromOffset(BASE_WIDTH, BASE_HEIGHT),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(18, 20, 28),
    BorderSizePixel = 0,
}, Gui)
corner(Window, 14)
stroke(Window, Color3.fromRGB(70, 82, 110), 1, 0.45)

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
    BackgroundColor3 = Color3.fromRGB(29, 32, 44),
    BorderSizePixel = 0,
}, Window)
corner(Header, 14)
create("Frame", {
    Size = UDim2.new(1, 0, 0, 15),
    Position = UDim2.new(0, 0, 1, -15),
    BackgroundColor3 = Color3.fromRGB(29, 32, 44),
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

create("TextLabel", {
    Size = UDim2.new(1, -120, 0, 23),
    Position = UDim2.fromOffset(56, 3),
    BackgroundTransparency = 1,
    Text = "SERVER FINDER",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 16,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

create("TextLabel", {
    Size = UDim2.new(1, -120, 0, 17),
    Position = UDim2.fromOffset(57, 25),
    BackgroundTransparency = 1,
    Text = IS_ADMIN and "admin • mateus_15600" or "by mateus_15600",
    TextColor3 = IS_ADMIN and Color3.fromRGB(255, 205, 105) or Color3.fromRGB(145, 220, 180),
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
    BackgroundColor3 = Color3.fromRGB(24, 26, 36),
    BorderSizePixel = 0,
}, Window)
corner(Sidebar, 10)

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
local TabButtons = {}

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
        Position = UDim2.new(0, 8, 0, 12 + (order - 1) * 50),
        BackgroundColor3 = Color3.fromRGB(40, 43, 57),
        Text = text,
        TextColor3 = Color3.fromRGB(215, 218, 230),
        TextSize = 13,
        Font = Enum.Font.SourceSansBold,
    }, Sidebar)
    button:SetAttribute("ActiveColor", color or Color3.fromRGB(0, 135, 190))
    corner(button, 8)
    TabButtons[name] = button
    return button
end

local SearchPage = makePage("Buscar")
local ChatPage = makePage("Chat")
local ScriptsPage = makePage("Scripts")
local AdminPage

local SearchTab = makeTab("Buscar", "⌂  BUSCAR", 1)
local ChatTab = makeTab("Chat", "☵  CHAT BOT", 2)
local ScriptsTab = makeTab("Scripts", "▤  SCRIPTS", 3)
local AdminTab
if IS_ADMIN then
    AdminPage = makePage("Admin")
    AdminTab = makeTab("Admin", "⚙  ADMIN", 4, Color3.fromRGB(180, 120, 35))
end

local function showPage(name)
    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end
    for tabName, button in pairs(TabButtons) do
        local activeColor = button:GetAttribute("ActiveColor") or Color3.fromRGB(0, 135, 190)
        button.BackgroundColor3 = tabName == name
            and activeColor
            or Color3.fromRGB(40, 43, 57)
    end
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
if AdminTab then
    AdminTab.MouseButton1Click:Connect(function()
        showPage("Admin")
    end)
end

-- Página Buscar.
create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundTransparency = 1,
    Text = "Troca inteligente de servidor",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 19,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, SearchPage)

create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 36),
    Position = UDim2.fromOffset(0, 34),
    BackgroundTransparency = 1,
    Text = "Escolha uma estratégia. BR/EN são rótulos; a API não informa o idioma do servidor.",
    TextColor3 = Color3.fromRGB(165, 170, 190),
    TextSize = 12,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, SearchPage)

local SearchStatus = create("TextLabel", {
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
    return button
end

local BRButton = searchButton("Servidor BR*", UDim2.fromOffset(0, 88), Color3.fromRGB(0, 145, 75))
local ENButton = searchButton("English Server*", UDim2.fromOffset(220, 88), Color3.fromRGB(0, 105, 205))
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

VerifiedButton.MouseButton1Click:Connect(function()
    VerifiedPopup.Visible = true
    VerifiedInput:CaptureFocus()
end)
VerifiedClose.MouseButton1Click:Connect(function()
    VerifiedPopup.Visible = false
end)

-- Página Chat.
create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundTransparency = 1,
    Text = Config.botName .. "  •  assistente de sessão",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, ChatPage)

create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    Position = UDim2.fromOffset(0, 32),
    BackgroundTransparency = 1,
    Text = "Online nesta sessão  •  conversa privada local",
    TextColor3 = Color3.fromRGB(120, 220, 165),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, ChatPage)

local ChatLog = create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -176),
    Position = UDim2.fromOffset(0, 94),
    BackgroundColor3 = Color3.fromRGB(23, 26, 36),
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 5,
}, ChatPage)
corner(ChatLog, 10)

local ChatLayout = create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, ChatLog)

local ChatInput = create("TextBox", {
    Size = UDim2.new(1, -84, 0, 42),
    Position = UDim2.new(0, 0, 1, -44),
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

local SendButton = create("TextButton", {
    Size = UDim2.fromOffset(74, 42),
    Position = UDim2.new(1, -74, 1, -44),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    Text = "Enviar",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 13,
    Font = Enum.Font.SourceSansBold,
}, ChatPage)
corner(SendButton, 9)

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
end

local function clearChat()
    for _, child in ipairs(ChatLog:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
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
    for _, word in ipairs(words) do
        if text:find(word, 1, true) then
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
        return "Os rótulos BR e EN são apenas informativos: a API pública não informa o idioma do servidor."
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

-- Aba Admin: ela nem é criada para outros usuários.
local AdminStatus
if AdminPage then
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Text = "Painel administrativo",
        TextColor3 = Color3.fromRGB(255, 220, 135),
        TextSize = 20,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, AdminPage)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.fromOffset(0, 36),
        BackgroundTransparency = 1,
        Text = "Acesso local autorizado para @" .. ADMIN_USERNAME
            .. ". Use esta área para manutenção da interface.",
        TextColor3 = Color3.fromRGB(185, 190, 210),
        TextSize = 12,
        TextWrapped = true,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, AdminPage)

    local AdminInfo = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 76),
        Position = UDim2.fromOffset(0, 92),
        BackgroundColor3 = Color3.fromRGB(28, 31, 42),
        Text = "Usuário: @" .. Player.Name .. "\n"
            .. "Escala atual: calculando...\n"
            .. "Viewport: calculando...",
        TextColor3 = Color3.fromRGB(220, 225, 240),
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSans,
    }, AdminPage)
    corner(AdminInfo, 9)

    local AdminClear = create("TextButton", {
        Size = UDim2.fromOffset(205, 44),
        Position = UDim2.fromOffset(0, 184),
        BackgroundColor3 = Color3.fromRGB(145, 70, 70),
        Text = "Limpar blacklist",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.SourceSansBold,
    }, AdminPage)
    corner(AdminClear, 8)

    local AdminScale = create("TextButton", {
        Size = UDim2.fromOffset(205, 44),
        Position = UDim2.fromOffset(220, 184),
        BackgroundColor3 = Color3.fromRGB(0, 125, 165),
        Text = "Recalcular escala",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.SourceSansBold,
    }, AdminPage)
    corner(AdminScale, 8)

    AdminStatus = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 46),
        Position = UDim2.new(0, 0, 1, -52),
        BackgroundColor3 = Color3.fromRGB(28, 31, 42),
        Text = "Painel pronto.",
        TextColor3 = Color3.fromRGB(165, 225, 180),
        TextSize = 12,
        TextWrapped = true,
        Font = Enum.Font.SourceSans,
    }, AdminPage)
    corner(AdminStatus, 8)

    AdminClear.MouseButton1Click:Connect(function()
        table.clear(blacklist)
        setStatus(AdminStatus, "Blacklist limpa com sucesso.", Color3.fromRGB(165, 225, 180))
    end)
    AdminScale.MouseButton1Click:Connect(function()
        applyResponsiveScale()
        setStatus(AdminStatus, "Escala recalculada: " .. string.format("%.2fx", currentScale), Color3.fromRGB(165, 225, 180))
    end)

    RunService.RenderStepped:Connect(function()
        if destroyed or not AdminPage.Parent then
            return
        end
        local viewport = getViewport()
        AdminInfo.Text = "Usuário: @" .. Player.Name .. "\n"
            .. "Escala atual: " .. string.format("%.2fx", currentScale) .. "\n"
            .. "Viewport: " .. math.floor(viewport.X) .. " × " .. math.floor(viewport.Y)
    end)
end

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
    Position = UDim2.new(0.5, -38, 0.18, 0),
    BackgroundColor3 = Color3.fromRGB(35, 40, 58),
    BorderSizePixel = 0,
    Image = "",
    ZIndex = 52,
}, Loading)
corner(LoadingAvatar, 38)
local LoadingAvatarStroke = stroke(LoadingAvatar, Color3.fromRGB(0, 190, 230), 2, 0.15)

local LoadingBrand = create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 24),
    Position = UDim2.new(0, 40, 0.18, 86),
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
    Position = UDim2.new(0, 40, 0.18, 110),
    BackgroundTransparency = 1,
    Text = IS_ADMIN and "admin mode • mateus_15600" or "by mateus_15600",
    TextColor3 = IS_ADMIN and Color3.fromRGB(255, 205, 105) or Color3.fromRGB(120, 220, 220),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 52,
}, Loading)

local LoadingTitle = create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 32),
    Position = UDim2.new(0, 40, 0.53, 0),
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
    Position = UDim2.new(0, 40, 0.64, 0),
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
    Position = UDim2.new(0.5, -150, 0.74, 0),
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
    Position = UDim2.new(0, 40, 0.78, 0),
    BackgroundTransparency = 1,
    Text = "O loading fecha sozinho em alguns segundos.",
    TextColor3 = Color3.fromRGB(125, 135, 160),
    TextSize = 11,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 51,
}, Loading)

local LoadingContinue = create("TextButton", {
    Size = UDim2.fromOffset(150, 32),
    Position = UDim2.new(0.5, -75, 0.87, 0),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    BorderSizePixel = 0,
    Text = "ENTRAR AGORA",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 52,
}, Loading)
corner(LoadingContinue, 8)

task.spawn(function()
    local ok, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(ADMIN_USERNAME)
    end)
    if not ok or not userId then
        return
    end
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
    loadingMessage = text or "Processando..."
    LoadingDetail.Text = loadingMessage
    LoadingTitle.Text = "Aguarde um momento..."
    LoadingHint.Text = "Você pode continuar e fechar esta tela quando quiser."
    loadingFinishing = false
    loadingProgress = 0.08
    LoadingBarFill.Size = UDim2.new(loadingProgress, 0, 1, 0)
    Loading.Visible = true
end

LoadingContinue.MouseButton1Click:Connect(function()
    hideLoading(true)
end)

local loadingConnection
loadingConnection = RunService.RenderStepped:Connect(function(delta)
    if destroyed then
        loadingConnection:Disconnect()
        return
    end
    applyResponsiveScale()
    clampWindowToViewport()
    if Loading.Visible and not loadingFinishing then
        loadingProgress = math.min(1, loadingProgress + delta * 0.18)
        LoadingBarFill.Size = UDim2.new(loadingProgress, 0, 1, 0)
        LoadingAvatar.Rotation = (LoadingAvatar.Rotation + delta * 18) % 360
        LoadingTitle.Text = "Preparando seu painel" .. string.rep(".", math.floor(os.clock() * 2) % 4)
    end
end)

-- Teleporte e busca verificada.
local function teleport(server)
    blacklist[server.id] = os.time() + Config.blacklistTime
    teleportFailed = false

    local ok, errorMessage = pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, server.id, Player)
    end)
    if not ok then
        setStatus(SearchStatus, "Falha ao iniciar: " .. tostring(errorMessage), Color3.fromRGB(240, 130, 130))
        return false
    end

    task.wait(8)
    return not teleportFailed
end

pcall(function()
    TeleportService.TeleportInitFailed:Connect(function(player, result)
        if player == Player then
            teleportFailed = true
            setStatus(SearchStatus, "Teleporte recusado: " .. tostring(result), Color3.fromRGB(240, 130, 130))
        end
    end)
end)

local function searchVerifiedUser()
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

        setStatus(VerifiedStatus, "Servidor encontrado. Entrando...", Color3.fromRGB(160, 230, 175))
        VerifiedPopup.Visible = false
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
    if searching then
        return
    end

    searching = true
    showLoading("Buscando " .. label .. "...")

    task.spawn(function()
        local connected = false
        for attempt = 1, 5 do
            if destroyed then
                break
            end
            setStatus(
                SearchStatus,
                label .. " • tentativa " .. attempt .. "/5",
                Color3.fromRGB(225, 210, 110)
            )
            local server = chooseServer(mode)
            if server then
                setStatus(
                    SearchStatus,
                    "Selecionado: " .. server.playing .. "/" .. server.maxPlayers,
                    Color3.fromRGB(165, 215, 240)
                )
                showLoading("Conectando ao servidor...")
                if teleport(server) then
                    connected = true
                    break
                end
            else
                break
            end
            task.wait(1)
        end

        searching = false
        hideLoading()
        if not connected then
            setStatus(SearchStatus, "Não foi possível trocar de servidor.", Color3.fromRGB(240, 130, 130))
        end
    end)
end

BRButton.MouseButton1Click:Connect(function()
    runSearch("full", "servidor BR*")
end)
ENButton.MouseButton1Click:Connect(function()
    runSearch("full", "servidor EN*")
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

UserInputService.InputChanged:Connect(function(input)
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

showPage("Buscar")
addMessage(Config.botName, "Olá, " .. Config.userName .. ". A interface foi ajustada para a sua tela.")

task.spawn(function()
    task.wait(1.8)
    hideLoading()
end)

task.delay(5, function()
    if not destroyed then
        hideLoading()
    end
end)

applyResponsiveScale()