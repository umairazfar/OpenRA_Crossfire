ForceDelay1 = 40
ForceDelay2 = 120
ForceDelay3 = 160
ForceInterval = 1

JeepReinforcements = {"mech", "mech", "jeep", "sniper", "1tnk"}
InsertionPath = { InsertionEntry.Location, InsertionLZ.Location }

--Ground Forces
Force1 = { "e1", "e1", "e1", "e1", "e2", "e2", "e2", "e3" }
Force2 = { "e1", "e1", "e1", "e1", "e2", "e2", "e2", "e3" }
Force3 = { "e2", "e2", "e1", "e1", "e3", "e3", "e3", "e3" }
Force4 = { "e1", "e1", "e1", "e1", "bggy", "bggy" }
Force5 = { "e1", "e1", "e1", "e1", "bggy", "bggy", "veer", "veer", "v2rl"}

SendJeeps = function()
	Reinforcements.Reinforce(player, JeepReinforcements, InsertionPath, Utils.Seconds(2))
	Media.PlaySpeechNotification(player, "ReinforcementsArrived")
end

--Indian Reinforcements
SendIndianInfantry = function()
	Ambush1Path = { Ambush1.Location, Rally1.Location }
	local units = Reinforcements.Reinforce(india, Force1, Ambush1Path, Utils.Seconds(ForceInterval))
	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)
	Ambush2Path = { Ambush3.Location, Rally2.Location }
	units = Reinforcements.Reinforce(india, Force2, Ambush2Path, Utils.Seconds(ForceInterval))
	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)
	Ambush3Path = { Ambush5.Location, Rally3.Location }
	units = Reinforcements.Reinforce(india, Force3, Ambush3Path, Utils.Seconds(ForceInterval))
	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)
	Trigger.AfterDelay(Utils.Seconds(ForceDelay1),SendIndianInfantry )
end

SendIndianBuggies = function()
	buggyPath = { Ambush2.Location, Rally1.Location }
	local units = Reinforcements.Reinforce(india, Force4, buggyPath, Utils.Seconds(ForceInterval))
	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)
	Trigger.AfterDelay(Utils.Seconds(ForceDelay2),SendIndianBuggies )
end

SendIndianTanks = function()
	TankPath = { Ambush4.Location, Rally3.Location}
	local units = Reinforcements.Reinforce(india, Force5, TankPath, ForceInterval)
	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)
	Trigger.AfterDelay(Utils.Seconds(ForceDelay3),SendIndianTanks )
end

BindActorTriggers = function(a)
	if a.HasProperty("Hunt") then
		if a.Owner == india then
			Trigger.OnIdle(a, a.Hunt)
		else
			Trigger.OnIdle(a, function(a) a.AttackMove(Outpost.Location) end)
		end
	end
end

OutpostDestroyed = function()
	MissionFailed()
end

MissionAccomplished = function()
	Media.PlaySpeechNotification(player, "Win")
end

MissionFailed = function()
	Media.PlaySpeechNotification(player, "Lose")
	player.MarkFailedObjective(SurviveObjective)
	india.MarkCompletedObjective(DestroyObjective)
end

SetUnitStances = function()
	Utils.Do(indianArmy, function(a)
		if a.Owner == player or a.Owner == india then
			a.Stance = "Defend"
		end
	end)
end

WorldLoaded = function()
	player = Player.GetPlayer("PAKISTAN")
	india = Player.GetPlayer("INDIA")
	
	Trigger.OnObjectiveCompleted(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)

	Trigger.OnObjectiveFailed(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)
	
	Trigger.OnKilled(Outpost, OutpostDestroyed)
	
	Trigger.AfterDelay(Utils.Seconds(600), function()
		player.MarkCompletedObjective(SurviveObjective)
		india.MarkFailedObjective(DestroyObjective)
	end)
	
	SurviveObjective = player.AddPrimaryObjective("The outpost must survive.")
	DestroyObjective = india.AddPrimaryObjective("The Pakistani outpost must be destroyed.")

	indianArmy = india.GetGroundAttackers()
	SetUnitStances()

	Trigger.AfterDelay(Utils.Seconds(5), function() Actor.Create("camera", true, { Owner = player, Location = InsertionLZ.CenterPosition }) end)
	Trigger.AfterDelay(Utils.Seconds(5), function() Media.PlaySpeechNotification(player, "PakMission01Briefing") end)
	Trigger.AfterDelay(Utils.Seconds(10), SendJeeps)
	Trigger.AfterDelay(Utils.Seconds(ForceDelay1),SendIndianInfantry )
	Trigger.AfterDelay(Utils.Seconds(ForceDelay2),SendIndianBuggies )
	Trigger.AfterDelay(Utils.Seconds(ForceDelay3),SendIndianTanks )
	Camera.Position = InsertionLZ.CenterPosition

	Media.PlayMovieFullscreen("landing.vqa")
end
