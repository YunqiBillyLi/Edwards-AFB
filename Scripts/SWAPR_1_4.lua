--- ===================================== SWAPR CONFIG =====================================

  local SWAPR_Prefixes = { "461st_" }  -- Add all the relevant client prefixes / suffixes to this table
  
  local Game_Mode = "MP" -- Must be set to either "SP" or "MP".  If set to "MP", server hook is required!
  
  local Slot_Block = false -- Must be set to either true or false. If true, client slots will be blocked / disabled when their respective replacements are destroyed after an attack (only works in MP!)
  
  local Replacement_Type = "AI" -- Must be set to either "AI" or "Static". If set to "AI", any targeted clients will receive uncontrolled AI replacements. If set to "Static", clients located on open parking spots (or within airbase areas) or on open terrain (far from FARPs and airbases) will receive static replacements (the rest of targeted clients will receive AI replacements instead, to work around DCS bugs)
  
  local Hidden_AI_Replacements = true -- Must be set to either true or false. If true, generated AI replacements will be hidden on F10 map (doesn't work for static replacements and doesn't work in MP!) 
  
  local Sheltered_Replacements = true -- Must be set to either true or false. If true, SWAPR will generate uncontrolled AI replacements for clients located inside sheltered parking spots. If false, no replacements will be generated for sheltered clients

--- ========================== DON'T MODIFY ANY OF THE LINES BELOW! =========================
  
 
 
 _SETTINGS:SetPlayerMenuOff()

  local Reference_Unit_Table = {}
  
  local Spawned_Replacement_Table = {}
  
  local Destroyed_Replacement_Table = {}
  
  local ClientReplaced_Table = {}
  
  local Heading_Table = {}
  
  local Ground_Start_Table = { ["From Parking Area"] = true , ["From Parking Area Hot"] = true , ["From Ground Area"] = true , ["From Ground Area Hot"] = true }

  local Force_Cold_Table = { ["Mi-8MT"] = true , ["SA342L"] = true , ["SA342M"] = true , ["SA342Minigun"] = true , ["SA342Mistral"] = true , ["Ka-50"] = true , ["UH-1H"] = true } 



local function Spawner()
   
   local ClientSET = SET_CLIENT:New():FilterActive(Active):FilterPrefixes(SWAPR_Prefixes):FilterOnce()
  
   for i, GroupTable in pairs( Reference_Unit_Table ) do
       
       if ClientSET:FindClient(GroupTable.ClientName) == nil and GroupTable.ReplacementType == "AI" and trigger.misc.getUserFlag(GroupTable.ClientName.."_Destroyed") ~= 999 then
          
          for UnitNumber, UnitTable in pairs( GroupTable.units ) do
             
              if Unit.getByName(UnitTable.name) == nil and GroupTable.CarrierObject == 0 and Destroyed_Replacement_Table[UnitTable.name] == "Enabled" and ClientReplaced_Table[UnitTable.name] ~= nil then
                 
                 coalition.addGroup(GroupTable.CountryID, GroupTable.CategoryID, GroupTable)
                 
                 ClientReplaced_Table[UnitTable.name] = nil
              end
          end
       end
       
       
       if ClientSET:FindClient(GroupTable.ClientName) == nil and GroupTable.ReplacementType == "Static" and GroupTable.Sheltered == "false" and Destroyed_Replacement_Table[GroupTable.ClientName.."_Replacement"] == "Enabled" and ClientReplaced_Table[GroupTable.ClientName.."_Replacement"] ~= nil and trigger.misc.getUserFlag(GroupTable.ClientName.."_Destroyed") ~= 999 then
          
          if StaticObject.getByName(GroupTable.ClientName.."_Replacement") == nil or StaticObject.getByName(GroupTable.ClientName.."_Replacement"):isExist() ~= true then
             
             coalition.addStaticObject(GroupTable.CountryID, GroupTable)
          
             ClientReplaced_Table[GroupTable.ClientName.."_Replacement"] = nil
          end
       end 
   end
end
  

local function DestroyHeading(Initiator_Unit)
      Initiator_Unit:destroy()
      Heading_Table[Initiator_Unit:getName()] = nil
end

Birth_Event_Handler_MOOSE = EVENTHANDLER:New()

Birth_Event_Handler_MOOSE:HandleEvent(EVENTS.Birth)

