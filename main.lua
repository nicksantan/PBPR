-----------------------------------------------------------------------------------------
--
-- Initial load and title screen for PBPR (main.lua) --
-----------------------------------------------------------------------------------------

-- Include Corona's "widget" and "storyboard" libraries

local widget = require "widget"
local storyboard = require "storyboard"

-- Set the 'theme' for native iOS buttons, etc.

widget.setTheme( "theme_ios" )

-- Hide the iPhone's status bar

display.setStatusBar( display.HiddenStatusBar );

-- Declare global variables to keep track of which pages were last visited

currentScene = "main";
backButtonOn = true;
lastScene = "players";
lastTeam = "BOS";
lastYear = "1997";

-- Generate an array of pages visited for the 'back' button. To begin, the array is filled with placeholders.

historyList = {"nuller","nuller","nuller","nuller","nuller","nuller","nuller","nuller","nuller","nuller","nuller"};

-- Declare some global variables to be used to indicate which team/player is being looked at. The default values are placeholders.

local whichTeam = "BOS";
local whichTeamSeason = "2007";
whichPlayer = "placeholder";

-- Initialize a local SQLite database

require "sqlite3"
local path = system.pathForFile("test.db", system.ResourceDirectory)
db = sqlite3.open( path )   

-- Handle the applicationExit event to close the db

local function onSystemEvent( event )
    if( event.type == "applicationExit" ) then              
        db:close()
    end
end

-- Event listeners for each of the tab buttons in the TabBar:

local function onPlayersView( event )
    updateHistory(currentScene);
	storyboard.gotoScene( "alphabet" )
end

local function onTeamsView( event )
    updateHistory(currentScene);
	storyboard.gotoScene( "teams" )
end

local function onRecordsView( event )
    updateHistory(currentScene);
	storyboard.gotoScene( "records" )
end

-- Create a TabBar widget with three buttons at the bottom of the screen

-- First, create a table to set up the buttons
local tabButtons = {
	{ label="Players", up="players.png", down="playersDown.png", width = 32, height = 28, onPress=onPlayersView, selected=false },
	{ label="Teams", up="teams.png", down="teamsDown.png", width = 43, height = 28, onPress=onTeamsView },
	{ label="Records", up="records.png", down="recordsDown.png", width = 28, height = 28, onPress=onRecordsView },
}

-- Create the actual tabBar widget

local tabBar = widget.newTabBar
	{
	top = display.contentHeight - 50,	-- 50 is default height for tabBar widget
	buttons = tabButtons
	}
	
-- Define a function used to create the navBar for each page with a title as an argument.

function createNavBar(title)

    navBar = widget.newTabBar{
	    top = 0,
	    --gradient = toolbarGradient,
	    bottomFill = {0, 0, 0, 255},
	    height = 44
    }

    navHeader = display.newRetinaText(title, 0, 0, native.systemFontBold, 16)
	navHeader:setTextColor(255, 255, 255)
	navHeader.x = display.contentWidth*.5
	navHeader.y = navBar.y
end
	
-- This function properly formats a year date (e.g. 1982) to shorthand (e.g. 82). It currently adds one to the year to return the 'Next season'
-- This can be overriden by passing the function 'origSeason - 1' etc.

function computeNextSeason(origSeason)
	-- Find the shorthand by lopping off '1900' from the date. If the result is > 100 (meaning the year is 2000-present), subtract 100 to account for that.
	local nextSeason = origSeason - 1900 + 1;
	if (nextSeason >= 100) then
		nextSeason = nextSeason - 100;
		-- Account for 2000-2009 by adding an additional '0' in front of 0,1,2,3,4,5,6,7,8 or 9
		if (nextSeason < 10) then
			nextSeason = "0".. nextSeason;
		end
	end
return nextSeason;
end

-- This function looks up a team's city and title (e.g. "Dallas Mavericks") given a team code (e.g. "DAL"). The argument 'whichName' is an option.
-- Specify '1' to receive just the team location, '2' to receive just the team's name, and '3' to return both.
function lookupTeamName(teamCode, whichNames)
    
    for row in db:nrows("SELECT * FROM teams WHERE team = '"..teamCode.."'") do
        local teamName = row.name;
		local teamLocation = row.location;
		local totalTitle = row.location .. " " .. row.name;
		
		if (whichNames == 1) then
			return teamLocation;
		end
			
		if (whichNames ==2) then
			return teamName;
		end
			
		if (whichNames == 3) then
			return totalTitle;
		end
	end
end
	
-- This function looks up a player's name given his unique 'ilkid'	

function lookupPlayerName(playerCode)

    for row in db:nrows("SELECT * FROM players WHERE ilkid = '"..playerCode.."'") do

		local firstName = string.sub(row.firstname,1,1) .. ".";
		local lastName = row.lastname;
		local firstYear = row.firstseason;
		local lastYear = row.lastseason;
		local concFirstSeason = computeNextSeason(firstYear-1);
		local concLastSeason = computeNextSeason(lastYear -1);
	
		local compName = firstName .. " " .. lastName .. " ('" .. concFirstSeason.."-'"..concLastSeason..")"; 
			
		return compName;	
	end
