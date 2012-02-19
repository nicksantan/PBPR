-----------------------------------------------------------------------------------------
--
-- teamseasons.lua
-- The view that appears when a particular team is clicked from the list of teams. A list of a given team's seasons.
--
-----------------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
     local blah = display.newRetinaText( "blah", 18, 0, "Helvetica-Bold", 12 )
	group:insert( blah )
	blah.isVisible = false;

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

	local group = self.view
	local widget = require "widget"
    currentScene = "teamseasons" .. ",".. whichTeam;
    --a test change
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
                        whichTeamSeason = event.target.id;
               			--goto a particular season's roster
               			
                        storyboard.gotoScene( "teamseason" );
                end
        end
 
 	       return true
	end
 
	-- onRender listener for the tableView that renders each row
	local function onRowRender( event )
        local row = event.target
        local rowGroup = event.view
        local teamName;
        local wins;
        local losses;
		--look up each year a team has existed and extract the wins and losses
		for row in db:nrows("SELECT * FROM team_seasons WHERE team =  '"..whichTeam.."' AND year = '"..event.target.id.."'") do
			wins = row.won;
			losses = row.lost;
		end
		
		
	
		--compute the text to display the team's record for each season
		local nextSeason = computeNextSeason(event.target.id);
		local compWL = wins .. " - " .. losses;
		local modifiedDate = event.target.id .. "-" .. nextSeason;
   	 	local text = display.newRetinaText( modifiedDate, 18, 0, "Helvetica-Bold", 18 )
    	text:setReferencePoint( display.CenterLeftReferencePoint )
    	text.y = row.height * 0.5
    	local textWL = display.newRetinaText(compWL, 18, 0, "Helvetica-Bold", 18);
    	textWL:setReferencePoint( display.CenterLeftReferencePoint )
    	textWL.y = row.height * 0.5
        
    	if not row.isCategory then
    		text.x = 15
    		text:setTextColor( 0 )
    		textWL.x = 250;
     		textWL:setTextColor(150);
    	end
 
        -- must insert everything into event.view: (tableView requirement)
        rowGroup:insert( text )
      	rowGroup:insert(textWL);
	end
 
	-- Create a row for each Season the team has existed and add it to the tableView:
	for row in db:nrows("SELECT * FROM team_seasons WHERE team = '"..whichTeam.."' ORDER BY year DESC") do
    	local rowHeight, rowColor, lineColor, isCategory, id
 		rowHeight = 40;
 		id = row.year;
        
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

	--create the NavBar with the appropriate title
	local teamName = lookupTeamName(whichTeam, 3);
	createNavBar(teamName);
displayBackButton();
	--insert everything into the group to be changed on scene changes
    group:insert(navBar);
    group:insert(navHeader);
    group:insert(backButton)
end

-- Called when scene is about to move offscreen:

function scene:exitScene( event )
	local group = self.view
 	lastScene = "teamseasons";
 	lastTeam = whichTeam;
 	teamSeasonsList:removeSelf()
  	teamSeasonsList = nil
  	
end

function scene:destroyScene( event )
	local group = self.view
	
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
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