-----------------------------------------------------------------------------------------
--
-- Initial load and title screen for PBPR (main.lua) --
-----------------------------------------------------------------------------------------

-- include Corona's "widget" and "storyboard" libraries

	
local widget = require "widget"
local storyboard = require "storyboard"

--set the 'theme' for native iOS buttons, etc.

widget.setTheme( "theme_ios" )
--hide the iPhone's status bar
display.setStatusBar( display.HiddenStatusBar );

--declare a global variable to keep track of which page was last visited
currentScene = "main";
backButtonOn = true;
lastScene = "players";
lastTeam = "BOS";
lastYear = "1997";

historyList = {"nuller","nuller","nuller","nuller","nuller","nuller","nuller","nuller","nuller","nuller","nuller"};
print(historyList[1]);
--lastPlayer probably isn't needed as there is nowhere to go from a player page.

--declare a global variable to be used to indicate which team is being looked at. Default is BOS
local whichTeam = "BOS";
local whichTeamSeason = "2007";
whichPlayer = "placeholder";

--Initialize the database
require "sqlite3"
local path = system.pathForFile("test.db", system.ResourceDirectory)
db = sqlite3.open( path )   
--Handle the applicationExit event to close the db
local function onSystemEvent( event )
        if( event.type == "applicationExit" ) then              
            db:close()
        end
end

-- event listeners for tab buttons:
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

-- create a tabBar widget with three buttons at the bottom of the screen

-- table to setup buttons
local tabButtons = {
	{ label="Players", up="singleNEW.png", down="singleDOWNNEW2.png", width = 32, height = 28, onPress=onPlayersView, selected=false },
	{ label="Teams", up="groupNEW.png", down="groupDOWNNEW.png", width = 43, height = 28, onPress=onTeamsView },
		{ label="Records", up="trophyNEW.png", down="trophyDOWNNEW.png", width = 28, height = 28, onPress=onRecordsView },
	}

-- create the actual tabBar widget
local tabBar = widget.newTabBar
	{
	top = display.contentHeight - 50,	-- 50 is default height for tabBar widget
	buttons = tabButtons
	}
	
function createNavBar(title)
	--create the navBar. This function will be called by each additional scene.
	--navBar = display.newImage("navBar.png", 0, 0, true)
--	navBar.x = display.contentWidth*.5
--	navBar.y = math.floor(display.screenOriginY + navBar.height*0.5)
 
 -- create a gradient for the top-half of the toolbar
--local toolbarGradient = graphics.newGradient( {168, 181, 198, 255 }, {139, 157, 180, 255}, "down" )

-- create toolbar to go at the top of the screen
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
	
--This function properly formats a year date (e.g. 1982) to shorthand (e.g. 82). It currently adds one to the year to return the 'Next season'
--This can be overriden by passing the function 'origSeason - 1' etc.

function computeNextSeason(origSeason)
	--find the shorthand by lopping off '1900' from the date. If the result is > 100 (meaning the year is 2000-present), subtract 100 to account for that.
	local nextSeason = origSeason - 1900 + 1;
	if (nextSeason >= 100) then
		nextSeason = nextSeason - 100;
		--Account for 2000-2009 by adding an additional '0' in front of 0,1,2,3,4,5,6,7,8 or 9
		if (nextSeason < 10) then
			nextSeason = "0"..nextSeason;
		end
	end
	
	return nextSeason;
	
end

--This function looks up a team's city and title (e.g. "Dallas Mavericks") given a team code (e.g. "DAL"). The argument 'whichName' is an option.
--Specify '1' to receive just the team location, '2' to receive just the team's name, and '3' to return both.
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
	
--This function looks up a player's name given his unique 'ilkid'	
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

--This function rounds a statistic to the appropriate number of decimal places (1)
--If the options argument is '2', the function will return an extra space before 1 digit statistics
--(This is so they line up with two digit statistics in table view)

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

--Simple function to turn a percentage into the format we want. (Right now, ".XX")
function formatPerc(stat)
	local twoDigit = math.floor(stat * 100) -- this will give us a two digit percentage
	local formattedStat = "." .. twoDigit	
	return formattedStat;
end


function split(myString) 
    local s = myString
    local t = {}

    for w in string.gmatch(s, "[^,]+") do
        t[#t+1] = w
    end

    return t;

end

-----GO TO TITLE SCENE ON APP LOAD

storyboard.gotoScene("title");
currentScene = "title"
function updateHistory(pageLeft)

if (historyList[11] ~= pageLeft) then
print("history updated, page left was just: " .. pageLeft);
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
    print("oldest history is: " .. historyList[1]);
   print(historyList[2]);
   print(historyList[3]);
    print(historyList[4]);
    print(historyList[5]);
    print(historyList[6]);
    print(historyList[7]);
    print(historyList[8]);
    print(historyList[9]);
    print(historyList[10]);
    print(historyList[11]);
    
    end
    


end

function displayBackButton()
	local onButtonEvent = function (event )
	

        if event.phase == "release" then
           
           --go to the fourth scene and then shift all the scenes
           
            local t ={};
            local h = historyList[11];
            print("okay, we're moving back in time to " .. h);
            t = split(h);
            print (#t);
  
            if (#t == 1) then
                print(type(t[1]));
                if (t[1] == "nuller") then
                    print ("it's nuller");
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
            
            if(#t==3) then -- this must be a teamseason page
            --set whichTeam ? 
            whichTeam = t[2];
            whichTeamSeason = t[3];
            
            storyboard.gotoScene(t[1]);
            
            end
                if(#t==2) then -- this could be a number of things
                print("#t is 2");
                    if (t[1] == "player_page") then
                    print("navigating back to a player page");
                        --t[2] is going to be whichPlayer
                        print("whichPlayer was "..whichPlayer.." being changed to "..t[2]);
                        whichPlayer = t[2];
                        storyboard.gotoScene(t[1]);
                    
                    elseif (t[1] == "players") then
                      print("navigating back to the list of players for a letter");
                        whichLetter = t[2];
                        storyboard.gotoScene(t[1]);
                        
                    elseif (t[1] == "teamseasons") then
                    print("navigating back to the list of teamseasons");
                        whichTeam = t[2];
                        storyboard.gotoScene(t[1]);
                    end
                end
                

            
            
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
   
           print("now, oldest spot is " .. historyList[1])
             print(historyList[2]);
   print(historyList[3]);
    print(historyList[4]);
    print(historyList[5]);
    print(historyList[6]);
    print(historyList[7]);
    print(historyList[8]);
    print(historyList[9]);
    print(historyList[10]);
    print(historyList[11]);
           
       
        if (historyList[11] == "nuller") then
              backButton:removeSelf();
           backButton = nil;
           end
           end
      
        end
    
 	
 	--create the backButton. This should also be a global function in main.lua

if (historyList[11] ~= "nuller") then
print ("back button is on like donkey kong");
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
print("back button should be off");
	backButton.isVisible = false;

end
end
