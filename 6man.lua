-----------------------------------------------------------------------------------------
--
-- 6man.lua
-- The list of all 6th man of the year winners.
--
-----------------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()


-- Called when the scene's view does not exist:
function scene:createScene( event )
	--This is some placeholder content to prevent a bug in the storyboard API
	--which mandates that some content must be inserted into the group.
	local group = self.view
	local blah = display.newRetinaText( "blah", 18, 0, "Helvetica-Bold", 12 )
	group:insert( blah )
	blah.isVisible = false;
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

	local group = self.view
	local widget = require "widget"
	currentScene = "6man";
    local listOptions = {
        top = 44,
        height = 386,
        maskFile = "mask-386.png";
	}
 
    
	theList = widget.newTableView( listOptions )

	-- onEvent listener for the tableView
	local function onRowTouch( event )
        local row = event.target
        local rowGroup = event.view
 
        if event.phase == "press" then
                if not row.isCategory then rowGroup.alpha = 0.5;
               
                end
 
        elseif event.phase == "release" then
        
            if not row.isCategory then
                        -- Update the history of scenes visited with the current scene before we change scenes
                        updateHistory(currentScene);
                        -- reRender property tells row to refresh if still onScreen when content moves
                        row.reRender = true
                        
                        -- Unpack which player was selected
                        local t
                        t = split(event.target.id);
                        whichPlayer = t[1]
               			
               			-- go to a particular player page
                        storyboard.gotoScene( "player_page" );
            end
        end
 	    return true
	end
 
	-- onRender listener for the tableView that renders each row
	local function onRowRender( event )
        local row = event.target
        local rowGroup = event.view
        
        --decompact the information stored in the ID field
       
        local t
        t = split(event.target.id);
       
        local year = t[2]
        local compYear = year .. "-" .. computeNextSeason(year);
        local name = t[3]
	
   	 	local textDate = display.newRetinaText( compYear, 18, 0, "Helvetica-Bold", 18 )
    	textDate:setReferencePoint( display.CenterLeftReferencePoint )
    	textDate.y = row.height * 0.5
    	
    	local textName = display.newRetinaText(name, 18, 0, "Helvetica-Bold", 18);
    	textName:setReferencePoint( display.CenterLeftReferencePoint )
    	textName.y = row.height * 0.5
        
    	if not row.isCategory then
    		textDate.x = 10
    		textDate:setTextColor( 100 )
    		textName.x = 120 ;
     		textName:setTextColor(0);
    	end
 
        -- must insert everything into event.view: (tableView requirement)
        rowGroup:insert( textDate )
   		rowGroup:insert(textName);
	end
 
	-- Create a row for each Player in the 6th Man of the Year list
	
	local playerFirstName;
    local playerLastName;
    local gp;
    local ppg;
    local rpg;
    local apg;
    local spg;
    local bpg;
    local ilkid;
    local year;   
    local id;
    
    
    --Populate the rows based on the 6th man of the year table
		
	for row in db:nrows("SELECT * FROM records_6man ORDER BY year DESC") do

	    playerFirstName = row.firstname;
	    playerLastName = row.lastname;
        ilkid = row.ilkid;
	    year = row.year;
	    
	    --combine all the info into a string called 'id' that will be unpacked later
	    id = ilkid .. "," .. year.. "," .. playerFirstName .. " " .. playerLastName;
        
        --create a row with this information
        theList:insertRow{
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
	
	createNavBar("Sixth Man of the Year");
    displayBackButton();
	
	--insert everything into the group to be changed on scene changes
    group:insert(navBar);
    group:insert(navHeader);
    group:insert(backButton)
end

-- Called when scene is about to move offscreen:

function scene:exitScene( event )
	local group = self.view
 	theList:removeSelf()
  	theList = nil
end

function scene:destroyScene( event )
	local group = self.view
end

-----------------------------------------------------------------------------------------
-- Do not touch below, listeners required for Storyboard API.
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