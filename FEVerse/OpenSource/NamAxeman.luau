-- [[ Nam Axeman : Reanimate ]] --

local Directories = {
	Main = "FEVerse/",
	RBXMs = "FEVerse/RBXMs/",
}

local NeckAccessories = {
	88886554182275,
	90788603154080,
	120111604252410,
	128893482026011,
	87291559615126,
}

local Settings = {
	CharacterName = "NamAxeman",
	AxeModel = 16471816474,
	HatDrop = true,
	PredictionFling = true,
	Frequency = 6,
	Amplification = 6,
	FrontOffset = 2.5,
}

local FEManager = loadstring(game:HttpGet("https://gist.githubusercontent.com/MelonsStuff/a003ea305dd302eab1f8d372daed38b4/raw/9db59962b28555fd699a7c29891efb85d45677ab/gistfile1.txt"))()
for i, v in pairs(Directories) do FEManager.EnsureFolder(v) end

do
	local Accessories = {}
	local Aligns = {}
	local Attachments = {}
	local BindableEvent = nil
	local Blacklist = {}
	local Character = nil
	local CurrentCamera = nil
	local Rig = nil
	local RigHumanoid = nil
	local RigHumanoidRootPart = nil

	local CFrame = CFrame
	local CFrameidentity = CFrame.identity
	local CFramelookAt = CFrame.lookAt
	local CFramenew = CFrame.new
	local Vector3 = Vector3
	local Vector3new = Vector3.new
	local Color3 = Color3
	local Instance = Instance
	local game = game
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local Workspace = game:GetService("Workspace")
	local RunService = game:GetService("RunService")
	local StarterGui = game:GetService("StarterGui")
	local UserInputService = game:GetService("UserInputService")

	local PostSimulation = RunService.PostSimulation
	local PreRender = RunService.PreRender
	local PreSimulation = RunService.PreSimulation
	local CharacterAdded = LocalPlayer.CharacterAdded
	local Mouse = LocalPlayer:GetMouse()

	local function FindFirstChildOfClassAndName(Parent, ClassName, Name)
		for _, Child in ipairs(Parent:GetChildren()) do
			if Child:IsA(ClassName) and Child.Name == Name then
				return Child
			end
		end
	end

	local function DetectNeckAccessories()
		local detected = {}
		for _, child in ipairs(Character:GetChildren()) do
			if child:IsA("Accoutrement") then
				local handle = FindFirstChildOfClassAndName(child, "BasePart", "Handle")
				if handle then
					for _, id in ipairs(NeckAccessories) do
						table.insert(detected, handle)
					end
				end
			end
		end
		return detected
	end

	local function OnCharacterAdded(NewCharacter)
		if NewCharacter ~= Rig then
			Character = NewCharacter
			table.clear(Aligns)
			table.clear(Blacklist)

			local HRP = Character:WaitForChild("HumanoidRootPart")
			local Humanoid = Character:WaitForChild("Humanoid")

			RigHumanoidRootPart.CFrame = HRP.CFrame

			local NeckAccs = DetectNeckAccessories()

			for _, neck in ipairs(NeckAccs) do
				table.insert(Aligns, {
					Part0 = neck,
					Part1 = RigHumanoidRootPart,
					Offset = CFrameidentity
				})
			end

			if Settings.HatDrop then
				task.spawn(function()
					HRP.AssemblyLinearVelocity = Vector3new(0, 27, 0)
					while Character and Humanoid.Health > 0 do
						HRP.CFrame = RigHumanoidRootPart.CFrame
						HRP.AssemblyLinearVelocity = Vector3new(0, 27, 0)
						task.wait()
					end
				end)
			end

			Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
		end
	end

	local function OnPostSimulation()
		if not OptionsSetCharacter and Rig and RigHumanoid then
			RigHumanoid:Move(Humanoid.MoveDirection)
			RigHumanoid.Jump = Humanoid.Jump
		end

		local Axis = 27 + math.sin(tick())

		for _, align in ipairs(Aligns) do
			local Part0 = align.Part0
			local Part1 = align.Part1

			if Part0.ReceiveAge == 0 and Part0:IsDescendantOf(Workspace) then
				Part0.AssemblyAngularVelocity = Vector3new(0, 0, 0)
				local LinearVelocity = Part1.AssemblyLinearVelocity * Axis
				Part0.AssemblyLinearVelocity = Vector3new(LinearVelocity.X, Axis, LinearVelocity.Z)
				Part0.CFrame = Part1.CFrame * align.Offset
			end
		end
	end

	local function OnInputBegan(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local target = Mouse.Target
			if target then
				local model = target:FindFirstAncestorOfClass("Model")
				if model and model:FindFirstChildOfClass("Humanoid") and model ~= Character and model ~= Rig then
					local targetHRP = FindFirstChildOfClassAndName(model, "BasePart", "HumanoidRootPart")
					if targetHRP then
						local flingVelocity = Vector3new(16384, 16384, 16384)
						while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and targetHRP:IsDescendantOf(Workspace) do
							targetHRP.AssemblyLinearVelocity = flingVelocity
							targetHRP.AssemblyAngularVelocity = flingVelocity

							if Settings.PredictionFling then
								local offset = Vector3new(math.sin(tick() * math.pi * 2 * Settings.Frequency) * Settings.Amplification, 0, 0)
								targetHRP.CFrame = CFrame.new(targetHRP.Position + offset)
							end

							task.wait()
						end
						targetHRP.AssemblyLinearVelocity = Vector3new(0, 0, 0)
						targetHRP.AssemblyAngularVelocity = Vector3new(0, 0, 0)
					end
				end
			end
		end
	end

	local function Start()
		-- Rig Oluştur
		local HumanoidModel = Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R6)
		Rig = HumanoidModel
		Rig.Name = Settings.CharacterName
		RigHumanoid = Rig.Humanoid
		RigHumanoidRootPart = Rig.HumanoidRootPart
		Rig.Parent = Workspace

		-- Attachments
		for _, desc in ipairs(Rig:GetDescendants()) do
			if desc:IsA("Attachment") then
				Attachments[desc.Name] = desc
			elseif desc:IsA("BasePart") then
				desc.CanCollide = false
			end
		end

		LocalPlayer.Character = Rig

		-- Events
		CharacterAdded:Connect(OnCharacterAdded)
		PostSimulation:Connect(OnPostSimulation)
		PreSimulation:Connect(function()
			if Rig then
				for _, part in ipairs(Rig:GetChildren()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
		UserInputService.InputBegan:Connect(OnInputBegan)

		OnCharacterAdded(LocalPlayer.Character)
	end

	Start()
end