function Birth_Event_Handler_MOOSE:OnEventBirth(EventData)   
   
   
   if EventData.initiator:getCategory() == Object.Category.UNIT and Heading_Table[EventData.initiator:getName()] ~= nil then
          
      Heading_Table[EventData.initiator:getName()].units[1].heading = UTILS.ToRadian( UNIT:Find(EventData.initiator):GetHeading() )
      
      timer.scheduleFunction(DestroyHeading, EventData.initiator , timer.getTime() + 3) 
   end
   
   local ClientSET2 = SET_CLIENT:New():FilterActive(Active):FilterPrefixes(SWAPR_Prefixes):FilterOnce()
        
       if ClientSET2:FindClient(EventData.initiator:getName()) and Reference_Unit_Table[EventData.initiator:getName().."_Replacement"] ~= nil then
          
          if Reference_Unit_Table[EventData.initiator:getName().."_Replacement"].CarrierName == 0 then   
        
             Spawner()                                                
          end       
       end
       
       
       if EventData.initiator:getCategory() == Object.Category.UNIT then
       
          if EventData.initiator:getPlayerName() == nil and Reference_Unit_Table[EventData.initiator:getName()] ~= nil then 
          
             local Spawned_Replacement = { 
                                            ["Initiator"] = EventData.initiator ,
                                            ["InitiatorCategory"] = EventData.initiator:getCategory() ,
                                            ["ClientName"] = Reference_Unit_Table[EventData.initiator:getName()].ClientName ,
                                            ["CoalitionID"] = Reference_Unit_Table[EventData.initiator:getName()].CoalitionID ,
                                            ["CountryID"] = Reference_Unit_Table[EventData.initiator:getName()].CountryID ,
                                            ["CarrierObject"] = Reference_Unit_Table[EventData.initiator:getName()].CarrierObject ,
                                            ["CarrierType"] = Reference_Unit_Table[EventData.initiator:getName()].CarrierType ,
                                            ["CarrierName"] = Reference_Unit_Table[EventData.initiator:getName()].CarrierName ,
                                            ["Closest_Base"] = Reference_Unit_Table[EventData.initiator:getName()].Closest_Base ,
                                            ["Closest_FARP"] = Reference_Unit_Table[EventData.initiator:getName()].Closest_FARP ,
                                            
                                          }
             
             Spawned_Replacement_Table[Spawned_Replacement.ClientName.."_Replacement"] = Spawned_Replacement
          end
       
       elseif EventData.initiator:getCategory() == Object.Category.STATIC and Reference_Unit_Table[EventData.initiator:getName()] ~= nil then
       
              local Spawned_Replacement = { 
                                            ["Initiator"] = EventData.initiator ,
                                            ["InitiatorCategory"] = EventData.initiator:getCategory() ,
                                            ["ClientName"] = Reference_Unit_Table[EventData.initiator:getName()].ClientName ,
                                            ["CoalitionID"] = Reference_Unit_Table[EventData.initiator:getName()].CoalitionID ,
                                            ["CountryID"] = Reference_Unit_Table[EventData.initiator:getName()].CountryID ,
                                            ["CarrierObject"] = Reference_Unit_Table[EventData.initiator:getName()].CarrierObject ,
                                            ["CarrierType"] = Reference_Unit_Table[EventData.initiator:getName()].CarrierType ,
                                            ["CarrierName"] = Reference_Unit_Table[EventData.initiator:getName()].CarrierName ,
                                            ["Closest_Base"] = Reference_Unit_Table[EventData.initiator:getName()].Closest_Base ,
                                            ["Closest_FARP"] = Reference_Unit_Table[EventData.initiator:getName()].Closest_FARP ,
                                            
                                           }
             
              Spawned_Replacement_Table[Spawned_Replacement.ClientName.."_Replacement"] = Spawned_Replacement
       end
end


local function AliveCheck(Replacement_Param_Table)
   
      if Replacement_Param_Table.ReplacementHit:isExist() ~= true then   
                 
         if Spawned_Replacement_Table[Replacement_Param_Table.ReplacementClientName.."_Replacement"] ~= nil then
          
            trigger.action.setUserFlag( Replacement_Param_Table.ReplacementClientName.."_Destroyed" , 999 )
        
            Spawned_Replacement_Table[Replacement_Param_Table.ReplacementClientName.."_Replacement"] = nil
             
            Destroyed_Replacement_Table[Replacement_Param_Table.ReplacementClientName.."_Replacement"] = "Disabled"
         end
      end 
end


