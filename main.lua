local asset = game:GetObjects("rbxassetid://89745408973860")[1]
local datamodel,GUI = pcall(function() 
    return asset:IsA("ScreenGui") and asset
end)
if not GUI then return end

if getgenv().UEMS_DEBUGGER_CLEANUP then 
    getgenv().UEMS_DEBUGGER_CLEANUP()
end

getgenv().UEMS_DEBUGGER_UI = GUI
GUI.Parent = gethui()
GUI.Name = crypt.generatekey(8, 12)

type remote_type = "RemoteEvent" | "RemoteFunction" | "Kick"

local SERVICES = {
	PLAYERS = game:GetService("Players"),
	STARTERGUI = game:GetService("StarterGui"),
    RUN = game:GetService("RunService"),
}

local LocalPlayer = SERVICES.PLAYERS.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(c)
	Character = c
	HumanoidRootPart = c:WaitForChild("HumanoidRootPart")
	Humanoid = c:WaitForChild("Humanoid")
end)

local __main = GUI:WaitForChild("MAIN")
local __info = GUI:WaitForChild("INFO")
local __output = GUI:WaitForChild("OUTPUT")

local __anticheattriggercontainer = __main:WaitForChild("AnticheatTriggerContainer"):WaitForChild("Container")

local core = {
	available_index = 0;
	close = __main:WaitForChild("Close"),
    _running_ = true,
    tests = {
        velocity = false,
        walkspeed = false,
        teleport = false,
    }
	main = {
		block_kick = {
			button = __main:WaitForChild("BlockKick"),
			state = false,
		},
		block_remotes = {
			button = __main:WaitForChild("BlockRemotes"),
			state = false,
		},
		pause_resume = {
			button = __main:WaitForChild("PauseResume"),
			state = false,
		},
		
		triggers = {
			teleport = __anticheattriggercontainer:WaitForChild("TeleportTrigger"),
			velocity = __anticheattriggercontainer:WaitForChild("VelocityTrigger"),
			walkspeed = __anticheattriggercontainer:WaitForChild("WalkSpeedTrigger"),
		},
		clear = __main:WaitForChild("Clear"),
	},
	templates = {
		FUNCTION = __output:WaitForChild("ScrollingFrame"):WaitForChild("FunctionTemplate"),
		REMOTE = __output:WaitForChild("ScrollingFrame"):WaitForChild("RemoteTemplate"),
		KICK = __output:WaitForChild("ScrollingFrame"):WaitForChild("KickTemplate"),
	},
    all_remote_meta = {},
	main_connections = {},
	event_hooks = {},
	function_hooks = {},
}

local state_parser = {
	[true] = "On",
	[false] = "Off",
}

function stringifyTable(tbl, indent)
	indent = indent or 0
	local formatting = string.rep("  ", indent)
	local result = "unpack({\n"
	local keys = {}

	for k in pairs(tbl) do
		table.insert(keys, k)
	end

	table.sort(keys, function(a, b)
		if type(a) == "number" and type(b) == "number" then
			return a < b
		else
			return tostring(a) < tostring(b)
		end
	end)

	for i, k in ipairs(keys) do
		local v = tbl[k]
		local isArray = k == i
		local keyStr = (isArray and "") or ((type(k) == "string") and `["{k}"] = ` or `[${tostring(k)}] = `)
		local valueStr

		if type(v) == "table" then
			valueStr = stringifyTable(v, indent + 1)
		elseif type(v) == "string" then
			valueStr = `"{v}"`
		else
			valueStr = tostring(v)
		end

		local line = formatting .. "  " .. keyStr .. valueStr
		if i < #keys then
			line = line .. ","
		end
		result = result .. line .. "\n"
	end

	result = result .. formatting .. "})"
	return result
end

local test_variables = {
    old_speed = nil,
    velocity_index = 0,
    safe_velocity_position = nil,
    safe_teleport_position = nil,
    teleport_index = 0,
}

