CameraDelay = 25

MissionAccomplished = function()
	Mission.MissionOver({ player }, nil, false)
end

MissionFailed = function()
        Mission.MissionOver(nil, { player }, false)
end

SetUnitStances = function()
	local playerUnits = Mission.GetGroundAttackersOf(player)
	local indiaUnits = Mission.GetGroundAttackersOf(india)
	for i, unit in ipairs(playerUnits) do
		Actor.SetStance(unit, "Defend")
	end
end

ChangeStance = function()
	local indiaUnits = Mission.GetGroundAttackersOf(india)
	for i, unit in ipairs(indiaUnits) do
		Actor.Hunt(unit)
	end
end

WorldLoaded = function()
	player = OpenRA.GetPlayer("PAKISTAN")
	india = OpenRA.GetPlayer("INDIA")
	
	ChangeStance()
	--ParadropIndianUnits()
	OpenRA.RunAfterDelay(CameraDelay, function() Actor.Create("camera", { Owner = player, Location = Paradrop2.Location }) end)
	
	OpenRA.SetViewportCenterPosition(Pakcon.CenterPosition)
	
	
end