if Slot_Block == true then

   Hit_Event_Handler_MOOSE = EVENTHANDLER:New()

   Hit_Event_Handler_MOOSE:HandleEvent(EVENTS.Hit)

   function Hit_Event_Handler_MOOSE:OnEventHit(EventData)
       
      if EventData.TgtDCSUnit ~= nil then 
         
         local Target = EventData.TgtDCSUnit 
   
         for i , ReplacementParam in pairs( Spawned_Replacement_Table ) do
       
             if Target == ReplacementParam.Initiator then
          
                local ReplacementHit = ReplacementParam.Initiator
                local ReplacementClientName = ReplacementParam.ClientName
             
                local Replacement_Param_Table = { ReplacementHit = ReplacementHit , ReplacementClientName = ReplacementClientName }
          
                timer.scheduleFunction(AliveCheck, Replacement_Param_Table , timer.getTime() + 2)
             end
         end
      end
   end 
end



local function SpawnHeadingStatics(Param_Table)
      
      local Replacement_Static_1 = {  
                                     ["hidden"] = Hidden_AI_Replacements ,
                                     ["hiddenOnPlanner"] = Hidden_AI_Replacements ,
                                     ["ClientName"] = Param_Table.Client_Name ,
                                     ["name"] = Param_Table.Client_Name.."_Replacement" ,
                                     ["groupId"] = nil ,
                                     ["CoalitionID"] = Param_Table.Heading_Templ.CoalitionID ,
                                     ["CountryID"] = Param_Table.Heading_Templ.CountryID ,
                                     ["CategoryID"] = Param_Table.Heading_Templ.CategoryID ,
                                     ["CarrierObject"] = 0 ,
                                     ["CarrierType"] = 0 ,
                                     ["CarrierName"] = 0 ,
                                     ["ReplacementType"] = "Static",
                                     ["Sheltered"] = "false",
                                     ["Closest_Base"] = Param_Table.Heading_Templ.Closest_Base ,
                                     ["Closest_FARP"] = Param_Table.Heading_Templ.Closest_FARP ,
                                     
                                     ["route"] = Param_Table.Heading_Templ.route
                                     
                                    }
                                    
                                    for k , unit_subtable in pairs( Param_Table.Heading_Templ.units ) do 
                              
                                        if unit_subtable.name == Param_Table.Client_Name.."_Heading" then
                                 
                                           if type(k) == "number" then
                                              
                                              Replacement_Static_1.heading = Heading_Table[Param_Table.Client_Name.."_Heading"].units[1].heading
                                              Replacement_Static_1.type = unit_subtable.type   
                                              Replacement_Static_1.y = unit_subtable.y
                                              Replacement_Static_1.x = unit_subtable.x
                                              Replacement_Static_1.livery_id = unit_subtable.livery_id
                                              Replacement_Static_1.unitId = nil
                                              
                                              Replacement_Static_1["units"] = { [1] = unit_subtable }
                                              Replacement_Static_1.units[1].livery_id = unit_subtable.livery_id
                                              Replacement_Static_1.units[1].heading = Heading_Table[Param_Table.Client_Name.."_Heading"].units[1].heading
                                              Replacement_Static_1.units[1].name = Param_Table.Client_Name.."_Replacement"
                                              Replacement_Static_1.units[1].unitId = nil
                                              Replacement_Static_1.units[1].y = unit_subtable.y
                                              Replacement_Static_1.units[1].x = unit_subtable.x
                                              Replacement_Static_1.units[1].CoalitionID = Param_Table.Heading_Templ.CoalitionID
                                              Replacement_Static_1.units[1].CountryID = Param_Table.Heading_Templ.CountryID
                                              Replacement_Static_1.units[1].CategoryID = Param_Table.Heading_Templ.CategoryID 
                                       
                                              
                                              if Param_Table.Airbase_zone == false and Param_Table.G_Mode == "SP" then
                                                 
                                                 Replacement_Static_1.y = unit_subtable.y + 10
                                                 Replacement_Static_1.x = unit_subtable.x + 10
                                                 Replacement_Static_1.units[1].y = unit_subtable.y + 10
                                                 Replacement_Static_1.units[1].x = unit_subtable.x + 10
                                              end
                                           end
                                        end
                                    end
                          
                          Reference_Unit_Table[Param_Table.Client_Name.."_Replacement"] = Replacement_Static_1
  
end


