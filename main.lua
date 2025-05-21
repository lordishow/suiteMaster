-- IY | DARK DEX | SIMPLE SPY | HYDROXIDE
-- BYPASSES | ANTICHEAT DEBUGGER |
local asset = game:GetObjects("rbxassetid://107332755935455")[1]
local datamodel,GUI = pcall(function() 
    return asset:IsA("ScreenGui") and asset
end)
if not GUI then return end
GUI.Enabled = true
GUI.Parent = gethui()
GUI.Name = crypt.generatekey(10,20)

if getgenv().UEMS_MAIN_CLEANUP then 
    getgenv().UEMS_MAIN_CLEANUP()
end

local CUSTOM_CREATION = {
	["Infinite Yield"] = function() 
		loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
	end,
	["Dark Dex"] = function() 
		loadstring(game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua", true))()
	end,
	["Simple Spy"] = function() 
		loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
	end,
	["Hydroxide"] = function() 
		local owner = "Upbolt"
		local branch = "revision"

		local function webImport(file)
			return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
		end

		webImport("init")
		webImport("ui/main")
	end,
}

local CUSTOM_DEBUGGING = {
	["BYPASSES"] = function() 
		loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/lordishow/suiteMaster/refs/heads/main/bypasses.lua"))()
	end,
	["Anti-Cheat Debugger"] = function() 
		loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/lordishow/suiteMaster/refs/heads/main/debugger.lua"))()
	end,
}

local __MAIN = GUI:WaitForChild("MAIN")
local __CREATION = __MAIN:WaitForChild("CREATION")
local __DEBUGGING = __MAIN:WaitForChild("DEBUGGING")

local core = {
	CLOSE = __MAIN:WaitForChild("Close"),
	creation = {
		TEMPLATE = __CREATION:WaitForChild("Container"):WaitForChild("Template")
	},
	debugging = {
		TEMPLATE = __DEBUGGING:WaitForChild("Container"):WaitForChild("Template")
	},
	main_connections = {}
}

getgenv().UEMS_MAIN_CLEANUP = function()
	if core.main_connections and #core.main_connections> 0 then
		for _, conn in core.main_connections do 
			conn:Disconnect()
		end
	end
	GUI:Destroy()
	getgenv().UEMS_MAIN_CLEANUP = nil
end

function core.add_creation_button(name, func)
	local New_Template = core.creation.TEMPLATE:Clone()
	New_Template.Parent = __CREATION:WaitForChild("Container")
	New_Template.Name = name
	New_Template.TextButton.Text = name
	New_Template.Visible = true
	core.main_connections[tostring(crypt.generatekey(10,20))] = New_Template.TextButton.MouseButton1Click:Connect(func)
end

function core.add_debugging_button(name, func)
	local New_Template = core.debugging.TEMPLATE:Clone()
	New_Template.Parent = __CREATION:WaitForChild("Container")
	New_Template.Name = name
	New_Template.TextButton.Text = name
	New_Template.Visible = true
	core.main_connections[tostring(crypt.generatekey(10,20))] = New_Template.TextButton.MouseButton1Click:Connect(func)
end

local function main()
	for name, load in CUSTOM_CREATION do 
		core.add_creation_button(name, load)
	end
	for name, load in CUSTOM_DEBUGGING do 
		core.add_debugging_button(name, load)
	end
end

main()
