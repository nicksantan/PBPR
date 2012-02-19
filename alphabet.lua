-----------------------------------------------------------------------------------------
--
-- alphabet.lua
-- The view that appears when the 'players' tab bar button is clicked. A list of each letter in the alphabet. When tapped, the view switches to 'players' - showing every player with a last name beginning with that letter.
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

local alphabetArray = { "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
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
	--list.isVisible = true;
	currentScene = "alphabet";
	local listOptions = {
        top = 44,
        height = 386,
        maskFile = "mask-386.png";
     -- maskFile = "mask-320x366.png"
     -- maskFile = "320-385-mask.png"
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
                        --set the global variable that lets the program know which letter is being viewed.
                        whichLetter = event.target.id;
            
                        --goto the Player's page
                        storyboard.gotoScene( "players" );
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
        local compName;
        --look up each team and extract some pertinent info to render. 
 		--for row in db:nrows("SELECT * FROM player_career WHERE ilkid = '"..event.target.id.."'") do
--perhaps extract this earlier?
		--	teamName = row.name;
		--	teamLocation = row.location;
		--	totalTitle = row.location .. " " .. row.name;
		--firstname = row.firstname;
	--	lastname = row.lastname
--compName = lastname .. ", " .. firstname
		-- end
		 
		--render the text based on these this info
		
		

       	local text = display.newRetinaText( event.target.id, 18, 0, "Helvetica-Bold", 16 )
        text:setReferencePoint( display.CenterLeftReferencePoint )
        text.y = row.height * 0.5
       	
       --	local textDate = display.newRetinaText(compDates, 18, 0, -"Helvetica-Bold", 12);
       -- textDate:setReferencePoint( display.CenterLeftReferencePoint )
       -- textDate.y = row.height * 0.5
        
        if not row.isCategory then
                text.x = 15
                text:setTextColor( 0 )
             --   textDate.x = 225;
              --  textDate:setTextColor(150);
        end
 
        -- must insert everything into event.view (tableView requirement)
        rowGroup:insert( text )
      --  rowGroup:insert(textDate);
	end
 
	-- Create a row for each team, sorted by whether or not the team still exists, the league, and then alphabetically

	for j=1,26 do
        local rowHeight, rowColor, lineColor, isCategory, id
 		rowHeight = 40;
 		
 		id = alphabetArray[j];
		
		--This category code is not currently in use.
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

	-- all objects must be added to group (e.g. self.view) but are not in this case since widgets act problematically with group.insert
	--	group:insert( list )
	--	group:insert( title )

	--create the NavBar with the appropriate title
	createNavBar("Last Name");
 
 displayBackButton();
 
 
 	
 
 
    -- Change the button's label text:
  	--  myButton:setLabel( "My Button" )

	--insert everything into the group to be changed on scene changes
    group:insert(navBar);
    group:insert(navHeader);
    group:insert(backButton )
    --group:insert(list);
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	--lastScene = "teams";
	list:removeSelf()
 	list = nil
 --	backButton:removeSelf();
 --	backButton = nil;
	--list.isVisible = false;
		
end

function scene:destroyScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. remove listeners, remove widgets, save state variables, etc.)
	
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