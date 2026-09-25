-- Centralizar o estado evita exceder o limite de 200 variáveis locais do Luau.
local _ServerFinderState = {}
--[[
    SERVER FINDER - RESPONSIVE EDITION

    Melhorias desta versão:
    - Escala automática baseada no tamanho real da tela.
    - Layout centrado, arrastável, minimizável e compatível com toque.
    - Loading renovado com progresso, animação e botão "entrar agora".
    - Liberação condicionada ao follow do criador, com verificação automática.
    - Abas Configs e Info com temas salvos, detalhes do script e acesso ao Discord.
    - Mantém busca de servidores, busca de usuário verificado e chatbot local.
    - Mostra novidades ao iniciar e consulta o país pelo IP público somente após o usuário tocar em OK.
    - Não exibe nem guarda o IP no script; o serviço de geolocalização recebe a conexão para estimar o país.
]]

 _ServerFinderState.Players = game:GetService("Players")
 _ServerFinderState.CoreGui = game:GetService("CoreGui")
 _ServerFinderState.HttpService = game:GetService("HttpService")
 _ServerFinderState.TeleportService = game:GetService("TeleportService")
 _ServerFinderState.UserInputService = game:GetService("UserInputService")
 _ServerFinderState.RunService = game:GetService("RunService")

 _ServerFinderState.Player = _ServerFinderState.Players.LocalPlayer or _ServerFinderState.Players.PlayerAdded:Wait()
 _ServerFinderState.PLACE_ID = 4924922222
 _ServerFinderState.GUARD_VERSION = "v1"
 _ServerFinderState.WRONG_GAME_MESSAGE = [[🇧🇷 você não está no jogo correto vá para o Brookhaven para usar o script
🇺🇸 You're not in the correct game. Go to Brookhaven to use the script.]]

_ServerFinderState.isBrookhaven = function()
    return (tonumber(game.PlaceId) or -1) == _ServerFinderState.PLACE_ID
end

_ServerFinderState.kickFromWrongGame = function()
    warn("[Server-Finder " .. _ServerFinderState.GUARD_VERSION .. "] Jogo incorreto. PlaceId: " .. tostring(game.PlaceId))
    pcall(function()
        if _ServerFinderState.Player and _ServerFinderState.Player.Parent then
            _ServerFinderState.Player:Kick(_ServerFinderState.WRONG_GAME_MESSAGE)
        end
    end)
    -- Segunda tentativa para executores que atrasam a primeira chamada.
    task.delay(0.25, function()
        pcall(function()
            if _ServerFinderState.Player and _ServerFinderState.Player.Parent then
                _ServerFinderState.Player:Kick(_ServerFinderState.WRONG_GAME_MESSAGE)
            end
        end)
    end)
end

if not _ServerFinderState.isBrookhaven() then
    _ServerFinderState.kickFromWrongGame()
    return
end

 _ServerFinderState.BASE_WIDTH = 720
 _ServerFinderState.BASE_HEIGHT = 460
 _ServerFinderState.MIN_SCALE = 0.55
 _ServerFinderState.MAX_USER_SCALE = 1.35
 _ServerFinderState.CREATOR_USERNAME = "mateus_15600"
 _ServerFinderState.CREATOR_PROFILE_URL = "https://www.roblox.com/users/profile?username=" .. _ServerFinderState.CREATOR_USERNAME
 _ServerFinderState.DISCORD_INVITE = "https://discord.gg/RtfAn6zku8"
 _ServerFinderState.DISCORD_INVITE_CODE = "RtfAn6zku8"

_ServerFinderState.Config = {
    botName = "NOVA",
    userName = _ServerFinderState.Player.DisplayName or _ServerFinderState.Player.Name,
    blacklistTime = 300,
    maxPages = 8,
    maxFriendPages = 20,
    maxRegionChecks = 30,
    regionCacheTime = 600,
    regionErrorCacheTime = 60,
}

-- Preferências visuais ficam no diretório de arquivos do executor.
-- O script continua funcionando mesmo em executores sem readfile/writefile:
-- nesse caso o tema vale para a sessão atual e a interface informa o motivo.
 _ServerFinderState.CONFIG_FILE = "ServerFinder_Config.json"
 _ServerFinderState.Themes = {
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

_ServerFinderState.addTheme = function(name, label, description, preview, baseName, overrides)
    local colors = {}
    for role, color in pairs(_ServerFinderState.Themes[baseName].colors) do
        colors[role] = color
    end
    for role, color in pairs(overrides) do
        colors[role] = color
    end

    _ServerFinderState.Themes[name] = {
        label = label,
        description = description,
        preview = preview,
        colors = colors,
    }
end

_ServerFinderState.addTheme("Troll", "Troll", "Rosa neon e energia caótica", Color3.fromRGB(255, 38, 145), "Sunset", {
    window = Color3.fromRGB(25, 12, 28),
    header = Color3.fromRGB(87, 16, 60),
    sidebar = Color3.fromRGB(48, 12, 43),
    panel = Color3.fromRGB(59, 17, 54),
    panelAlt = Color3.fromRGB(44, 13, 45),
    deep = Color3.fromRGB(19, 8, 23),
    surface = Color3.fromRGB(92, 23, 73),
    popup = Color3.fromRGB(79, 20, 65),
    notice = Color3.fromRGB(106, 31, 60),
    input = Color3.fromRGB(68, 21, 67),
    tab = Color3.fromRGB(74, 20, 69),
    tabHover = Color3.fromRGB(127, 31, 93),
    primary = Color3.fromRGB(255, 38, 145),
    success = Color3.fromRGB(40, 218, 100),
    warning = Color3.fromRGB(255, 220, 35),
    danger = Color3.fromRGB(255, 45, 95),
    purple = Color3.fromRGB(210, 70, 255),
    accent = Color3.fromRGB(255, 103, 206),
    accentStrong = Color3.fromRGB(255, 0, 190),
    border = Color3.fromRGB(201, 61, 170),
    text = Color3.fromRGB(255, 239, 250),
    textBright = Color3.fromRGB(255, 255, 255),
    textMuted = Color3.fromRGB(235, 174, 210),
    textDim = Color3.fromRGB(200, 131, 180),
    textAccent = Color3.fromRGB(255, 189, 231),
    textSuccess = Color3.fromRGB(150, 255, 182),
    textWarning = Color3.fromRGB(255, 232, 110),
    textDanger = Color3.fromRGB(255, 151, 171),
})

_ServerFinderState.addTheme("Doido", "Doido", "Roxo elétrico com verde-limão", Color3.fromRGB(177, 255, 42), "Ocean", {
    window = Color3.fromRGB(19, 13, 35),
    header = Color3.fromRGB(48, 24, 83),
    sidebar = Color3.fromRGB(31, 19, 57),
    panel = Color3.fromRGB(42, 25, 72),
    panelAlt = Color3.fromRGB(34, 20, 62),
    deep = Color3.fromRGB(14, 9, 29),
    surface = Color3.fromRGB(60, 35, 99),
    popup = Color3.fromRGB(53, 28, 88),
    notice = Color3.fromRGB(67, 40, 85),
    input = Color3.fromRGB(52, 31, 86),
    tab = Color3.fromRGB(47, 28, 80),
    tabHover = Color3.fromRGB(77, 43, 121),
    primary = Color3.fromRGB(151, 74, 255),
    success = Color3.fromRGB(112, 218, 38),
    successAlt = Color3.fromRGB(83, 170, 42),
    purple = Color3.fromRGB(190, 76, 255),
    warning = Color3.fromRGB(255, 220, 45),
    danger = Color3.fromRGB(255, 68, 133),
    accent = Color3.fromRGB(177, 255, 42),
    accentStrong = Color3.fromRGB(216, 255, 0),
    border = Color3.fromRGB(130, 88, 205),
    text = Color3.fromRGB(246, 241, 255),
    textMuted = Color3.fromRGB(190, 174, 222),
    textDim = Color3.fromRGB(151, 132, 190),
    textAccent = Color3.fromRGB(218, 255, 139),
    textSuccess = Color3.fromRGB(188, 255, 140),
    textWarning = Color3.fromRGB(255, 226, 121),
    textDanger = Color3.fromRGB(255, 151, 177),
})

_ServerFinderState.addTheme("Colorido", "Colorido", "Azul, rosa e amarelo vibrantes", Color3.fromRGB(255, 93, 171), "Ocean", {
    window = Color3.fromRGB(12, 23, 42),
    header = Color3.fromRGB(18, 42, 76),
    sidebar = Color3.fromRGB(14, 34, 62),
    panel = Color3.fromRGB(22, 48, 79),
    panelAlt = Color3.fromRGB(17, 40, 69),
    deep = Color3.fromRGB(8, 21, 39),
    surface = Color3.fromRGB(32, 62, 94),
    popup = Color3.fromRGB(26, 54, 87),
    notice = Color3.fromRGB(44, 57, 86),
    input = Color3.fromRGB(28, 57, 91),
    tab = Color3.fromRGB(25, 53, 86),
    tabHover = Color3.fromRGB(40, 77, 119),
    primary = Color3.fromRGB(35, 157, 255),
    success = Color3.fromRGB(50, 207, 132),
    successAlt = Color3.fromRGB(46, 157, 139),
    purple = Color3.fromRGB(177, 82, 255),
    warning = Color3.fromRGB(255, 198, 42),
    danger = Color3.fromRGB(255, 73, 119),
    accent = Color3.fromRGB(255, 93, 171),
    accentStrong = Color3.fromRGB(255, 52, 165),
    border = Color3.fromRGB(76, 139, 207),
    text = Color3.fromRGB(240, 248, 255),
    textMuted = Color3.fromRGB(174, 201, 226),
    textDim = Color3.fromRGB(127, 164, 201),
    textAccent = Color3.fromRGB(255, 186, 222),
    textSuccess = Color3.fromRGB(157, 246, 193),
    textWarning = Color3.fromRGB(255, 224, 119),
    textDanger = Color3.fromRGB(255, 153, 167),
})

_ServerFinderState.addTheme("Louco", "Louco", "Preto com verde ácido e vermelho", Color3.fromRGB(120, 255, 0), "Midnight", {
    window = Color3.fromRGB(9, 12, 12),
    header = Color3.fromRGB(19, 35, 22),
    sidebar = Color3.fromRGB(13, 26, 17),
    panel = Color3.fromRGB(20, 38, 24),
    panelAlt = Color3.fromRGB(16, 31, 20),
    deep = Color3.fromRGB(6, 10, 8),
    surface = Color3.fromRGB(30, 52, 32),
    popup = Color3.fromRGB(25, 46, 28),
    notice = Color3.fromRGB(45, 43, 21),
    input = Color3.fromRGB(25, 47, 28),
    tab = Color3.fromRGB(23, 43, 26),
    tabHover = Color3.fromRGB(39, 67, 35),
    primary = Color3.fromRGB(120, 255, 0),
    success = Color3.fromRGB(80, 220, 65),
    successAlt = Color3.fromRGB(46, 152, 58),
    purple = Color3.fromRGB(180, 58, 230),
    warning = Color3.fromRGB(255, 188, 0),
    danger = Color3.fromRGB(255, 35, 48),
    accent = Color3.fromRGB(174, 255, 61),
    accentStrong = Color3.fromRGB(90, 255, 0),
    border = Color3.fromRGB(76, 134, 56),
    text = Color3.fromRGB(238, 255, 235),
    textMuted = Color3.fromRGB(166, 199, 160),
    textDim = Color3.fromRGB(116, 156, 111),
    textAccent = Color3.fromRGB(205, 255, 176),
    textSuccess = Color3.fromRGB(159, 255, 132),
    textWarning = Color3.fromRGB(255, 221, 104),
    textDanger = Color3.fromRGB(255, 139, 139),
})

_ServerFinderState.addTheme("FakeErrors", "Erros Fakes", "Visual de alerta; sem erros reais", Color3.fromRGB(255, 63, 55), "Midnight", {
    window = Color3.fromRGB(27, 12, 15),
    header = Color3.fromRGB(66, 20, 25),
    sidebar = Color3.fromRGB(43, 15, 19),
    panel = Color3.fromRGB(55, 19, 23),
    panelAlt = Color3.fromRGB(42, 14, 19),
    deep = Color3.fromRGB(18, 8, 11),
    surface = Color3.fromRGB(75, 26, 29),
    popup = Color3.fromRGB(73, 22, 26),
    notice = Color3.fromRGB(86, 29, 24),
    input = Color3.fromRGB(61, 19, 25),
    tab = Color3.fromRGB(63, 20, 26),
    tabHover = Color3.fromRGB(103, 31, 36),
    primary = Color3.fromRGB(222, 52, 57),
    success = Color3.fromRGB(54, 176, 97),
    warning = Color3.fromRGB(255, 151, 38),
    danger = Color3.fromRGB(255, 54, 56),
    purple = Color3.fromRGB(167, 66, 181),
    accent = Color3.fromRGB(255, 112, 87),
    accentStrong = Color3.fromRGB(255, 65, 49),
    border = Color3.fromRGB(165, 55, 60),
    text = Color3.fromRGB(255, 239, 239),
    textMuted = Color3.fromRGB(219, 172, 174),
    textDim = Color3.fromRGB(177, 126, 132),
    textAccent = Color3.fromRGB(255, 183, 164),
    textSuccess = Color3.fromRGB(156, 237, 177),
    textWarning = Color3.fromRGB(255, 208, 135),
    textDanger = Color3.fromRGB(255, 151, 151),
})

_ServerFinderState.addTheme("WindowsClassic", "Clássico Windows", "Cinza clássico e azul de título", Color3.fromRGB(0, 0, 128), "Midnight", {
    window = Color3.fromRGB(192, 192, 192),
    header = Color3.fromRGB(0, 0, 128),
    sidebar = Color3.fromRGB(212, 208, 200),
    panel = Color3.fromRGB(192, 192, 192),
    panelAlt = Color3.fromRGB(212, 208, 200),
    deep = Color3.fromRGB(128, 128, 128),
    surface = Color3.fromRGB(223, 223, 223),
    popup = Color3.fromRGB(212, 208, 200),
    notice = Color3.fromRGB(223, 223, 223),
    discordCard = Color3.fromRGB(192, 192, 192),
    input = Color3.fromRGB(255, 255, 255),
    tab = Color3.fromRGB(192, 192, 192),
    tabHover = Color3.fromRGB(170, 190, 220),
    neutral = Color3.fromRGB(128, 128, 128),
    mutedButton = Color3.fromRGB(160, 160, 160),
    resize = Color3.fromRGB(128, 128, 128),
    overlay = Color3.fromRGB(50, 50, 50),
    loadingBar = Color3.fromRGB(160, 160, 160),
    infoButton = Color3.fromRGB(0, 0, 128),
    avatar = Color3.fromRGB(160, 160, 160),
    primary = Color3.fromRGB(0, 0, 128),
    success = Color3.fromRGB(0, 128, 0),
    successAlt = Color3.fromRGB(0, 112, 112),
    purple = Color3.fromRGB(128, 0, 128),
    warning = Color3.fromRGB(192, 96, 0),
    danger = Color3.fromRGB(128, 0, 0),
    discord = Color3.fromRGB(0, 0, 128),
    accent = Color3.fromRGB(0, 0, 128),
    accentStrong = Color3.fromRGB(0, 0, 160),
    border = Color3.fromRGB(128, 128, 128),
    text = Color3.fromRGB(0, 0, 0),
    textBright = Color3.fromRGB(0, 0, 0),
    textMuted = Color3.fromRGB(64, 64, 64),
    textDim = Color3.fromRGB(96, 96, 96),
    textAccent = Color3.fromRGB(0, 0, 128),
    textSuccess = Color3.fromRGB(0, 96, 0),
    textWarning = Color3.fromRGB(128, 64, 0),
    textDanger = Color3.fromRGB(128, 0, 0),
})

 _ServerFinderState.ThemeBindings = {}
 _ServerFinderState.ThemeButtons = {}
 _ServerFinderState.TabButtons = {}
 _ServerFinderState.TabIndicators = {}
 _ServerFinderState.TabStrokes = {}
_ServerFinderState.ThemeStatus = nil
_ServerFinderState.InfoTab = nil
 _ServerFinderState.currentThemeName = "Midnight"

_ServerFinderState.isTheme = function(name)
    return type(name) == "string" and _ServerFinderState.Themes[name] ~= nil
end

_ServerFinderState.loadSavedTheme = function()
    if type(readfile) ~= "function" then
        return "Midnight"
    end

    local ok, raw = pcall(readfile, _ServerFinderState.CONFIG_FILE)
    if not ok or type(raw) ~= "string" or raw == "" then
        return "Midnight"
    end

    local decodedOk, decoded = pcall(function()
        return _ServerFinderState.HttpService:JSONDecode(raw)
    end)
    if decodedOk and type(decoded) == "table" and _ServerFinderState.isTheme(decoded.theme) then
        return decoded.theme
    end
    return "Midnight"
end

_ServerFinderState.Config.theme = _ServerFinderState.loadSavedTheme()
_ServerFinderState.currentThemeName = _ServerFinderState.Config.theme

_ServerFinderState.saveTheme = function()
    if type(writefile) ~= "function" then
        return false, "Este executor não permite salvar arquivos."
    end

    local ok, errorMessage = pcall(function()
        writefile(_ServerFinderState.CONFIG_FILE, _ServerFinderState.HttpService:JSONEncode({
            theme = _ServerFinderState.Config.theme,
        }))
    end)
    if not ok then
        return false, tostring(errorMessage)
    end
    return true
end

_ServerFinderState.colorKey = function(color)
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

 _ServerFinderState.BackgroundRoles = {
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

 _ServerFinderState.TextRoles = {
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

 _ServerFinderState.StrokeRoles = {
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

_ServerFinderState.inferThemeRole = function(className, property, value)
    local key = _ServerFinderState.colorKey(value)
    if not key then
        return nil
    end
    if property == "BackgroundColor3" then
        return _ServerFinderState.BackgroundRoles[key]
    end
    if property == "TextColor3" then
        return _ServerFinderState.TextRoles[key]
    end
    if className == "UIStroke" and property == "Color" then
        return _ServerFinderState.StrokeRoles[key]
    end
    return nil
end

_ServerFinderState.applyTheme = function(name)
    if not _ServerFinderState.isTheme(name) then
        name = "Midnight"
    end

    _ServerFinderState.Config.theme = name
    _ServerFinderState.currentThemeName = name
    local colors = _ServerFinderState.Themes[name].colors
    for _, binding in ipairs(_ServerFinderState.ThemeBindings) do
        if binding.object and binding.object.Parent and colors[binding.role] then
            pcall(function()
                binding.object[binding.property] = colors[binding.role]
            end)
        end
    end

    for _, themeButton in ipairs(_ServerFinderState.ThemeButtons) do
        if themeButton.button and themeButton.button.Parent then
            local selected = themeButton.name == name
            themeButton.button.BackgroundColor3 = selected
                and colors.primary
                or colors.tab
            themeButton.button.TextColor3 = colors.textBright
            themeButton.button.Text = selected
                and "✓  " .. themeButton.label .. "\n" .. _ServerFinderState.Themes[themeButton.name].description
                or themeButton.label .. "\n" .. _ServerFinderState.Themes[themeButton.name].description
            if themeButton.preview and themeButton.preview.Parent then
                themeButton.preview.BackgroundColor3 = _ServerFinderState.Themes[themeButton.name].preview
            end
        end
    end

    for tabName, button in pairs(_ServerFinderState.TabButtons) do
        local activeColor = tabName == "Configs" and colors.purple or colors.primary
        button:SetAttribute("ActiveColor", activeColor)
        if _ServerFinderState.TabIndicators[tabName] then
            _ServerFinderState.TabIndicators[tabName].BackgroundColor3 = activeColor
        end
    end
    if _ServerFinderState.InfoTab and _ServerFinderState.InfoTab.Parent then
        _ServerFinderState.InfoTab.BackgroundColor3 = _ServerFinderState.InfoTab:GetAttribute("IsActive")
            and colors.primary
            or colors.infoButton
        _ServerFinderState.InfoTab.TextColor3 = _ServerFinderState.InfoTab:GetAttribute("IsActive")
            and colors.textBright
            or colors.textAccent
    end

    if _ServerFinderState.ThemeStatus and _ServerFinderState.ThemeStatus.Parent then
        _ServerFinderState.ThemeStatus.Text = "Tema atual: " .. _ServerFinderState.Themes[name].label
        _ServerFinderState.ThemeStatus.TextColor3 = colors.textSuccess
    end
end

 _ServerFinderState.blacklist = {}
_ServerFinderState.friendServerCache = nil
 _ServerFinderState.friendServerCacheAt = 0
 _ServerFinderState.regionCache = {}
 _ServerFinderState.regionApiUnavailable = false
 _ServerFinderState.regionAuthRequired = false
 _ServerFinderState.searching = false
 _ServerFinderState.teleportFailed = false
 _ServerFinderState.destroyed = false
_ServerFinderState.loadingConnection = nil
_ServerFinderState.inputChangedConnection = nil
_ServerFinderState.teleportInitFailedConnection = nil
_ServerFinderState.creatorUserId = nil
 _ServerFinderState.followUnlocked = false
 _ServerFinderState.followChecking = false
 _ServerFinderState.followGateVisible = true
 _ServerFinderState.FOLLOW_LOADING_MIN_SECONDS = 3
 _ServerFinderState.FOLLOW_RECHECK_INTERVAL = 30
 _ServerFinderState.followGateStartedAt = os.clock()
 _ServerFinderState.currentScale = 1
 _ServerFinderState.manualScale = 1
_ServerFinderState.SearchStatus = nil

_ServerFinderState.create = function(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
        local role = _ServerFinderState.inferThemeRole(className, property, value)
        if role then
            table.insert(_ServerFinderState.ThemeBindings, {
                object = object,
                property = property,
                role = role,
            })
        end
    end
    object.Parent = parent
    return object
end

_ServerFinderState.corner = function(object, radius)
    _ServerFinderState.create("UICorner", {CornerRadius = UDim.new(0, radius)}, object)
end

_ServerFinderState.stroke = function(object, color, thickness, transparency)
    return _ServerFinderState.create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, object)
end

_ServerFinderState.styleButton = function(button, color, hoverColor)
    button.AutoButtonColor = false
    _ServerFinderState.stroke(button, Color3.fromRGB(255, 255, 255), 1, 0.82)
    local themeRole = _ServerFinderState.inferThemeRole("TextButton", "BackgroundColor3", color)
    local function baseColor()
        return themeRole and _ServerFinderState.Themes[_ServerFinderState.currentThemeName].colors[themeRole] or color
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

_ServerFinderState.disableButton = function(button, color)
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

_ServerFinderState.clamp = function(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

_ServerFinderState.setStatus = function(label, text, color)
    if label and label.Parent then
        label.Text = tostring(text)
        if color then
            label.TextColor3 = color
        end
    end
end

_ServerFinderState.urlEncode = function(value)
    return tostring(value):gsub("([^%w%-_%.~])", function(character)
        return string.format("%%%02X", string.byte(character))
    end)
end

_ServerFinderState.getRequester = function()
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

 _ServerFinderState.HTTP_TIMEOUT = 12

_ServerFinderState.responseBody = function(response)
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

_ServerFinderState.httpGet = function(url)
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
    local requester = _ServerFinderState.getRequester()
    if requester then
        local ok, response = pcall(requester, {
            Url = url,
            Method = "GET",
            Timeout = _ServerFinderState.HTTP_TIMEOUT,
        })
        if not ok then
            error(lastError or response)
        end
        local bodyOk, body = pcall(_ServerFinderState.responseBody, response)
        if bodyOk then
            return body
        end
        error(body)
    end

    error(lastError or "O executor não possui uma função HTTP.")
end

_ServerFinderState.httpRequest = function(url, method, body)
    local requester = _ServerFinderState.getRequester()
    if not requester then
        error("Este executor não possui request para POST.")
    end

    local options = {
        Url = url,
        Method = method or "GET",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json",
            ["User-Agent"] = "Roblox/WinInet",
            ["Referer"] = "https://www.roblox.com/",
        },
        Body = body,
        Timeout = _ServerFinderState.HTTP_TIMEOUT,
    }
    local ok, response = pcall(requester, options)
    if not ok then
        -- Alguns executores rejeitam a opção Timeout; repete sem ela.
        options.Timeout = nil
        ok, response = pcall(requester, options)
    end
    if not ok then
        error(response)
    end
    local bodyOk, responseBody = pcall(_ServerFinderState.responseBody, response)
    if bodyOk then
        return responseBody
    end

    local status = type(response) == "table"
        and tonumber(response.StatusCode or response.Status)
    if status == 401 then
        error("HTTP_STATUS_401: o Roblox exige autenticação para consultar os detalhes deste servidor.")
    end
    error(responseBody)
end

_ServerFinderState.decodeJson = function(body, message)
    local ok, data = pcall(function()
        return _ServerFinderState.HttpService:JSONDecode(body)
    end)
    if not ok or type(data) ~= "table" then
        error(message or "Resposta JSON inválida.")
    end
    return data
end

_ServerFinderState.getServers = function(cursor)
    local url = "https://games.roblox.com/v1/games/"
        .. _ServerFinderState.PLACE_ID
        .. "/servers/Public?sortOrder=Desc&limit=100"

    if cursor and cursor ~= "" then
        url = url .. "&cursor=" .. _ServerFinderState.urlEncode(cursor)
    end

    local lastError = "A API não retornou uma lista válida de servidores."
    for attempt = 1, 3 do
        local ok, body = pcall(function()
            return _ServerFinderState.httpGet(url)
        end)
        if ok and body then
            local decoded, data = pcall(function()
                return _ServerFinderState.decodeJson(body)
            end)
            if decoded and type(data.data) == "table" then
                return data
            end
            lastError = decoded and "A API não retornou uma lista válida de servidores." or tostring(data)
        else
            lastError = tostring(body)
        end
        task.wait(attempt * 0.5)
    end

    return nil, lastError
end

_ServerFinderState.isAvailable = function(server)
    if type(server) ~= "table"
        or type(server.id) ~= "string"
        or server.id == game.JobId
        or type(server.playing) ~= "number"
        or type(server.maxPlayers) ~= "number"
        or server.playing >= server.maxPlayers then
        return false
    end

    if _ServerFinderState.blacklist[server.id] then
        if os.time() >= _ServerFinderState.blacklist[server.id] then
            _ServerFinderState.blacklist[server.id] = nil
        else
            return false
        end
    end
    return true
end

 _ServerFinderState.FRIEND_SERVER_CACHE_SECONDS = 30

_ServerFinderState.getFriendServerIds = function()
    if _ServerFinderState.friendServerCache and os.time() - _ServerFinderState.friendServerCacheAt < _ServerFinderState.FRIEND_SERVER_CACHE_SECONDS then
        return _ServerFinderState.friendServerCache
    end

    local friendUserIds = {}
    local knownUserIds = {}
    local cursor
    local finishedFriends = false

    for page = 1, _ServerFinderState.Config.maxFriendPages do
        if _ServerFinderState.destroyed then
            error("Busca de amigos cancelada.")
        end

        _ServerFinderState.setStatus(
            _ServerFinderState.SearchStatus,
            "Verificando os servidores dos seus amigos...",
            Color3.fromRGB(225, 210, 110)
        )

        local url = "https://friends.roblox.com/v1/users/"
            .. tostring(_ServerFinderState.Player.UserId)
            .. "/friends?limit=100"
        if cursor and cursor ~= "" then
            url = url .. "&cursor=" .. _ServerFinderState.urlEncode(cursor)
        end

        local friendsData = _ServerFinderState.decodeJson(_ServerFinderState.httpGet(url), "Resposta inválida ao consultar a lista de amigos.")
        if type(friendsData.data) ~= "table" then
            error("A API do Roblox não retornou a lista de amigos.")
        end

        for _, friend in ipairs(friendsData.data) do
            local userId = type(friend) == "table" and tonumber(friend.id or friend.userId)
            if userId and not knownUserIds[userId] then
                knownUserIds[userId] = true
                table.insert(friendUserIds, userId)
            end
        end

        cursor = friendsData.nextPageCursor
        if not cursor or cursor == "" then
            finishedFriends = true
            break
        end
    end

    if not finishedFriends then
        error("A lista de amigos excedeu o limite de páginas; nenhum servidor será escolhido sem verificar todos.")
    end

    local friendServerIds = {}
    for startIndex = 1, #friendUserIds, 100 do
        local batch = {}
        local expected = {}
        local endIndex = math.min(startIndex + 99, #friendUserIds)
        for index = startIndex, endIndex do
            local userId = friendUserIds[index]
            table.insert(batch, userId)
            expected[userId] = true
        end

        local presenceData = _ServerFinderState.decodeJson(
            _ServerFinderState.httpRequest(
                "https://presence.roblox.com/v1/presence/users",
                "POST",
                _ServerFinderState.HttpService:JSONEncode({userIds = batch})
            ),
            "Resposta inválida ao consultar os servidores dos amigos."
        )
        if type(presenceData.userPresences) ~= "table" then
            error("A API do Roblox não retornou a presença dos amigos.")
        end

        local received = {}
        for _, presence in ipairs(presenceData.userPresences) do
            local userId = type(presence) == "table" and tonumber(presence.userId)
            if userId and expected[userId] then
                received[userId] = true
                local gameId = presence.gameId
                if tonumber(presence.userPresenceType) == 2
                    and tonumber(presence.placeId) == _ServerFinderState.PLACE_ID
                    and type(gameId) == "string"
                    and gameId ~= "" then
                    friendServerIds[gameId] = true
                end
            end
        end

        for userId in pairs(expected) do
            if not received[userId] then
                error("A consulta de presença veio incompleta; nenhum servidor será escolhido por segurança.")
            end
        end
    end

    _ServerFinderState.friendServerCache = friendServerIds
    _ServerFinderState.friendServerCacheAt = os.time()
    return friendServerIds
end

_ServerFinderState.collectServers = function(maxPages)
    local result = {}
    local known = {}
    local cursor = ""
    local pageLimit = maxPages or _ServerFinderState.Config.maxPages
    local friendServersOk, friendServers = pcall(_ServerFinderState.getFriendServerIds)
    if not friendServersOk then
        return result, "Não consegui confirmar os servidores dos seus amigos. " .. tostring(friendServers)
    end
    local excludedFriendServers = 0

    for page = 1, pageLimit do
        if _ServerFinderState.destroyed then
            return {}
        end

        local data, fetchError = _ServerFinderState.getServers(cursor)
        if not data then
            return result, fetchError
        end

        for _, server in ipairs(data.data) do
            if not known[server.id] then
                known[server.id] = true
                if friendServers[server.id] then
                    excludedFriendServers = excludedFriendServers + 1
                    _ServerFinderState.blacklist[server.id] = os.time() + _ServerFinderState.Config.blacklistTime
                elseif _ServerFinderState.isAvailable(server) then
                    table.insert(result, server)
                end
            end
        end

        cursor = data.nextPageCursor or ""
        if cursor == "" then
            break
        end
        task.wait(0.2)
    end

    if #result == 0 and excludedFriendServers > 0 then
        return result, "Só encontrei servidores com amigos ou sem vagas. Tente buscar novamente em alguns segundos."
    end
    return result
end

_ServerFinderState.isIpAddress = function(value)
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

_ServerFinderState.getServerIp = function(server)
    local body = _ServerFinderState.httpRequest(
        "https://gamejoin.roblox.com/v1/join-game-instance",
        "POST",
        _ServerFinderState.HttpService:JSONEncode({
            placeId = _ServerFinderState.PLACE_ID,
            gameId = server.id,
            isTeleport = false,
            isPlayTogetherGame = false,
            gameJoinAttemptId = server.id,
        })
    )
    local data = _ServerFinderState.decodeJson(body, "A API de região retornou um JSON inválido.")
    local joinScript = data.joinScript
    if type(joinScript) ~= "table" then
        return nil
    end

    local endpoints = joinScript.UdmuxEndpoints
    if type(endpoints) == "table" then
        for _, endpoint in ipairs(endpoints) do
            local address = type(endpoint) == "table" and endpoint.Address
            if _ServerFinderState.isIpAddress(address) then
                return address
            end
        end
    end

    if _ServerFinderState.isIpAddress(joinScript.MachineAddress) then
        return joinScript.MachineAddress
    end
    return nil
end

_ServerFinderState.lookupIpRegion = function(ip)
    local urls = {
        "https://ipwho.is/" .. tostring(ip),
        "https://ip-api.com/json/" .. tostring(ip)
            .. "?fields=status,countryCode,country,city",
    }

    for _, url in ipairs(urls) do
        local ok, body = pcall(function()
            return _ServerFinderState.httpGet(url)
        end)
        if ok and body then
            local decoded, data = pcall(function()
                return _ServerFinderState.decodeJson(body)
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

-- Consulta apenas o país da conexão atual; o serviço externo verá o IP público da conexão.
_ServerFinderState.lookupMyCountry = function()
    local ok, body = pcall(function()
        return _ServerFinderState.httpGet("https://ipwho.is/")
    end)
    if not ok or type(body) ~= "string" then
        return nil
    end

    local decoded, data = pcall(function()
        return _ServerFinderState.decodeJson(body)
    end)
    if not decoded or type(data) ~= "table" or data.success == false then
        return nil
    end

    local countryCode = data.country_code or data.countryCode
    if not countryCode then
        return nil
    end
    return {
        countryCode = string.upper(tostring(countryCode)),
        country = tostring(data.country or countryCode),
    }
end

_ServerFinderState.getServerRegion = function(server)
    local cached = _ServerFinderState.regionCache[server.id]
    local cacheTime = cached and cached.error
        and _ServerFinderState.Config.regionErrorCacheTime
        or _ServerFinderState.Config.regionCacheTime
    if cached and os.time() - cached.time < cacheTime then
        if not cached.region and cached.error then
            _ServerFinderState.regionApiUnavailable = true
            _ServerFinderState.regionApiError = cached.error
        end
        return cached.region, cached.error
    end

    local ok, result = pcall(function()
        local ip = _ServerFinderState.getServerIp(server)
        if not ip then
            error("O Roblox não informou o endpoint necessário para verificar a região deste servidor.")
        end
        local region = _ServerFinderState.lookupIpRegion(ip)
        if not region then
            error("As APIs de geolocalização não retornaram uma região para este servidor.")
        end
        return region
    end)
    local region
    local regionError
    if ok then
        region = result
    else
        regionError = tostring(result)
        _ServerFinderState.regionApiUnavailable = true
        _ServerFinderState.regionApiError = regionError
        if regionError:find("HTTP_STATUS_401", 1, true) then
            _ServerFinderState.regionAuthRequired = true
        end
    end

    _ServerFinderState.regionCache[server.id] = {
        time = os.time(),
        region = region,
        error = regionError,
    }
    return region, regionError
end

_ServerFinderState.selectApproximateBrazilServer = function(servers)
    local selected
    local selectedPing = math.huge

    for _, server in ipairs(servers) do
        if _ServerFinderState.serverScore(server, "brazil") > -math.huge then
            local ping = tonumber(server.ping)
            if ping and ping < selectedPing then
                selected = server
                selectedPing = ping
            end
        end
    end

    if selected then
        selected.region = {
            countryCode = "BR",
            country = "Brasil (estimado pela latência)",
            city = "",
        }
        selected.regionApproximate = true
        selected.regionPing = selectedPing
    end
    return selected
end

_ServerFinderState.serverScore = function(server, mode)
    local playing = tonumber(server.playing) or 0
    local maximum = tonumber(server.maxPlayers) or 1
    local free = maximum - playing
    local occupancy = playing / math.max(1, maximum)
    local score = occupancy * 1000 - free

    if (mode == "full" or mode == "brazil") and (playing < 6 or free < 2) then
        return -math.huge
    end
    return score
end

_ServerFinderState.chooseServer = function(mode)
    if mode == "brazil" then
        _ServerFinderState.regionApiUnavailable = false
        _ServerFinderState.regionApiError = nil
        _ServerFinderState.regionAuthRequired = false
    end

    local servers, fetchError = _ServerFinderState.collectServers()
    if #servers == 0 then
        return nil, fetchError or "Nenhum servidor disponível foi encontrado."
    end

    if mode == "brazil" then
        local brazilServers = {}
        local checked = 0
        local regionCheckBlocked = _ServerFinderState.regionApiUnavailable

        for _, server in ipairs(servers) do
            if _ServerFinderState.serverScore(server, "brazil") > -math.huge then
                if checked >= _ServerFinderState.Config.maxRegionChecks or regionCheckBlocked then
                    break
                end
                checked = checked + 1
                _ServerFinderState.setStatus(
                    _ServerFinderState.SearchStatus,
                    "Verificando a região de servidores elegíveis... " .. checked .. "/" .. _ServerFinderState.Config.maxRegionChecks,
                    Color3.fromRGB(225, 210, 110)
                )
                local region = _ServerFinderState.getServerRegion(server)
                if _ServerFinderState.regionAuthRequired then
                    regionCheckBlocked = true
                    break
                end
                if _ServerFinderState.regionApiUnavailable then
                    regionCheckBlocked = true
                    break
                end
                if region and region.countryCode == "BR" then
                    server.region = region
                    table.insert(brazilServers, server)
                end
                task.wait(0.05)
            end
        end

        if #brazilServers > 0 then
            servers = brazilServers
        elseif _ServerFinderState.regionAuthRequired then
            local approximateServer = _ServerFinderState.selectApproximateBrazilServer(servers)
            if approximateServer then
                return approximateServer, nil
            end
            return nil, "O Roblox bloqueou a confirmação exata da região (HTTP 401) e não há servidores com latência disponível para estimativa."
        elseif regionCheckBlocked then
            local detail = _ServerFinderState.regionApiError
            local message = "Não foi possível confirmar a região brasileira. Nenhum teleporte foi feito."
            if detail and detail ~= "" then
                message = message .. "\nDetalhe: " .. detail
            else
                message = message .. " Tente novamente mais tarde."
            end
            return nil, message
        else
            return nil, "Não encontrei servidor BR elegível entre os servidores verificados."
        end
    end

    if mode == "random" then
        return servers[math.random(1, #servers)], nil
    end

    local selected
    local bestScore = -math.huge

    for _, server in ipairs(servers) do
        local score = _ServerFinderState.serverScore(server, mode)

        if score > bestScore then
            selected = server
            bestScore = score
        end
    end

    if selected then
        return selected, nil
    end
    if mode == "full" then
        return nil, "Não encontrei um servidor com ocupação alta e vagas disponíveis. Tente o servidor aleatório."
    end
    if mode == "brazil" then
        return nil, "Nao encontrei servidor BR com pelo menos 6 jogadores e 2 vagas."
    end
    return servers[1], nil
end

-- Localização da GUI.
local parent
if type(gethui) == "function" then
    local ok, result = pcall(gethui)
    if ok then
        parent = result
    end
end
parent = parent or _ServerFinderState.CoreGui

 _ServerFinderState.old = parent:FindFirstChild("ServerFinderResponsive")
if _ServerFinderState.old then
    _ServerFinderState.old:Destroy()
end

 _ServerFinderState.Gui = _ServerFinderState.create("ScreenGui", {
    Name = "ServerFinderResponsive",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, nil)

 _ServerFinderState.guiAttached = pcall(function()
    _ServerFinderState.Gui.Parent = parent
end)
if not _ServerFinderState.guiAttached or not _ServerFinderState.Gui.Parent then
    _ServerFinderState.Gui.Parent = _ServerFinderState.Player:WaitForChild("PlayerGui")
end

-- Destruir/reexecutar a interface encerra conexões globais e tarefas desta instância.
_ServerFinderState.Gui.Destroying:Connect(function()
    _ServerFinderState.destroyed = true
    for _, connection in pairs({_ServerFinderState.loadingConnection, _ServerFinderState.inputChangedConnection, _ServerFinderState.teleportInitFailedConnection}) do
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
    end
end)

 _ServerFinderState.Window = _ServerFinderState.create("Frame", {
    Size = UDim2.fromOffset(_ServerFinderState.BASE_WIDTH, _ServerFinderState.BASE_HEIGHT),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(15, 18, 27),
    BorderSizePixel = 0,
}, _ServerFinderState.Gui)
_ServerFinderState.corner(_ServerFinderState.Window, 14)
_ServerFinderState.stroke(_ServerFinderState.Window, Color3.fromRGB(70, 82, 110), 1, 0.45)
_ServerFinderState.create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(21, 27, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 15, 23)),
    }),
    Rotation = 90,
}, _ServerFinderState.Window)

 _ServerFinderState.WindowScale = _ServerFinderState.create("UIScale", {
    Scale = 1,
}, _ServerFinderState.Window)

_ServerFinderState.getViewport = function()
    local camera = workspace.CurrentCamera
    if camera then
        return camera.ViewportSize
    end
    return Vector2.new(_ServerFinderState.BASE_WIDTH + 30, _ServerFinderState.BASE_HEIGHT + 30)
end

_ServerFinderState.applyResponsiveScale = function()
    if _ServerFinderState.destroyed or not _ServerFinderState.Window.Parent then
        return
    end

    local viewport = _ServerFinderState.getViewport()
    local baseWidth = math.max(1, _ServerFinderState.Window.Size.X.Offset)
    local baseHeight = math.max(1, _ServerFinderState.Window.Size.Y.Offset)
    local widthScale = math.max(1, viewport.X - 24) / baseWidth
    local heightScale = math.max(1, viewport.Y - 24) / baseHeight
    local fitScale = math.max(0.1, math.min(widthScale, heightScale))
    local maximumAllowed = math.min(_ServerFinderState.MAX_USER_SCALE, fitScale)
    _ServerFinderState.currentScale = math.min(math.max(0.1, _ServerFinderState.manualScale), maximumAllowed)
    _ServerFinderState.WindowScale.Scale = _ServerFinderState.currentScale
end

_ServerFinderState.clampWindowToViewport = function()
    if _ServerFinderState.destroyed or not _ServerFinderState.Window.Parent then
        return
    end

    local viewport = _ServerFinderState.getViewport()
    local absoluteSize = _ServerFinderState.Window.AbsoluteSize
    local windowWidth = math.max(1, absoluteSize.X)
    local windowHeight = math.max(1, absoluteSize.Y)
    local margin = 6
    local position = _ServerFinderState.Window.Position

    local positionX = viewport.X * position.X.Scale + position.X.Offset
    local positionY = viewport.Y * position.Y.Scale + position.Y.Offset
    local minimumX = windowWidth / 2 + margin
    local maximumX = viewport.X - windowWidth / 2 - margin
    local minimumY = windowHeight / 2 + margin
    local maximumY = viewport.Y - windowHeight / 2 - margin

    local clampedX = minimumX <= maximumX
        and _ServerFinderState.clamp(positionX, minimumX, maximumX)
        or viewport.X / 2
    local clampedY = minimumY <= maximumY
        and _ServerFinderState.clamp(positionY, minimumY, maximumY)
        or viewport.Y / 2

    _ServerFinderState.Window.Position = UDim2.new(
        position.X.Scale,
        clampedX - viewport.X * position.X.Scale,
        position.Y.Scale,
        clampedY - viewport.Y * position.Y.Scale
    )
end

 _ServerFinderState.Header = _ServerFinderState.create("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Color3.fromRGB(25, 30, 44),
    BorderSizePixel = 0,
}, _ServerFinderState.Window)
_ServerFinderState.corner(_ServerFinderState.Header, 14)
_ServerFinderState.create("Frame", {
    Size = UDim2.new(1, 0, 0, 15),
    Position = UDim2.new(0, 0, 1, -15),
    BackgroundColor3 = Color3.fromRGB(25, 30, 44),
    BorderSizePixel = 0,
}, _ServerFinderState.Header)
_ServerFinderState.create("Frame", {
    Size = UDim2.new(1, -24, 0, 2),
    Position = UDim2.fromOffset(12, 46),
    BackgroundColor3 = Color3.fromRGB(75, 218, 225),
    BorderSizePixel = 0,
}, _ServerFinderState.Header)

 _ServerFinderState.OwnerAvatar = _ServerFinderState.create("ImageLabel", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.fromOffset(12, 7),
    BackgroundColor3 = Color3.fromRGB(48, 52, 68),
    BorderSizePixel = 0,
    Image = "",
}, _ServerFinderState.Header)
_ServerFinderState.corner(_ServerFinderState.OwnerAvatar, 17)

 _ServerFinderState.HubTitle = _ServerFinderState.create("TextLabel", {
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
}, _ServerFinderState.Header)

 _ServerFinderState.TitleShine = _ServerFinderState.create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 82, 18)),
        ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 202, 83)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 248, 190)),
        ColorSequenceKeypoint.new(0.72, Color3.fromRGB(255, 202, 83)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 82, 18)),
    }),
    Offset = Vector2.new(-1, 0),
    Rotation = 0,
}, _ServerFinderState.HubTitle)

