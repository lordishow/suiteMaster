local asset = game:GetObjects("rbxassetid://85089109830455")[1]
local datamodel,GUI = pcall(function() 
    return asset:IsA("ScreenGui") and asset
end)
if not GUI then return end

if getgenv().UEMS_BYPASSES_CLEANUP then 
    getgenv().UEMS_BYPASSES_CLEANUP()
end

GUI.Parent = gethui()
GUI.Name = crypt.generatekey(8, 12)

local SERVICES = {
	STARTERGUI = game:GetService("StarterGui")
}

local _BYPASSES_ = {
	["Adonis"] = function()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua'))()
	end,
}

local core = {
	CLOSE = GUI:WaitForChild("MAIN"):WaitForChild("Close"),
	TEMPLATE = GUI:WaitForChild("MAIN"):WaitForChild("Container"):WaitForChild("Template")
}

getgenv().UEMS_BYPASSES_CLEANUP = function() 
	GUI:Destroy()
	getgenv().UEMS_BYPASSES_CLEANUP = nil
end

function core:CreateTemplate(bypass_name, bypass_function)
	local new_temp = core.TEMPLATE:Clone()
	new_temp.Parent = GUI:WaitForChild("MAIN"):WaitForChild("Container")
	new_temp.Visible = true
	new_temp:WaitForChild("TextButton").Text = bypass_name
	new_temp:WaitForChild("TextButton").MouseButton1Click:Connect(bypass_function)
end

local function main()
	for _, bypass in _BYPASSES_ do
		core:CreateTemplate(_, bypass)
	end
	core.CLOSE.MouseButton1Click:Connect(function() 
		GUI:Destroy()
	end)

	SERVICES.STARTERGUI:SetCore("SendNotification", {
			Title = "Bypasses",
			Text = "Loaded Succesfully!",
			Duration = 1.5
		})
end

main()