end

-- This function rounds a statistic to the appropriate number of decimal places (1)
-- If the options argument is '2', the function will return an extra space before 1 digit statistics
-- (This is so they line up with two digit statistics in table view)

function formatStat(stat, options)
		 
	local underTen; -- Switch for whether or not the stat is under 10
	local digits = 1		-- you want 1 digit after the decimal point
 	local shift = 10 ^ digits
  	local result = math.floor(stat*shift) / shift --lop off the trailing decimals
  	
  	if (result < 10) then --set the 'under 10' flag
  		underTen = 1;
  	else
  		underTen = 0;
  	end
  	
  	if (options == 2) then --if options are checked, add a " " space before single digit stats.
  		if (underTen ==1) then
  			result = " " .. string.format("%.1f", result);
  		else
  			result = string.format("%.1f", result);
		end

	else --otherwise, just format the result and return it
		result = string.format("%.1f", result);
	end

return result;
end

-- Simple function to turn a percentage into the format we want. (Right now, ".XX")

function formatPerc(stat)
    local twoDigit = math.floor(stat * 100) -- this will give us a two digit percentage
	local formattedStat = "." .. twoDigit	
	return formattedStat;
end

-- Function to split a string into an array using commas as a delimiter.

function split(myString) 
    local s = myString
    local t = {}

    for w in string.gmatch(s, "[^,]+") do
        t[#t+1] = w
    end

    return t;
end

-- Function to update the history array with the previous page visited.

function updateHistory(pageLeft)

    -- If the page is new, shift the history array to the left.
    
    if (historyList[11] ~= pageLeft) then
        historyList[1] = historyList[2];
        historyList[2] = historyList[3];
        historyList[3] = historyList[4];
        historyList[4] = historyList[5];
        historyList[5] = historyList[6];
        historyList[6] = historyList[7];
        historyList[7] = historyList[8];
        historyList[8] = historyList[9];
        historyList[9] = historyList[10];
        historyList[10] = historyList[11];
        historyList[11] = pageLeft;
    end
end

-- Define a function to display tbe 'back' button if applicable.

function displayBackButton()
    local onButtonEvent = function (event )
	    if event.phase == "release" then
            
            -- Go to the last scene in the history array and shift the array right.
           
            -- Split the history list item and determine which type of page was visited last.
            
            local t ={};
            local h = historyList[11];
            t = split(h);
   
            
            
            -- If there is only one field in the historyList item, we can go directly to that scene except if the item is null or if the item is one of the tab bar buttons. In those cases, highlight the appropriate tab bar button.
            
            if (#t == 1) then
            
                if (t[1] == "nuller") then
                    -- Do nothing.
                elseif (t[1] == "records") then
                    tabBar:pressButton( 3, false )
                elseif (t[1] == "alphabet") then
                    tabBar:pressButton( 1 , false)
                elseif (t[1] == "teams") then
                    tabBar:pressButton( 2, false )
                end
                
                if (t[1] ~= "nuller") then
                    storyboard.gotoScene( t[1] )
                end
            end
            
            if(#t==3) then -- This must be a teamseason page
                whichTeam = t[2];
                whichTeamSeason = t[3];
                storyboard.gotoScene(t[1]);
            end
            
            if(#t==2) then -- This could be a number of things. First, evaluate the first field.
            
                if (t[1] == "player_page") then
                    -- t[2] is going to be whichPlayer
                    whichPlayer = t[2];
                    storyboard.gotoScene(t[1]);
                    
                elseif (t[1] == "players") then
                    
                    whichLetter = t[2];
                    storyboard.gotoScene(t[1]);
                        
                elseif (t[1] == "teamseasons") then
                   
                    whichTeam = t[2];
                    storyboard.gotoScene(t[1]);
                
                end
            end
                

           --Shift the history list right. 
            
            historyList[11] = historyList[10];
            historyList[10] = historyList[9];
            historyList[9] = historyList[8];
            historyList[8] = historyList[7];
            historyList[7] = historyList[6];
            historyList[6] = historyList[5];
            historyList[5] = historyList[4];
            historyList[4] = historyList[3];
            historyList[3] = historyList[2];
            historyList[2] = historyList[1];
            historyList[1] = "nuller";
   
            -- If the last spot in the history array is empty, remove the backButton.
            if (historyList[11] == "nuller") then
                backButton:removeSelf();
                backButton = nil;
            end
        end
      
    end
    
 	
 	--create the backButton. This should also be a global function in main.lua

    if (historyList[11] ~= "nuller") then

        local widget = require "widget"
        backButton = widget.newButton{
      id = "backButton",
      left =5,
      --top = 6,
      style = "backSmall",
      --  width = 150, height = 28,
      cornerRadius = 8,
      label = "Back",
      onEvent = onButtonEvent
   }
        backButton.y = navBar.y
   
    else

        backButton = display.newRetinaText( "blah", 18, 0, "Helvetica-Bold", 12 )

	    backButton.isVisible = false;

    end
end

----                               ----
-----GO TO TITLE SCENE ON APP LOAD-----
----                               ----

storyboard.gotoScene("title");
currentScene = "title"
