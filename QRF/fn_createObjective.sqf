_location = _this select 0;
_locationName = text _location;
_locationPosition = position _location;
_locationSize = size _location;
//QRF_ObjSizes = [1,1,2,2,3];
_size = QRF_ObjSizes call bis_fnc_selectRandom;
QRF_ObjSizes = QRF_ObjSizes - [_size];
publicVariable "QRF_ObjSizes";
_pos = [_locationPosition, (_locationSize + random 500) , random 360 ] call BIS_fnc_relPos;
_spawnPos = [];
_max_distance = 100;
while{ count _spawnPos < 1 } do {
	_spawnPos = _center findEmptyPosition[ 30 , _max_distance , "Land_Cargo_Patrol_V3_F" ];
	_max_distance = _max_distance + 50;
};


switch (_size) do {

	case 1:
	{
		//Small
		_comp = QRF_smallObjComps call BIS_fnc_selectRandom;
		_newComp = [_spawnPos, _comp] call QRF_fnc_createComposition;
		_grp = [_spawnPos, WEST, (QRF_PatrolGrps call BIS_fnc_selectRandom)] call QRF_fnc_spawnGroup;
		//_grp setVariable ["GAIA_ZONE_INTEND",[currentTargetMarkerName, "MOVE"], false];

	};

	case 2:
	{
		// Medium
		_comp = QRF_mediumObjComps call BIS_fnc_selectRandom;
		_newComp = [_spawnPos, _comp] call QRF_fnc_createComposition;
	};

	case 3:
	{
		// Large
		_comp = QRF_largeObjComps call BIS_fnc_selectRandom;
		_newComp = [_spawnPos, _comp] call QRF_fnc_createComposition;
	};

};