local function StaticHeading_Madness( Database_Template_Table , ClientName , Airbase_Area , Game_Mode, FARP_Based , Park_Spot , ClosestAirbase , ClosestFARP ) 
      
                          local Heading_Template = {
                                                     
                                                     ["ClientName"] = ClientName ,
                                                     ["task"] = "Nothing" ,
                                                     ["uncontrolled"] = true ,
                                                     ["hidden"] = Hidden_AI_Replacements ,
                                                     ["hiddenOnPlanner"] = Hidden_AI_Replacements ,
                                                     ["y"] = Database_Template_Table.y ,
                                                     ["x"] = Database_Template_Table.x ,
                                                     ["name"] = ClientName.."_Heading" , 
                                                     ["CoalitionID"] = Database_Template_Table.CoalitionID , 
                                                     ["CountryID"] = Database_Template_Table.CountryID ,
                                                     ["CategoryID"] = Database_Template_Table.CategoryID ,
                                                     ["groupId"] = 1 ,
                                                     ["CarrierObject"] = 0 ,
                                                     ["CarrierType"] = 0 ,
                                                     ["CarrierName"] = 0 ,
                                                     ["ReplacementType"] = "AI",
                                                     ["Sheltered"] = "false",
                                                     
                                                     ["route"] = Database_Template_Table.route
                                                  
                                                   } -- end of Unit_Template
                               
                             
                             for k , unit_subtable in pairs( Database_Template_Table.units ) do 
                                 
                                 if Database_Template_Table.units[k].name == ClientName then
                                    
                                    if type(k) == "number" then
                                      
                                       Heading_Template["units"] = { [1] = Database_Template_Table.units[k] }
                                       Heading_Template.units[1].skill = "Excellent"
                                       Heading_Template.units[1].name = ClientName.."_Heading"
                                       Heading_Template.units[1].unitId = 1
                                       Heading_Template.units[1].payload.fuel = 0
                                       Heading_Template.units[1].payload.pylons = {}
                                       Heading_Template.units[1].CoalitionID = Database_Template_Table.CoalitionID
                                       Heading_Template.units[1].CountryID = Database_Template_Table.CountryID
                                       Heading_Template.units[1].CategoryID = Database_Template_Table.CategoryID
                                       
                                    end
                                 end
                             end
                             
                             if Heading_Template.route.points[1].action and Heading_Template.route.points[1].action == "From Parking Area Hot" then
                                Heading_Template.route.points[1].type = "TakeOffParking"
                                Heading_Template.route.points[1].action = "From Parking Area"
                             end
                             
                             if Heading_Template.route.points[1].action and Heading_Template.route.points[1].action == "From Ground Area Hot" and Force_Cold_Table[Heading_Template.units[1].type] then
                                Heading_Template.route.points[1].type = "TakeOffGround"
                                Heading_Template.route.points[1].action = "From Ground Area"
                             end
                             
                             if ( Airbase_Area == true or Park_Spot == true ) and FARP_Based ~= true then
                                Heading_Template["Closest_Base"] = ClosestAirbase:GetName()
                                Heading_Template["Closest_FARP"] = 0 
                                
                             elseif Airbase_Area ~= true and Park_Spot ~= true and FARP_Based ~= true then   
                                Heading_Template["Closest_Base"] = 0
                                Heading_Template["Closest_FARP"] = 0 
                             end
                             
                             
                             Heading_Table[Heading_Template.ClientName.."_Heading"] = Heading_Template
                             
                             coalition.addGroup(Heading_Template.CountryID, Heading_Template.CategoryID, Heading_Template)
                             
                             local HeadingStatics_Param_Table = { Heading_Templ = Heading_Template , Client_Name = ClientName , Airbase_zone = Airbase_Area , G_Mode = Game_Mode }
                             
                             timer.scheduleFunction(SpawnHeadingStatics, HeadingStatics_Param_Table , timer.getTime() + 1 )
                             
