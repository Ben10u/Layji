if not game:IsLoaded() then 
	game.Loaded:Wait() 
end

if game.PlaceId == 110829983956014 then
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local rootPart = character:WaitForChild("HumanoidRootPart")
	local HiddenFlags = {}

	local function MoveTo(pos, increment)
		if HiddenFlags.CurrentlyMoving then return end
		HiddenFlags.CurrentlyMoving = true

		local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local Root = Char:FindFirstChild("HumanoidRootPart")
		local Increment = increment or shared.Speed or 10

		local function IncrementalMove(start_pos, end_pos)
			local offset = end_pos - start_pos
			local distance = offset.Magnitude
			local direction = offset.Unit
			local currentPos = start_pos

			while shared.AutoEgg and distance > Increment do
				currentPos += direction * Increment
				Root.CFrame = CFrame.new(currentPos)
				Root.AssemblyLinearVelocity = Vector3.zero
				task.wait()
				offset = end_pos - currentPos
				distance = offset.Magnitude
			end

			if not shared.AutoEgg then return end
			Root.CFrame = CFrame.new(end_pos)
		end

		if Char and Root then
			local currentPos = Root.Position
			local downPos = Vector3.new(currentPos.X, pos.Y, currentPos.Z)
			local acrossPos = Vector3.new(pos.X, pos.Y, pos.Z)
			local finalPos = pos

			IncrementalMove(currentPos, downPos)
			IncrementalMove(downPos, acrossPos)
			IncrementalMove(acrossPos, finalPos)
		end

		HiddenFlags.CurrentlyMoving = false
	end


	local function Wait(delayTime)
		local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local Root = Char:FindFirstChild("HumanoidRootPart")
		local StartTime = tick()

		if Char and Root then
			local InitCFrame = Root.CFrame

			task.spawn(function()
				while shared.AutoEgg and tick() - StartTime <= (delayTime or 1) do
					for _, v in Char:GetDescendants() do
						if v:IsA("BasePart") or v:IsA("MeshPart") then
							v.CanCollide = false
						end
					end
					Root.CFrame = InitCFrame
					Root.AssemblyLinearVelocity = Vector3.zero
					task.wait()
				end
			end)

			while shared.AutoEgg and tick() - StartTime <= (delayTime or 1) do
				task.wait(1/60)
			end
		end
	end

	local function GetClosestEgg()
		local closestEgg = nil
		local shortestDistance = math.huge

		for _, v in pairs(workspace:GetChildren()) do
			if v:IsA("Model") and v.Name:lower():find("egg") then
				local pos = v:GetPivot().Position
				local dist = (rootPart.Position - pos).Magnitude

				if dist < shortestDistance then
					shortestDistance = dist
					closestEgg = v
				end
			end
		end

		return closestEgg
	end

	local PlaceID = game.PlaceId
	local AllIDs = {}
	local foundAnything = ""
	local actualHour = os.date("!*t").hour
	local Deleted = false
	local File = pcall(function()
		AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
	end)
	if not File then
		table.insert(AllIDs, actualHour)
		writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
	end
	function TPReturner()
		local Site;
		if foundAnything == "" then
			Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
		else
			Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
		end
		local ID = ""
		if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
			foundAnything = Site.nextPageCursor
		end
		local num = 0;
		for i,v in pairs(Site.data) do
			local Possible = true
			ID = tostring(v.id)
			if tonumber(v.maxPlayers) > tonumber(v.playing) then
				for _,Existing in pairs(AllIDs) do
					if num ~= 0 then
						if ID == tostring(Existing) then
							Possible = false
						end
					else
						if tonumber(actualHour) ~= tonumber(Existing) then
							local delFile = pcall(function()
								delfile("NotSameServers.json")
								AllIDs = {}
								table.insert(AllIDs, actualHour)
							end)
						end
					end
					num = num + 1
				end
				if Possible == true then
					table.insert(AllIDs, ID)
					wait()
					pcall(function()
						writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
						wait()
						game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
					end)
					wait(4)
				end
			end
		end
	end

	function Teleport()
		while wait() do
			pcall(function()
				TPReturner()
				if foundAnything ~= "" then
					TPReturner()
				end
			end)
		end
	end

	for _, v in pairs(Players:GetPlayers()) do
		if v.Name == "Sthai073" then
			Teleport()
		end
	end

	while shared.AutoEgg do
		local egg = GetClosestEgg()

		if egg then
			MoveTo(egg:GetPivot().Position)
			Wait(.15)

			for _, part in pairs(egg:GetDescendants()) do
				if part:IsA("ProximityPrompt") then
					fireproximityprompt(part)
				end
			end
		else
			if shared.autoHop then 
				Teleport()
			end
		end

		task.wait(.1)
	end
end