-- Reflexo animado para o dourado parecer metálico, sem perder legibilidade.
task.spawn(function()
    while not _ServerFinderState.destroyed and _ServerFinderState.TitleShine.Parent do
        for offset = -1, 1, 0.035 do
            if _ServerFinderState.destroyed or not _ServerFinderState.TitleShine.Parent then
                return
            end
            _ServerFinderState.TitleShine.Offset = Vector2.new(offset, 0)
            task.wait(0.035)
        end
        task.wait(0.65)
    end
end)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -235, 0, 17),
    Position = UDim2.fromOffset(57, 25),
    BackgroundTransparency = 1,
    Text = "by mateus_15600",
    TextColor3 = Color3.fromRGB(145, 220, 180),
    TextSize = 11,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.Header)

 _ServerFinderState.Minimize = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -72, 0, 9),
    BackgroundColor3 = Color3.fromRGB(75, 80, 100),
    Text = "—",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 18,
    Font = Enum.Font.SourceSansBold,
}, _ServerFinderState.Header)
_ServerFinderState.corner(_ServerFinderState.Minimize, 7)

 _ServerFinderState.Close = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -38, 0, 9),
    BackgroundColor3 = Color3.fromRGB(190, 55, 65),
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
}, _ServerFinderState.Header)
_ServerFinderState.corner(_ServerFinderState.Close, 7)

 _ServerFinderState.Sidebar = _ServerFinderState.create("Frame", {
    Size = UDim2.new(0, 132, 1, -60),
    Position = UDim2.fromOffset(10, 56),
    BackgroundColor3 = Color3.fromRGB(20, 24, 35),
    BorderSizePixel = 0,
}, _ServerFinderState.Window)
_ServerFinderState.corner(_ServerFinderState.Sidebar, 10)
_ServerFinderState.stroke(_ServerFinderState.Sidebar, Color3.fromRGB(78, 93, 122), 1, 0.68)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -16, 0, 15),
    Position = UDim2.fromOffset(8, 4),
    BackgroundTransparency = 1,
    Text = "NAVEGAÇÃO",
    TextColor3 = Color3.fromRGB(115, 190, 210),
    TextSize = 9,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.Sidebar)

 _ServerFinderState.Main = _ServerFinderState.create("Frame", {
    Size = UDim2.new(1, -162, 1, -60),
    Position = UDim2.fromOffset(152, 56),
    BackgroundTransparency = 1,
}, _ServerFinderState.Window)

 _ServerFinderState.ResizeGrip = _ServerFinderState.create("TextButton", {
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
}, _ServerFinderState.Window)
_ServerFinderState.corner(_ServerFinderState.ResizeGrip, 6)
_ServerFinderState.stroke(_ServerFinderState.ResizeGrip, Color3.fromRGB(90, 210, 230), 1, 0.25)

 _ServerFinderState.Pages = {}

