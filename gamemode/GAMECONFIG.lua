AddCSLuaFile()
// ********************************
// * Tower Defense Gamemode - Game *
// ********************************
// GAMECONFIG.lua - Loads game configuration

// Amount of money the players start with
GM.StartMoney = 30

// Flashlight?
GM.FlashlightEnabled = false

// ------------------------------------------------------------------------------------------------------------------
// Target Selection Logic
// ------------------------------------------------------------------------------------------------------------------

local Logic_HighestHP

if (SERVER) then
	function Logic_HighestHP( tower, targets )
		// Find the target with the highest HP
		local curtarget = targets[1]
		local curhp = curtarget.HP
		for _, ent in pairs( targets ) do
			if (ent.HP > curhp) then
				curhp = ent.HP
				curtarget = ent
			end
		end
		return curtarget
	end
end

// ------------------------------------------------------------------------------------------------------------------
// Pistol Tower
// ------------------------------------------------------------------------------------------------------------------
towers.Register( "tower_pistol", 1, {
	PrintName = "Pistol Tower",
	UpgradeName = "t_pist",
	MaxLvl = 3,
	Delay = 2,
	Damage = 30,
	Ammo = 500,
	DefaultDamage = 30,
	ShootNum = 1,
	Effect = "AR2Tracer",
	MuzzleFlash = "ShellEject",
	MuzzleFlashOffset = Vector( 0, 0, 20 ),
	Cost = 10,
	Snd = Sound( "weapons/pistol/pistol_fire2.wav" ),
	Range = 128,
	DefaultRange = 128,
	Model = "models/GMODTD/pistoltower/pistoltower.mdl",
	Color = color_white,
	Animation = "rotation",
	AnimationSpeed = 0
} )

towers.Register( "tower_pistol", 2, {
	Delay = 0.9,
	Damage = 35,
	DefaultDamage = 35,
	AnimationSpeed = 1,
	Cost = 4
} )

towers.Register( "tower_pistol", 3, {
	Delay = 0.8,
	Damage = 40,
	DefaultDamage = 40,
	AnimationSpeed = 2,
	Cost = 5
} )

AddTower( "tower_pistol", 	"Pistol Tower", 		{ 10, 4, 5 },
	towers.CompileDescription( "tower_pistol", 
		"Weak but an effective and cheap way of dealing with enemies." ),
	"t_pist", 0
);

// ------------------------------------------------------------------------------------------------------------------
// SMG Tower
// ------------------------------------------------------------------------------------------------------------------
towers.Register( "tower_smg", 1, {
	PrintName = "SMG Tower",
	UpgradeName = "t_smg",
	MaxLvl = 3,
	Delay = 0.2,
	Damage = 10,
	DefaultDamage = 10,
	ShootNum = 1,
	Ammo = 100,
	Effect = "AR2Tracer",
	MuzzleFlash = "RifleShellEject",
	MuzzleFlashOffset = Vector( 0, 0, 20 ),
	Cost = 25,
	Snd = Sound( "weapons/smg1/smg1_fire1.wav" ),
	Range = 256,
	DefaultRange = 256,
	Model = "models/GMODTD/smgtower/smgtower.mdl",
	Color = color_white,
	Animation = "rotation",
	AnimationSpeed = 0
} )

towers.Register( "tower_smg", 2, {
	Damage = 14,
	DefaultDamage = 14,
	AnimationSpeed = 1,
	Cost = 10
} )

towers.Register( "tower_smg", 3, {
	Damage = 18,
	DefaultDamage = 18,
	Delay = 0.15,
	AnimationSpeed = 2,
	Cost = 12
} )

AddTower( "tower_smg", 	"SMG Tower", 		{ 25, 10, 12 },
	towers.CompileDescription( "tower_smg", 
		"Powerful but slightly expensive means of disposing enemies." ),
	"t_smg", 0
);

