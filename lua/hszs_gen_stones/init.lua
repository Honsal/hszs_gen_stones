local genStoneDelay = CreateConVar("hszs_gen_stones_delay", 75, bit.bor(FCVAR_SERVER_CAN_EXECUTE), "Sets delay of auto generation of stones."):GetInt()

local makeStone = function(pl)
	local start = pl:LocalToWorld(pl:OBBCenter())
	local dir = VectorRand() * Vector(1, 1, 0) + Vector(0, 0, math.Rand(-0.05, -0.1))
	local endpos = start + dir * 600
	
	local wep = pl:GetActiveWeapon()
	
	if !IsValid(wep) then
		wep = nil
	end
	
	local filter = {pl, wep}
		
	local min = Vector(-8.078350, -7.429850, -4.773050)
	local max = Vector(7.414750, 5.654650, 7.281250)
	
	local td = {
		start = start,
		endpos = endpos,
		filter = filter,
		mask = MASK_SOLID,
		mins = min,
		maxs = max
	}

	
	local trace = util.TraceHull(td)
	
	local count = 0
	for i = 1, 100 do
		if (!trace.Hit or !trace.HitWorld) or (trace.MatType ~= MAT_DIRT and trace.MatType ~= MAT_GRATE and trace.MatType ~= MAT_SNOW and trace.MatType ~= MAT_SAND and trace.MatType ~= MAT_SLOSH and trace.MatType ~= MAT_GRASS) then
			local tr = util.TraceLine({
				start = trace.StartPos,
				endpos = trace.StartPos + Vector(0, 0, -1000000),
				filter = td.filter,
				mask = td.mask
			})
			
			if !tr.Hit then
				count = count + 1
				if count >= 99 then
					return
				end
				continue
			end
			
			if tr.MatType ~= MAT_DIRT and tr.MatType ~= MAT_GRATE and tr.MatType ~= MAT_SNOW and tr.MatType ~= MAT_SAND and tr.MatType ~= MAT_SLOSH and tr.MatType ~= MAT_GRASS then
				count = count + 1
				if count >= 99 then
					return
				end
				continue
			end
			dir = VectorRand() * Vector(1, 1, 0) + Vector(0, 0, math.Rand(-0.05, -0.1))
			endpos = start + dir * 600
			td.endpos = endpos
			trace = util.TraceHull(td)
			count = count + 1
		end
	end
	
	if count == 100 then
		return
	end
	
	local pos = trace.HitPos
	local ent = ents.Create("prop_weapon")
	ent:SetWeaponType("weapon_zs_stone")
	ent:SetClip1(1)
	ent:SetPos(pos)
	ent:SetAngles((pos - start):Angle())
	ent:Spawn()
	
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
end

local nextGenStones = 0
local genStones = function()
	local time = CurTime()
	if nextGenStones <= time then
		for _, v in pairs(player.GetAll()) do
			if IsValid(v) and v:Team() == TEAM_HUMAN then
				makeStone(v)
			end
		end
		nextGenStones = time + genStoneDelay
	end
end
hook.Remove("Think", "hszs_gen_stones", genStones)
-- hook.Add("Think", "hszs_gen_stones", genStones)