_ServerFinderState.makePage = function(name)
    local page = _ServerFinderState.create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
    }, _ServerFinderState.Main)
    _ServerFinderState.Pages[name] = page
    return page
end

_ServerFinderState.makeTab = function(name, text, order, color)
    local button = _ServerFinderState.create("TextButton", {
        Size = UDim2.new(1, -16, 0, 42),
        Position = UDim2.new(0, 8, 0, 26 + (order - 1) * 50),
        BackgroundColor3 = Color3.fromRGB(40, 43, 57),
        Text = text,
        TextColor3 = Color3.fromRGB(215, 218, 230),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSansBold,
        AutoButtonColor = false,
    }, _ServerFinderState.Sidebar)
    button:SetAttribute("ActiveColor", color or Color3.fromRGB(0, 135, 190))
    _ServerFinderState.corner(button, 8)
    _ServerFinderState.create("UIPadding", {
        PaddingLeft = UDim.new(0, 15),
    }, button)
    _ServerFinderState.TabStrokes[name] = _ServerFinderState.stroke(button, Color3.fromRGB(255, 255, 255), 1, 0.9)
    local indicator = _ServerFinderState.create("Frame", {
        Size = UDim2.fromOffset(4, 26),
        Position = UDim2.fromOffset(5, 8),
        BackgroundColor3 = color or Color3.fromRGB(0, 135, 190),
        BorderSizePixel = 0,
        Visible = false,
        Active = false,
    }, button)
    _ServerFinderState.corner(indicator, 2)
    _ServerFinderState.TabIndicators[name] = indicator
    button.MouseEnter:Connect(function()
        if not button:GetAttribute("IsActive") then
            button.BackgroundColor3 = _ServerFinderState.Themes[_ServerFinderState.currentThemeName].colors.tabHover
            if _ServerFinderState.TabStrokes[name] then
                _ServerFinderState.TabStrokes[name].Transparency = 0.55
            end
        end
    end)
    button.MouseLeave:Connect(function()
        if not button:GetAttribute("IsActive") then
            button.BackgroundColor3 = _ServerFinderState.Themes[_ServerFinderState.currentThemeName].colors.tab
            if _ServerFinderState.TabStrokes[name] then
                _ServerFinderState.TabStrokes[name].Transparency = 0.9
            end
        end
    end)
    _ServerFinderState.TabButtons[name] = button
    return button
