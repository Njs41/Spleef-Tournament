spleef = {
	world = World:new("spleeft"),
	floorLevel = 77,
	floorMirrorLevel = 122,
	floorLowX = 765,
	floorLowZ = -1065,
	floorHighX = 825,
	floorHighZ = -1005,
	floorBreakData = {},
	repairTimer = Timer:new("spleef_repairFloorStep", 2),
	startAnnouce1 = Timer:new("spleef_startAnnouce1", 30 * 20),
	startAnnouce2 = Timer:new("spleef_startAnnouce2", 15 * 20),
	startAnnouce3 = Timer:new("spleef_startAnnouce3", 15 * 20),
	startRound = Timer:new("spleef_startRound", 5 * 20),
	gates = {	{764, -1049},
				{764, -1048},
				{764, -1047},
				{764, -1036},
				{764, -1035},
				{764, -1034},
				{764, -1023},
				{764, -1022},
				{764, -1021},
				{781, -1004},
				{782, -1004},
				{783, -1004},
				{794, -1004},
				{795, -1004},
				{796, -1004},
				{807, -1004},
				{808, -1004},
				{809, -1004},
				{826, -1021},
				{826, -1022},
				{826, -1023},
				{826, -1034},
				{826, -1035},
				{826, -1036},
				{826, -1047},
				{826, -1048},
				{826, -1049},
				{809, -1066},
				{808, -1066},
				{807, -1066},
				{796, -1066},
				{795, -1066},
				{794, -1066},
				{783, -1066},
				{782, -1066},
				{781, -1066}
			},
	gatesOpen1 = Timer:new("spleef_gatesOpen1", 1 * 20),
	gatesOpen2 = Timer:new("spleef_gatesOpen2", 1 * 20),
	gatesOpen3 = Timer:new("spleef_gatesOpen3", 1 * 20),
	gatesClose1 = Timer:new("spleef_gatesClose1", 5 * 20),
	gatesClose2 = Timer:new("spleef_gatesClose2", 1 * 20),
	gatesClose3 = Timer:new("spleef_gatesClose3", 1 * 20),
	lobbyLocation = Location:new(spleef.world, 795, 93, -1003),
	players = {},
	contestants = {},
	stageWinners = {},
	stage = 1,
	doors = {	{782,-1001},
				{795,-1001},
				{808,-1001},
				{829,-1022},
				{829,-1035},
				{829,-1048},
				{808,-1069},
				{795,-1069},
				{782,-1069},
				{761,-1048},
				{761,-1035},
				{761,-1022},
				{782,-1001},
				{795,-1001},
				{808,-1001}
			}
};

function spleef.broadcast(message)
	spleef.world:broadcast("&3[Spleef]: &b" .. message);
end

function spleef.message(player, message)
	player:sendMessage("&3[Spleef]: &b" .. message);
end

function spleef_breakFloor(data)
	local x = tonumber(data["x"]);
	local y = tonumber(data["y"]);
	local z = tonumber(data["z"]);
	
	if x >= spleef.floorLowX and x <= spleef.floorHighX and z >= spleef.floorLowZ and z <= spleef.floorHighZ and y == spleef.floorLevel then
		local mirrorBlock = Location:new(spleef.world, x, spleef.floorMirrorLevel, z);
		local block = Location:new(spleef.world, x, spleef.floorLevel, z);
		block:setBlock(0, 0);
		mirrorBlock:setBlock(0, 0);
		local node = {
			x = x,
			z = z,
			blockID = tonumber(data["blockID"]),
			blockData = tonumber(data["blockData"])
		};
		table.insert(spleef.floorBreakData, node);
	end
end

function spleef_repairFloor()
	spleef.repairTimer:startRepeating();
end

function spleef_stopFloorRepair()
	spleef.repairTimer:cancel();
end

function spleef_repairFloorStep()
	local dataSize = #spleef.floorBreakData;
	
	if dataSize > 0 then
		local node = spleef.floorBreakData[dataSize];
		local floorBlock = Location:new(spleef.world, node.x, spleef.floorLevel, node.z);
		local mirrorBlock = Location:new(spleef.world, node.x, spleef.floorMirrorLevel, node.z);
		floorBlock:setBlock(node.blockID, node.blockData);
		mirrorBlock:setBlock(node.blockID, node.blockData);
		table.remove(spleef.floorBreakData);
	else
		spleef.repairTimer:cancel();
	end
end

function spleef_scheduleMatchAnnoucements()
	spleef.broadcast("Next round starting in 60 seconds!");
	spleef.startAnnouce1:start();
end

function spleef_startAnnouce1()
	spleef.broadcast("Next round starting in 30 seconds!");
	spleef.startAnnouce2:start();
end

function spleef_startAnnouce2()
	spleef.broadcast("Next round starting in 15 seconds!");
	spleef.startAnnouce3:start();
end

function spleef_startAnnouce3()
	local currentDoor = 1;
	for playerName, status in pairs(spleef.players) do
		local player = Player:new(playerName);
		local door = spleef.doors[currentDoor];
		local location = Location:new(spleef.world, door[1], 78, door[2]);
		
		if spleef.stageWinners[playerName] == nil then
			spleef.contestants[playerName] = 1;
			
			player:teleport(location);
			
			if currentDoor == #spleef.doors - 1 then
				currentDoor = 1;
			else
				currentDoor = currentDoor + 1;
			end
		end
	end
	spleef.broadcast("Next round starting! Gates open in 5 seconds, good luck contestants!");
	spleef.startRound:start();
end

function spleef_startRound()
	spleef.gatesOpen1:start();
end

function spleef_editGates(blockID, y)
	for index, coords in pairs(spleef.gates) do
		local block = Location:new(spleef.world, coords[1], y, coords[2]);
		block:setBlock(blockID, 0);
	end
end

function spleef_gatesOpen1()
	spleef.gatesOpen2:start();
	spleef_editGates(0, 78);
end

function spleef_gatesOpen2()
	spleef.gatesOpen3:start();
	spleef_editGates(0, 79);
end

function spleef_gatesOpen3()
	spleef.gatesClose1:start();
	spleef_editGates(0, 80);
end

function spleef_gatesClose1()
	spleef.gatesClose2:start();
	spleef_editGates(101, 80);
end

function spleef_gatesClose2()
	spleef.gatesClose3:start();
	spleef_editGates(101, 79);
end

function spleef_gatesClose3()
	spleef_editGates(101, 78);
end

function spleef_net(data)
	local player = Player:new(data["player"]);
	player:teleport(spleef.lobbyLocation);
	
	if spleef.players[player.name] ~= nil then
		spleef_removePlayer(player);
		spleef_checkWinner();
	end
end

function spleef_checkWinner()
	local count = 0;
	local last = nil;
	for player, status in pairs(spleef.contestants) do
		count = count + 1;
		last = Player:new(player);
	end

	if count == 1 then
		last:teleport(spleef.lobbyLocation);
		spleef.message(last, "You have won the match, you will not be included in any further rounds until the next stage of the tournament!");
		spleef.broadcast(last.name .. " has won this round!");
		spleef.stageWinners[last.name] = 1;
		spleef.contestants[last.name] = nil;
		spleef_repairFloor(); 
	end
end

function spleef_removePlayer(player)
	if spleef.contestants[player.name] ~= nil then
		spleef.contestants[player.name] = nil;
		spleef.message(player, "You have been removed from the match! Better luck next time...");
	end
end

function spleef_signup(data)
	local player = Player:new(data["player"]);
	if spleef.players[player.name] == nil then
		spleef.players[player.name] = 1;
		spleef.message(player, "You are now signed up for the spleef tournament!");
	else
		spleef.message(player, "You are already signed up, silly!");
	end
end

function Timer:start()
    self.id = EventEngine.timer.scheduleTask(self.func, self.delay);
end

function spleef_switchRound(data)
	spleef.players = spleef.stageWinners;
	spleef.stageWinners = {};
	spleef.stage = spleef.stage + 1;
	spleef.broadcast("Stage " .. tostring(spleef.stage) .. " of the tournament is starting now!");
end

registerHook("LEFT_CLICK_BLOCK", "spleef_breakFloor", "spleeft");
registerHook("INTERACT", "spleef_repairFloor", 77, "spleeft", 789, 90, -1001);
registerHook("INTERACT", "spleef_stopFloorRepair", 77, "spleeft", 789, 90, -1002);
registerHook("REGION_ENTER", "spleef_net", "spleeft-net1");
registerHook("REGION_ENTER", "spleef_net", "spleeft-net2");
registerHook("INTERACT", "spleef_signup", 77, "spleeft", 795, 94, -1001);
registerHook("INTERACT", "spleef_scheduleMatchAnnoucements", 77, "spleeft", 789, 88, -1002);
registerHook("INTERACT", "spleef_switchRound", 77, "spleeft", 801, 88, -1001);