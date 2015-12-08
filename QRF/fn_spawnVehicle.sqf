private ["_ret","_veh","_grp"];
_ret = _this call BIS_fnc_spawnvehicle;
_veh = _ret select 0;
_grp = _ret select 2;
{
	_x setSkill ["spotdistance", 0.75];
	_x setSkill ["aimingspeed", 0.15];
	_x setSkill ["aimingaccuracy", 0.2];
	_x setSkill ["aimingshake", 0.15];
	_x setSkill ["spottime", 0.4];
	_x setSkill ["commanding", 0.8];
	_x setSkill ["general", 0.8];
	_x AddMPEventHandler ["mpkilled", {_this spawn QRF_fnc_onUnitKilled}];
	if (HCconnected) then {
		handle = [_x] call QRF_fnc_sendToHC;
	};
} foreach units _grp;

_veh AddMPEventHandler ["mpkilled", {_this spawn QRF_fnc_onUnitKilled}];

if ([true, false] call bis_fnc_selectRandom) then
{
	_veh allowCrewInImmobile true;
};


_ret;