end

 _ServerFinderState.SearchPage = _ServerFinderState.makePage("Buscar")
 _ServerFinderState.ChatPage = _ServerFinderState.makePage("Chat")
 _ServerFinderState.ScriptsPage = _ServerFinderState.makePage("Scripts")
 _ServerFinderState.ConfigsPage = _ServerFinderState.makePage("Configs")
 _ServerFinderState.InfoPage = _ServerFinderState.makePage("Info")

 _ServerFinderState.SearchTab = _ServerFinderState.makeTab("Buscar", "⌂  BUSCAR", 1)
 _ServerFinderState.ChatTab = _ServerFinderState.makeTab("Chat", "☵  CHAT BOT", 2)
 _ServerFinderState.ScriptsTab = _ServerFinderState.makeTab("Scripts", "▤  SCRIPTS", 3)
 _ServerFinderState.ConfigsTab = _ServerFinderState.makeTab("Configs", "⚙  CONFIGS", 4, Color3.fromRGB(112, 78, 178))

_ServerFinderState.InfoTab = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(52, 30),
    Position = UDim2.new(1, -132, 0, 9),
    BackgroundColor3 = Color3.fromRGB(42, 57, 75),
    Text = "INFO",
    TextColor3 = Color3.fromRGB(185, 240, 240),
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
    AutoButtonColor = false,
}, _ServerFinderState.Header)
_ServerFinderState.corner(_ServerFinderState.InfoTab, 7)
_ServerFinderState.stroke(_ServerFinderState.InfoTab, Color3.fromRGB(95, 220, 225), 1, 0.35)
_ServerFinderState.InfoTab.MouseEnter:Connect(function()
    _ServerFinderState.InfoTab.BackgroundColor3 = _ServerFinderState.Themes[_ServerFinderState.currentThemeName].colors.tabHover
end)
_ServerFinderState.InfoTab.MouseLeave:Connect(function()
    _ServerFinderState.InfoTab.BackgroundColor3 = _ServerFinderState.Themes[_ServerFinderState.currentThemeName].colors.infoButton
end)

_ServerFinderState.showPage = function(name)
    local colors = _ServerFinderState.Themes[_ServerFinderState.currentThemeName].colors
    for pageName, page in pairs(_ServerFinderState.Pages) do
        page.Visible = pageName == name
    end
    for tabName, button in pairs(_ServerFinderState.TabButtons) do
        local activeColor = button:GetAttribute("ActiveColor") or colors.primary
        local isActive = tabName == name
        button:SetAttribute("IsActive", isActive)
        button.BackgroundColor3 = isActive and activeColor or colors.tab
        if _ServerFinderState.TabIndicators[tabName] then
            _ServerFinderState.TabIndicators[tabName].Visible = isActive
            _ServerFinderState.TabIndicators[tabName].BackgroundColor3 = activeColor
        end
        if _ServerFinderState.TabStrokes[tabName] then
            _ServerFinderState.TabStrokes[tabName].Color = isActive and activeColor or colors.border
            _ServerFinderState.TabStrokes[tabName].Transparency = isActive and 0.25 or 0.9
        end
    end
    _ServerFinderState.InfoTab:SetAttribute("IsActive", name == "Info")
    _ServerFinderState.InfoTab.BackgroundColor3 = name == "Info" and colors.primary or colors.infoButton
    _ServerFinderState.InfoTab.TextColor3 = name == "Info" and colors.textBright or colors.textAccent
end

_ServerFinderState.SearchTab.MouseButton1Click:Connect(function()
    _ServerFinderState.showPage("Buscar")
end)
_ServerFinderState.ChatTab.MouseButton1Click:Connect(function()
    _ServerFinderState.showPage("Chat")
end)
_ServerFinderState.ScriptsTab.MouseButton1Click:Connect(function()
    _ServerFinderState.showPage("Scripts")
end)
_ServerFinderState.ConfigsTab.MouseButton1Click:Connect(function()
    _ServerFinderState.showPage("Configs")
end)
_ServerFinderState.InfoTab.MouseButton1Click:Connect(function()
    _ServerFinderState.showPage("Info")
end)

-- Página Buscar.
 _ServerFinderState.SearchCard = _ServerFinderState.create("Frame", {
    Size = UDim2.new(1, 0, 0, 238),
    Position = UDim2.fromOffset(0, 0),
    BackgroundColor3 = Color3.fromRGB(23, 28, 41),
    BorderSizePixel = 0,
}, _ServerFinderState.SearchPage)
_ServerFinderState.corner(_ServerFinderState.SearchCard, 11)
_ServerFinderState.stroke(_ServerFinderState.SearchCard, Color3.fromRGB(70, 93, 125), 1, 0.72)

_ServerFinderState.create("Frame", {
    Size = UDim2.fromOffset(4, 72),
    Position = UDim2.fromOffset(0, 18),
    BackgroundColor3 = Color3.fromRGB(75, 218, 225),
    BorderSizePixel = 0,
}, _ServerFinderState.SearchCard)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 34),
    Position = UDim2.fromOffset(16, 15),
    BackgroundTransparency = 1,
    Text = "Troca inteligente de servidor",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 19,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.SearchPage)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 36),
    Position = UDim2.fromOffset(16, 49),
    BackgroundTransparency = 1,
    Text = "BR confirma o país do servidor. As buscas ignoram servidores onde seus amigos estão.",
    TextColor3 = Color3.fromRGB(165, 170, 190),
    TextSize = 12,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.SearchPage)

_ServerFinderState.SearchStatus = _ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 48),
    Position = UDim2.new(0, 0, 1, -58),
    BackgroundColor3 = Color3.fromRGB(28, 31, 42),
    Text = "Pronto para buscar.",
    TextColor3 = Color3.fromRGB(225, 210, 110),
    TextSize = 12,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
}, _ServerFinderState.SearchPage)
_ServerFinderState.corner(_ServerFinderState.SearchStatus, 8)
_ServerFinderState.stroke(_ServerFinderState.SearchStatus, Color3.fromRGB(98, 105, 135), 1, 0.72)

_ServerFinderState.searchButton = function(text, position, color)
    local button = _ServerFinderState.create("TextButton", {
        Size = UDim2.fromOffset(205, 46),
        Position = position,
        BackgroundColor3 = color,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.SourceSansBold,
    }, _ServerFinderState.SearchPage)
    _ServerFinderState.corner(button, 9)
    _ServerFinderState.styleButton(button, color, Color3.fromRGB(
        math.min(color.R * 1.16 + 0.03, 1),
        math.min(color.G * 1.16 + 0.03, 1),
        math.min(color.B * 1.16 + 0.03, 1)
    ))
    return button
end

 _ServerFinderState.BRButton = _ServerFinderState.searchButton("Servidor BR", UDim2.fromOffset(0, 88), Color3.fromRGB(0, 145, 75))
 _ServerFinderState.ENButton = _ServerFinderState.searchButton("English Server", UDim2.fromOffset(220, 88), Color3.fromRGB(65, 70, 88))
_ServerFinderState.disableButton(_ServerFinderState.ENButton, Color3.fromRGB(65, 70, 88))
_ServerFinderState.create("TextLabel", {
    Size = UDim2.fromOffset(205, 18),
    Position = UDim2.fromOffset(220, 70),
    BackgroundTransparency = 1,
    Text = "DESATIVADO",
    TextColor3 = Color3.fromRGB(245, 190, 105),
    TextSize = 10,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
}, _ServerFinderState.SearchPage)
 _ServerFinderState.VerifiedButton = _ServerFinderState.searchButton(
    "Procurar usuário verificado",
    UDim2.fromOffset(0, 148),
    Color3.fromRGB(120, 55, 190)
)
 _ServerFinderState.RandomButton = _ServerFinderState.searchButton("Servidor aleatório", UDim2.fromOffset(220, 148), Color3.fromRGB(205, 115, 0))

 _ServerFinderState.VerifiedPopup = _ServerFinderState.create("Frame", {
    Size = UDim2.fromOffset(390, 185),
    Position = UDim2.new(0.5, -195, 0.5, -92),
    BackgroundColor3 = Color3.fromRGB(29, 32, 44),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 20,
}, _ServerFinderState.Window)
_ServerFinderState.corner(_ServerFinderState.VerifiedPopup, 12)
_ServerFinderState.stroke(_ServerFinderState.VerifiedPopup, Color3.fromRGB(100, 115, 145), 1, 0.25)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -55, 0, 34),
    Position = UDim2.fromOffset(15, 12),
    BackgroundTransparency = 1,
    Text = "Procurar usuário com selo azul",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 16,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 21,
}, _ServerFinderState.VerifiedPopup)

 _ServerFinderState.VerifiedClose = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -38, 0, 10),
    BackgroundColor3 = Color3.fromRGB(190, 55, 65),
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 18,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 21,
}, _ServerFinderState.VerifiedPopup)
_ServerFinderState.corner(_ServerFinderState.VerifiedClose, 7)

 _ServerFinderState.VerifiedInput = _ServerFinderState.create("TextBox", {
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
}, _ServerFinderState.VerifiedPopup)
_ServerFinderState.corner(_ServerFinderState.VerifiedInput, 8)

 _ServerFinderState.VerifiedSearch = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(100, 38),
    Position = UDim2.new(1, -115, 0, 62),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    Text = "Verificar",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 13,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 21,
}, _ServerFinderState.VerifiedPopup)
_ServerFinderState.corner(_ServerFinderState.VerifiedSearch, 8)

 _ServerFinderState.VerifiedStatus = _ServerFinderState.create("TextLabel", {
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
}, _ServerFinderState.VerifiedPopup)

 _ServerFinderState.TeleportConfirmPopup = _ServerFinderState.create("Frame", {
    Size = UDim2.fromOffset(410, 210),
    Position = UDim2.new(0.5, -205, 0.5, -105),
    BackgroundColor3 = Color3.fromRGB(29, 32, 44),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 60,
}, _ServerFinderState.Window)
_ServerFinderState.corner(_ServerFinderState.TeleportConfirmPopup, 12)
_ServerFinderState.stroke(_ServerFinderState.TeleportConfirmPopup, Color3.fromRGB(92, 190, 220), 1, 0.2)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -30, 0, 34),
    Position = UDim2.fromOffset(15, 14),
    BackgroundTransparency = 1,
    Text = "Servidor encontrado",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 18,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 61,
}, _ServerFinderState.TeleportConfirmPopup)

 _ServerFinderState.TeleportConfirmMessage = _ServerFinderState.create("TextLabel", {
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
}, _ServerFinderState.TeleportConfirmPopup)

 _ServerFinderState.TeleportCancelButton = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(150, 38),
    Position = UDim2.new(0, 15, 1, -53),
    BackgroundColor3 = Color3.fromRGB(76, 82, 103),
    Text = "CANCELAR",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 61,
}, _ServerFinderState.TeleportConfirmPopup)
_ServerFinderState.corner(_ServerFinderState.TeleportCancelButton, 8)
_ServerFinderState.styleButton(_ServerFinderState.TeleportCancelButton, Color3.fromRGB(76, 82, 103), Color3.fromRGB(94, 102, 128))

 _ServerFinderState.TeleportContinueButton = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(210, 38),
    Position = UDim2.new(1, -225, 1, -53),
    BackgroundColor3 = Color3.fromRGB(0, 145, 185),
    Text = "CONTINUAR",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 61,
}, _ServerFinderState.TeleportConfirmPopup)
_ServerFinderState.corner(_ServerFinderState.TeleportContinueButton, 8)
_ServerFinderState.styleButton(_ServerFinderState.TeleportContinueButton, Color3.fromRGB(0, 145, 185), Color3.fromRGB(25, 175, 215))

-- Aviso de inicialização e consentimento antes de consultar a localização pelo IP.
 _ServerFinderState.StartupOverlay = _ServerFinderState.create("Frame", {
    Size = UDim2.fromScale(1, 1),
    Position = UDim2.fromScale(0, 0),
    BackgroundColor3 = Color3.fromRGB(5, 7, 12),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Active = true,
    Visible = false,
    ZIndex = 90,
}, _ServerFinderState.Window)

 _ServerFinderState.StartupPopup = _ServerFinderState.create("Frame", {
    Size = UDim2.fromOffset(430, 246),
    Position = UDim2.new(0.5, -215, 0.5, -123),
    BackgroundColor3 = Color3.fromRGB(29, 32, 44),
    BorderSizePixel = 0,
    ZIndex = 91,
}, _ServerFinderState.StartupOverlay)
_ServerFinderState.corner(_ServerFinderState.StartupPopup, 12)
_ServerFinderState.stroke(_ServerFinderState.StartupPopup, Color3.fromRGB(92, 190, 220), 1, 0.2)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 30),
    Position = UDim2.fromOffset(14, 12),
    BackgroundTransparency = 1,
    Text = "Server Finder — atualizações",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 17,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 92,
}, _ServerFinderState.StartupPopup)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 82),
    Position = UDim2.fromOffset(14, 47),
    BackgroundTransparency = 1,
    Text = "Novidades desta atualização:\n• Aviso exibido ao iniciar.\n• Identificação aproximada do país pela conexão atual.\n• A busca do país começa somente depois do OK.",
    TextColor3 = Color3.fromRGB(215, 220, 235),
    TextSize = 13,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 92,
}, _ServerFinderState.StartupPopup)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 56),
    Position = UDim2.fromOffset(14, 133),
    BackgroundTransparency = 1,
    Text = "Privacidade: ao tocar OK, ipwho.is receberá seu IP público para estimar o país. O script não exibe nem guarda o endereço IP.",
    TextColor3 = Color3.fromRGB(170, 180, 200),
    TextSize = 12,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 92,
}, _ServerFinderState.StartupPopup)

 _ServerFinderState.StartupOkButton = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(120, 36),
    Position = UDim2.new(1, -134, 1, -48),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    Text = "OK",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 92,
}, _ServerFinderState.StartupPopup)
_ServerFinderState.corner(_ServerFinderState.StartupOkButton, 8)
_ServerFinderState.styleButton(_ServerFinderState.StartupOkButton, Color3.fromRGB(0, 135, 190), Color3.fromRGB(25, 165, 215))

 _ServerFinderState.StartupStatus = _ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -40, 0, 36),
    Position = UDim2.new(0, 20, 1, -48),
    BackgroundColor3 = Color3.fromRGB(27, 34, 48),
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Visible = false,
    Text = "",
    TextColor3 = Color3.fromRGB(220, 230, 245),
    TextSize = 13,
    TextWrapped = true,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 100,
}, _ServerFinderState.Window)
_ServerFinderState.corner(_ServerFinderState.StartupStatus, 8)
_ServerFinderState.stroke(_ServerFinderState.StartupStatus, Color3.fromRGB(92, 190, 220), 1, 0.35)

_ServerFinderState.teleportDecision = nil
_ServerFinderState.askTeleportConfirmation = function(server, context, matchmaking)
    local playing = tonumber(server and server.playing)
    local maximum = tonumber(server and server.maxPlayers)
    local occupancy = playing and maximum and (tostring(playing) .. "/" .. tostring(maximum)) or "disponível"
    local target = context or "um novo servidor"

    if matchmaking then
            _ServerFinderState.TeleportConfirmMessage.Text = "O Roblox escolhe por localizacao e latencia; nao garante servidor brasileiro.\n"
            .. "Você quer sair deste servidor e continuar?"
    else
        local approximationNotice = ""
        if server and server.regionApproximate then
            approximationNotice = "\nA região é uma estimativa pela latência; o Roblox bloqueou a confirmação exata."
        end
        _ServerFinderState.TeleportConfirmMessage.Text = "Encontrei " .. target .. " (" .. occupancy .. ")."
            .. approximationNotice
            .. "\nVocê quer sair deste servidor e continuar para o destino encontrado?"
    end
    _ServerFinderState.teleportDecision = nil
    _ServerFinderState.TeleportConfirmPopup.Visible = true

    while _ServerFinderState.teleportDecision == nil and not _ServerFinderState.destroyed do
        task.wait()
    end

    local accepted = _ServerFinderState.teleportDecision == true and not _ServerFinderState.destroyed
    _ServerFinderState.teleportDecision = nil
    if _ServerFinderState.TeleportConfirmPopup.Parent then
        _ServerFinderState.TeleportConfirmPopup.Visible = false
    end
    return accepted