// ------------------------------------------------------------------------------------------------------------------
// Shotgun Tower
// ------------------------------------------------------------------------------------------------------------------
towers.Register( "tower_shotgun", 1, {
	PrintName = "Shotgun Tower",
	UpgradeName = "t_shot",
	MaxLvl = 3,
	Delay = 3,
	Damage = 30,
	DefaultDamage = 30,
	ShootNum = 6,
	Ammo = 64,
	Effect = "AR2Tracer",
	MuzzleFlash = "ShotgunShellEject",
	MuzzleFlashOffset = Vector( 0, 0, 20 ),
	Cost = 40,
	Snd = Sound( "weapons/shotgun/shotgun_fire7.wav" ),
	Range = 128,
	DefaultRange = 256,
	Model = "models/GMODTD/shotguntower/shotguntower.mdl",
	Color = color_white,
	Animation = "rotation",
	AnimationSpeed = 0
} )
towers.Register( "tower_shotgun", 2, {
	Delay = 2,
	ShootNum = 8,
	AnimationSpeed = 1,
	Cost = 4
} )
towers.Register( "tower_shotgun", 3, {
	Delay = 1.5,
	ShootNum = 10,
	AnimationSpeed = 2,
	Cost = 5
} )
AddTower( "tower_shotgun", 	"Shotgun Tower", 		{ 40, 18, 20 },
	towers.CompileDescription( "tower_shotgun", 
		"Burst shots deal alot of damage, but the fire rate is low and it's expensive." ),
	"t_shot", 0
);

// ------------------------------------------------------------------------------------------------------------------
// Sniper Tower
// ------------------------------------------------------------------------------------------------------------------
towers.Register( "tower_sniper", 1, {
	PrintName = "Sniper Tower",
	UpgradeName = "t_snip",
	MaxLvl = 3,
	Delay = 5,
	Damage = 200,
	DefaultDamage = 200,
	ShootNum = 1,
	Ammo = 10,
	Effect = "AR2Tracer",
	MuzzleFlash = "ShellEject",
	MuzzleFlashOffset = Vector( 0, 0, 20 ),
	Cost = 60,
	Snd = Sound( "weapons/scout/scout_fire-1.wav" ),
	Range = 768,
	DefaultRange = 768,
	Model = "models/GMODTD/snipertower/snipertower.mdl",
	Color = color_white,
	Animation = "rotation",
	AnimationSpeed = 0,
	SelectTarget = Logic_HighestHP
} )
towers.Register( "tower_sniper", 2, {
	Delay = 4,
	Damage = 250,
	DefaultDamage = 250,
	AnimationSpeed = 1,
	Cost = 30
} )
towers.Register( "tower_sniper", 3, {
	Delay = 1.5,
	Damage = 300,
	DefaultDamage = 300,
	AnimationSpeed = 2,
	Cost = 40
} )
AddTower( "tower_sniper", 	"Sniper Tower", 		{ 60, 30, 40 },
	towers.CompileDescription( "tower_sniper", 
		"Burst shots deal alot of damage, but the fire rate is low and it's expensive." ),
	"t_snip", 0
);
	
// ------------------------------------------------------------------------------------------------------------------
// Paralysis Tower
// ------------------------------------------------------------------------------------------------------------------
towers.Register( "tower_paralyse", 1, {
	PrintName = "Paralysis Tower",
	UpgradeName = "t_slow",
	MaxLvl = 3,
	Delay = 5,
	Damage = 0,
	DefaultDamage = 0,
	ShootNum = 1,
	Health = 100,
	Ammo = 500,
	Effect = "AR2Tracer",
	MuzzleFlash = "",
	MuzzleFlashOffset = Vector( 0, 0, 20 ),
	Cost = 20,
	Snd = Sound( "" ),
	Range = 128,
	DefaultRange = 128,
	Model = "models/GMODTD/para/para.mdl",
	Color = color_white,
	Animation = "rotation",
	AnimationSpeed = 0,
	ParalyzeSlowDown = true,
	SlowTime = 10,
	SlowDamage = 0,
	SelectTarget = Logic_HighestHP
} )
towers.Register( "tower_paralyse", 2, {
	Delay = 4,
	SlowTime = 20,
	AnimationSpeed = 1,
	Cost = 10
} )
towers.Register( "tower_paralyse", 3, {
	Delay = 3,
	SlowTime = 30,
	AnimationSpeed = 2,
	Cost = 15
} )
AddTower( "tower_paralyse", 	"Paralysis Tower", 		{ 20, 10, 15 },
	towers.CompileDescription( "tower_paralyse", 
		"Temporarily freezes an enemy, but deals no damage." ),
	"t_slow", 0
);

