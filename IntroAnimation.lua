-- @lightgray2 - OpenSource --
-- Usage: https://pastebin.com/KAKkbuxr
local createTextAnimation = function(settings)
	local TweenService = game:GetService("TweenService")
	local CoreGui = game:GetService("CoreGui")
	local Lighting = game:GetService("Lighting")
	local SoundService = game:GetService("SoundService")

	local mainText = settings.MainText or "Insert above text.."
	local descText = settings.Desc or "Insert below text.."
	local duration = settings.Duration or 4
	local typeSpeed = settings.Speed or 19
	local lineSpeed = settings.Linespeed or 4
	local fontAbove = Enum.Font[settings.FontAbove or "Code"]
	local fontBelow = Enum.Font[settings.FontBelow or "Code"]
	local sfx = settings.SFX or "rbxassetid://18237017685"
	local sfxVolume = settings["Vol.SFX"] or 2
	local blurEnabled = settings.Blur == true
	local theme = (settings.Themes or ""):lower()
	local wrapMain = settings.WrapMain ~= false
	local wrapDesc = settings.WrapDesc ~= false
	local customText = settings.CustomText == true
	local showProgress = settings.Progress == true
	local lineSize = settings.Size or (#mainText * 18)

	local themeColor = Color3.fromRGB(255, 255, 255)
	if theme == "neon" then themeColor = Color3.fromRGB(0, 255, 136)
	elseif theme == "danger" then themeColor = Color3.fromRGB(255, 50, 50)
	elseif theme == "cool" then themeColor = Color3.fromRGB(100, 200, 255)
	elseif theme == "sunset" then themeColor = Color3.fromRGB(255, 175, 100)
	end

	local blur
	if blurEnabled then
		blur = Instance.new("BlurEffect")
		blur.Size = 0
		blur.Parent = Lighting
		TweenService:Create(blur, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 20 }):Play()
	end

	local function playTypeSound()
		local sound = Instance.new("Sound")
		sound.SoundId = sfx
		sound.Volume = sfxVolume
		sound.Parent = SoundService
		sound:Play()
		game.Debris:AddItem(sound, 2)
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.Parent = CoreGui

	local centerLine = Instance.new("Frame")
	centerLine.AnchorPoint = Vector2.new(0.5, 0.5)
	centerLine.Position = UDim2.new(0.5, 0, 0.5, 0)
	centerLine.Size = UDim2.new(0, 0, 0, 4)
	centerLine.BackgroundColor3 = themeColor
	centerLine.BorderSizePixel = 0
	centerLine.Parent = screenGui

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 1)
	title.Position = UDim2.new(0.5, 0, 0.5, -10)
	title.Size = UDim2.new(0, lineSize, 0, 50)
	title.Text = customText and mainText or ""
	title.RichText = customText
	title.TextColor3 = themeColor
	title.BackgroundTransparency = 1
	title.Font = fontAbove
	title.TextWrapped = wrapMain
	title.TextScaled = not customText
	title.Parent = screenGui

	local desc = Instance.new("TextLabel")
	desc.AnchorPoint = Vector2.new(0.5, 0)
	desc.Position = UDim2.new(0.5, 0, 0.5, 20)
	desc.Size = UDim2.new(0, lineSize, 0, 100)
	desc.Text = customText and descText or ""
	desc.RichText = customText
	desc.TextColor3 = themeColor
	desc.BackgroundTransparency = 1
	desc.Font = fontBelow
	desc.TextWrapped = wrapDesc
	desc.TextXAlignment = Enum.TextXAlignment.Center
	desc.TextYAlignment = Enum.TextYAlignment.Top
	desc.TextScaled = not customText
	desc.Parent = screenGui

	local function animateLine(size)
		local tween = TweenService:Create(centerLine, TweenInfo.new(1 / lineSpeed, Enum.EasingStyle.Sine), {
			Size = UDim2.new(0, size, 0, 4)
		})
		tween:Play()
		tween.Completed:Wait()
	end

	local function animateLineBack()
		local tween = TweenService:Create(centerLine, TweenInfo.new(1 / lineSpeed, Enum.EasingStyle.Sine), {
			Size = UDim2.new(0, 0, 0, 4)
		})
		tween:Play()
		tween.Completed:Wait()
	end

	local function typewrite(label, text)
		label.Text = ""
		for i = 1, #text do
			label.Text = string.sub(text, 1, i)
			playTypeSound()
			task.wait(1 / typeSpeed)
		end
	end

	local function reverseTypewrite(label)
		for i = #label.Text, 1, -1 do
			label.Text = string.sub(label.Text, 1, i - 1)
			playTypeSound()
			task.wait(1 / typeSpeed)
		end
	end
	coroutine.wrap(function()
		animateLine(lineSize)

		if not customText then
			typewrite(title, mainText)
			typewrite(desc, descText)
		end

		if showProgress then
			TweenService:Create(centerLine, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
				Size = UDim2.new(0, 0, 0, 4)
			}):Play()
			wait(duration)
		else
			wait(duration)
			if not customText then
				reverseTypewrite(desc)
				reverseTypewrite(title)
			end
			animateLineBack()
		end

		if blur then
			TweenService:Create(blur, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = 0 }):Play()
			task.delay(0.4, function() blur:Destroy() end)
		end
		screenGui:Destroy()
	end)()
end

return createTextAnimation