end

_ServerFinderState.TeleportCancelButton.MouseButton1Click:Connect(function()
    _ServerFinderState.teleportDecision = false
end)
_ServerFinderState.TeleportContinueButton.MouseButton1Click:Connect(function()
    _ServerFinderState.teleportDecision = true
end)

 _ServerFinderState.startupCountryCheckStarted = false
_ServerFinderState.StartupOkButton.MouseButton1Click:Connect(function()
    if _ServerFinderState.startupCountryCheckStarted then
        return
    end
    _ServerFinderState.startupCountryCheckStarted = true
    _ServerFinderState.StartupOverlay.Visible = false
    _ServerFinderState.StartupStatus.Visible = true
    _ServerFinderState.StartupStatus.Text = "Verificando o país pela conexão…"
    _ServerFinderState.StartupStatus.TextColor3 = Color3.fromRGB(220, 230, 245)

    task.spawn(function()
        local country = _ServerFinderState.lookupMyCountry()
        if _ServerFinderState.destroyed or not _ServerFinderState.StartupStatus.Parent then
            return
        end

        local message
        if country and country.countryCode == "BR" then
            message = "País detectado: Brasil (BR). A localização pelo IP é aproximada."
            _ServerFinderState.StartupStatus.TextColor3 = Color3.fromRGB(130, 225, 165)
        elseif country then
            message = "País detectado: " .. country.country .. " (" .. country.countryCode .. ")."
            _ServerFinderState.StartupStatus.TextColor3 = Color3.fromRGB(235, 205, 125)
        else
            message = "Não foi possível verificar o país pela conexão atual."
            _ServerFinderState.StartupStatus.TextColor3 = Color3.fromRGB(240, 145, 145)
        end
        _ServerFinderState.StartupStatus.Text = message
        task.delay(6, function()
            if not _ServerFinderState.destroyed and _ServerFinderState.StartupStatus.Parent and _ServerFinderState.StartupStatus.Text == message then
                _ServerFinderState.StartupStatus.Visible = false
            end
        end)
    end)
end)

 _ServerFinderState.startupPopupShown = false
_ServerFinderState.showStartupPopup = function()
    if _ServerFinderState.startupPopupShown
        or _ServerFinderState.destroyed
        or not _ServerFinderState.followUnlocked
        or not _ServerFinderState.StartupOverlay.Parent then
        return
    end
    _ServerFinderState.startupPopupShown = true
    _ServerFinderState.StartupOverlay.Visible = true
end

_ServerFinderState.VerifiedButton.MouseButton1Click:Connect(function()
    _ServerFinderState.VerifiedPopup.Visible = true
    _ServerFinderState.VerifiedInput:CaptureFocus()
end)
_ServerFinderState.VerifiedClose.MouseButton1Click:Connect(function()
    _ServerFinderState.VerifiedPopup.Visible = false
end)

-- Página Scripts.
 _ServerFinderState.ScriptsCard = _ServerFinderState.create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.fromOffset(0, 0),
    BackgroundColor3 = Color3.fromRGB(23, 28, 41),
    BorderSizePixel = 0,
}, _ServerFinderState.ScriptsPage)
_ServerFinderState.corner(_ServerFinderState.ScriptsCard, 11)
_ServerFinderState.stroke(_ServerFinderState.ScriptsCard, Color3.fromRGB(70, 93, 125), 1, 0.72)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 40),
    Position = UDim2.new(0, 14, 0.5, -20),
    BackgroundTransparency = 1,
    Text = "Scripts personalizados em breve",
    TextColor3 = Color3.fromRGB(245, 248, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
}, _ServerFinderState.ScriptsCard)

-- Página Configs.
 _ServerFinderState.ConfigsCard = _ServerFinderState.create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.fromOffset(0, 0),
    BackgroundColor3 = Color3.fromRGB(23, 28, 41),
    BorderSizePixel = 0,
}, _ServerFinderState.ConfigsPage)
_ServerFinderState.corner(_ServerFinderState.ConfigsCard, 11)
_ServerFinderState.stroke(_ServerFinderState.ConfigsCard, Color3.fromRGB(70, 93, 125), 1, 0.72)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 30),
    Position = UDim2.fromOffset(14, 12),
    BackgroundTransparency = 1,
    Text = "Configurações do script",
    TextColor3 = Color3.fromRGB(245, 248, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.ConfigsCard)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 28),
    Position = UDim2.fromOffset(14, 43),
    BackgroundTransparency = 1,
    Text = "Escolha entre 10 temas. Role a lista para ver todas as opções.",
    TextColor3 = Color3.fromRGB(165, 170, 190),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.ConfigsCard)

_ServerFinderState.ThemeStatus = _ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 24),
    Position = UDim2.fromOffset(14, 72),
    BackgroundTransparency = 1,
    Text = "Tema atual: " .. _ServerFinderState.Themes[_ServerFinderState.Config.theme].label,
    TextColor3 = Color3.fromRGB(145, 240, 180),
    TextSize = 12,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.ConfigsCard)

 _ServerFinderState.ThemeList = _ServerFinderState.create("ScrollingFrame", {
    Size = UDim2.new(1, -28, 1, -179),
    Position = UDim2.fromOffset(14, 100),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.fromOffset(0, 0),
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(75, 218, 225),
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, _ServerFinderState.ConfigsCard)
 _ServerFinderState.ThemeGrid = _ServerFinderState.create("UIGridLayout", {
    CellSize = UDim2.new(0.5, -6, 0, 62),
    CellPadding = UDim2.fromOffset(8, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, _ServerFinderState.ThemeList)
_ServerFinderState.create("UIPadding", {
    PaddingLeft = UDim.new(0, 2),
    PaddingRight = UDim.new(0, 2),
    PaddingTop = UDim.new(0, 2),
}, _ServerFinderState.ThemeList)
_ServerFinderState.ThemeGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    _ServerFinderState.ThemeList.CanvasSize = UDim2.fromOffset(0, _ServerFinderState.ThemeGrid.AbsoluteContentSize.Y + 8)
end)

_ServerFinderState.themeOption = function(name, order)
    local theme = _ServerFinderState.Themes[name]
    local button = _ServerFinderState.create("TextButton", {
        Size = UDim2.new(0.5, -6, 0, 62),
        LayoutOrder = order,
        BackgroundColor3 = Color3.fromRGB(40, 43, 57),
        Text = theme.label .. "\n" .. theme.description,
        TextColor3 = Color3.fromRGB(245, 248, 255),
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Font = Enum.Font.SourceSansBold,
        AutoButtonColor = false,
    }, _ServerFinderState.ThemeList)
    _ServerFinderState.corner(button, 9)
    _ServerFinderState.stroke(button, Color3.fromRGB(70, 93, 125), 1, 0.45)
    _ServerFinderState.create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 24),
    }, button)

    local preview = _ServerFinderState.create("Frame", {
        Size = UDim2.fromOffset(10, 40),
        Position = UDim2.new(1, -20, 0.5, -20),
        BackgroundColor3 = theme.preview,
        BorderSizePixel = 0,
    }, button)
    _ServerFinderState.corner(preview, 5)

    table.insert(_ServerFinderState.ThemeButtons, {
        name = name,
        label = theme.label,
        button = button,
        preview = preview,
    })

    button.MouseEnter:Connect(function()
        if name ~= _ServerFinderState.currentThemeName then
            button.BackgroundColor3 = _ServerFinderState.Themes[_ServerFinderState.currentThemeName].colors.tabHover
        end
    end)
    button.MouseLeave:Connect(function()
        if name ~= _ServerFinderState.currentThemeName then
            button.BackgroundColor3 = _ServerFinderState.Themes[_ServerFinderState.currentThemeName].colors.tab
        end
    end)
    button.MouseButton1Click:Connect(function()
        _ServerFinderState.applyTheme(name)
        local saved, errorMessage = _ServerFinderState.saveTheme()
        if saved then
            _ServerFinderState.ThemeStatus.Text = "✓ " .. theme.label .. " selecionado e salvo."
            _ServerFinderState.ThemeStatus.TextColor3 = _ServerFinderState.Themes[name].colors.textSuccess
        else
            _ServerFinderState.ThemeStatus.Text = theme.label .. " selecionado. " .. tostring(errorMessage)
            _ServerFinderState.ThemeStatus.TextColor3 = _ServerFinderState.Themes[name].colors.textWarning
        end
    end)
end

_ServerFinderState.themeOption("Midnight", 1)
_ServerFinderState.themeOption("Ocean", 2)
_ServerFinderState.themeOption("Emerald", 3)
_ServerFinderState.themeOption("Sunset", 4)
_ServerFinderState.themeOption("Troll", 5)
_ServerFinderState.themeOption("Doido", 6)
_ServerFinderState.themeOption("Colorido", 7)
_ServerFinderState.themeOption("Louco", 8)
_ServerFinderState.themeOption("FakeErrors", 9)
_ServerFinderState.themeOption("WindowsClassic", 10)

 _ServerFinderState.ConfigSaveButton = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(188, 38),
    Position = UDim2.new(0, 14, 1, -72),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    Text = "SALVAR CONFIGURAÇÃO",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
}, _ServerFinderState.ConfigsCard)
_ServerFinderState.corner(_ServerFinderState.ConfigSaveButton, 8)
_ServerFinderState.styleButton(_ServerFinderState.ConfigSaveButton, Color3.fromRGB(0, 135, 190), Color3.fromRGB(25, 165, 215))
_ServerFinderState.ConfigSaveButton.MouseButton1Click:Connect(function()
    local saved, errorMessage = _ServerFinderState.saveTheme()
    if saved then
        _ServerFinderState.ThemeStatus.Text = "✓ Tema " .. _ServerFinderState.Themes[_ServerFinderState.Config.theme].label .. " salvo neste executor."
        _ServerFinderState.ThemeStatus.TextColor3 = _ServerFinderState.Themes[_ServerFinderState.Config.theme].colors.textSuccess
    else
        _ServerFinderState.ThemeStatus.Text = tostring(errorMessage)
        _ServerFinderState.ThemeStatus.TextColor3 = _ServerFinderState.Themes[_ServerFinderState.Config.theme].colors.textWarning
    end
end)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 28),
    Position = UDim2.new(0, 14, 1, -34),
    BackgroundTransparency = 1,
    Text = "Com writefile, a escolha fica salva para a próxima execução.",
    TextColor3 = Color3.fromRGB(120, 145, 170),
    TextSize = 11,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, _ServerFinderState.ConfigsCard)

-- Página Chat.
 _ServerFinderState.ChatCard = _ServerFinderState.create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.fromOffset(0, 0),
    BackgroundColor3 = Color3.fromRGB(20, 24, 36),
    BorderSizePixel = 0,
}, _ServerFinderState.ChatPage)
_ServerFinderState.corner(_ServerFinderState.ChatCard, 11)
_ServerFinderState.stroke(_ServerFinderState.ChatCard, Color3.fromRGB(70, 93, 125), 1, 0.72)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 32),
    Position = UDim2.fromOffset(14, 12),
    BackgroundTransparency = 1,
    Text = _ServerFinderState.Config.botName .. "  •  assistente de sessão",
    TextColor3 = Color3.fromRGB(245, 245, 250),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.ChatPage)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 24),
    Position = UDim2.fromOffset(14, 44),
    BackgroundTransparency = 1,
    Text = "Online nesta sessão  •  conversa privada local",
    TextColor3 = Color3.fromRGB(120, 220, 165),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.ChatPage)

 _ServerFinderState.ChatLog = _ServerFinderState.create("ScrollingFrame", {
    Size = UDim2.new(1, -28, 1, -176),
    Position = UDim2.fromOffset(14, 94),
    BackgroundColor3 = Color3.fromRGB(15, 19, 29),
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 5,
}, _ServerFinderState.ChatPage)
_ServerFinderState.corner(_ServerFinderState.ChatLog, 10)
_ServerFinderState.stroke(_ServerFinderState.ChatLog, Color3.fromRGB(63, 76, 103), 1, 0.76)

 _ServerFinderState.ChatLayout = _ServerFinderState.create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, _ServerFinderState.ChatLog)

 _ServerFinderState.ChatInput = _ServerFinderState.create("TextBox", {
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
}, _ServerFinderState.ChatPage)
_ServerFinderState.corner(_ServerFinderState.ChatInput, 9)
_ServerFinderState.stroke(_ServerFinderState.ChatInput, Color3.fromRGB(75, 92, 122), 1, 0.7)

 _ServerFinderState.SendButton = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(90, 42),
    Position = UDim2.new(1, -104, 1, -44),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    Text = "Enviar",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 13,
    Font = Enum.Font.SourceSansBold,
}, _ServerFinderState.ChatPage)
_ServerFinderState.corner(_ServerFinderState.SendButton, 9)
_ServerFinderState.styleButton(_ServerFinderState.SendButton, Color3.fromRGB(0, 135, 190), Color3.fromRGB(25, 165, 215))

 _ServerFinderState.ChatMessages = {}
 _ServerFinderState.MAX_CHAT_MESSAGES = 80

