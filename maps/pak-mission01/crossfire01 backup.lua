
StanceDelay = 10
CameraDelay = 5

MissionSuccessDelay = 600

ForceDelay1 = 40
ForceDelay2 = 120
ForceDelay3 = 160
ForceInterval = 25

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

SendIndianInfantry = function()
	Ambush1Path = { Ambush1.Location, Rally1.Location }
	Reinforcements.Reinforce(india, Force1, Ambush1Path, Utils.Seconds(ForceInterval))
	Ambush2Path = { Ambush3.Location, Rally2.Location }
	Reinforcements.Reinforce(india, Force2, Ambush2Path, Utils.Seconds(ForceInterval))
	Ambush3Path = { Ambush5.Location, Rally3.Location }
	Reinforcements.Reinforce(india, Force3, Ambush3Path, Utils.Seconds(ForceInterval))
	Trigger.AfterDelay(Utils.Seconds(ForceDelay1),SendIndianInfantry )
end

SendIndianBuggies = function()
	buggyPath = { Ambush2.Location, Rally1.Location }
	Reinforcements.Reinforce(india, Force4, buggyPath, Utils.Seconds(ForceInterval))
	Trigger.AfterDelay(Utils.Seconds(ForceDelay2),SendIndianBuggies )
end

SendIndianTanks = function()
	TankPath = { Ambush4.Location, Rally3.Location}
	Reinforcements.Reinforce(india, Force5, TankPath, ForceInterval)
	Trigger.AfterDelay(Utils.Seconds(ForceDelay3),SendIndianTanks )
end

OutpostDestroyed = function()
	player.MarkFailedObjective(SurviveObjective)
	india.MarkCompletedObjective(DefendObjective)
end

MissionAccomplished = function()
	Media.PlaySpeechNotification(player, "Win")
end

MissionFailed = function()
	Media.PlaySpeechNotification(player, "Lose")
end


SetUnitStances = function()
	Utils.Do(Map.NamedActors, function(a)
		if a.Owner == player or a.Owner == india then
			a.Stance = "Defend"
		end
	end)
end

RunInitialActivities = function()
	Trigger.AfterDelay(Utils.Seconds(12), function()
		for i = 0, 2 do
			Trigger.AfterDelay(Utils.Seconds(i), function()
				Media.PlaySoundNotification(player, "AlertBuzzer")
			end)
		end
		Utils.Do(indianArmy, function(a)
			if not a.IsDead and a.HasProperty("Hunt") then
				Trigger.OnIdle(a, a.Hunt)
			end
		end)
	end)
	Trigger.AfterDelay(Utils.Seconds(600), function()
		player.MarkCompletedObjective(SurviveObjective)
		india.MarkFailedObjective(DestroyObjective)
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

	Trigger.OnPlayerLost(player, MissionFailed)

	Trigger.OnPlayerWon(player, MissionAccomplished)


	SurviveObjective = player.AddPrimaryObjective("The outpost must survive.")
	DestroyObjective = india.AddPrimaryObjective("The Pakistani outpost must be destroyed.")

	Trigger.OnKilled(Outpost, OutpostDestroyed)

	indianArmy = india.GetGroundAttackers()

	RunInitialActivities()

	SetUnitStances()

	Trigger.AfterDelay(Utils.Seconds(5), function() Actor.Create("camera", true, { Owner = player, Location = BaseCameraPoint.Location }) end)
	Trigger.AfterDelay(Utils.Seconds(5), SendJeeps)
	Trigger.AfterDelay(Utils.Seconds(ForceDelay1),SendIndianInfantry )
	Trigger.AfterDelay(Utils.Seconds(ForceDelay2),SendIndianBuggies )
	Trigger.AfterDelay(Utils.Seconds(ForceDelay3),SendIndianTanks )
	Camera.Position = InsertionLZ.CenterPosition

	Media.PlayMovieFullscreen("landing.vqa")
end