end  


  local SWAPR_SET = SET_CLIENT:New():FilterPrefixes(SWAPR_Prefixes):FilterOnce()
  
  for i , Unborn_Client in pairs( SWAPR_SET:GetSetObjects() ) do
      
      Park_Spot = nil
      Sheltered = nil
      Airbase_Area = nil
      On_Ground = nil
      FARP_Based = nil
      
            
      if Unborn_Client:GetName() then
                           
         local Unborn_ClientName = Unborn_Client:GetName()
 
         if _DATABASE:GetGroupTemplateFromUnitName(Unborn_ClientName) ~= nil then
            
            local Database_Template_Table = _DATABASE:GetGroupTemplateFromUnitName(Unborn_ClientName)
            
            local ReferenceCoord = COORDINATE:New(Database_Template_Table.x , 0 , Database_Template_Table.y)
            
            local ClosestAirbase, Airbase_Distance = ReferenceCoord:GetClosestAirbase2(Airbase.Category.AIRDROME)
                
            local ClosestFARP, FARP_Distance = ReferenceCoord:GetClosestAirbase2(Airbase.Category.HELIPAD)
            
            local ClosestCarrier, Carrier_Distance = ReferenceCoord:GetClosestAirbase2(Airbase.Category.SHIP)
            
            local ParkCoord = ReferenceCoord:GetClosestParkingSpot(ClosestAirbase)
            
            
            if ClosestAirbase ~= nil and ReferenceCoord:Get2DDistance(ParkCoord) < 20 then
               
               for i, ParkData in pairs( ClosestAirbase:GetParkingData(false) ) do   
                   
                   if ParkData.vTerminalPos.x == ParkCoord.x and ParkData.vTerminalPos.z == ParkCoord.z then
                      
                      if ParkData.Term_Type ~= 68 then
                         
                         Park_Spot = true    
                         Sheltered = false
 
                      elseif ParkData.Term_Type == 68 then
                         
                         Park_Spot = true 
                         Sheltered = true
                      end
                   end 
               end           
            end
            
            if ClosestAirbase ~= nil and ReferenceCoord:Get2DDistance(ParkCoord) >= 20 then
                  
                   Sheltered = false
                   Park_Spot = false
                   
                   if Airbase_Distance < 4000 then 
                     
                      Airbase_Area = true
                      
                   elseif Airbase_Distance >= 4000 then
                        
                          if ( Carrier_Distance == nil or Carrier_Distance >= 300 ) then
                             
                             Airbase_Area = false
                          end
                   end
            end
            
            
            if Database_Template_Table.route.points[1].action and Ground_Start_Table[Database_Template_Table.route.points[1].action] then
               On_Ground = true
            else  
               On_Ground = false
            end
            
            
            if FARP_Distance and On_Ground == true then 
               if FARP_Distance < 100 then
                  FARP_Based = true
               else 
                  FARP_Based = false
               end
            end
                
                
                if ( Carrier_Distance == nil or Carrier_Distance >= 300 ) and ClosestAirbase ~= nil and On_Ground then
                   if FARP_Distance == nil or FARP_Distance >= 100 then
                      if ( Sheltered == false and Replacement_Type == "Static" and Park_Spot == true and Database_Template_Table.route.points[1].type ~= "TakeOffGround" and Database_Template_Table.route.points[1].action ~= "From Ground Area" ) 
                      or ( Sheltered == false and Replacement_Type == "Static" and Airbase_Area == false ) then
                         
                         StaticHeading_Madness( Database_Template_Table , Unborn_ClientName , Airbase_Area , Game_Mode , FARP_Based , Park_Spot , ClosestAirbase , ClosestFARP )
                      end           
                   end           
                end            
                
                
                if ( Carrier_Distance == nil or Carrier_Distance >= 300 ) and ClosestAirbase ~= nil and On_Ground then
                   if FARP_Distance == nil or FARP_Distance >= 100 then
                      if ( Sheltered == false and Replacement_Type == "AI" )
                      or ( Replacement_Type == "Static" and Sheltered == false and Airbase_Area == true and ( (Database_Template_Table.route.points[1].type == "TakeOffGround" and Database_Template_Table.route.points[1].action == "From Ground Area") or Database_Template_Table.route.points[1].action == "From Ground Area Hot")) then
                           
                            local Unit_Template_1 = {
                                                     
                                                      ["ClientName"] = Unborn_ClientName ,
                                                      ["task"] = "Nothing" ,
                                                      ["uncontrolled"] = true ,
                                                      ["hidden"] = Hidden_AI_Replacements ,
                                                      ["hiddenOnPlanner"] = Hidden_AI_Replacements ,
                                                      ["y"] = Database_Template_Table.y ,
                                                      ["x"] = Database_Template_Table.x ,
                                                      ["name"] = Unborn_ClientName.."_Replacement" , 
                                                      ["CoalitionID"] = Database_Template_Table.CoalitionID , 
                                                      ["CountryID"] = Database_Template_Table.CountryID ,
                                                      ["CategoryID"] = Database_Template_Table.CategoryID ,
                                                      ["groupId"] = nil ,
                                                      ["CarrierObject"] = 0 ,
                                                      ["CarrierType"] = 0 ,
                                                      ["CarrierName"] = 0 ,
                                                      ["ReplacementType"] = "AI" ,
                                                      ["Sheltered"] = "false" ,
                                                      
                                                      ["route"] = Database_Template_Table.route
                                                  
                                                     } -- end of Unit_Template
                          
                             
                             for k , unit_subtable in pairs( Database_Template_Table.units ) do 
                                 
                                 if Database_Template_Table.units[k].name == Unborn_ClientName then
                                    
                                    if type(k) == "number" then
                                      
                                       Unit_Template_1["units"] = { [1] = Database_Template_Table.units[k] }
                                       Unit_Template_1.units[1].skill = "Excellent"
                                       Unit_Template_1.units[1].name = Unborn_ClientName.."_Replacement"
                                       Unit_Template_1.units[1].unitId = nil
                                       Unit_Template_1.units[1].payload.fuel = 0
                                       Unit_Template_1.units[1].payload.pylons = {}
                                       Unit_Template_1.units[1].CoalitionID = Database_Template_Table.CoalitionID
                                       Unit_Template_1.units[1].CountryID = Database_Template_Table.CountryID
                                       Unit_Template_1.units[1].CategoryID = Database_Template_Table.CategoryID
                                       
                                       if ( Airbase_Area ~= true and Park_Spot ~= true and FARP_Based ~= true ) or (Airbase_Area == true and Park_Spot ~= true and FARP_Based ~= true) then
                                          Unit_Template_1.units[1].y = Unit_Template_1.units[1].y + 10
                                          Unit_Template_1.units[1].x = Unit_Template_1.units[1].x + 10
                                       end
                                       
                                    end
                                 end
                             end
                             
                             if Unit_Template_1.route.points[1].action and Unit_Template_1.route.points[1].action == "From Parking Area Hot" then
                                Unit_Template_1.route.points[1].type = "TakeOffParking"
                                Unit_Template_1.route.points[1].action = "From Parking Area"
                             end
                             
                             if Unit_Template_1.route.points[1].action and Unit_Template_1.route.points[1].action == "From Ground Area Hot" and Force_Cold_Table[Unit_Template_1.units[1].type] then
                                Unit_Template_1.route.points[1].type = "TakeOffGround"
                                Unit_Template_1.route.points[1].action = "From Ground Area"
                             end
                             
                             if ( Airbase_Area == true or Park_Spot == true ) or (Airbase_Area == true and Park_Spot ~= true) and FARP_Based ~= true then
                                Unit_Template_1["Closest_Base"] = ClosestAirbase:GetName()
                                Unit_Template_1["Closest_FARP"] = 0
                            
                             elseif Airbase_Area ~= true and Park_Spot ~= true and FARP_Based ~= true then   
                                Unit_Template_1["Closest_Base"] = 0
                                Unit_Template_1["Closest_FARP"] = 0
                            
                             end
                         
                         Reference_Unit_Table[Unborn_ClientName.."_Replacement"] = Unit_Template_1
                      end
                   end
                end
                      
                
                if ( Carrier_Distance == nil or Carrier_Distance >= 300 ) and ClosestAirbase ~= nil and On_Ground then
                   if FARP_Distance == nil or FARP_Distance >= 100 then
                      if Sheltered == true and Sheltered_Replacements == true then
                      
                           local Unit_Template_2 = {
                                                     
                                                     ["ClientName"] = Unborn_ClientName ,
                                                     ["task"] = "Nothing" ,
                                                     ["uncontrolled"] = true ,
                                                     ["hidden"] = Hidden_AI_Replacements ,
                                                     ["hiddenOnPlanner"] = Hidden_AI_Replacements ,
                                                     ["y"] = Database_Template_Table.y ,
                                                     ["x"] = Database_Template_Table.x ,
                                                     ["name"] = Unborn_ClientName.."_Replacement" , 
                                                     ["CoalitionID"] = Database_Template_Table.CoalitionID , 
                                                     ["CountryID"] = Database_Template_Table.CountryID ,
                                                     ["CategoryID"] = Database_Template_Table.CategoryID ,
                                                     ["groupId"] = nil ,
                                                     ["CarrierObject"] = 0 ,
                                                     ["CarrierType"] = 0 ,
                                                     ["CarrierName"] = 0 ,
                                                     ["ReplacementType"] = "AI" ,
                                                     ["Sheltered"] = "true" ,
                                                     ["Closest_Base"] = ClosestAirbase:GetName() ,
                                                     ["Closest_FARP"] = 0 ,
                                                     
                                                     ["route"] = Database_Template_Table.route
                                                  
                                                    } -- end of Unit_Template
                          
                         
                             for k , unit_subtable in pairs( Database_Template_Table.units ) do 
                                 
                                 if Database_Template_Table.units[k].name == Unborn_ClientName then
                                    
                                    if type(k) == "number" then
                                      
                                       Unit_Template_2["units"] = { [1] = Database_Template_Table.units[k] }
                                       Unit_Template_2.units[1].skill = "Excellent"
                                       Unit_Template_2.units[1].name = Unborn_ClientName.."_Replacement"
                                       Unit_Template_2.units[1].unitId = nil
                                       Unit_Template_2.units[1].payload.fuel = 0
                                       Unit_Template_2.units[1].payload.pylons = {}
                                       Unit_Template_2.units[1].CoalitionID = Database_Template_Table.CoalitionID
                                       Unit_Template_2.units[1].CountryID = Database_Template_Table.CountryID
                                       Unit_Template_2.units[1].CategoryID = Database_Template_Table.CategoryID
                                    end
                                 end
                             end
                             
                             if Unit_Template_2.route.points[1].action and Unit_Template_2.route.points[1].action == "From Parking Area Hot" then
                                Unit_Template_2.route.points[1].type = "TakeOffParking"
                                Unit_Template_2.route.points[1].action = "From Parking Area"
                             end
                         
                         Reference_Unit_Table[Unborn_ClientName.."_Replacement"] = Unit_Template_2
                      end
                   end 
                end  
                   
                
                if FARP_Distance ~= nil and FARP_Distance < 100 and ClosestFARP ~= nil and On_Ground then
                     
                      local Unit_Template_3 = {
                                                     
                                                ["ClientName"] = Unborn_ClientName ,
                                                ["task"] = "Nothing" ,
                                                ["uncontrolled"] = true ,
                                                ["hidden"] = Hidden_AI_Replacements ,
                                                ["hiddenOnPlanner"] = Hidden_AI_Replacements ,
                                                ["y"] = Database_Template_Table.y ,
                                                ["x"] = Database_Template_Table.x ,
                                                ["name"] = Unborn_ClientName.."_Replacement" , 
                                                ["CoalitionID"] = Database_Template_Table.CoalitionID , 
                                                ["CountryID"] = Database_Template_Table.CountryID ,
                                                ["CategoryID"] = Database_Template_Table.CategoryID ,
                                                ["groupId"] = nil ,
                                                ["CarrierObject"] = 0 ,
                                                ["CarrierType"] = 0 ,
                                                ["CarrierName"] = 0 ,
                                                ["ReplacementType"] = "AI",
                                                ["Sheltered"] = "false" ,
                                                ["Closest_Base"] = 0 ,
                                                ["Closest_FARP"] = ClosestFARP:GetName() ,
                                               
                                                ["route"] = Database_Template_Table.route
                                                  
                                               } -- end of Unit_Template
                               
                                
                                for k , unit_subtable in pairs( Database_Template_Table.units ) do 
                                 
                                    if Database_Template_Table.units[k].name == Unborn_ClientName then
                                    
                                       if type(k) == "number" then
                                          
                                          Unit_Template_3["units"] = { [1] = Database_Template_Table.units[k] }
                                          Unit_Template_3.units[1].skill = "Excellent"
                                          Unit_Template_3.units[1].speed = 0
                                          Unit_Template_3.units[1].name = Unborn_ClientName.."_Replacement"
                                          Unit_Template_3.units[1].unitId = nil
                                          Unit_Template_3.units[1].payload.fuel = 0
                                          Unit_Template_3.units[1].payload.pylons = {}
                                          Unit_Template_3.units[1].CoalitionID = Database_Template_Table.CoalitionID
                                          Unit_Template_3.units[1].CountryID = Database_Template_Table.CountryID
                                          Unit_Template_3.units[1].CategoryID = Database_Template_Table.CategoryID
                                          Unit_Template_3.units[1].y = Unit_Template_3.units[1].y + 10
                                          Unit_Template_3.units[1].x = Unit_Template_3.units[1].x + 10
                                          
                                       end     
                                    end   
                                end
                                
                                if Unit_Template_3.route.points[1].action and Unit_Template_3.route.points[1].action == "From Ground Area Hot" and Force_Cold_Table[Unit_Template_3.units[1].type] then
                                   Unit_Template_3.route.points[1].type = "TakeOffGround"
                                   Unit_Template_3.route.points[1].action = "From Ground Area"
                                end
                     
                   Reference_Unit_Table[Unborn_ClientName.."_Replacement"] = Unit_Template_3
                end             
        end
     end  
  end
  