function core.update()
    if core.tests.walkspeed then
        if not test_variables.old_speed then
            test_variables.old_speed = Humanoid.WalkSpeed
        end 
        Humanoid.WalkSpeed = test_variables.old_speed * 25
	else
        if test_variables.old_speed then
            Humanoid.WalkSpeed = test_variables.old_speed
            test_variables.old_speed = nil
        end 
    end

    if core.tests.velocity then
        if not test_variables.safe_velocity_position then 
            test_variables.safe_velocity_position = HumanoidRootPart.CFrame
        end
        test_variables.velocity_index += 1
        local bodyVelocity = HumanoidRootPart:FindFirstChild("_test_velocity_") or Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bodyVelocity.Velocity = Vector3.new(0, 1000, 0)
		bodyVelocity.P = 100000
        bodyVelocity.Name = "_test_velocity_"
		bodyVelocity.Parent = HumanoidRootPart
		
        bodyVelocity.Velocity = Vector3.new(
			math.random(-300 - test_variables.velocity_index, 300 + test_variables.velocity_index),
			math.random(300 + test_variables.velocity_index, 600 + test_variables.velocity_index),
			math.random(-300 - test_variables.velocity_index, 300 + test_variables.velocity_index)
		)
	else
        local test_vel = HumanoidRootPart:FindFirstChild("_test_velocity_")
        if test_vel then
            test_vel:Destroy()
            test_variables.velocity_index = 0
            HumanoidRootPart.CFrame = test_variables.safe_velocity_position
            test_variables.safe_velocity_position = nil
        end 
    end

    if core.tests.teleport then
        if not test_variables.safe_teleport_position then 
            test_variables.safe_teleport_position = HumanoidRootPart.CFrame
        end
        test_variables.teleport_index += 1
        HumanoidRootPart.CFrame *= CFrame.new(0,0,-test_variables.teleport_index)
	else
        if test_variables.safe_teleport_position then
            HumanoidRootPart.CFrame = test_variables.safe_teleport_position
            test_variables.safe_teleport_position = nil
        end 
    end
end

function core.set_info(FullName : string, Arguments : string)
	__info:WaitForChild("InfoContainer"):WaitForChild("ScrollingFrame"):WaitForChild("Args").Text = Arguments
	__info:WaitForChild("InfoContainer"):WaitForChild("FullName").Text = FullName
end

function core.add_hook(remote : RemoteEvent? | RemoteFunction?, remote_type : remote_type, ...)
	if remote_type == "RemoteEvent" then
		core.event_hooks[remote] = {
            exclude = false,
			CALLS = {
			}
		}	
		core.event_hooks[remote].add = function(...)
			core.available_index += 1
			local Arguments = {...}
			local ReadableArgs = stringifyTable(Arguments)
			core.event_hooks[remote].CALLS[core.available_index] = {
				ReadableArgs = ReadableArgs,
				conn = nil,
			}

			local new_event_template = core.templates.REMOTE:Clone()
			new_event_template:RemoveTag("template")
            
			local success, fullName = pcall(function()
	            return remote:GetFullName()
            end)
            fullName = success and fullName or "[Destroyed Remote]"
            new_event_template.FullName.Text = fullName
            
			core.event_hooks[remote].CALLS[core.available_index].conn = new_event_template.Info.MouseButton1Click:Connect(function()
				core.set_info(fullName, ReadableArgs)
			end)

            core.event_hooks[remote].exclude_conn = new_event_template.Exclude.MouseButton1Click:Connect(function() 
                core.event_hooks[remote].exclude = true
            end)
			new_event_template.Parent = __output:WaitForChild("ScrollingFrame")
			new_event_template.Visible = true
		end
		return core.event_hooks[remote]
	elseif remote_type == "RemoteFunction" then
		core.function_hooks[remote] = {
            exclude = false,
			CALLS = {
			}
		}	
		core.function_hooks[remote].add = function(...)
			core.available_index += 1
			local Arguments = {...}
			local ReadableArgs = stringifyTable(Arguments)
			core.function_hooks[remote].CALLS[core.available_index] = {
				ReadableArgs = ReadableArgs,
			}
			
			local new_event_template = core.templates.FUNCTION:Clone()
			new_event_template:RemoveTag("template")
			local success, fullName = pcall(function()
	            return remote:GetFullName()
            end)
            fullName = success and fullName or "[Destroyed Remote]"
            new_event_template.FullName.Text = fullName

			core.function_hooks[remote].CALLS[core.available_index].conn = new_event_template.Info.MouseButton1Click:Connect(function()
                core.set_info(fullName, ReadableArgs)
			end)
            core.function_hooks[remote].exclude_conn = new_event_template.Exclude.MouseButton1Click:Connect(function() 
                core.function_hooks[remote].exclude = true
            end)

			new_event_template.Parent = __output:WaitForChild("ScrollingFrame")
			new_event_template.Visible = true
		end
		return core.function_hooks[remote]
	else
		local new_event_template = core.templates.KICK:Clone()
		new_event_template:RemoveTag("template")
		new_event_template.FullName.Text = string.format(":Kick('%s')", unpack({...}))
		new_event_template.Parent = __output:WaitForChild("ScrollingFrame")
		new_event_template.Visible = true
		return
	end
