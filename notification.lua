local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local NotificationLib = {}
NotificationLib.__index = NotificationLib

-- Remover instância anterior se já existir (para evitar duplicação ao reexecutar)
if CoreGui:FindFirstChild("ModernNotifications") then
    CoreGui.ModernNotifications:Destroy()
end

-- Configuração de Cores & Temas
local THEMES = {
    success = {
        accent = Color3.fromRGB(16, 185, 129),
        icon = "rbxassetid://6023426915" -- Ícone de check
    },
    error = {
        accent = Color3.fromRGB(239, 68, 68),
        icon = "rbxassetid://6023426915" -- Ícone de erro/fechar
    },
    warning = {
        accent = Color3.fromRGB(245, 158, 11),
        icon = "rbxassetid://6023426915"
    },
    info = {
        accent = Color3.fromRGB(59, 130, 246),
        icon = "rbxassetid://6023426915"
    }
}

function NotificationLib.new()
    local self = setmetatable({}, NotificationLib)
    
    -- ScreenGui na CoreGui (Protegido do jogo)
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "ModernNotifications"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Proteção contra detecção básica em alguns executores
    pcall(function()
        self.screenGui.Parent = CoreGui
    end)
    if not self.screenGui.Parent then
        self.screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Holder / Container no canto superior direito
    self.holder = Instance.new("Frame")
    self.holder.Name = "Holder"
    self.holder.Size = UDim2.new(0, 340, 1, -40)
    self.holder.Position = UDim2.new(1, -20, 0, 20)
    self.holder.AnchorPoint = Vector2.new(1, 0)
    self.holder.BackgroundTransparency = 1
    self.holder.Parent = self.screenGui
    
    self.layout = Instance.new("UIListLayout")
    self.layout.Name = "Layout"
    self.layout.SortOrder = Enum.SortOrder.LayoutOrder
    self.layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    self.layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    self.layout.Padding = UDim.new(0, 10)
    self.layout.Parent = self.holder
    
    return self
end

function NotificationLib:Notify(options)
    local titleText = options.Title or "Notificação"
    local messageText = options.Message or ""
    local notifType = options.Type or "info"
    local duration = options.Duration or 4
    
    local theme = THEMES[notifType] or THEMES.info
    
    -- Card Principal
    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(1, 0, 0, 65)
    card.BackgroundColor3 = Color3.fromRGB(22, 27, 34) -- Estilo Discord/GitHub Dark
    card.BackgroundTransparency = 0.1
    card.BorderSizePixel = 0
    card.Position = UDim2.new(1, 50, 0, 0)
    card.Parent = self.holder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.88
    stroke.Thickness = 1
    stroke.Parent = card
    
    -- Barra Lateral Accent
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, -16)
    accent.Position = UDim2.new(0, 8, 0, 8)
    accent.BackgroundColor3 = theme.accent
    accent.BorderSizePixel = 0
    accent.Parent = card
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accent
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -35, 0, 20)
    title.Position = UDim2.new(0, 24, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(240, 246, 252)
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card
    
    -- Mensagem
    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(1, -35, 0, 24)
    message.Position = UDim2.new(0, 24, 0, 30)
    message.BackgroundTransparency = 1
    message.Font = Enum.Font.Gotham
    message.Text = messageText
    message.TextColor3 = Color3.fromRGB(139, 148, 158)
    message.TextSize = 11
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.Parent = card
    
    -- Barra de Progresso inferior
    local progBg = Instance.new("Frame")
    progBg.Size = UDim2.new(1, 0, 0, 2)
    progBg.Position = UDim2.new(0, 0, 1, -2)
    progBg.BackgroundColor3 = Color3.fromRGB(33, 38, 45)
    progBg.BorderSizePixel = 0
    progBg.Parent = card
    
    local progBar = Instance.new("Frame")
    progBar.Size = UDim2.new(1, 0, 1, 0)
    progBar.BackgroundColor3 = theme.accent
    progBar.BorderSizePixel = 0
    progBar.Parent = progBg
    
    -- Animação de Entrada
    TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    -- Animação da Barra de Progresso
    TweenService:Create(progBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()
    
    -- Função de Fechamento Suave
    task.delay(duration, function()
        if card and card.Parent then
            local tweenOut = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 50, 0, 0),
                BackgroundTransparency = 1
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

return NotificationLib