local function Loops_and_Spawn()
   
   for i , GroupTable in pairs( Reference_Unit_Table ) do
      
       trigger.action.setUserFlag( GroupTable.ClientName.."_Destroyed" , 1)
      
       Destroyed_Replacement_Table[GroupTable.ClientName.."_Replacement"] = "Enabled"
      
       ClientReplaced_Table[i] = "Born"
   end   
   
   Spawner()
   
   for i , GroupTable in pairs( Reference_Unit_Table ) do
       ClientReplaced_Table[i] = nil
   end
end 

timer.scheduleFunction(Loops_and_Spawn, nil , timer.getTime() + 5)


function FlagChecker()
       
    for i , GroupTable in pairs( Reference_Unit_Table ) do
       
        if trigger.misc.getUserFlag(GroupTable.ClientName) ~= nil and trigger.misc.getUserFlag(GroupTable.ClientName) ~= 0 then     
           
           if Unit.getByName(GroupTable.ClientName.."_Replacement") ~= nil and Unit.getByName(GroupTable.ClientName.."_Replacement"):isExist() ~= nil then
              
              ClientReplaced_Table[GroupTable.ClientName.."_Replacement"] = "Replaced by client"
              
              Unit.getByName(GroupTable.ClientName.."_Replacement"):destroy()
              
              trigger.action.setUserFlag( GroupTable.ClientName , 0)  
           end
        
           if StaticObject.getByName(GroupTable.ClientName.."_Replacement") ~= nil then
              
              ClientReplaced_Table[GroupTable.ClientName.."_Replacement"] = "Replaced by client"
              
              StaticObject.getByName(GroupTable.ClientName.."_Replacement"):destroy()
              
              trigger.action.setUserFlag( GroupTable.ClientName , 0)  
           end
           
           
           if Unit.getByName(GroupTable.ClientName.."_Replacement") == nil and StaticObject.getByName(GroupTable.ClientName.."_Replacement") == nil then
                  
              trigger.action.setUserFlag( GroupTable.ClientName , 0)
           end
        end
    end
    return timer.getTime() + 1
