do
--create an instance of the IADS
redIADS = SkynetIADS:create('Iraq')


--add all units with unit name beginning with 'EW' to the IADS:
redIADS:addEarlyWarningRadarsByPrefix('EW')

--add all groups begining with group name 'SAM' to the IADS:
redIADS:addSAMSitesByPrefix('SAM')

redIADS:getSAMSiteByGroupName('SAM Enemy SA-6'):setActAsEW(true)

--set the sa15 as point defence for the SA-10 site, we set it to always react to a HARM so we can demonstrate the point defence mechanism in Skynet
local zsu = redIADS:getSAMSiteByGroupName('AAA Enemy ZSU-34-4-1')
redIADS:getSAMSiteByGroupName('SAM Enemy SA-6'):addPointDefence(zsu):setHARMDetectionChance(50)

-- activate the IADS
redIADS:activate()	

end