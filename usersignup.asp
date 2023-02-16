<?php

# sample code Airbnb
// prerequisite files
require_once 'conf.php';
require_once 'class/class.smarty/Smarty.class.php';
require_once 'class/class.content.php';
require_once 'class/class.gamehandler.php';

$Handler = new Handler();
$Handler->caching = false;

// if user data fields return empty
if (empty($_POST)) $Handler->plain('status=Error&strReason=Invalid Input');
$_POST = $Handler->MySQL('EscapeArray', $_POST);

// user registration limiter
$Registration = $Handler->MySQL('FetchObject', "SELECT COUNT(*) AS 'Limit' FROM users WHERE DateCreated >= CURDATE()");
if ($Registration->Limit > Configuration::getPublic('RegistrationLimit')) $Handler->plain('status=Error&strReason=We\'ve reached our limit of '.Configuration::getPublic('RegistrationLimit').' user registrations for today. Please come back again tomorrow!');

// limits failed signup attemps from the same ip addresses
$Registration = $Handler->MySQL('FetchObject', "SELECT COUNT(*) AS 'Limit' FROM users WHERE Address = '{$_SERVER['REMOTE_ADDR']}' AND DateCreated >= CURDATE()");
if ($Registration->Limit > 5) $Handler->plain('status=Error&strReason=You have reached maximum number of registration attempts. Please try again later.');

// prevents duplicate usernames during user signup by cross-referencing the username in database.
$ResultSet = $Handler->MySQL('Query', "SELECT id FROM `users` WHERE Name = '{$_POST["strUsername"]}'");
if ($ResultSet->num_rows > 0) $Handler->plain('status=Taken&strReason=The username is already in use by another character.');

// user data        
$Hash = $Handler->encryptPassword($_POST["strUsername"], $_POST["strPassword"]);
$CountryCode = $Handler->getCountryCode();
$ActivationFlag = Configuration::getPublic('EmailActivation') ? 0 : 5;
$FILTER_VALIDATE_EMAIL = filter_var($_POST["strEmail"], FILTER_VALIDATE_EMAIL);
$Domain = explode('@', $_POST["strEmail"]);
$Domain = array_pop($Domain);
$MX_RECORD_CHECK = checkdnsrr($Domain, 'MX');

$_POST["intColorHair"] = dechex($_POST["intColorHair"]);
$_POST["intColorSkin"] = dechex($_POST["intColorSkin"]);
$_POST["intColorEye"] = dechex($_POST["intColorEye"]);

// subtmits user data into database
$Handler->MySQL('Query', "INSERT INTO `users` (`Name`, `Hash`, `HairID`, `Access`, `ActivationFlag`, `PermamuteFlag`, `Country`, `Age`, `Gender`, `Email`, `Level`, `Gold`, `Coins`, `Exp`, `ColorHair`, `ColorSkin`, `ColorEye`, `ColorBase`, `ColorTrim`, `ColorAccessory`, `SlotsBag`, `SlotsBank`, `SlotsHouse`, `DateCreated`, `LastLogin`, `CpBoostExpire`, `RepBoostExpire`, `GoldBoostExpire`, `ExpBoostExpire`, `UpgradeExpire`, `UpgradeDays`, `Upgraded`, `Achievement`, `Settings`, `DailyQuests0`, `DailyQuests1`, `DailyQuests2`, `MonthlyQuests0`, `LastArea`, `CurrentServer`, `HouseInfo`, `KillCount`, `DeathCount`, `Address`) VALUES ('{$_POST["strUsername"]}', '{$Hash}', {$_POST['HairID']}, 1, {$ActivationFlag}, 0, '{$CountryCode}', {$_POST['intAge']}, '{$_POST["strGender"]}', '{$_POST["strEmail"]}', 1, 10000, 1000, 0, '{$_POST["intColorHair"]}', '{$_POST["intColorSkin"]}', '{$_POST["intColorEye"]}', '000000', '000000', '000000', 40, 0, 20, NOW(), NOW(), '2000-01-01 00:00:00', '2000-01-01 00:00:00', '2000-01-01 00:00:00', '2000-01-01 00:00:00', '2000-01-01 00:00:00', 0, 0, 0, 0, 0, 0, 0, 0, 'faroff-1|Enter|Spawn', 'Offline', '', 0, 0, '{$_SERVER['REMOTE_ADDR']}');"); 
$Handler->UserData = $Handler->getUserObjectByName($_POST["strUsername"]); 
if ($Handler->UserData == NULL) $Handler->plain("status=Error&strReason=Could not create your character. Please contact staff members as soon as possible!");

switch ($_POST['ClassID']) {
    case 2: 
		# Swordsman ( type of class/character in game chosen during signup)
        $Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('2', '{$Handler->UserData->id}', '1', 1, 1957, 0)");
		$Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('994', '{$Handler->UserData->id}', '1', 1, 1957, 0)");
		$Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('996', '{$Handler->UserData->id}', '0', 1, 1957, 0)");
		$Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('997', '{$Handler->UserData->id}', '1', 1, 1957, 0)");
		$Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('998', '{$Handler->UserData->id}', '1', 1, 1957, 0)");
		$Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('971', '{$Handler->UserData->id}', '0', 3, 0, 0)");
		$Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('972', '{$Handler->UserData->id}', '0', 3, 0, 0)");
		$Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('973', '{$Handler->UserData->id}', '0', 3, 0, 0)");
		$Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('974', '{$Handler->UserData->id}', '0', 3, 0, 0)");
        break;
    case 4: 
		# Blacksmith ( type of class/character in game chosen during signup)
        $Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('2008451', '{$Handler->UserData->id}', '1', 1, 1957, 0)");
        break;
    case 3: 
		# Mage ( type of class/character in game chosen during signup)
        $Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('3', '{$Handler->UserData->id}', '1', 1, 1957, 0)");
        break;
    case 5: 
		# Axeman ( type of class/character in game chosen during signup)
        $Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('975', '{$Handler->UserData->id}', '1', 1, 1957, 0)");
        break;
}

$Handler->MySQL('Query', "INSERT INTO `users_items` (itemid, userid, equipped, quantity, EnhID, Bank) VALUES ('995', '{$Handler->UserData->id}', '1', 1, 1957, 0)");
if (Configuration::getPublic('EmailActivation')) $Handler->sendVerification($Handler->UserData);
$Handler->plain($Handler->AuthenticateUser($Hash) ? 'status=Success' :'status=Error&strReason=Account created but failed to be authenticated, please contact an administrator.');
?>
