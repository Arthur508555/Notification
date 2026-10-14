--[[
    CYBERPUNK / NEON LIGHT NOTIFICATION LIBRARY
    Criado para: Arthur508555
    Hospedagem: GitHub (loadstring compatível)
    Estilo: Modern, Deep Glass, Neon Glow, Animated
--]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local CyberNotify = {}
CyberNotify.__index = CyberNotify

-- Limpeza de instâncias antigas
if CoreGui:FindFirstChild("CyberNotifications") then
    CoreGui.CyberNotifications:Destroy()
end

-- Configurações de Cores Cyberpunk (Neon)
local THEMES = {
    success = {
        accent = Color3.fromRGB(0, 255, 157), -- Verde Neon / Ciano
        glow = Color3.fromRGB(0, 255, 157),
        icon = "rbxassetid://11419713314"
    },
    error = {
        accent = Color3.fromRGB(255, 0, 85), -- Magenta/Vermelho Neon
        glow = Color3.fromRGB(255, 0, 85),
        icon = "rbxassetid://11419719656"
    },
    warning = {
        accent = Color3.fromRGB(255, 208, 0), -- Amarelo Neon
        glow = Color3.fromRGB(255, 166, 0),
        icon = "rbxassetid://11419717158"
    },
    info = {
        accent = Color3.fromRGB(0, 162, 255), -- Azul Neon
        glow = Color3.fromRGB(0, 110, 255),
        icon = "rbxassetid://11419721028"
    }
}

function CyberNotify.new()
    local self = setmetatable({}, CyberNotify)
    
    -- ScreenGui Principal (Protegido na CoreGui)
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "CyberNotifications"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Tenta colocar na CoreGui, se falhar vai pro PlayerGui
    local success, err = pcall(function()
        self.screenGui.Parent = CoreGui
    end)
    if not success then
        self.screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Container Principal (Direita - Centro)
    self.holder = Instance.new("Frame")
    self.holder.Name = "Holder"
    self.holder.Size = UDim2.new(0, 320, 1, -60)
    self.holder.Position = UDim2.new(1, -25, 0, 30)
    self.holder.AnchorPoint = Vector2.new(1, 0)
    self.holder.BackgroundTransparency = 1
    self.holder.Parent = self.screenGui
    
    -- Layout Automático (Stacking)
    self.layout = Instance.new("UIListLayout")
    self.layout.Name = "Layout"
    self.layout.SortOrder = Enum.SortOrder.LayoutOrder
    self.layout.VerticalAlignment = Enum.VerticalAlignment.Bottom -- Novas aparecem embaixo
    self.layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    self.layout.Padding = UDim.new(0, 15) -- Espaçamento maior
    self.layout.Parent = self.holder
    
    return self
end

function CyberNotify:Notify(options)
    local titleText = options.Title or "SYSTEM"
    local messageText = options.Message or "No message provided."
    local notifType = (options.Type or "info"):lower()
    local duration = options.Duration or 5
    
    local theme = THEMES[notifType] or THEMES.info
    
    -- Calcular altura necessária para o texto da mensagem
    local labelSize = TextService:GetTextSize(
        messageText, 
        12, 
        Enum.Font.Gotham, 
        Vector2.new(250, 1000) -- Largura máxima fixa
    )
    local cardHeight = math.max(70, labelSize.Y + 45) -- Altura dinâmica

    -- [[ ESTRUTURA DA INTERFACE (UI) ]] --
    
    -- 1. Card Principal (O container com Glassmorphism)
    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(1, 0, 0, cardHeight)
    card.BackgroundColor3 = Color3.fromRGB(10, 11, 14) -- Fundo muito escuro
    card.BackgroundTransparency = 0.2 -- Transparência para efeito glass
    card.BorderSizePixel = 0
    card.Position = UDim2.new(1, 40, 0, 0) -- Começa fora da tela
    card.Parent = self.holder
    
    -- Cantos arredondados sutis (Cyberpunk é mais quadrado)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card
    
    -- 2. Neon Glow Border (Borda Brilhante)
    local glowStroke = Instance.new("UIStroke")
    glowStroke.Name = "GlowStroke"
    glowStroke.Color = theme.accent
    glowStroke.Thickness = 1.2
    glowStroke.Transparency = 0.3
    glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glowStroke.Parent = card
    
    -- 3. Efeito de Gradiente na Borda (opcional, dá mais profundidade)
    local uigradient = Instance.new("UIGradient")
    uigradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.accent),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)), -- Brilho no meio
        ColorSequenceKeypoint.new(1, theme.glow)
    })
    uigradient.Rotation = 45
    uigradient.Parent = glowStroke
    
    -- 4. Ícone do Tipo (com Glow)
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 22, 0, 22)
    icon.Position = UDim2.new(0, 12, 0, 12)
    icon.BackgroundTransparency = 1
    icon.Image = theme.icon
    icon.ImageColor3 = theme.accent -- Ícone brilha na cor do tema
    icon.Parent = card
    
    -- 5. Título (GothamBold - Estilo Moderno)
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -50, 0, 20)
    title.Position = UDim2.new(0, 42, 0, 12)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = titleText:upper() -- Cyberpunk gosta de CAPS
    title.TextColor3 = Color3.fromRGB(255, 255, 255) -- Branco Puro
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card
    
    -- 6. Mensagem (Gotham - Leitura Limpa)
    local message = Instance.new("TextLabel")
    message.Name = "Message"
    message.Size = UDim2.new(1, -50, 0, labelSize.Y)
    message.Position = UDim2.new(0, 42, 0, 32)
    message.BackgroundTransparency = 1
    message.Font = Enum.Font.Gotham
    message.Text = messageText
    message.TextColor3 = Color3.fromRGB(200, 205, 215) -- Cinza claro azulado
    message.TextSize = 12
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.Parent = card
    
    -- 7. Barra de Progresso Cyberpunk (Linha Fina Neon)
    local progBg = Instance.new("Frame")
    progBg.Name = "ProgBg"
    progBg.Size = UDim2.new(1, -20, 0, 2) -- Recuada nas bordas
    progBg.Position = UDim2.new(0, 10, 1, -8)
    progBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progBg.BackgroundTransparency = 0.9 -- Quase invisível
    progBg.BorderSizePixel = 0
    progBg.Parent = card
    
    local progBar = Instance.new("Frame")
    progBar.Name = "ProgBar"
    progBar.Size = UDim2.new(1, 0, 1, 0)
    progBar.BackgroundColor3 = theme.accent -- Cor Neon
    progBar.BorderSizePixel = 0
    progBar.Parent = progBg
    
    -- Adicionar Glow na barra de progresso (UIStroke)
    local progGlow = Instance.new("UIStroke")
    progGlow.Color = theme.glow
    progGlow.Thickness = 1
    progGlow.Transparency = 0.5
    progGlow.Parent = progBar

    -- [[ ANIMAÇÕES E LÓGICA ]] --
    
    -- Animação de Entrada: Slide + Rebote (Quart Out)
    local tweenIn = TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    })
    
    -- Animação da Borda Brilhante (Pulsar sutil)
    local tweenGlow = TweenService:Create(glowStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Transparency = 0.6 -- Pulsa entre 0.3 e 0.6
    })
    
    -- Animação da Barra de Progresso (Linear)
    local tweenProgress = TweenService:Create(progBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    })
    
    -- Iniciar Animações
    tweenIn:Play()
    tweenGlow:Play()
    tweenProgress:Play()
    
    -- Função de Fechamento Suave (Slide Out + Fade)
    local function closeNotification()
        if card and card.Parent then
            -- Para animações em andamento
            tweenGlow:Cancel()
            
            local tweenOut = TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 50, 0, 0), -- Slide out pra direita
                BackgroundTransparency = 1 -- Fade out
            })
            
            -- Fade out dos elementos internos tbm
            TweenService:Create(title, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            TweenService:Create(message, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            TweenService:Create(icon, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
            TweenService:Create(glowStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            TweenService:Create(progBar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()

            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                card:Destroy()
            end)
        end
    end
    
    -- Permitir fechar clicando na notificação
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = card
    clickBtn.MouseButton1Click:Connect(closeNotification)

    -- Timer automático
    task.delay(duration, closeNotification)
end

return CyberNotify