_ServerFinderState.addMessage = function(author, text, color)
    local message = _ServerFinderState.create("TextLabel", {
        Size = UDim2.new(1, -18, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(35, 38, 50),
        Text = "  " .. author .. "\n  " .. tostring(text),
        TextColor3 = color,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.SourceSans,
    }, _ServerFinderState.ChatLog)
    _ServerFinderState.corner(message, 8)
    table.insert(_ServerFinderState.ChatMessages, message)
    if #_ServerFinderState.ChatMessages > _ServerFinderState.MAX_CHAT_MESSAGES then
        local oldest = table.remove(_ServerFinderState.ChatMessages, 1)
        if oldest and oldest.Parent then
            oldest:Destroy()
        end
    end
end

_ServerFinderState.clearChat = function()
    for _, child in ipairs(_ServerFinderState.ChatLog:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    _ServerFinderState.ChatMessages = {}
end

_ServerFinderState.ChatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    _ServerFinderState.ChatLog.CanvasSize = UDim2.new(0, 0, 0, _ServerFinderState.ChatLayout.AbsoluteContentSize.Y + 14)
    _ServerFinderState.ChatLog.CanvasPosition = Vector2.new(0, math.max(0, _ServerFinderState.ChatLayout.AbsoluteContentSize.Y))
end)

 _ServerFinderState.Suggestions = _ServerFinderState.create("Frame", {
    Size = UDim2.new(1, 0, 0, 28),
    Position = UDim2.fromOffset(0, 60),
    BackgroundTransparency = 1,
}, _ServerFinderState.ChatPage)

_ServerFinderState.suggestion = function(text, position)
    local button = _ServerFinderState.create("TextButton", {
        Size = UDim2.fromOffset(128, 26),
        Position = position,
        BackgroundColor3 = Color3.fromRGB(42, 47, 63),
        Text = text,
        TextColor3 = Color3.fromRGB(205, 215, 235),
        TextSize = 11,
        Font = Enum.Font.SourceSansBold,
    }, _ServerFinderState.Suggestions)
    _ServerFinderState.corner(button, 7)
    _ServerFinderState.styleButton(button, Color3.fromRGB(42, 47, 63), Color3.fromRGB(59, 68, 91))
    return button
end

 _ServerFinderState.SuggestTalk = _ServerFinderState.suggestion("Vamos conversar", UDim2.fromOffset(0, 0))
 _ServerFinderState.SuggestAbout = _ServerFinderState.suggestion("Fale sobre você", UDim2.fromOffset(138, 0))
 _ServerFinderState.SuggestClear = _ServerFinderState.suggestion("Limpar conversa", UDim2.fromOffset(276, 0))

 _ServerFinderState.ChatState = {
    lastIntent = nil,
    lastMode = nil,
    turnCount = 0,
}
_ServerFinderState.runSearch = nil

_ServerFinderState.hasAny = function(text, words)
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

_ServerFinderState.answer = function(rawMessage)
    local original = tostring(rawMessage)
    local text = string.lower(original)
    _ServerFinderState.ChatState.turnCount = _ServerFinderState.ChatState.turnCount + 1

    local name = original:match("[Mm][Ee][Uu] [Nn][Oo][Mm][Ee] é%s+(.+)")
        or original:match("[Mm][Ee][Uu] [Nn][Oo][Mm][Ee] É%s+(.+)")
        or original:match("[Mm][Ee][Uu] [Nn][Oo][Mm][Ee] e%s+(.+)")
        or original:match("[Mm][Ee][Uu] [Nn][Oo][Mm][Ee] E%s+(.+)")
    if name and #name > 1 then
        _ServerFinderState.Config.userName = name:gsub("^%s+", ""):gsub("%s+$", "")
        _ServerFinderState.ChatState.lastIntent = "profile"
        return "Fechado. Vou chamar você de " .. _ServerFinderState.Config.userName .. " nesta sessão."
    end

    if _ServerFinderState.hasAny(text, {"limpar conversa", "apagar conversa", "limpa chat"}) then
        _ServerFinderState.clearChat()
        _ServerFinderState.ChatState.lastIntent = "clear"
        return "Conversa limpa. Podemos começar de novo."
    end
    if _ServerFinderState.hasAny(text, {"qual seu nome", "seu nome"}) then
        _ServerFinderState.ChatState.lastIntent = "identity"
        return "Eu sou " .. _ServerFinderState.Config.botName .. ". Fui configurado para ajudar com esta interface."
    end
    if _ServerFinderState.hasAny(text, {"oi", "ola", "olá", "bom dia", "boa tarde", "boa noite"}) then
        _ServerFinderState.ChatState.lastIntent = "greeting"
        return "Oi, " .. _ServerFinderState.Config.userName .. ". Quer conversar ou quer que eu encontre um servidor?"
    end
    if _ServerFinderState.hasAny(text, {"o que você faz", "o que voce faz", "como funciona", "capacidades"}) then
        _ServerFinderState.ChatState.lastIntent = "capabilities"
        return "Posso explicar a interface, lembrar o contexto desta sessão e iniciar uma busca quando você pedir."
    end
    if _ServerFinderState.hasAny(text, {"erro", "falhou", "não funciona", "nao funciona", "problema"}) then
        _ServerFinderState.ChatState.lastIntent = "troubleshooting"
        return "Me diga o texto exato do erro. Assim separo falha HTTP, teleporte recusado ou bloqueio do executor."
    end
    if _ServerFinderState.hasAny(text, {"idioma", "brasil", "br", "english", "inglês"}) then
        _ServerFinderState.ChatState.lastIntent = "language"
        return "O botão BR tenta confirmar o país do servidor. Se o Roblox bloquear essa consulta, ele usa a menor latência disponível e avisa que é uma estimativa."
    end
    if _ServerFinderState.hasAny(text, {"servidor aleatório", "servidor aleatorio", "qualquer servidor"}) then
        _ServerFinderState.ChatState.lastIntent = "search"
        _ServerFinderState.ChatState.lastMode = "random"
        task.defer(function()
            _ServerFinderState.runSearch("random", "servidor aleatório")
        end)
        return "Vou procurar um servidor aleatório agora."
    end
    if _ServerFinderState.hasAny(text, {"buscar servidor", "trocar servidor", "servidor cheio", "melhor servidor"}) then
        _ServerFinderState.ChatState.lastIntent = "search"
        _ServerFinderState.ChatState.lastMode = "full"
        task.defer(function()
            _ServerFinderState.runSearch("full", "servidor")
        end)
        return "Vou procurar um servidor com bastante movimento."
    end
    if _ServerFinderState.hasAny(text, {"fale sobre você", "quem é você"}) then
        _ServerFinderState.ChatState.lastIntent = "about"
        return "Sou um assistente local. Não envio a conversa para uma API externa."
    end

    _ServerFinderState.ChatState.lastIntent = "fallback"
    return "Entendi. Posso conversar, explicar a interface ou buscar um servidor."
end

_ServerFinderState.sendChat = function(message)
    local text = message or _ServerFinderState.ChatInput.Text
    if not text or text:gsub("%s+", "") == "" then
        return
    end
    _ServerFinderState.ChatInput.Text = ""
    _ServerFinderState.addMessage(_ServerFinderState.Config.userName, text, Color3.fromRGB(150, 210, 255))
    task.wait(0.2)
    _ServerFinderState.addMessage(_ServerFinderState.Config.botName, _ServerFinderState.answer(text), Color3.fromRGB(170, 240, 185))
end

_ServerFinderState.SendButton.MouseButton1Click:Connect(_ServerFinderState.sendChat)
_ServerFinderState.ChatInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        _ServerFinderState.sendChat()
    end
end)
_ServerFinderState.SuggestTalk.MouseButton1Click:Connect(function()
    _ServerFinderState.sendChat("Oi, quero conversar")
end)
_ServerFinderState.SuggestAbout.MouseButton1Click:Connect(function()
    _ServerFinderState.sendChat("Fale sobre você")
end)
_ServerFinderState.SuggestClear.MouseButton1Click:Connect(function()
    _ServerFinderState.sendChat("Limpar conversa")
end)

-- Página Info, acessível pelo botão no topo.
_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundTransparency = 1,
    Text = "Sobre o Server Finder",
    TextColor3 = Color3.fromRGB(245, 248, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.InfoPage)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 32),
    Position = UDim2.fromOffset(0, 34),
    BackgroundTransparency = 1,
    Text = "Tudo o que você precisa saber antes de iniciar uma busca.",
    TextColor3 = Color3.fromRGB(155, 190, 205),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.InfoPage)

 _ServerFinderState.InfoCard = _ServerFinderState.create("Frame", {
    Size = UDim2.new(1, 0, 0, 128),
    Position = UDim2.fromOffset(0, 78),
    BackgroundColor3 = Color3.fromRGB(25, 31, 45),
    BorderSizePixel = 0,
}, _ServerFinderState.InfoPage)
_ServerFinderState.corner(_ServerFinderState.InfoCard, 10)
_ServerFinderState.stroke(_ServerFinderState.InfoCard, Color3.fromRGB(70, 191, 210), 1, 0.68)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 25),
    Position = UDim2.fromOffset(14, 12),
    BackgroundTransparency = 1,
    Text = "Como usar",
    TextColor3 = Color3.fromRGB(120, 230, 220),
    TextSize = 15,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.InfoCard)

_ServerFinderState.create("TextLabel", {
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
}, _ServerFinderState.InfoCard)

_ServerFinderState.copyToClipboard = function(text)
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

 _ServerFinderState.Toast = _ServerFinderState.create("Frame", {
    Size = UDim2.fromOffset(224, 54),
    Position = UDim2.new(1, 12, 0, 62),
    BackgroundColor3 = Color3.fromRGB(28, 118, 92),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 80,
}, _ServerFinderState.Window)
_ServerFinderState.corner(_ServerFinderState.Toast, 9)
_ServerFinderState.stroke(_ServerFinderState.Toast, Color3.fromRGB(135, 255, 205), 1, 0.35)

 _ServerFinderState.ToastMessage = _ServerFinderState.create("TextLabel", {
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
}, _ServerFinderState.Toast)

 _ServerFinderState.toastId = 0
_ServerFinderState.showToast = function(message, color)
    _ServerFinderState.toastId = _ServerFinderState.toastId + 1
    local currentToastId = _ServerFinderState.toastId
    _ServerFinderState.Toast.BackgroundColor3 = color or Color3.fromRGB(28, 118, 92)
    _ServerFinderState.ToastMessage.Text = message
    _ServerFinderState.Toast.Visible = true
    task.delay(2.8, function()
        if currentToastId == _ServerFinderState.toastId and _ServerFinderState.Toast.Parent then
            _ServerFinderState.Toast.Visible = false
        end
    end)
end

 _ServerFinderState.DiscordCard = _ServerFinderState.create("Frame", {
    Size = UDim2.new(1, 0, 0, 64),
    Position = UDim2.fromOffset(0, 308),
    BackgroundColor3 = Color3.fromRGB(31, 35, 55),
    BorderSizePixel = 0,
}, _ServerFinderState.InfoPage)
_ServerFinderState.corner(_ServerFinderState.DiscordCard, 10)
_ServerFinderState.stroke(_ServerFinderState.DiscordCard, Color3.fromRGB(105, 112, 220), 1, 0.62)

 _ServerFinderState.DiscordIconFallback = _ServerFinderState.create("TextLabel", {
    Size = UDim2.fromOffset(40, 40),
    Position = UDim2.fromOffset(10, 12),
    BackgroundColor3 = Color3.fromRGB(88, 101, 242),
    Text = "☁",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 22,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
}, _ServerFinderState.DiscordCard)
_ServerFinderState.corner(_ServerFinderState.DiscordIconFallback, 20)

 _ServerFinderState.DiscordIcon = _ServerFinderState.create("ImageLabel", {
    Size = UDim2.fromOffset(40, 40),
    Position = UDim2.fromOffset(10, 12),
    BackgroundTransparency = 1,
    Image = "",
    ImageTransparency = 1,
}, _ServerFinderState.DiscordCard)
_ServerFinderState.corner(_ServerFinderState.DiscordIcon, 20)

 _ServerFinderState.DiscordName = _ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -176, 0, 22),
    Position = UDim2.fromOffset(60, 8),
    BackgroundTransparency = 1,
    Text = "Meu servidor no Discord",
    TextColor3 = Color3.fromRGB(240, 242, 255),
    TextSize = 13,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.DiscordCard)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -176, 0, 20),
    Position = UDim2.fromOffset(60, 31),
    BackgroundTransparency = 1,
    Text = "discord.gg/RtfAn6zku8",
    TextColor3 = Color3.fromRGB(165, 175, 215),
    TextSize = 11,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.DiscordCard)

 _ServerFinderState.CopyDiscordButton = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(104, 36),
    Position = UDim2.new(1, -114, 0, 14),
    BackgroundColor3 = Color3.fromRGB(88, 101, 242),
    Text = "COPIAR LINK",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
}, _ServerFinderState.DiscordCard)
_ServerFinderState.corner(_ServerFinderState.CopyDiscordButton, 8)
_ServerFinderState.styleButton(_ServerFinderState.CopyDiscordButton, Color3.fromRGB(88, 101, 242), Color3.fromRGB(111, 123, 255))

_ServerFinderState.CopyDiscordButton.MouseButton1Click:Connect(function()
    if _ServerFinderState.copyToClipboard(_ServerFinderState.DISCORD_INVITE) then
        _ServerFinderState.showToast("✓ Link do Discord copiado!", Color3.fromRGB(28, 118, 92))
    else
        _ServerFinderState.showToast("Não foi possível copiar neste executor.", Color3.fromRGB(145, 78, 64))
    end
end)

_ServerFinderState.loadDiscordIcon = function(iconUrl, guildId)
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
                local imageBody = _ServerFinderState.httpGet(iconUrl)
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
        return _ServerFinderState.httpGet(
            "https://discord.com/api/v10/invites/"
                .. _ServerFinderState.DISCORD_INVITE_CODE
                .. "?with_counts=true"
        )
    end)
    if not ok or not body then
        return
    end

    local decoded, invite = pcall(function()
        return _ServerFinderState.HttpService:JSONDecode(body)
    end)
    local guild = decoded and invite and invite.guild
    if not guild then
        return
    end

    if guild.name and _ServerFinderState.DiscordName.Parent then
        _ServerFinderState.DiscordName.Text = tostring(guild.name)
    end

    if guild.id and guild.icon and _ServerFinderState.DiscordIcon.Parent then
        -- PNG também funciona para ícones animados como uma imagem estática.
        local iconUrl = "https://cdn.discordapp.com/icons/"
            .. tostring(guild.id)
            .. "/"
            .. tostring(guild.icon)
            .. ".png"
            .. "?size=128"
        local iconSource, isLocalAsset = _ServerFinderState.loadDiscordIcon(
            iconUrl,
            tostring(guild.id) .. "_" .. tostring(guild.icon)
        )
        local imageOk = pcall(function()
            _ServerFinderState.DiscordIcon.Image = iconSource
            _ServerFinderState.DiscordIcon.ImageTransparency = 0
        end)
        if imageOk and isLocalAsset then
            _ServerFinderState.DiscordIconFallback.Visible = false
        end
    end
end)

 _ServerFinderState.InfoNotice = _ServerFinderState.create("Frame", {
    Size = UDim2.new(1, 0, 0, 82),
    Position = UDim2.fromOffset(0, 212),
    BackgroundColor3 = Color3.fromRGB(29, 34, 47),
    BorderSizePixel = 0,
}, _ServerFinderState.InfoPage)
_ServerFinderState.corner(_ServerFinderState.InfoNotice, 10)
_ServerFinderState.stroke(_ServerFinderState.InfoNotice, Color3.fromRGB(220, 178, 82), 1, 0.72)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 22),
    Position = UDim2.fromOffset(14, 11),
    BackgroundTransparency = 1,
    Text = "Aviso importante",
    TextColor3 = Color3.fromRGB(255, 215, 125),
    TextSize = 14,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.InfoNotice)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -28, 0, 44),
    Position = UDim2.fromOffset(14, 34),
    BackgroundTransparency = 1,
    Text = "O botão BR tenta confirmar o país antes do teleporte e não entra em servidores com amigos.\n"
        .. "Se o Roblox bloquear a confirmação exata, usa a menor latência disponível e identifica o resultado como estimado.",
    TextColor3 = Color3.fromRGB(210, 215, 225),
    TextSize = 11,
    TextWrapped = true,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, _ServerFinderState.InfoNotice)

 _ServerFinderState.InfoVersion = _ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    Position = UDim2.new(0, 0, 1, -28),
    BackgroundTransparency = 1,
    Text = "Server Finder  •  " .. _ServerFinderState.GUARD_VERSION .. "  •  interface responsiva",
    TextColor3 = Color3.fromRGB(120, 145, 170),
    TextSize = 11,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
}, _ServerFinderState.InfoPage)

-- Loading renovado.
 _ServerFinderState.Loading = _ServerFinderState.create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(8, 10, 17),
    BackgroundTransparency = 0.03,
    Visible = true,
    Active = true,
    ZIndex = 50,
}, _ServerFinderState.Window)
_ServerFinderState.corner(_ServerFinderState.Loading, 14)
_ServerFinderState.stroke(_ServerFinderState.Loading, Color3.fromRGB(0, 190, 230), 1, 0.35)

-- O overlay cobre o cabeçalho; este X mantém a tela fechável durante a verificação.
 _ServerFinderState.LoadingClose = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -42, 0, 10),
    BackgroundColor3 = Color3.fromRGB(190, 55, 65),
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 55,
}, _ServerFinderState.Loading)
_ServerFinderState.corner(_ServerFinderState.LoadingClose, 7)
_ServerFinderState.styleButton(_ServerFinderState.LoadingClose, Color3.fromRGB(190, 55, 65), Color3.fromRGB(225, 70, 80))

 _ServerFinderState.LoadingAccent = _ServerFinderState.create("Frame", {
    Size = UDim2.new(0, 4, 1, -84),
    Position = UDim2.fromOffset(24, 42),
    BackgroundColor3 = Color3.fromRGB(0, 190, 230),
    BorderSizePixel = 0,
    ZIndex = 51,
}, _ServerFinderState.Loading)
_ServerFinderState.corner(_ServerFinderState.LoadingAccent, 3)

 _ServerFinderState.LoadingAvatar = _ServerFinderState.create("ImageLabel", {
    Size = UDim2.fromOffset(76, 76),
    Position = UDim2.new(0.5, -38, 0, 54),
    BackgroundColor3 = Color3.fromRGB(35, 40, 58),
    BorderSizePixel = 0,
    Image = "",
    ZIndex = 52,
}, _ServerFinderState.Loading)
_ServerFinderState.corner(_ServerFinderState.LoadingAvatar, 38)
 _ServerFinderState.LoadingAvatarStroke = _ServerFinderState.stroke(_ServerFinderState.LoadingAvatar, Color3.fromRGB(0, 190, 230), 2, 0.15)

 _ServerFinderState.LoadingBrand = _ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 24),
    Position = UDim2.new(0, 40, 0, 140),
    BackgroundTransparency = 1,
    Text = "SERVER FINDER",
    TextColor3 = Color3.fromRGB(245, 248, 255),
    TextSize = 20,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 52,
}, _ServerFinderState.Loading)

_ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 18),
    Position = UDim2.new(0, 40, 0, 165),
    BackgroundTransparency = 1,
    Text = "by mateus_15600",
    TextColor3 = Color3.fromRGB(120, 220, 220),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 52,
}, _ServerFinderState.Loading)

 _ServerFinderState.LoadingTitle = _ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 32),
    Position = UDim2.new(0, 40, 0, 208),
    BackgroundTransparency = 1,
    Text = "Preparando seu painel...",
    TextColor3 = Color3.fromRGB(240, 240, 250),
    TextSize = 18,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 51,
}, _ServerFinderState.Loading)

 _ServerFinderState.LoadingDetail = _ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 24),
    Position = UDim2.new(0, 40, 0, 248),
    BackgroundTransparency = 1,
    Text = "Ajustando a interface à sua tela...",
    TextColor3 = Color3.fromRGB(175, 180, 200),
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 51,
}, _ServerFinderState.Loading)

 _ServerFinderState.LoadingBarBack = _ServerFinderState.create("Frame", {
    Size = UDim2.new(0, 300, 0, 7),
    Position = UDim2.new(0.5, -150, 0, 294),
    BackgroundColor3 = Color3.fromRGB(37, 44, 62),
    BorderSizePixel = 0,
    ZIndex = 51,
}, _ServerFinderState.Loading)
_ServerFinderState.corner(_ServerFinderState.LoadingBarBack, 4)

 _ServerFinderState.LoadingBarFill = _ServerFinderState.create("Frame", {
    Size = UDim2.new(0.12, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 190, 230),
    BorderSizePixel = 0,
    ZIndex = 52,
}, _ServerFinderState.LoadingBarBack)
_ServerFinderState.corner(_ServerFinderState.LoadingBarFill, 4)
_ServerFinderState.create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 235, 205)),
    }),
}, _ServerFinderState.LoadingBarFill)

 _ServerFinderState.LoadingHint = _ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 18),
    Position = UDim2.new(0, 40, 0, 316),
    BackgroundTransparency = 1,
    Text = "Siga o criador para liberar o painel.",
    TextColor3 = Color3.fromRGB(125, 135, 160),
    TextSize = 11,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 51,
}, _ServerFinderState.Loading)

 _ServerFinderState.LoadingContinue = _ServerFinderState.create("TextButton", {
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
}, _ServerFinderState.Loading)
_ServerFinderState.corner(_ServerFinderState.LoadingContinue, 8)

 _ServerFinderState.FollowStatus = _ServerFinderState.create("TextLabel", {
    Size = UDim2.new(1, -80, 0, 38),
    Position = UDim2.new(0, 40, 0, 338),
    BackgroundTransparency = 1,
    Text = "Siga @" .. _ServerFinderState.CREATOR_USERNAME .. " para liberar o script.",
    TextColor3 = Color3.fromRGB(255, 215, 125),
    TextSize = 11,
    TextWrapped = true,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    ZIndex = 52,
}, _ServerFinderState.Loading)

 _ServerFinderState.FollowOpen = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(132, 32),
    Position = UDim2.new(0.5, -140, 0, 374),
    BackgroundColor3 = Color3.fromRGB(0, 135, 190),
    BorderSizePixel = 0,
    Text = "ABRIR PERFIL",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 52,
}, _ServerFinderState.Loading)
_ServerFinderState.corner(_ServerFinderState.FollowOpen, 8)
_ServerFinderState.styleButton(_ServerFinderState.FollowOpen, Color3.fromRGB(0, 135, 190), Color3.fromRGB(0, 170, 215))

 _ServerFinderState.FollowCheck = _ServerFinderState.create("TextButton", {
    Size = UDim2.fromOffset(132, 32),
    Position = UDim2.new(0.5, 8, 0, 374),
    BackgroundColor3 = Color3.fromRGB(28, 118, 92),
    BorderSizePixel = 0,
    Text = "JÁ SEGUI — VERIFICAR",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 10,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 52,
}, _ServerFinderState.Loading)
_ServerFinderState.corner(_ServerFinderState.FollowCheck, 8)
_ServerFinderState.styleButton(_ServerFinderState.FollowCheck, Color3.fromRGB(28, 118, 92), Color3.fromRGB(38, 150, 112))

task.spawn(function()
    local ok, userId = pcall(function()
        return _ServerFinderState.Players:GetUserIdFromNameAsync(_ServerFinderState.CREATOR_USERNAME)
    end)
    if not ok or not userId then
        return
    end
    _ServerFinderState.creatorUserId = userId
    local thumbOk, thumbnail = pcall(function()
        return _ServerFinderState.Players:GetUserThumbnailAsync(
            userId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)
    if thumbOk and thumbnail and _ServerFinderState.OwnerAvatar.Parent then
        _ServerFinderState.OwnerAvatar.Image = thumbnail
        _ServerFinderState.LoadingAvatar.Image = thumbnail
    end
end)

 _ServerFinderState.loadingProgress = 0.12
 _ServerFinderState.loadingMessage = "Ajustando a interface à sua tela..."
 _ServerFinderState.loadingFinishing = false

_ServerFinderState.hideLoading = function(instant)
    if _ServerFinderState.Loading and _ServerFinderState.Loading.Parent then
        if _ServerFinderState.followGateVisible and not _ServerFinderState.followUnlocked and not instant then
            return
        end
        if instant then
            _ServerFinderState.loadingFinishing = false
            _ServerFinderState.Loading.Visible = false
            return
        end

        if not _ServerFinderState.Loading.Visible or _ServerFinderState.loadingFinishing then
            return
        end

        _ServerFinderState.loadingFinishing = true
        _ServerFinderState.loadingProgress = 1
        _ServerFinderState.LoadingBarFill.Size = UDim2.new(1, 0, 1, 0)
        _ServerFinderState.LoadingHint.Text = "Carregamento concluído."
        task.wait(0.18)

        if not _ServerFinderState.Loading.Parent then
            return
        end
        _ServerFinderState.Loading.Visible = false
        _ServerFinderState.loadingFinishing = false
    end
end

_ServerFinderState.showLoading = function(text)
    if _ServerFinderState.followGateVisible and not _ServerFinderState.followUnlocked then
        return
    end
    _ServerFinderState.loadingMessage = text or "Processando..."
    _ServerFinderState.LoadingDetail.Text = _ServerFinderState.loadingMessage
    _ServerFinderState.LoadingTitle.Text = "Aguarde um momento..."
    _ServerFinderState.LoadingHint.Text = "Você pode continuar e fechar esta tela quando quiser."
    -- Busca e teleporte usam a mesma camada visual, mas não devem parecer a tela de follow.
    _ServerFinderState.FollowStatus.Visible = false
    _ServerFinderState.FollowOpen.Visible = false
    _ServerFinderState.FollowCheck.Visible = false
    _ServerFinderState.LoadingContinue.Visible = false
    _ServerFinderState.loadingFinishing = false
    _ServerFinderState.loadingProgress = 0.08
    _ServerFinderState.LoadingBarFill.Size = UDim2.new(_ServerFinderState.loadingProgress, 0, 1, 0)
    _ServerFinderState.Loading.Visible = true
end

_ServerFinderState.parseFollowResponse = function(body)
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
        return _ServerFinderState.HttpService:JSONDecode(normalized)
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

_ServerFinderState.resolveCreatorUserId = function()
    if _ServerFinderState.creatorUserId then
        return _ServerFinderState.creatorUserId
    end

    local ok, userId = pcall(function()
        return _ServerFinderState.Players:GetUserIdFromNameAsync(_ServerFinderState.CREATOR_USERNAME)
    end)
    if ok and userId then
        _ServerFinderState.creatorUserId = userId
        return userId
    end
    error("Não foi possível localizar o perfil do criador.")
end

_ServerFinderState.queryCreatorFollow = function()
    local creatorId = _ServerFinderState.resolveCreatorUserId()
    local cursor

    -- Esta rota pública não exige cookie do Roblox. A consulta paginada
    -- evita depender de /user/following-exists, que exige autenticação web.
    for page = 1, 50 do
        if _ServerFinderState.destroyed then
            error("Verificação cancelada.")
        end
        if not _ServerFinderState.followUnlocked and _ServerFinderState.FollowStatus and _ServerFinderState.FollowStatus.Parent then
            _ServerFinderState.FollowStatus.Text = "Verificando sua lista de follows... " .. page .. "/50"
        end
        local url = "https://friends.roblox.com/v1/users/"
            .. tostring(_ServerFinderState.Player.UserId)
            .. "/followings?sortOrder=Asc&limit=100"
        if cursor and cursor ~= "" then
            url = url .. "&cursor=" .. _ServerFinderState.urlEncode(cursor)
        end

        local data = _ServerFinderState.decodeJson(_ServerFinderState.httpGet(url), "Resposta de follow inválida.")
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

_ServerFinderState.lockFollowGate = function(statusText)
    local wasVisible = _ServerFinderState.followGateVisible
    _ServerFinderState.followUnlocked = false
    _ServerFinderState.followGateVisible = true
    if not wasVisible then
        _ServerFinderState.followGateStartedAt = os.clock()
    end
    if not _ServerFinderState.Loading or not _ServerFinderState.Loading.Parent then
        return
    end

    _ServerFinderState.loadingFinishing = false
    _ServerFinderState.Loading.Visible = true
    _ServerFinderState.LoadingClose.Visible = true
    _ServerFinderState.loadingProgress = 0.08
    _ServerFinderState.LoadingBarFill.Size = UDim2.new(_ServerFinderState.loadingProgress, 0, 1, 0)
    _ServerFinderState.LoadingTitle.Text = "Follow necessário"
    _ServerFinderState.LoadingDetail.Text = "Siga @" .. _ServerFinderState.CREATOR_USERNAME .. " para continuar."
    _ServerFinderState.LoadingHint.Text = "O painel será liberado automaticamente quando o follow for confirmado."
    _ServerFinderState.FollowStatus.Visible = true
    _ServerFinderState.FollowStatus.Text = statusText or "Siga @" .. _ServerFinderState.CREATOR_USERNAME .. " para liberar o script."
    _ServerFinderState.FollowStatus.TextColor3 = Color3.fromRGB(255, 215, 125)
    _ServerFinderState.FollowOpen.Visible = true
    _ServerFinderState.FollowCheck.Visible = true
    _ServerFinderState.FollowOpen.Active = true
    _ServerFinderState.FollowCheck.Active = true
    _ServerFinderState.LoadingContinue.Visible = false
end

_ServerFinderState.unlockFollowGate = function()
    local shouldHide = _ServerFinderState.followGateVisible
    local minimumRemaining = math.max(0, _ServerFinderState.FOLLOW_LOADING_MIN_SECONDS - (os.clock() - _ServerFinderState.followGateStartedAt))
    _ServerFinderState.followUnlocked = true
    _ServerFinderState.followGateVisible = false
    _ServerFinderState.followChecking = false
    _ServerFinderState.FollowStatus.Text = "✓ Follow confirmado. O painel foi liberado."
    _ServerFinderState.FollowStatus.TextColor3 = Color3.fromRGB(145, 240, 180)
    _ServerFinderState.FollowOpen.Visible = false
    _ServerFinderState.FollowCheck.Visible = false
    _ServerFinderState.LoadingContinue.Visible = false
    _ServerFinderState.LoadingClose.Visible = true
    _ServerFinderState.LoadingTitle.Text = "Acesso liberado!"
    _ServerFinderState.LoadingDetail.Text = "Obrigado por seguir o criador."
    _ServerFinderState.LoadingHint.Text = "Abrindo o painel automaticamente..."
    _ServerFinderState.LoadingBarFill.Size = UDim2.new(1, 0, 1, 0)

    if shouldHide then
        task.spawn(function()
            task.wait(minimumRemaining)
            if not _ServerFinderState.destroyed and _ServerFinderState.Loading.Parent then
                _ServerFinderState.hideLoading(true)
                _ServerFinderState.showStartupPopup()
            end
        end)
    end
end

_ServerFinderState.checkFollowGate = function(silent)
    if _ServerFinderState.destroyed or _ServerFinderState.followChecking then
        return
    end
    if _ServerFinderState.followUnlocked and not silent then
        return
    end

    _ServerFinderState.followChecking = true
    if not silent or not _ServerFinderState.followUnlocked then
        _ServerFinderState.Loading.Visible = true
        _ServerFinderState.LoadingClose.Visible = true
        _ServerFinderState.LoadingTitle.Text = "Verificando follow..."
        _ServerFinderState.LoadingDetail.Text = "Consultando o perfil do criador."
        _ServerFinderState.FollowStatus.Text = "Aguarde, verificando..."
        _ServerFinderState.FollowStatus.TextColor3 = Color3.fromRGB(225, 210, 110)
        _ServerFinderState.FollowOpen.Active = false
        _ServerFinderState.FollowCheck.Active = false
    end

    task.spawn(function()
        local ok, isFollowing = pcall(_ServerFinderState.queryCreatorFollow)
        if _ServerFinderState.destroyed or not _ServerFinderState.Loading.Parent then
            return
        end

        _ServerFinderState.followChecking = false
        if ok and isFollowing == true then
            _ServerFinderState.unlockFollowGate()
            return
        end

        if ok and isFollowing == false then
            if _ServerFinderState.searching and _ServerFinderState.followUnlocked then
                return
            end
            _ServerFinderState.lockFollowGate("Ainda não encontrei o follow. Siga o criador; o painel abrirá sozinho quando confirmar.")
        elseif not _ServerFinderState.followUnlocked then
            _ServerFinderState.Loading.Visible = true
            _ServerFinderState.LoadingClose.Visible = true
            _ServerFinderState.FollowOpen.Active = true
            _ServerFinderState.FollowCheck.Active = true
            local reason = tostring(isFollowing or "erro desconhecido"):gsub("[%c]+", " ")
            if #reason > 90 then
                reason = reason:sub(1, 90) .. "..."
            end
            _ServerFinderState.FollowStatus.Text = "Falha ao verificar follow: " .. reason
            _ServerFinderState.FollowStatus.TextColor3 = Color3.fromRGB(240, 130, 130)
            _ServerFinderState.LoadingTitle.Text = "Follow necessário"
            _ServerFinderState.LoadingDetail.Text = "Confira o HTTP do executor e tente verificar novamente."
        end
    end)
end

_ServerFinderState.FollowOpen.MouseButton1Click:Connect(function()
    local opened = false
    local openers = {}
    if type(open_url) == "function" then
        table.insert(openers, open_url)
    end
    if type(syn) == "table" and type(syn.open_url) == "function" then
        table.insert(openers, syn.open_url)
    end

    for _, opener in ipairs(openers) do
        local ok = pcall(opener, _ServerFinderState.CREATOR_PROFILE_URL)
        if ok then
            opened = true
            break
        end
    end

    if opened then
        _ServerFinderState.FollowStatus.Text = "Perfil aberto. Siga o criador e clique em verificar."
    elseif _ServerFinderState.copyToClipboard(_ServerFinderState.CREATOR_PROFILE_URL) then
        _ServerFinderState.FollowStatus.Text = "Link do perfil copiado. Siga o criador e clique em verificar."
    else
        _ServerFinderState.FollowStatus.Text = _ServerFinderState.CREATOR_PROFILE_URL
    end
    _ServerFinderState.FollowStatus.TextColor3 = Color3.fromRGB(165, 215, 240)
end)

_ServerFinderState.FollowCheck.MouseButton1Click:Connect(_ServerFinderState.checkFollowGate)

_ServerFinderState.LoadingContinue.MouseButton1Click:Connect(function()
    if _ServerFinderState.followUnlocked then
        _ServerFinderState.hideLoading(true)
    else
        _ServerFinderState.checkFollowGate()
    end
end)

_ServerFinderState.LoadingClose.MouseButton1Click:Connect(function()
    _ServerFinderState.destroyed = true
    if _ServerFinderState.Gui and _ServerFinderState.Gui.Parent then
        _ServerFinderState.Gui:Destroy()
    end
end)

-- Mantém o estado sincronizado: seguir libera sozinho; deixar de seguir mostra o bloqueio.
task.spawn(function()
    while not _ServerFinderState.destroyed do
        task.wait(_ServerFinderState.FOLLOW_RECHECK_INTERVAL)
        if not _ServerFinderState.destroyed and not _ServerFinderState.searching then
            _ServerFinderState.checkFollowGate(true)
        end
    end
end)

_ServerFinderState.lastViewport = nil
_ServerFinderState.loadingConnection = _ServerFinderState.RunService.RenderStepped:Connect(function(delta)
    if _ServerFinderState.destroyed then
        _ServerFinderState.loadingConnection:Disconnect()
        return
    end
    local viewport = _ServerFinderState.getViewport()
    if not _ServerFinderState.lastViewport or viewport.X ~= _ServerFinderState.lastViewport.X or viewport.Y ~= _ServerFinderState.lastViewport.Y then
        _ServerFinderState.lastViewport = viewport
        _ServerFinderState.applyResponsiveScale()
        _ServerFinderState.clampWindowToViewport()
    end
    if _ServerFinderState.Loading.Visible and not _ServerFinderState.loadingFinishing and not _ServerFinderState.followChecking and not _ServerFinderState.followUnlocked then
        _ServerFinderState.loadingProgress = math.min(1, _ServerFinderState.loadingProgress + delta * 0.18)
        _ServerFinderState.LoadingBarFill.Size = UDim2.new(_ServerFinderState.loadingProgress, 0, 1, 0)
        _ServerFinderState.LoadingTitle.Text = "Preparando seu painel" .. string.rep(".", math.floor(os.clock() * 2) % 4)
    end
end)

-- Teleporte e busca verificada.
_ServerFinderState.teleport = function(server, excludeFriendServers)
    local instanceId = type(server) == "table" and (server.id or server.gameId)
    if type(instanceId) ~= "string" or instanceId == "" then
        _ServerFinderState.setStatus(_ServerFinderState.SearchStatus, "O servidor selecionado não possui um ID válido.", Color3.fromRGB(240, 130, 130))
        return false
    end

    if excludeFriendServers then
        _ServerFinderState.friendServerCache = nil
        _ServerFinderState.friendServerCacheAt = 0
        local friendsOk, currentFriendServers = pcall(_ServerFinderState.getFriendServerIds)
        if not friendsOk then
            _ServerFinderState.setStatus(
                _ServerFinderState.SearchStatus,
                "Não consegui confirmar os servidores dos seus amigos; teleporte cancelado.",
                Color3.fromRGB(240, 130, 130)
            )
            return false
        end
        if currentFriendServers[instanceId] then
            _ServerFinderState.setStatus(
                _ServerFinderState.SearchStatus,
                "Um amigo entrou nesse servidor durante a confirmação. Vou procurar outro.",
                Color3.fromRGB(225, 210, 110)
            )
            return false
        end
    end

    _ServerFinderState.blacklist[instanceId] = os.time() + _ServerFinderState.Config.blacklistTime
    _ServerFinderState.teleportFailed = false
    local teleportStarted = false
    local teleportStartedAt
    local attemptConnection
    pcall(function()
        attemptConnection = _ServerFinderState.Player.OnTeleport:Connect(function(state)
            local stateName = tostring(state)
            if stateName:find("Started", 1, true)
                or stateName:find("WaitingForServer", 1, true)
                or stateName:find("InProgress", 1, true) then
                teleportStarted = true
                teleportStartedAt = teleportStartedAt or os.clock()
            elseif stateName:find("Failed", 1, true) then
                _ServerFinderState.teleportFailed = true
            end
        end)
    end)

    local ok, errorMessage = pcall(function()
        _ServerFinderState.TeleportService:TeleportToPlaceInstance(_ServerFinderState.PLACE_ID, instanceId, _ServerFinderState.Player)
    end)
    if not ok then
        if attemptConnection then
            attemptConnection:Disconnect()
        end
        _ServerFinderState.setStatus(_ServerFinderState.SearchStatus, "Falha ao iniciar: " .. tostring(errorMessage), Color3.fromRGB(240, 130, 130))
        return false
    end

    if not attemptConnection then
        local fallbackDeadline = os.clock() + 12
        while not _ServerFinderState.teleportFailed and not _ServerFinderState.destroyed and os.clock() < fallbackDeadline do
            task.wait(0.1)
        end
        if not _ServerFinderState.teleportFailed and not _ServerFinderState.destroyed then
            _ServerFinderState.setStatus(_ServerFinderState.SearchStatus, "Não foi possível confirmar o início do teleporte.", Color3.fromRGB(240, 130, 130))
        end
        return false
    end

    local deadline = os.clock() + 12
    while not _ServerFinderState.teleportFailed and not _ServerFinderState.destroyed and os.clock() < deadline do
        local startupConfirmed = teleportStarted
            and teleportStartedAt
            and os.clock() - teleportStartedAt >= 1.5
        if startupConfirmed then
            break
        end
        task.wait(0.1)
    end
    attemptConnection:Disconnect()

    if teleportStarted and not _ServerFinderState.teleportFailed then
        return true
    end
    if not _ServerFinderState.teleportFailed and not _ServerFinderState.destroyed then
        _ServerFinderState.setStatus(_ServerFinderState.SearchStatus, "O teleporte não começou dentro do tempo esperado. Tente outro servidor.", Color3.fromRGB(240, 130, 130))
    end
    return false
end

pcall(function()
    _ServerFinderState.teleportInitFailedConnection = _ServerFinderState.TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
        if player == _ServerFinderState.Player then
            _ServerFinderState.teleportFailed = true
            _ServerFinderState.setStatus(_ServerFinderState.SearchStatus, "Teleporte recusado: " .. tostring(result) .. " - " .. tostring(errorMessage or "sem detalhes"), Color3.fromRGB(240, 130, 130))
        end
    end)
end)