end

function clear()
	for _, remote_table in core.event_hooks do
        if remote_table.exclude_conn then
            remote_table.exclude_conn:Disconnect()
        end
		for _, call in remote_table.CALLS do
            if call and call.conn == nil then continue end
			call.conn:Disconnect()
			call = nil
		end
	end
    for _, remote_table in core.function_hooks do
        if remote_table.exclude_conn then
            remote_table.exclude_conn:Disconnect()
        end
		for _, call in remote_table.CALLS do
            if call and call.conn == nil then continue end
			call.conn:Disconnect()
			call = nil
		end
	end
	for _, kid in __output:WaitForChild("ScrollingFrame"):GetChildren() do
		if not kid:IsA("UIGridLayout") and not kid:HasTag("template") then
			kid:Destroy()
		end
	end
end

getgenv().UEMS_DEBUGGER_CLEANUP = function()
	core._running_ = false
	for _,conn in core.main_connections do 
		conn:Disconnect()
	end
    
	clear()
	if getgenv().UEMS_DEBUGGER_UI then 
        getgenv().UEMS_DEBUGGER_UI:Destroy()
    end
end

function setup_remote_hooks()
	--[[ do in executor ]]
    local old;
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...) 
        if checkcaller() then return old(self, ...) end
        if not core._running_ or core.main.pause_resume.state == false then 
            return old(self, ...)
        end
        setthreadidentity(8)
        local method = getnamecallmethod()
        local self_type = method and (method == "FireServer" and "RemoteEvent" or method == "InvokeServer" and "RemoteFunction" or method == "Kick" and "Kick") or nil       
 
        if self_type ~= "Kick" and self_type ~= nil then 
            local RemoteMeta = core.all_remote_meta[self]
            if not RemoteMeta then
                if self_type == "RemoteEvent" then 
                    core.all_remote_meta[self] = core.add_hook(self, "RemoteEvent")
                elseif self_type == "RemoteFunction" then 
                    core.all_remote_meta[self] = core.add_hook(self, "RemoteFunction")
                end
            elseif RemoteMeta.exclude then
                return old(self, ...)  
            end
            RemoteMeta = core.all_remote_meta[self]
            if core.main.block_remotes.state == true then
                if core.all_remote_meta[self] then 
                    RemoteMeta.add(...) 
                end
                return
            end
        elseif self_type == "Kick" and self_type ~= nil then
            if core.main.block_kick.state == true then
                core.add_hook(nil,"Kick", ...)
                return
            end
        end
        
        return old(self, ...)
    end))
end