// ------------------------------------------------------------------------------------------------------------------
// Flame Tower
// ------------------------------------------------------------------------------------------------------------------
towers.Register( "tower_flame", 1, {
	PrintName = "Flame Tower",
	UpgradeName = "t_fire",
	MaxLvl = 3,
	Delay = 4,
	Damage = 30,
	DefaultDamage = 30,
	ShootNum = 1,
	Ammo = 350,
	Effect = "AR2Tracer",
	MuzzleFlash = "MuzzleEffect",
	MuzzleFlashOffset = Vector( 0, 0, 20 ),
	Cost = 30,
	Snd = Sound( "weapons/pistol/pistol_fire2.wav" ),
	Range = 256,
	DefaultRange = 256,
	Model = "models/GMODTD/flametower/flametower.mdl",
	Color = color_white,
	Animation = "rotation",
	AnimationSpeed = 0,
	IgniteOnHit = true,
	IgniteTime = 5,
	IgniteDamage = 35,
	SelectTarget = Logic_HighestHP
} )
towers.Register( "tower_flame", 2, {
	Delay = 3.5,
	Damage = 40,
	DefaultDamage = 50,
	IgniteTime = 6,
	IgniteDamage = 50,
	AnimationSpeed = 1,
	Cost = 20
} )
towers.Register( "tower_flame", 3, {
	Delay = 2.5,
	Damage = 50,
	DefaultDamage = 50,
	IgniteTime = 7,
	IgniteDamage = 65,
	AnimationSpeed = 2,
	Cost = 25
} )
AddTower( "tower_flame", 	"Flame Tower", 		{ 30, 20, 25 },
	towers.CompileDescription( "tower_flame", 
		"Deals a burning shot that ignites the enemy for a certain time." ),
	"t_fire", 1
);

// ------------------------------------------------------------------------------------------------------------------
// Ammo Supply tower
// ------------------------------------------------------------------------------------------------------------------
towers.Register( "tower_ammosupply", 1, {
	PrintName = "AmmoSupply Tower",
	UpgradeName = "t_ammosupply",
	MaxLvl = 3,
	Cost = 10,
	Range = 50,
	Ammo = 1,
	Delay = 5,
	Ammoregen = 1,
	Effect = "AR2Tracer",
	MuzzleFlash = "MuzzleEffect",
	MuzzleFlashOffset = Vector( 0, 0, 20 ),
	Damage = 0,
	ShootNum = 0,
	Model = "models/props_combine/breenglobe.mdl",
	Color = color_white,
	SelectTarget = Logic_HighestHP
} )
towers.Register( "tower_ammosupply", 2, {
Range = 100,
Ammoregen = 2,
Cost = 5
} )
towers.Register( "tower_ammosupply", 3, {
Range = 150,
Ammoregen = 5,
Cost = 4
} )
AddTower( "tower_ammosupply", 	"AmmoSupply Tower", 		{ 10, 4, 5 },
	towers.CompileDescription( "tower_ammosupply", 
		"Ammo supplier regenerates aall towers ammo in its radius." ),
	"t_ammosupply", 1
);

