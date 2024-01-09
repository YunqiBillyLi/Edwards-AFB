--- THIS SCRIPT MUST BE PLACED IN C:\Users\<YOUR_USERNAME>\Saved Games\DCS or DCS.openbeta\Scripts\Hooks (within your dedicated server!) ---

--- =================================================== SWAPR HOOK CONFIG ==============================================================

local SWAPR_Prefixes = { "461st_" }  -- Add all the relevant client prefixes / suffixes to this table

--- ========================== DON'T MODIFY ANY OF THE LINES BELOW IF YOU'RE UNFAMILIAR WITH LUA AND MOOSE =============================



SWAPR_Callback_Table = {}
 
function SWAPR_Callback_Table.onPlayerTryChangeSlot(playerID, side, slotID)
   
   if DCS.isServer() and DCS.isMultiplayer() then 
   
      if ( slotID ~= '' and slotID ~= nil ) then
       
         local Unit_Name = DCS.getUnitProperty(slotID, DCS.UNIT_NAME)
        
         for i , Preffix_Suffix in pairs( SWAPR_Prefixes ) do
             
             if type(Unit_Name) == "string" and (string.find(Unit_Name, Preffix_Suffix, 1, true) ~= nil) then
        
                net.dostring_in('server', " trigger.action.setUserFlag(\""..Unit_Name.."\", " .. 666 .. "); ")
             end         
         end 
      end
   end
end   


function SWAPR_Callback_Table.onGameEvent(eventName, playerID, slotID)
         
         if eventName == "change_slot" and slotID ~= nil and slotID ~= '' and playerID ~= nil then
            
            --net.send_chat_to("change_slot event detected!\nplayerID = "..playerID.."\nslotID = "..slotID, playerID)
            
            local Unit_Name = DCS.getUnitProperty(slotID, DCS.UNIT_NAME)
            
            if net.dostring_in('server', " return trigger.misc.getUserFlag(\""..Unit_Name.."_Destroyed\"); ") ~= nil then
               
               local DestroyedFlag = net.dostring_in('server', " return trigger.misc.getUserFlag(\""..Unit_Name.."_Destroyed\"); ")
            
               if DestroyedFlag == "999" then
               
                  local Player_List = net.get_player_list()
               
                  for PlayerIDIndex, playerId in pairs( Player_List ) do
                   
                      local Player_Info = net.get_player_info( playerId )
                      
                      if Player_Info.slot == slotID and playerID == playerId then
                      
                         net.force_player_slot(playerId, 0, '')
                      
                         net.send_chat_to(Unit_Name.." DISABLED!", playerId)
                         net.send_chat_to("CHOOSE ANOTHER SLOT!", playerId)
                      end
                  end
               end
            end   
         end
end

 
DCS.setUserCallbacks(SWAPR_Callback_Table)