function main()
	core.main_connections.bkick = core.main.block_kick.button.MouseButton1Click:Connect(function()
		core.main.block_kick.state = not core.main.block_kick.state
		core.main.block_kick.button.BackgroundColor3 = core.main.block_kick.button[state_parser[core.main.block_kick.state]].Value
		core.main.block_kick.button.Outline.BackgroundColor3 = core.main.block_kick.button.Outline[state_parser[core.main.block_kick.state]].Value	
	end)
	
	core.main_connections.bremotes = core.main.block_remotes.button.MouseButton1Click:Connect(function()
		core.main.block_remotes.state = not core.main.block_remotes.state
		
		core.main.block_remotes.button.BackgroundColor3 = core.main.block_remotes.button[state_parser[core.main.block_remotes.state]].Value
		core.main.block_remotes.button.Outline.BackgroundColor3 = core.main.block_remotes.button.Outline[state_parser[core.main.block_remotes.state]].Value
	end)
	
	core.main_connections.presume = core.main.pause_resume.button.MouseButton1Click:Connect(function()
		core.main.pause_resume.state = not core.main.pause_resume.state

		core.main.pause_resume.button.BackgroundColor3 = core.main.pause_resume.button[state_parser[core.main.pause_resume.state]].Value
		core.main.pause_resume.button.Outline.BackgroundColor3 = core.main.pause_resume.button.Outline[state_parser[core.main.pause_resume.state]].Value
		if core.main.pause_resume.state == true then 
			core.main.pause_resume.button.Text = "Running"
		else
			core.main.pause_resume.button.Text = "Paused"
		end
	end)
	
	core.main_connections.cremote = core.close.MouseButton1Click:Connect(function()
        if getgenv().UEMS_DEBUGGER_CLEANUP then 
            getgenv().UEMS_DEBUGGER_CLEANUP()
        end
	end)
	
	-- -- --
	
	core.main_connections.teleportt = core.main.triggers.teleport.MouseButton1Click:Connect(function()
        core.tests.teleport = true
		task.delay(4, function() 
            core.tests.teleport = false
		end)
	end)

	core.main_connections.velocityt = core.main.triggers.velocity.MouseButton1Click:Connect(function()
        core.tests.velocity = true
		task.delay(4, function() 
            core.tests.velocity = false
		end)
	end)

	core.main_connections.walkst = core.main.triggers.walkspeed.MouseButton1Click:Connect(function()
        core.tests.walkspeed = true
		task.delay(4, function() 
            core.tests.walkspeed = false
		end)
	end)

	-- -- --
	
	core.main_connections.cargs = __info:WaitForChild("CopyArgs").MouseButton1Click:Connect(function()
		setclipboard(__info:WaitForChild("InfoContainer"):WaitForChild("ScrollingFrame"):WaitForChild("Args").Text)
		SERVICES.STARTERGUI:SetCore("SendNotification", {
			Title = "Exploit Creation Suite",
			Text = "Copied Arguments to Clipboard",
			Duration = 1.5
		})
	end)
	
	core.main_connections.cfullname = __info:WaitForChild("CopyPath").MouseButton1Click:Connect(function()
	    setclipboard(__info:WaitForChild("InfoContainer"):WaitForChild("FullName").Text)
		SERVICES.STARTERGUI:SetCore("SendNotification", {
			Title = "Exploit Creation Suite",
			Text = "Copied Path to Clipboard",
			Duration = 1.5
		})	
	end)
	
	core.main_connections.clear = core.main.clear.MouseButton1Click:Connect(function()
        if getgenv().UEMS_DEBUGGER_CLEANUP then 
            getgenv().UEMS_DEBUGGER_CLEANUP()
        end
	end)
	SERVICES.STARTERGUI:SetCore("SendNotification", {
			Title = "Debugger",
			Text = "Loaded Succesfully!",
			Duration = 1.5
		})

    core.main_connections.run = SERVICES.RUN.RenderStepped:Connect(function() 
        core.update()
    end)

	setup_remote_hooks()
    	
end

main()