end


  if Game_Mode == "SP" then
      
     Handler = {}

     function Handler:onEvent(event)
   
              if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT and event.initiator:getPlayerName() ~= nil then 
                 
                 if Unit.getByName(event.initiator:getName().."_Replacement") ~= nil and Unit.getByName(event.initiator:getName().."_Replacement"):isExist() ~= nil then
                    
                    ClientReplaced_Table[event.initiator:getName().."_Replacement"] = "Replaced by client"
                    
                    Unit.getByName(event.initiator:getName().."_Replacement"):destroy()
                 end
                 
                 if StaticObject.getByName(event.initiator:getName().."_Replacement") ~= nil then     
                    
                    ClientReplaced_Table[event.initiator:getName().."_Replacement"] = "Replaced by client"
                    
                    StaticObject.getByName(event.initiator:getName().."_Replacement"):destroy()
                 end
              end
     end 
     
     world.addEventHandler(Handler)
  
  elseif Game_Mode == "MP" then 
     
     timer.scheduleFunction(FlagChecker, nil, timer.getTime() + 1)
  end
  
  local SWAPR_SET_2 = SET_CLIENT:New():FilterPrefixes(SWAPR_Prefixes):FilterOnce()
  
  MESSAGE:New("*** SWAPR Config ***".."\n\nGame_Mode = "..Game_Mode.."\nSlot_Block = "..tostring(Slot_Block).."\nReplacement_Type = "..Replacement_Type.."\nHidden_AI_Replacements = "..tostring(Hidden_AI_Replacements)..
  "\nSheltered_Replacements = "..tostring(Sheltered_Replacements).."\n\nSWAPR_SET count = "..SWAPR_SET_2:Count(), 20):ToAll() 