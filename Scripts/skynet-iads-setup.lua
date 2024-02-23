do
--create an instance of the IADS
redIADS = SkynetIADS:create('USSR')

---debug settings remove from here on if you do not wan't any output on what the IADS is doing by default
local iadsDebug = redIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.radarWentDark = true
iadsDebug.contacts = true
iadsDebug.radarWentLive = true
iadsDebug.noWorkingCommmandCenter = false
iadsDebug.ewRadarNoConnection = false
iadsDebug.samNoConnection = false
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = false
iadsDebug.hasNoPower = false
iadsDebug.harmDefence = true
iadsDebug.samSiteStatusEnvOutput = true
iadsDebug.earlyWarningRadarStatusEnvOutput = true
iadsDebug.commandCenterStatusEnvOutput = true
---end remove debug ---

--add all units with unit name beginning with 'EW' to the IADS:
redIADS:addEarlyWarningRadarsByPrefix('EW')

--add all groups begining with group name 'SAM' to the IADS:
redIADS:addSAMSitesByPrefix('SAM')

---we add a K-50 AWACs, manually. This could just as well be automated by adding an 'EW' prefix to the unit name:
redIADS:addEarlyWarningRadar('Enemy A-50')

redIADS:getSAMSiteByGroupName('SAM Enemy S-300'):setActAsEW(true)

--set the sa15 as point defence for the SA-10 site, we set it to always react to a HARM so we can demonstrate the point defence mechanism in Skynet
local sa15 = redIADS:getSAMSiteByGroupName('SAM Enemy SA-15-1')
redIADS:getSAMSiteByGroupName('SAM Enemy S-300'):addPointDefence(sa15):setHARMDetectionChance(95)

-- activate the IADS
redIADS:activate()	

end