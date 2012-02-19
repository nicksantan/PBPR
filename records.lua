-----------------------------------------------------------------------------------------
--
-- records.lua
-- The view that appears when the 'awards' tab bar button is clicked. A list of each 
-- award or record available for view (e.g. ROY, MVP, etc.)
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

local recordsArray = { "Most Valuable Player", "League Champions", "Rookie of the Year", "Defensive Player of the Year", "Sixth Man Award" };
-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	
	 local blah = display.newRetinaText( "blah", 18, 0, "Helvetica-Bold", 12 )
	group:insert( blah )
	blah.isVisible = false;
	
	

	
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
manageBackButton();
	local group = self.view
	--list.isVisible = true;
	currentScene = "records";
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
                        --set the global variable that lets the program know which letter is being viewed.
                        whichRecord = event.target.id;
                       
                        --goto the applicable record's page
                        --put a switch statement here.
                        if (event.target.id == "Most Valuable Player") then
                        storyboard.gotoScene( "MVP" );
                        end 
                        if (event.target.id == "Rookie of the Year") then
                        storyboard.gotoScene( "ROY" );
                        end 
                        if (event.target.id == "Defensive Player of the Year") then
                        storyboard.gotoScene( "DPOY" );
                        end 
                        if (event.target.id == "Sixth Man Award") then
                        storyboard.gotoScene( "6man" );
                        end 
                        if (event.target.id == "League Champions") then
                        storyboard.gotoScene( "champions" );
                        end 
                        
                end
        end
 
        return true
	end
 
	-- onRender listener for the tableView that renders each row.
	local function onRowRender( event )
        local row = event.target
        local rowGroup = event.view
      

       	local text = display.newRetinaText( event.target.id, 18, 0, "Helvetica-Bold", 18 )
        text:setReferencePoint( display.CenterLeftReferencePoint )
        text.y = row.height * 0.5
       	        
        if not row.isCategory then
                text.x = 15
                text:setTextColor( 0 )
        
        end
 
        -- must insert everything into event.view (tableView requirement)
        rowGroup:insert( text )
      
	end
 
	-- Create a row manually for each entry.
	
	
	
	
	for j=1,5 do
        local rowHeight, rowColor, lineColor, isCategory, id
 		rowHeight = 40;
 		
 		id = recordsArray[j];
		
	
      
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
	createNavBar("Awards");
 
 
 
 
 	
 
 
    -- Change the button's label text:
  	--  myButton:setLabel( "My Button" )

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