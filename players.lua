-----------------------------------------------------------------------------------------
--
-- players.lua
-- The view that appears when a letter on the 'alphabet' page is clicked.
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

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
	currentScene = "players" .. "," .. whichLetter;
	
	local listOptions = {
        top = 44,
        height = 386,
        maskFile = "mask-386.png";
	}
 	
 	local widget = require "widget"
	list = widget.newTableView( listOptions )

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
                    print( "You touched row #" .. event.index )
                    
                   
                    local s = event.target.id;
                    t = split(s);
                    whichPlayer = t[1];
                       
                    --go to the player's page
                    storyboard.gotoScene( "player_page" );
                end
            end
 
            return true
	    end
 
	-- onRender listener for the tableView that renders each row.
	local function onRowRender( event )
        
        local row = event.target
        local rowGroup = event.view
        local teamName;
        local firstname;
        local lastname;
        local teamName;
        local firstSeason;
        local lastSeason;
        local compName;
        local compDates;
       
	
        local s = event.target.id;
 
        local t = split(s);

        local ilkid = t[1]; 
        firstname = t[2];
        lastname = t[3];
        firstSeason = t[4];
        lastSeason = t[5];

        compName = lastname .. ", " .. firstname;
        compDates = firstSeason .. " - " ..lastSeason;
	
       	local text = display.newRetinaText( compName, 18, 0, "Helvetica-Bold", 18 )
        text:setReferencePoint( display.CenterLeftReferencePoint )
        text.y = row.height * 0.5
       	
       	local textDate = display.newRetinaText(compDates, 18, 0, "Helvetica-Bold", 18);
        textDate:setReferencePoint( display.CenterLeftReferencePoint )
        textDate.y = row.height * 0.5
        
        if not row.isCategory then
            text.x = 13
            text:setTextColor( 0 )
                
            textDate.x = 217;
            textDate:setTextColor(150);
        end
 
        -- must insert everything into event.view (tableView requirement)
        rowGroup:insert( text )
        rowGroup:insert(textDate);
	end
 
	-- Create a row for each team, sorted by whether or not the team still exists, the league, and then alphabetically

	for row in db:nrows("SELECT * FROM players WHERE lastname LIKE '"..whichLetter.."%' ORDER BY lastname ASC, firstname ASC ") do
        local rowHeight, rowColor, lineColor, isCategory, id
 		rowHeight = 40;
 		
 		local firstname = row.firstname;
		local lastname = row.lastname
		local firstSeason = row.firstseason 
		local lastSeason = row.lastseason
 		id = row.ilkid .. "," .. firstname .. "," .. lastname .. "," .. firstSeason .. ",".. lastSeason;
		
		-- This category code is not currently in use.
       	-- make the 25th item a category
        if i == 25 then
                isCategory = true; rowHeight = 24; rowColor={ 70, 70, 130, 255 }; lineColor={0,0,0,255}
        end
 
        -- make the 45th item a category as well
        if i == 45 then
                isCategory = true; rowHeight = 24; rowColor={ 70, 70, 130, 255 }; lineColor={0,0,0,255}
        end
    
        -- function below is responsible for creating the row
        list:insertRow{
            onEvent=onRowTouch,
            id=id,
            onRender=onRowRender,
            height=rowHeight,
            isCategory=isCategory,
            rowColor=rowColor,
            lineColor=lineColor
        }
	end

	--  All objects must be added to group (e.g. self.view) but are not in this case since widgets act problematically with group.insert
	--	group:insert( list )
	--	group:insert( title )

	--create the NavBar with the appropriate title
	createNavBar("Players");
 
    displayBackButton();
 
	--insert everything into the group to be changed on scene changes
    group:insert(navBar);
    group:insert(navHeader);
    group:insert( backButton )
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )

	local group = self.view
	--lastScene = "teams";
  	list:removeSelf()
  	list = nil
	--list.isVisible = false;
end

function scene:destroyScene( event )
	local group = self.view
end

-----------------------------------------------------------------------------------------
-- Do not touch below. Listeners required for Storyboard API.
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