// ------------------------------------------------------------------------------------------------------------------
// Frost Tower
// ------------------------------------------------------------------------------------------------------------------
towers.Register( "tower_frost", 1, {
	PrintName = "Frost Tower",
	UpgradeName = "t_ice",
	MaxLvl = 3,
	Delay = 4,
	Damage = 1,
	DefaultDamage = 30,
	ShootNum = 1,
	Ammo = 100,
	Effect = "AR2Tracer",
	MuzzleFlash = "MuzzleEffect",
	MuzzleFlashOffset = Vector( 0, 0, 20 ),
	Cost = 30,
	Snd = Sound( "weapons/pistol/pistol_fire2.wav" ),
	Range = 256,
	DefaultRange = 256,
	Model = "models/GMODTD/icetower/icetower.mdl",
	Color = color_white,
	Animation = "rotation",
	AnimationSpeed = 0,
	SlowOnHit = true,
	SlowTime = 30,
	SlowDamage = 1,
	SelectTarget = Logic_HighestHP
} )
towers.Register( "tower_frost", 2, {
	Delay = 3.5,
	Damage = 45,
	DefaultDamage = 45,
	SlowTime = 40,
	SlowDamage = 45,
	AnimationSpeed = 1,
	Cost = 20
} )
towers.Register( "tower_frost", 3, {
	Delay = 2.5,
	Damage = 60,
	DefaultDamage = 60,
	SlowTime = 50,
	SlowDamage = 50,
	AnimationSpeed = 2,
	Cost = 25
} )
AddTower( "tower_frost", 	"Frost Tower", 		{ 30, 20, 25 },
	towers.CompileDescription( "tower_frost", 
		"Deals an icey shot that slows down the enemy for a certain time." ),
	"t_ice", 1
);



AddWave( "monster_headcrab", 10, 2, "NORMAL" )
// AddWave( classname, amount, spawndelay, level )

// Note: The following code is unfinished, it was never uploaded to the servers (as of 4th October 2009)
// It may or may not work, you can use the syntax above to add your own waves

local RandomAll = { "monster_headcrab", "monster_fastheadcrab", "monster_ztorso", "monster_fastzombie", "monster_poisonzomb" }
local RandomHeadcrab = { "monster_headcrab", "monster_fastheadcrab" }
// You can make tables with any combination of monster you like

// Waves
// These ones will pick a random monster from the RandomAll table
AddWave( RandomAll,	 10,	 2,	 "NORMAL")
AddWave( RandomAll,	 10,	 2,	 "NORMAL")
AddWave( RandomAll,	 10,	 2,	 "NORMAL")
AddWave( RandomAll,	 10,	 2,	 "NORMAL")
AddWave( RandomAll,	 1,		 2,	 "BOSS",	 "boss", 10, 10)

// These ones will pick a random monster from the RandomHeadcrab table
AddWave( RandomHeadcrab, 10,	 2,	 "NORMAL")
AddWave( RandomHeadcrab, 10,	 2,	 "NORMAL")
AddWave( RandomHeadcrab, 10,	 2,	 "NORMAL")
AddWave( RandomHeadcrab, 10,	 2,	 "NORMAL")
AddWave( RandomHeadcrab, 1,		 2,	 "BOSS", 	 "boss", 20, 10)

AddWave( RandomAll,		 10,	 2,	 "NORMAL")
AddWave( RandomAll,		 10,	 2,	 "NORMAL")
AddWave( RandomAll,		 10,	 2,	 "NORMAL")
AddWave( RandomAll,		 10,	 2,	 "NORMAL")
AddWave( RandomAll,		 1,		 2,	 "BOSS", 	 "boss", 30, 10)

AddWave( RandomAll,		 10,	 2,	 "NORMAL")
AddWave( RandomAll,		 10,	 2,	 "NORMAL")
AddWave( RandomAll,		 10,	 2,	 "NORMAL")
AddWave( RandomAll,		 10,	 2,	 "NORMAL")
AddWave( RandomAll,		 1,		 2,	 "BOSS", 	 "boss", 40, 10)

AddWave( RandomAll,	 10,	 2,	 "NORMAL")
AddWave( RandomAll,	 10,	 2,	 "NORMAL")
AddWave( RandomAll, 	 10,	 2,	 "NORMAL")
AddWave( RandomAll,	 10,	 2,	 "NORMAL")
AddWave( RandomAll,	 1,		 2,	 "BOSS", 	 "boss", 50, 10)

AddWave( RandomAll,	 10,	 2,	 "NORMAL")
AddWave( RandomAll,	 10,	 2,	 "NORMAL")
AddWave( RandomAll, 	 10,	 2,	 "NORMAL")
AddWave( RandomAll,	 10,	 2,	 "NORMAL")
AddWave( RandomAll,	 1,		 2,	 "BOSS", 	 "boss", 60) 
