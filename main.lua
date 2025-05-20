
if getgenv().UEMS_UI then 
    getgenv().UEMS_UI:Destroy()
    getgenv().UEMS_UI = nil
end

getgenv().UEMS_LOADSTRINGS = {
    ["Dex"] = "https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua",
	["InfiniteYield"] = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
	["SimpleSpy"] = "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua",
	["Hydroxide"] = "_hydroxide_custom_",
	["AnticheatDebugger"] = "https://raw.githubusercontent.com/lordishow/suiteMaster/refs/heads/main/debugger.lua",
	["Bypasses"] = "https://raw.githubusercontent.com/lordishow/suiteMaster/refs/heads/main/bypasses.lua",
}

local StarterGui = game:GetService("StarterGui")

StarterGui:SetCore("SendNotification", {
    Title = "Suite",
    Text = "Loading User Interface",
    Duration = 5
})

local asset = game:GetObjects("rbxassetid://100247930854587")[1]
local datamodel,GUI = pcall(function() 
    return asset:IsA("ScreenGui") and asset
end)
print(datamodel, GUI)
if datamodel and GUI then 
    getgenv().UEMS_UI = GUI
    local _logic_ = {}
    local _main = GUI:WaitForChild("MAIN")	

    local core = {
        CREATION = _main:WaitForChild("CREATION"),
        DEBUGGING = _main:WaitForChild("DEBUGGING"),
        CLOSE = _main:WaitForChild("Close"),
        creation_buttons = {
            DEX = _main:WaitForChild("CREATION"):WaitForChild("Container"):WaitForChild("Dex"):WaitForChild("TextButton"),
            HYDROXIDE = _main:WaitForChild("CREATION"):WaitForChild("Container"):WaitForChild("Hydroxide"):WaitForChild("TextButton"),
            INFINITEYIELD = _main:WaitForChild("CREATION"):WaitForChild("Container"):WaitForChild("InfiniteYield"):WaitForChild("TextButton"),
            SIMPLESPY = _main:WaitForChild("CREATION"):WaitForChild("Container"):WaitForChild("SimpleSpy"):WaitForChild("TextButton"),
        },
        debugging_buttons = {
            ANTICHEATDEBUGGER = _main:WaitForChild("DEBUGGING"):WaitForChild("Container"):WaitForChild("AnticheatDebugger"):WaitForChild("TextButton"),
            BYPASSES = _main:WaitForChild("DEBUGGING"):WaitForChild("Container"):WaitForChild("Bypasses"):WaitForChild("TextButton"),
        }
    }

    function _logic_.load_module(string_to_load : string)
        if string_to_load ~= "_hydroxide_custom_" then
            loadstring(game:HttpGet(string_to_load))()
        else
            local owner = "Upbolt"
            local branch = "revision"

            local function webImport(file)
                return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
            end

            webImport("init")
            webImport("ui/main")
        end
    end

    function _logic_.init()
        local obfuscated_name = crypt.generatekey(math.random(8, 12))
        GUI.Name = obfuscated_name
        GUI.Parent = gethui()
        local LOADSTRINGS = getgenv().UEMS_LOADSTRINGS
        
        core.creation_buttons.DEX.MouseButton1Up:Connect(function()
            _logic_.load_module(LOADSTRINGS["Dex"])
        end)
        core.creation_buttons.SIMPLESPY.MouseButton1Up:Connect(function()
            _logic_.load_module(LOADSTRINGS["SimpleSpy"])
        end)
        core.creation_buttons.HYDROXIDE.MouseButton1Up:Connect(function()
            _logic_.load_module(LOADSTRINGS["Hydroxide"])
        end)
        core.creation_buttons.INFINITEYIELD.MouseButton1Up:Connect(function()
            _logic_.load_module(LOADSTRINGS["InfiniteYield"])
        end)
        core.debugging_buttons.ANTICHEATDEBUGGER.MouseButton1Up:Connect(function()
            _logic_.load_module(LOADSTRINGS["AnticheatDebugger"]) 
        end)
        core.debugging_buttons.BYPASSES.MouseButton1Up:Connect(function()
            _logic_.load_module(LOADSTRINGS["Bypasses"])
        end)
        core.CLOSE.MouseButton1Up:Connect(function()
            GUI:Destroy()
        end)
    end

    _logic_.init()
else
    pcall(print, meta, asset)
end