_ServerFinderState.searchVerifiedUser = function()
    if not _ServerFinderState.followUnlocked then
        _ServerFinderState.setStatus(_ServerFinderState.VerifiedStatus, "Siga o criador para liberar o script.", Color3.fromRGB(225, 210, 110))
        return
    end
    local username = _ServerFinderState.VerifiedInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if username == "" then
        _ServerFinderState.setStatus(_ServerFinderState.VerifiedStatus, "Digite um username.", Color3.fromRGB(240, 130, 130))
        return
    end
    if _ServerFinderState.searching then
        _ServerFinderState.setStatus(_ServerFinderState.VerifiedStatus, "Aguarde a busca atual terminar.", Color3.fromRGB(225, 210, 110))
        return
    end

    _ServerFinderState.searching = true
    _ServerFinderState.setStatus(_ServerFinderState.VerifiedStatus, "Consultando o perfil...", Color3.fromRGB(225, 210, 110))
    _ServerFinderState.showLoading("Verificando o usuário...")

    task.spawn(function()
        local ok, result = pcall(function()
            local lookupResponse = _ServerFinderState.httpRequest(
                "https://users.roblox.com/v1/usernames/users",
                "POST",
                _ServerFinderState.HttpService:JSONEncode({
                    usernames = {username},
                    excludeBannedUsers = true,
                })
            )
            local lookupData = _ServerFinderState.HttpService:JSONDecode(lookupResponse)
            local userData = lookupData.data and lookupData.data[1]
            if not userData or not userData.id then
                error("Usuário não encontrado.")
            end

            local profileResponse = _ServerFinderState.httpGet("https://users.roblox.com/v1/users/" .. tostring(userData.id))
            local profile = _ServerFinderState.HttpService:JSONDecode(profileResponse)
            if profile.hasVerifiedBadge ~= true then
                error("Esse usuário não possui o selo de verificação.")
            end

            local presenceResponse = _ServerFinderState.httpRequest(
                "https://presence.roblox.com/v1/presence/users",
                "POST",
                _ServerFinderState.HttpService:JSONEncode({userIds = {userData.id}})
            )
            local presenceData = _ServerFinderState.HttpService:JSONDecode(presenceResponse)
            local presence = presenceData.userPresences and presenceData.userPresences[1]

            if not presence
                or presence.userPresenceType ~= 2
                or not presence.gameId then
                error("O usuário verificado não está em um servidor agora.")
            end

            if tonumber(presence.placeId) ~= _ServerFinderState.PLACE_ID then
                error("O usuário verificado não está no Brookhaven.")
            end

            return {
                id = presence.gameId,
                username = userData.name or username,
            }
        end)

        if not ok then
            _ServerFinderState.setStatus(_ServerFinderState.VerifiedStatus, tostring(result), Color3.fromRGB(240, 130, 130))
            _ServerFinderState.searching = false
            _ServerFinderState.hideLoading()
            return
        end

        _ServerFinderState.setStatus(_ServerFinderState.VerifiedStatus, "Servidor encontrado. Aguardando confirmação...", Color3.fromRGB(225, 210, 110))
        _ServerFinderState.VerifiedPopup.Visible = false
        if not _ServerFinderState.askTeleportConfirmation(result, "o servidor do usuário " .. result.username) then
            _ServerFinderState.searching = false
            _ServerFinderState.hideLoading()
            _ServerFinderState.setStatus(_ServerFinderState.VerifiedStatus, "Teleporte cancelado.", Color3.fromRGB(225, 210, 110))
            return
        end
        _ServerFinderState.setStatus(_ServerFinderState.VerifiedStatus, "Entrando no servidor confirmado...", Color3.fromRGB(160, 230, 175))
        local joined = _ServerFinderState.teleport(result)
        _ServerFinderState.searching = false
        _ServerFinderState.hideLoading()
        if not joined then
            _ServerFinderState.setStatus(_ServerFinderState.VerifiedStatus, "O teleporte para o servidor falhou.", Color3.fromRGB(240, 130, 130))
        end
    end)
end

_ServerFinderState.VerifiedSearch.MouseButton1Click:Connect(_ServerFinderState.searchVerifiedUser)

_ServerFinderState.runSearch = function(mode, label)
    if not _ServerFinderState.followUnlocked then
        _ServerFinderState.setStatus(_ServerFinderState.SearchStatus, "Siga o criador para liberar o script.", Color3.fromRGB(225, 210, 110))
        return
    end
    if _ServerFinderState.searching then
        return
    end

    _ServerFinderState.searching = true
    _ServerFinderState.friendServerCache = nil
    _ServerFinderState.friendServerCacheAt = 0
    if mode == "matchmaking" then
        _ServerFinderState.showLoading("Aguardando o matchmaking do Roblox...")
    else
        _ServerFinderState.showLoading("Buscando " .. label .. "...")
    end

    task.spawn(function()
        local connected = false
        local cancelled = false
        local failureMessage
        local ok, searchError = pcall(function()
            local maxAttempts = mode == "matchmaking" and 1 or (mode == "brazil" and 2 or 5)
            for attempt = 1, maxAttempts do
                if _ServerFinderState.destroyed then
                    break
                end
                _ServerFinderState.setStatus(
                    _ServerFinderState.SearchStatus,
                    label .. " • tentativa " .. attempt .. "/" .. maxAttempts,
                    Color3.fromRGB(225, 210, 110)
                )
                if mode == "matchmaking" then
                    _ServerFinderState.setStatus(
                        _ServerFinderState.SearchStatus,
                        "Pedindo ao Roblox para escolher a nova instância...",
                        Color3.fromRGB(225, 210, 110)
                    )
                    if _ServerFinderState.askTeleportConfirmation(nil, label, true) then
                        _ServerFinderState.showLoading("Entrando pelo matchmaking do Roblox...")
                        local requested, requestError = pcall(function()
                            _ServerFinderState.TeleportService:Teleport(_ServerFinderState.PLACE_ID, _ServerFinderState.Player)
                        end)
                        if requested then
                            connected = true
                            _ServerFinderState.setStatus(
                                _ServerFinderState.SearchStatus,
                                "Matchmaking iniciado; o Roblox escolhe a instância automaticamente.",
                                Color3.fromRGB(165, 215, 240)
                            )
                        else
                            failureMessage = "Não consegui iniciar o matchmaking do Roblox: " .. tostring(requestError)
                        end
                    else
                        cancelled = true
                        _ServerFinderState.setStatus(_ServerFinderState.SearchStatus, "Teleporte cancelado.", Color3.fromRGB(225, 210, 110))
                    end
                    break
                end

                local server, selectionError = _ServerFinderState.chooseServer(mode)
                if server and mode == "brazil" and server.regionUnverified then
                    selectionError = "A regiao do servidor nao foi confirmada. Nenhum teleporte foi feito."
                    server = nil
                end
                if server then
                    local selectionText = "Selecionado: " .. server.playing .. "/" .. server.maxPlayers
                    if mode == "brazil" and server.region then
                        local city = server.region.city ~= "" and server.region.city .. ", " or ""
                        selectionText = selectionText .. " • " .. city .. server.region.country
                        if server.regionApproximate and server.regionPing then
                            selectionText = selectionText .. " (" .. tostring(math.floor(server.regionPing)) .. " ms)"
                        end
                    end
                    _ServerFinderState.setStatus(
                        _ServerFinderState.SearchStatus,
                        selectionText,
                        Color3.fromRGB(165, 215, 240)
                    )
                    if _ServerFinderState.askTeleportConfirmation(server, label) then
                        _ServerFinderState.showLoading("Conectando ao servidor...")
                        if _ServerFinderState.teleport(server, true) then
                            connected = true
                            break
                        end
                    else
                        cancelled = true
                        _ServerFinderState.setStatus(_ServerFinderState.SearchStatus, "Teleporte cancelado.", Color3.fromRGB(225, 210, 110))
                        break
                    end
                else
                    failureMessage = selectionError
                    _ServerFinderState.setStatus(
                        _ServerFinderState.SearchStatus,
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
        _ServerFinderState.searching = false
        _ServerFinderState.hideLoading()
        if not connected and not cancelled then
            _ServerFinderState.setStatus(
                _ServerFinderState.SearchStatus,
                failureMessage or "Não foi possível trocar de servidor.",
                Color3.fromRGB(240, 130, 130)
            )
        end
    end)
end
_ServerFinderState.BRButton.MouseButton1Click:Connect(function()
    _ServerFinderState.runSearch("brazil", "Servidor BR")
end)
_ServerFinderState.RandomButton.MouseButton1Click:Connect(function()
    _ServerFinderState.runSearch("random", "servidor aleatório")
end)

-- Arrastar janela.
 _ServerFinderState.dragging = false
_ServerFinderState.dragStart = nil
_ServerFinderState.startPosition = nil
 _ServerFinderState.resizing = false
_ServerFinderState.resizeStart = nil
_ServerFinderState.resizeStartScale = nil

_ServerFinderState.Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        _ServerFinderState.dragging = true
        _ServerFinderState.dragStart = input.Position
        _ServerFinderState.startPosition = _ServerFinderState.Window.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                _ServerFinderState.dragging = false
            end
        end)
    end
end)

_ServerFinderState.ResizeGrip.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        _ServerFinderState.resizing = true
        _ServerFinderState.resizeStart = input.Position
        _ServerFinderState.resizeStartScale = _ServerFinderState.manualScale
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                _ServerFinderState.resizing = false
            end
        end)
    end
end)

_ServerFinderState.inputChangedConnection = _ServerFinderState.UserInputService.InputChanged:Connect(function(input)
    local isPointerMove = input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    if _ServerFinderState.dragging and isPointerMove then
        local delta = input.Position - _ServerFinderState.dragStart
        _ServerFinderState.Window.Position = UDim2.new(
            _ServerFinderState.startPosition.X.Scale,
            _ServerFinderState.startPosition.X.Offset + delta.X,
            _ServerFinderState.startPosition.Y.Scale,
            _ServerFinderState.startPosition.Y.Offset + delta.Y
        )
        _ServerFinderState.clampWindowToViewport()
    end

    if _ServerFinderState.resizing and isPointerMove then
        local delta = input.Position - _ServerFinderState.resizeStart
        local horizontalChange = delta.X / _ServerFinderState.BASE_WIDTH
        local verticalChange = delta.Y / _ServerFinderState.BASE_HEIGHT
        local scaleChange = math.max(horizontalChange, verticalChange)
        _ServerFinderState.manualScale = _ServerFinderState.clamp(_ServerFinderState.resizeStartScale + scaleChange, _ServerFinderState.MIN_SCALE, _ServerFinderState.MAX_USER_SCALE)
        _ServerFinderState.applyResponsiveScale()
        _ServerFinderState.clampWindowToViewport()
    end
end)

 _ServerFinderState.minimized = false
_ServerFinderState.Minimize.MouseButton1Click:Connect(function()
    _ServerFinderState.minimized = not _ServerFinderState.minimized
    _ServerFinderState.Sidebar.Visible = not _ServerFinderState.minimized
    _ServerFinderState.Main.Visible = not _ServerFinderState.minimized
    _ServerFinderState.Window.Size = _ServerFinderState.minimized
        and UDim2.new(0, 720, 0, 48)
        or UDim2.new(0, 720, 0, 460)
    _ServerFinderState.Minimize.Text = _ServerFinderState.minimized and "+" or "—"
    _ServerFinderState.applyResponsiveScale()
    _ServerFinderState.clampWindowToViewport()
end)

_ServerFinderState.Close.MouseButton1Click:Connect(function()
    _ServerFinderState.destroyed = true
    _ServerFinderState.Gui:Destroy()
end)

-- Aplica o tema salvo somente depois de toda a interface estar registrada.
_ServerFinderState.applyTheme(_ServerFinderState.Config.theme)
_ServerFinderState.showPage("Buscar")
_ServerFinderState.addMessage(_ServerFinderState.Config.botName, "Olá, " .. _ServerFinderState.Config.userName .. ". A interface foi ajustada para a sua tela.")

task.spawn(function()
    task.wait(0.4)
    if not _ServerFinderState.destroyed then
        _ServerFinderState.checkFollowGate()
    end
end)

_ServerFinderState.applyResponsiveScale()