//////////////////////////////////////
//Init Debug
//////////////////////////////////////
if (("QRF_debug" call BIS_fnc_getParamValue) == 1) then {
	QRF_debug = true;
	publicVariable "QRF_debug";
} else {
	QRF_debug = false;
	publicVariable "QRF_debug";
};

//////////////////////////////////////
//Init Common Variables
//////////////////////////////////////

enableSaving [false, false];
QRF_HCconnected = false;
QRF_HQ = [West,"HQ"];
QRF_objRadius = 3500;
QRF_ObjLocations = [];
QRF_station = objNull;
QRF_stations = [];
QRF_Objectives = [];
QRF_ObjQty = "ObjQty" call BIS_fnc_getParamValue;
QRF_ObjSizes =[];
switch (QRF_ObjQty) do
{
	case 3:
	{
		QRF_ObjSizes = [1,2,3];
	};

	case 5:
	{
		QRF_ObjSizes = [1,1,2,2,3];
	};

	case 7:
	{
		QRF_ObjSizes = [1,1,2,2,2,3,3];
	};

};

QRF_PatrolGrps = [];
QRF_Vehicles = [];
QRF_Tanks = [];

//////////////////////////////////////
//Init Third Party Scripts
//////////////////////////////////////


//////////////////////////////////////
//Init AI System
//////////////////////////////////////

if (isServer) then {
        // From what range away from closest player should units be cached (in meters or what every metric system arma uses)?
        // To test this set it to 20 meters. Then make sure you get that close and move away.
        // You will notice 2 levels of caching 1 all but leader, 2 completely away
        // Stage 2 is 2 x GAIA_CACHE_STAGE_1. So default 2000, namely 2 x 1000
        GAIA_CACHE_STAGE_1             = 1000;
        // The follow 3 influence how close troops should be to known conflict to be used. (so they wont travel all the map to support)
        // How far should footmobiles be called in to support attacks.
        // This is also the range that is used by the transport system. If futher then the below setting from a zone, they can get transport.
        MCC_GAIA_MAX_SLOW_SPEED_RANGE  = 600;
        // How far should vehicles be called in to support attacks. (including boats)
        MCC_GAIA_MAX_MEDIUM_SPEED_RANGE= 4500;
        // How far should air units be called in to support attacks.
        MCC_GAIA_MAX_FAST_SPEED_RANGE  = 80000;
        // How logn should mortars and artillery wait (in seconds) between fire support missions.
        MCC_GAIA_MORTAR_TIMEOUT        = 120;
        // DANGEROUS SETTING!!!
        // If set to TRUE gaia will even send units that she does NOT control into attacks. Be aware ONLy for attacks.
        // They will not suddenly patrol if set to true.
        MCC_GAIA_ATTACKS_FOR_NONGAIA     = false;

        // If set to false, ai will not use smoke and flares (during night)
        MCC_GAIA_AMBIANT                 = true;

        // Influence how high the chance is (when applicaple) that units do smokes and flare (so not robotic style)
        // Default is 20 that is a chance of 1 out of 20 when they are applicable to use smokes and flares
        MCC_GAIA_AMBIANT_CHANCE          = 20;
        // The seconds of rest a transporter takes after STARTING his last order
        MCC_GAIA_TRANSPORT_RESTTIME     = 40;
        call compile preprocessfile "gaia\gaia_init.sqf";
        [] spawn {
        	_gaia_respawn = [];
        	while {true} do	{
                //player globalchat "Deleting started..............";

                {
                	_gaia_respawn = (missionNamespace getVariable [ "GAIA_RESPAWN_" + str(_x),[] ]);
                    //Store ALL original group setups
                    if (count(_gaia_respawn)==0) then {[(_x)] call fn_cache_original_group;};

                    if ((({alive _x} count units _x) == 0) ) then
                    {
                        //Before we send him to heaven check if he should be reincarnated
                        if (count(_gaia_respawn)==2) then { [_gaia_respawn,(_x getVariable  ["MCC_GAIA_RESPAWN",-1]),(_x getVariable  ["MCC_GAIA_CACHE",false]),(_x getVariable  ["GAIA_zone_intend",[]])] call fn_uncache_original_group;};

                        //Remove the respawn group content before the group is re-used
                        missionNamespace setVariable ["GAIA_RESPAWN_" + str(_x), nil];

                        deleteGroup _x;
                    };

                    sleep .1;

                } foreach allGroups;

                sleep 2;
        	};
    	};
};




//////////////////////////////////////
//Init Headless Client
//////////////////////////////////////

if (!(isServer) && !(hasInterface)) then {
	QRF_HCconnected = true;
	publicVariable "QRF_HCconnected";
};

//////////////////////////////////////
//Init Server
//////////////////////////////////////

if (isServer) then {

	//////////////////////////////////////
	// Build Stations and Objectives Arrays
	//////////////////////////////////////

	_localLocs = nearestLocations [[0,0,0], ["NameLocal"], [] call BIS_fnc_mapSize];
	_mil = [];
	QRF_ObjLocations = [];
	{
		if ((tolower (text _x)) in ["military"]) then {
			_mil pushBack _x;
		};
	} foreach _localLocs;
	QRF_stations = _mil;
	_locTypes = ["NameCity", "NameCityCapital", "NameVillage", "NameLocal"];
	_locs = nearestLocations [ [0,0,0], _locTypes, QRF_objRadius];
	{
		if (!(tolower (text _x)) in ["military"]) then {
			QRF_ObjLocations pushBack _x;
		};
	} foreach _locs;

	publicVariable "QRF_stations";
	publicVariable "QRF_ObjLocations";

	//////////////////////////////////////
	// Choose Station
	//////////////////////////////////////

	QRF_station = QRF_stations call bis_fnc_selectRandom;

	//////////////////////////////////////
	// Choose Objectives
	//////////////////////////////////////

	for "_i" from 0 to QRF_ObjQty step 1 do 	{
		_obj = QRF_ObjLocations call bis_fnc_selectRandom;
		QRF_ObjLocations = QRF_ObjLocations - [_obj];
		QRF_Objectives pushBack _obj;
	};
	publicVariable "QRF_Objectives";
	{
		_null = [_x] call QRF_fnc_createObjective;
	} forEach QRF_Objectives;
};

//////////////////////////////////////
//Init Clients
//////////////////////////////////////

if (isDedicated || !hasInterface) exitWith {};


//////////////////////////////////////
//BIS Jukebox
//////////////////////////////////////
if (("bisJukebox" call BIS_fnc_getParamValue) == 1) then {
	_mus = [] spawn BIS_fnc_jukebox;
};

