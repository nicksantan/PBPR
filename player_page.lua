-----------------------------------------------------------------------------------------
--
-- player_page.lua
-- The view that appears when a player has been clicked. Displays their career information and season statistics.
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
	
	-- A placeholder
    local blah = display.newRetinaText( "blah", 18, 0, "Helvetica-Bold", 12 )
	group:insert( blah )
	blah.isVisible = false;

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

    local group = self.view
	local widget = require "widget"
    
    -- Define the current scene
    currentScene = "player_page" .. "," .. whichPlayer;
    print (currentScene);

    
    -- Create some variables to be displayed on screen
    
    local gp
    local pts
    local rebs
    local asts
    local stls
    local blks
    local ht
    local wt
    local pos
    local college
    local ppg;
    local rpg;
    local apg;
    local spg;
    local bpg;
    local birthdate;
    local fn;
    local ln;

    -- Calculate some career totals and averages by pulling from the player_career table
    
    for row in db:nrows("SELECT * FROM player_career WHERE ilkid = '"..whichPlayer.."'" ) do

        gp = row.gp;
        pts = row.pts
        rebs = row.reb
        asts = row.asts
        stls = row.stl
        blks = row.blk
        ppg = formatStat(pts/gp,2);
        rpg = formatStat(rebs/gp,2);
        apg = formatStat(asts/gp,2)
        spg = formatStat(stls/gp,2)
        bpg = formatStat(blks/gp,2)
    
    end

    -- Pull some vital information (e.g. height, weight, college) from the players table
    
    for row in db:nrows("SELECT * FROM players WHERE ilkid = '"..whichPlayer.."'" ) do
        pos = row.position;
        ht = row.h_feet .."-".. row.h_inches
        wt = row.weight
        college = row.college
        
        -- If the player didn't go to college, replace college text to be "None"
        
        if (college == "NULL") then
            college = "None"
        end

        birthdate = row.birthdate;
        local s = birthdate
        
        -- Special case for No Data (right now, Rookies)
        
        if (s == "No Data") then
            birthdate = "No Data";
        else
            --Convert the birthday into the appopriate format (we're stripping a bunch of empty 'time' information from the table)
            local t = {}
            for w in string.gmatch(s, "%S+") do
                t[#t+1] = w
            end
        birthdate = t[1];
        end
    
        fn = row.firstname;
        ln = row.lastname;
    end


    -- Create a key to translate position data to their full names
    
    posTable = { C="Center", G = "Guard", F="Forward" }

    -- Create a white background to fill screen
	
	local bg = display.newRect( 0, 45, 320, 120 )
	bg:setFillColor( 255 )	-- white
	group:insert(bg);
	
    local compName = fn .. " " .. ln;
	local nameDisplay = display.newRetinaText( compName, 0, 0, "Helvetica-Bold", 18 )
	
	nameDisplay:setTextColor( 0 )	-- black
	nameDisplay:setReferencePoint( display.TopLeftReferencePoint )
	nameDisplay.x = 5
	nameDisplay.y = 50
	
	group:insert(nameDisplay);
	
	
	
	local posText
	
	-- Special case for no position listed (Rookies)
	
	if (pos == "?") then    
	    posText = " ";
	else
	posText = posTable[pos];
	end
	
	local posDisplay = display.newRetinaText( posText, 0, 0, "Helvetica", 18 )
	posDisplay:setTextColor( 0 )	-- black
	posDisplay:setReferencePoint( display.TopLeftReferencePoint )
	posDisplay.x = 320 - posDisplay.width -5
	posDisplay.y = 50
    group:insert(posDisplay);
    local htwtDisplay = display.newRetinaText( ht .. ", " .. wt .. " lbs.", 0, 0, "Helvetica", 14 )
    print("height is: " .. ht);  
    
    -- Special case for no data for HT or WT (Rookies)
    if (ht == "No Data-No Data") then   
        -- For now, just hide that field.
        htwtDisplay.isVisible = false;
	else 
	    htwtDisplay.isVisible = true;
	end
	
	htwtDisplay:setTextColor( 0 )	-- black
	htwtDisplay:setReferencePoint( display.TopLeftReferencePoint )
	htwtDisplay.x = 5
	htwtDisplay.y = nameDisplay.y + nameDisplay.height + 5;
	group:insert(htwtDisplay);
	
	local bornDisplay = display.newRetinaText( "Born: " .. birthdate, 0, 0, "Helvetica", 14 )
	bornDisplay:setTextColor( 0 )	-- black
	bornDisplay:setReferencePoint( display.TopLeftReferencePoint )
	bornDisplay.x = 5
	bornDisplay.y = htwtDisplay.y + htwtDisplay.height + 5;
	group:insert(bornDisplay);
	
	local collegeDisplay = display.newRetinaText( "College: " .. college, 0, 0, "Helvetica", 14 )
	collegeDisplay:setTextColor( 0 )	-- black
	collegeDisplay:setReferencePoint( display.TopLeftReferencePoint )
	collegeDisplay.x = 5
	collegeDisplay.y = bornDisplay.y + bornDisplay.height + 5;
    group:insert(collegeDisplay);

    local statBoxBg = display.newRect( 125,  posDisplay.y + posDisplay.height + 5, 320, 33 )
	statBoxBg:setFillColor( 230 )	-- lt. grey
    group:insert(statBoxBg);

    local ppgDisplay = display.newRetinaText( ppg, 0, 0, "Helvetica-Bold", 18 )
	ppgDisplay:setTextColor( 0 )	-- black
	ppgDisplay:setReferencePoint( display.TopLeftReferencePoint )
	ppgDisplay.x = 125
	ppgDisplay.y = posDisplay.y + posDisplay.height + 5;
	group:insert(ppgDisplay);
	
	local rpgDisplay = display.newRetinaText( rpg, 0, 0, "Helvetica-Bold", 18 )
	rpgDisplay:setTextColor( 0 )	-- black
	rpgDisplay:setReferencePoint( display.TopLeftReferencePoint )
	rpgDisplay.x = 165
	rpgDisplay.y = posDisplay.y + posDisplay.height + 5;
	group:insert(rpgDisplay);
	
	local apgDisplay = display.newRetinaText( apg, 0, 0, "Helvetica-Bold", 18 )
	apgDisplay:setTextColor( 0 )	-- black
	apgDisplay:setReferencePoint( display.TopLeftReferencePoint )
	apgDisplay.x = 205
	apgDisplay.y = posDisplay.y + posDisplay.height + 5;
	group:insert(apgDisplay);
	
	local spgDisplay = display.newRetinaText( spg, 0, 0, "Helvetica-Bold", 18 )
	spgDisplay:setTextColor( 0 )	-- black
	spgDisplay:setReferencePoint( display.TopLeftReferencePoint )
	spgDisplay.x = 245
	spgDisplay.y = posDisplay.y + posDisplay.height + 5;
	group:insert(spgDisplay);
	
	local bpgDisplay = display.newRetinaText( bpg, 0, 0, "Helvetica-Bold", 18 )
	bpgDisplay:setTextColor( 0 )	-- black
	bpgDisplay:setReferencePoint( display.TopLeftReferencePoint )
	bpgDisplay.x = 285
	bpgDisplay.y = posDisplay.y + posDisplay.height + 5;
    group:insert(bpgDisplay);

    local statMarkerPpg = display.newRetinaText("ppg",0,0,"Helvetica",10)
    statMarkerPpg:setTextColor( 0 )	-- black
	statMarkerPpg:setReferencePoint( display.TopLeftReferencePoint )
	statMarkerPpg.x = ppgDisplay.x + ppgDisplay.width - statMarkerPpg.width
	statMarkerPpg.y = ppgDisplay.y + ppgDisplay.height - 5;
	group:insert(statMarkerPpg);

    local statMarkerRpg = display.newRetinaText("rpg",0,0,"Helvetica",10)
    statMarkerRpg:setTextColor( 0 )	-- black
	statMarkerRpg:setReferencePoint( display.TopLeftReferencePoint )
	statMarkerRpg.x = rpgDisplay.x + rpgDisplay.width - statMarkerRpg.width
	statMarkerRpg.y = rpgDisplay.y + rpgDisplay.height - 5;
	group:insert(statMarkerRpg);

    local statMarkerApg = display.newRetinaText("apg",0,0,"Helvetica",10)
    statMarkerApg:setTextColor( 0 )	-- black
	statMarkerApg:setReferencePoint( display.TopLeftReferencePoint )
	statMarkerApg.x = apgDisplay.x + apgDisplay.width - statMarkerApg.width
	statMarkerApg.y = apgDisplay.y + apgDisplay.height - 5;
	group:insert(statMarkerApg);

    local statMarkerSpg = display.newRetinaText("spg",0,0,"Helvetica",10)
    statMarkerSpg:setTextColor( 0 )	-- black
	statMarkerSpg:setReferencePoint( display.TopLeftReferencePoint )
	statMarkerSpg.x = spgDisplay.x + spgDisplay.width - statMarkerSpg.width
	statMarkerSpg.y = spgDisplay.y + spgDisplay.height - 5;
	group:insert(statMarkerSpg);

    local statMarkerBpg = display.newRetinaText("bpg",0,0,"Helvetica",10)
    statMarkerBpg:setTextColor( 0 )	-- black
	statMarkerBpg:setReferencePoint( display.TopLeftReferencePoint )
	statMarkerBpg.x = bpgDisplay.x + bpgDisplay.width - statMarkerBpg.width
	statMarkerBpg.y = bpgDisplay.y + bpgDisplay.height - 5;	
    group:insert(statMarkerBpg);

    -- Create some text that will serve as the 'header' for the stat table.
    
    local compCats = " Yr  Tm GP  MPG  PPG FG% FT% 3P%  RPG  APG SPG BPG"

   	local catText = display.newRetinaText( compCats, 18, 0, "Monaco", 10 )
   	catText:setTextColor( 0 )	
    catText:setReferencePoint( display.CenterLeftReferencePoint )
    catText.y = collegeDisplay.y + collegeDisplay.height + 10
    catText.x = 7
    group:insert(catText);
    		
    local listOptions = {
        top = 160 ,-- 145, --was 44
        height = 270,
        maskFile = "mask-270.png",
        bgColor = { 255, 255, 255, 255 };
	}
 
    -- Draw a horizontal line under the column headers
	
    local baseHeight = collegeDisplay.y + collegeDisplay.height
	local horizLine = display.newLine( 0,baseHeight+1, 320,baseHeight+1 )
	horizLine:setColor( 0, 0, 0, 255 )
	group:insert(horizLine);
	
	-- Draw the tableview for the statistics
	
	teamSeasonsList = widget.newTableView( listOptions )
	group:insert(teamSeasonsList);
	
	-- Draw some colored columns to differentiate the columns visually
	
	local barHeight = 480 - baseHeight - 50;
	local bg1 = display.newRect( 0,baseHeight , 30, barHeight )
	bg1:setReferencePoint( display.TopLeftReferencePoint )
	bg1:setFillColor( 0,0,200,30); 
	group:insert(bg1);
	
	local bg2 = display.newRect( 52, baseHeight, 18, barHeight )
	bg2:setReferencePoint( display.TopLeftReferencePoint )
	bg2:setFillColor( 0,0,200,30); 
	group:insert(bg2);
	
	local bg3 = display.newRect( 102, baseHeight, 30, barHeight )
	bg3:setReferencePoint( display.TopLeftReferencePoint )
	bg3:setFillColor( 0,0,200,30); 
	group:insert(bg3);
	
	local bg4 = display.newRect( 156, baseHeight, 23, barHeight )
	bg4:setReferencePoint( display.TopLeftReferencePoint )
	bg4:setFillColor( 0,0,200,30); 
	group:insert(bg4);
	
	local bg5 = display.newRect( 204, baseHeight, 30, barHeight )
	bg5:setReferencePoint( display.TopLeftReferencePoint )
	bg5:setFillColor( 0,0,200,30); 
	group:insert(bg5);
	
	local bg6 = display.newRect( 266, baseHeight, 23, barHeight )
	bg6:setReferencePoint( display.TopLeftReferencePoint )
	bg6:setFillColor( 0,0,200,30); 
	-- onEvent listener for the tableView
	group:insert(bg6);
	
	-- Draw another horizontal line with a shadow effect
	local horizLineB = display.newLine( 0,baseHeight + 20, 320,baseHeight + 20 )
	horizLineB:setColor( 0, 0, 0, 255 )
	group:insert(horizLineB);
	local shadow = display.newImage( "shadow.png" )
    shadow:setReferencePoint( display.TopLeftReferencePoint )
    shadow.y = baseHeight+20
    shadow.xScale = 320
    shadow.alpha = 0.45
    group:insert(shadow);

	
	local function onRowTouch( event )
        local row = event.target
        local rowGroup = event.view
 
        if event.phase == "press" then
                if not row.isCategory then rowGroup.alpha = 0.5;
               
                end
 
        elseif event.phase == "release" then
 
            if not row.isCategory then
                
                -- Decompact the row information
                
                local t = split(event.target.id);
            
                -- First, check for 'TOT' - we only want to go to a teamseason page if the team is real, and not a row representing one or more teams
                -- Note that the '~' symbol in Lua means "NOT", much like "!" in other languages.
                if (t[2] ~= "TOT") then
                	updateHistory(currentScene);
                    -- reRender property tells row to refresh if still onScreen when content moves
                    row.reRender = true
                    local t = split(event.target.id);
		            local year = t[1]
		            local team = t[2]
                    whichTeamSeason =year;
                    whichYear = year;
                    whichTeam = team;
               		
               		 -- Go to a particular season's roster
               		
                    storyboard.gotoScene( "teamseason" );
                end
            end
        end
 
 	   return true
	end
 
 	
	-- onRender listener for the tableView that renders each row
	local function onRowRender( event )
        local row = event.target
        local rowGroup = event.view
        local teamName;
           
        local gp;
        local ppg;
        local fgp;
        local ftp;
        local tpp;
        local rpg;
        local apg;
        local spg;
        local bpg;
        local team;
        local year;
        
        -- This is where we draw each row (each representing a season) in the player's stat table
        -- First decompact the row's information stored in the id field
	    
		t = split(event.target.id);
		year = t[1]
		team = t[2]
		gp = t[3] 
		mpg = t[4] 
		ppg = t[5] 
		fgp = t[6]
		ftp = t[7] 
		tpp = t[8] 
		rpg = t[9] 
		apg = t[10] 
		spg = t[11];
		bpg = t[12];
		
	    year = "'"..computeNextSeason(year-1);
			
        -- Draw the stats onscreen in a line in a monospace font
        
	    local compStats = year .. " " .. team .. " " .. gp .. " " .. mpg .. " " .. ppg .. " " .. fgp .. " " .. ftp .. " " .. tpp .. " " .. rpg .. " " .. apg .. " " .. spg .. " " .. bpg;
   	 	local text = display.newRetinaText( compStats, 18, 0, "Monaco", 10 )
    	text:setReferencePoint( display.CenterLeftReferencePoint )
    	text.y = row.height * 0.5
    	
    	if not row.isCategory then
    		text.x = 7
    		text:setTextColor( 0 )
    	end
 
        -- must insert everything into event.view: (tableView requirement)
        rowGroup:insert( text )
	end
 
	-- Create a row for each season the player played and add it to the tableView:
	for row in db:nrows("SELECT * FROM player_regular_season WHERE ilkid = '"..whichPlayer.."' ORDER BY year DESC" ) do
    	local rowHeight, rowColor, lineColor, isCategory, id
 		rowHeight = 40;
 		local team = row.team;
 		local year = row.year;
 		local gp = row.gp
	
	    -- Special case for games being under ten
	
	    if (gp < 10) then
	        gp = " "..gp;
	    end
	
	    local team = row.team;
	    local mpg = formatStat(row.minutes/row.gp,2);
	    local ppg = formatStat(row.pts / row.gp,2);
	    local fgp = formatPerc(row.fgm/row.fga,1);
	    local ftp = row.ftm / row.fta
	
	    -- Special case formatting for free throw percentage (we only want three characters, and some players have 0% or 100% ft%)
	    -- Note this may still be problematic in certain edge cases.
	    
	    if (ftp == 1) then
	        ftp = "1.0";
	
	    elseif (row.ftm == 0) then
	        ftp = ".00";
	
	    else
		    ftp = formatPerc(ftp);
		
	    end
	
	    local tpp;
	    
	    -- Special case to account for seasons before the advent of the 3-pointer.
	
	    if (row.tpm > 0) then
	        tpp = formatPerc(row.tpm/row.tpa);
	    else
	        tpp = ".00";
	    end
	
	    local rpg = formatStat(row.reb / row.gp,2);
	    local apg = formatStat(row.asts / row.gp,2);
	    local spg = formatStat(row.stl / row.gp,1);
	    local bpg = formatStat(row.blk / row.gp,1);
 		
 		-- Trying to combine team and year into one ID
 		id = row.year .. "," .. team .. "," .. gp .. "," .. mpg .. "," .. ppg .. "," .. fgp .. "," .. ftp .. "," .. tpp .. "," .. rpg .. "," .. apg .. "," .. spg .. "," .. bpg;
 		
        -- make the 25th item a category (not being used right now)
        if i == 25 then
                isCategory = true; rowHeight = 24; rowColor={ 70, 70, 130, 255 }; lineColor={0,0,0,255}
        end
 
        -- make the 45th item a category as well
        if i == 45 then
                isCategory = true; rowHeight = 24; rowColor={ 70, 70, 130, 255 }; lineColor={0,0,0,255}
        end
        
        rowColor={ 70, 70, 130, 0 };
        
        -- Function below is responsible for creating the row
        
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

	
	
	local theName = lookupPlayerName(whichPlayer);
	
	-- Create the NavBar with the appropriate title
	createNavBar(theName);
    displayBackButton();
	
	-- Insert everything into the group to be changed on scene changes
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