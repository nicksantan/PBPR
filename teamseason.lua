-----------------------------------------------------------------------------------------
--
-- teamseason.lua
-- The view that appears when a particular team season is clicked from the list of teamseasons. A list of a given season's players for a particular team.
--
-----------------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	-- Placeholder
    local blah = display.newRetinaText( "blah", 18, 0, "Helvetica-Bold", 12 )
	group:insert( blah )
	blah.isVisible = false;

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

	local group = self.view
	local widget = require "widget"
    currentScene = "teamseason" .. ","..whichTeam ..","..whichTeamSeason;

	local listOptions = {
        top = 44,
        height = 386,
        maskFile = "mask-386.png";
	}
 
	teamSeasonsList = widget.newTableView( listOptions )

	-- onEvent listener for the tableView
	local function onRowTouch( event )
        local row = event.target
        local rowGroup = event.view
 
        if event.phase == "press" then
                if not row.isCategory then rowGroup.alpha = 0.5;
               
                end
 
        elseif event.phase == "release" then
 
                if not row.isCategory then
                        updateHistory(currentScene);
                        -- reRender property tells row to refresh if still onScreen when content moves
                        row.reRender = true
                        local t = split(event.target.id);
                        whichPlayer = t[1];
                       
               			--goto a particular season's roster
                        storyboard.gotoScene( "player_page" );
                end
        end
 
 	   return true
	end
 
	-- onRender listener for the tableView that renders each row
	local function onRowRender( event )
        local row = event.target
        local rowGroup = event.view
       

	    local ilkid
	    local playerFirstName
	    local playerLastName
	    local compStats
	    -- Decompact the row's information into seperate fields   
	    t = split(event.target.id);
		
		ilkid = t[1]
		playerFirstName = t[2]
		playerLastName = t[3] 
		compStats = t[4] 
		
		local totalName
		
		totalName = playerFirstName .. " " .. playerLastName;
	
	    local text = display.newRetinaText( totalName, 18, 0, "Helvetica-Bold", 12 )
    	text:setReferencePoint( display.CenterLeftReferencePoint )
    	text.y = row.height * 0.5
    	
    	local textStats = display.newRetinaText(compStats, 18, 0, "Monaco", 10);
    	textStats:setReferencePoint( display.CenterLeftReferencePoint )
    	textStats.y = row.height * 0.5
        
    	if not row.isCategory then
    		text.x = 10
    		text:setTextColor( 0 )
    		textStats.x = 124 ;
     		textStats:setTextColor(0);
    	end
 
        -- must insert everything into event.view: (tableView requirement)
        rowGroup:insert( text )
   		rowGroup:insert(textStats);
	end
 
	-- Create a row for each Player on that team, that seasonand add it to the tableView:
	for row in db:nrows("SELECT * FROM player_regular_season WHERE team = '"..whichTeam.."' AND year = '"..whichTeamSeason.."' ORDER BY minutes DESC, gp DESC, pts DESC" ) do
    	local rowHeight, rowColor, lineColor, isCategory, id
 		rowHeight = 40;
 	    
 	    local teamName;
        local playerFirstName;
        local playerLastName;
        local gp;
        local ppg;
        local rpg;
        local apg;
        local spg;
        local bpg;
        
 	    playerFirstName = row.firstname;
	    playerLastName = row.lastname;
	    gp = row.gp
	
	    -- Special case for games being under ten
	    if (gp < 10) then
	        gp = " "..gp;
	    end
	
	    ppg = formatStat(row.pts / row.gp,2);
	    rpg = formatStat(row.reb / row.gp,2);
	    apg = formatStat(row.asts / row.gp,2);
	    spg = formatStat(row.stl / row.gp,1);
	    bpg = formatStat(row.blk / row.gp,1);
		
	    local totalName = playerFirstName .. " " .. playerLastName;
	
	    local compStats = gp .. " gp " .. ppg .. " ppg " .. rpg .. " rpg " .. apg .. " apg ";	--let's combine the id to include everything
       
        local tempIlkid
        tempIlkid = row.ilkid;
    
        id = tempIlkid .. ","..playerFirstName..","..playerLastName..","..compStats;   
        
        -- make the 25th item a category (not being used right now)
        if i == 25 then
                isCategory = true; rowHeight = 24; rowColor={ 70, 70, 130, 255 }; lineColor={0,0,0,255}
        end
 
        -- make the 45th item a category as well
        if i == 45 then
                isCategory = true; rowHeight = 24; rowColor={ 70, 70, 130, 255 }; lineColor={0,0,0,255}
        end
    
        -- function below is responsible for creating the row
        teamSeasonsList:insertRow{
                onEvent=onRowTouch,
                id=id,
                onRender=onRowRender,
                height=rowHeight,
                isCategory=isCategory,
                rowColor=rowColor,
                lineColor=lineColor
        }
	end

	-- all objects must be added to group (e.g. self.view) but are not in this case since widgets act problematically with group.insert
	--	group:insert( list )
	--	group:insert( title )

	
	local teamName = lookupTeamName(whichTeam, 2);
	local nextSeason = computeNextSeason(whichTeamSeason);
	local seasonTitle = "'" ..computeNextSeason(whichTeamSeason-1) .. "-"..nextSeason
	local compTitle = seasonTitle .. " "..teamName
	
	-- Create the NavBar with the appropriate title
	createNavBar(compTitle);
    displayBackButton();
	
	--insert everything into the group to be changed on scene changes
    group:insert(navBar);
    group:insert(navHeader);
    group:insert(backButton)
end

-- Called when scene is about to move offscreen:

function scene:exitScene( event )
	local group = self.view
 	teamSeasonsList:removeSelf()
  	teamSeasonsList = nil
end

function scene:destroyScene( event )
	local group = self.view
	
end

-----------------------------------------------------------------------------------------
-- Storyboard API Listeners.
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene