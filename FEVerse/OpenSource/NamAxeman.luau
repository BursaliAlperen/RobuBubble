-- [[ Nam Axeman : Reanimate ]] --

local Reanimate_Settings = {
	Frequency = 6,
	Amplification = 6,
	FrontOffset = 2.5,
}

local NeckAccessories = {
	88886554182275,
	90788603154080,
	120111604252410,
	128893482026011,
	87291559615126,
}

do
	local ReanimateAxe
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
	local Humanoid = nil

	local table = table
	local tableclear = table.clear
	local tableinsert = table.insert
	local mathsin = math.sin
	local mathpi = math.pi
	local osclock = os.clock

	local FlingVelocity = Vector3new(16384, 16384, 16384)
	local HatDropLinearVelocity = Vector3new(0, 27, 0)
	local Vector3zero = Vector3new(0, 0, 0)

	local FindFirstChildOfClassAndName = function(Parent, ClassName, Name)
		for _, Child in ipairs(Parent:GetChildren()) do
			if Child:IsA(ClassName) and Child.Name == Name then
				return Child
			end
		end
	end

	local DetectNeckAccessories = function()
		local detected = {}
		if not Character then return detected end
		for _, child in ipairs(Character:GetChildren()) do
			if child:IsA("Accoutrement") then
				local handle = FindFirstChildOfClassAndName(child, "BasePart", "Handle")
				if handle then
					tableinsert(detected, {
						Part0 = handle,
						Part1 = RigHumanoidRootPart,
						Offset = CFrameidentity
					})
				end
			end
		end
		return detected
	end

	local OnCharacterAdded = function(NewCharacter)
		if NewCharacter ~= Rig then
			Character = NewCharacter
			tableclear(Aligns)
			tableclear(Blacklist)

			local HRP = Character:WaitForChild("HumanoidRootPart")
			Humanoid = Character:WaitForChild("Humanoid")

			RigHumanoidRootPart.CFrame = HRP.CFrame

			local neckAligns = DetectNeckAccessories()
			for _, align in ipairs(neckAligns) do
				tableinsert(Aligns, align)
			end

			task.spawn(function()
				if HRP and Humanoid then
					while Character and Humanoid.Health > 0 do
						HRP.AssemblyLinearVelocity = HatDropLinearVelocity
						task.wait()
					end
				end
			end)

			Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
		end
	end

	local OnPostSimulation = function()
		if Rig and RigHumanoid and Humanoid then
			RigHumanoid:Move(Humanoid.MoveDirection)
			RigHumanoid.Jump = Humanoid.Jump
		end

		local Axis = 27 + mathsin(osclock())

		for _, align in ipairs(Aligns) do
			local Part0 = align.Part0
			local Part1 = align.Part1

			if Part0 and Part0.ReceiveAge == 0 and Part0:IsDescendantOf(Workspace) then
				Part0.AssemblyAngularVelocity = Vector3zero
				local LinearVelocity = Part1.AssemblyLinearVelocity * Axis
				Part0.AssemblyLinearVelocity = Vector3new(LinearVelocity.X, Axis, LinearVelocity.Z)
				Part0.CFrame = Part1.CFrame * align.Offset
			end
		end
	end

	local OnInputBegan = function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local target = Mouse.Target
			if target then
				local model = target:FindFirstAncestorOfClass("Model")
				if model and model:FindFirstChildOfClass("Humanoid") and model ~= Character and model ~= Rig then
					local targetHRP = FindFirstChildOfClassAndName(model, "BasePart", "HumanoidRootPart")
					if targetHRP then
						while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and targetHRP:IsDescendantOf(Workspace) do
							targetHRP.AssemblyLinearVelocity = FlingVelocity
							targetHRP.AssemblyAngularVelocity = FlingVelocity

							local Time = osclock()
							local offset = Vector3new(mathsin(Time * mathpi * 2 * Reanimate_Settings.Frequency) * Reanimate_Settings.Amplification, 0, 0)
							targetHRP.CFrame = CFrame.new(targetHRP.Position + offset)

							task.wait()
						end
						targetHRP.AssemblyLinearVelocity = Vector3zero
						targetHRP.AssemblyAngularVelocity = Vector3zero
					end
				end
			end
		end
	end

	local CreateMobileUI = function()
		local gui = Instance.new("ScreenGui")
		gui.Name = "AxemanMobileUI"
		gui.ResetOnSpawn = false
		gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")

		local function createButton(name, pos, text)
			local b = Instance.new("TextButton")
			b.Name = name
			b.Size = UDim2.new(0, 46, 0, 46)
			b.Position = pos
			b.Text = text
			b.TextSize = 17
			b.Font = Enum.Font.GothamBold
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
			b.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
			b.BorderSizePixel = 0
			b.Parent = gui

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 12)
			corner.Parent = b

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(100, 100, 100)
			stroke.Thickness = 1.4
			stroke.Parent = b

			return b
		end

		local attackBtn = createButton("AttackBtn", UDim2.new(0.88, 0, 0.62, 0), "⚔")
		attackBtn.MouseButton1Down:Connect(function()
			if Humanoid then
				Humanoid:TakeDamage(10)
			end
		end)

		local jumpBtn = createButton("JumpBtn", UDim2.new(0.88, 0, 0.74, 0), "⤒")
		jumpBtn.MouseButton1Down:Connect(function()
			if RigHumanoid then
				RigHumanoid.Jump = true
			end
		end)

		local crouchBtn = createButton("CrouchBtn", UDim2.new(0.88, 0, 0.86, 0), "↓")
		crouchBtn.MouseButton1Down:Connect(function()
			if RigHumanoid then
				RigHumanoid.WalkSpeed = 8
				task.delay(0.2, function()
					if RigHumanoid then
						RigHumanoid.WalkSpeed = 16
					end
				end)
			end
		end)
	end

	local Start = function()
		local desc = Instance.new("HumanoidDescription")
		local model = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
		Rig = model
		Rig.Name = "NamAxeman"
		RigHumanoid = Rig.Humanoid
		RigHumanoidRootPart = Rig.HumanoidRootPart
		Rig.Parent = Workspace

		for _, desc in ipairs(Rig:GetDescendants()) do
			if desc:IsA("Attachment") then
				Attachments[desc.Name] = desc
			elseif desc:IsA("BasePart") then
				desc.CanCollide = false
			end
		end

		local CreateObject = function(Name)
			local Part = Instance.new("Part")
			Part.Name = Name
			Part.Massless = true
			Part.CanCollide = true
			Part.Transparency = 1
			Part.Size = Vector3new(0.1, 0.1, 0.1)
			Part.Anchored = true
			Part.Parent = Rig
			return Part
		end

		ReanimateAxe = CreateObject("Reanimate_Axe")

		LocalPlayer.Character = Rig

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

		CreateMobileUI()

		if LocalPlayer.Character then
			OnCharacterAdded(LocalPlayer.Character)
		end
	end

	Start()
end
