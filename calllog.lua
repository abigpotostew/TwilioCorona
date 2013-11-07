--*********************************************************************************************
--
-- ====================================================================
-- Corona SDK "Widget" Sample Code
-- ====================================================================
--
-- File: main.lua
--
-- Version 2.0
--
-- Copyright (C) 2013 Corona Labs Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--
-- Published changes made to this software and associated documentation and module files (the
-- "Software") may be used and distributed by Corona Labs, Inc. without notification. Modifications
-- made to this software and associated documentation and module files may or may not become
-- part of an official software release. All modifications made to the software will be
-- licensed under these same terms and conditions.
--
--*********************************************************************************************

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- create a constant for the left spacing of the row content
local LEFT_PADDING = 10

local tableView = nil

function scene:createTableLog(twilio_response)
    -- Forward reference for our tableView
	local group = self.view
    
    --Data to be displayed when a row is selected
	local rowDisplayData = {['To:'] = 'to_formatted', ['From:'] = 'from_formatted', ['Status:'] = 'status', ['Duration:'] = 'duration'}
    
	-- Text to show which item we selected
    local itemSelected = {}
    local itemY = 150
    for k, v in pairs(rowDisplayData) do
       itemSelected[k] = display.newText( k, 0, 0, native.systemFontBold, 14 )
       itemSelected[k]:setTextColor( 0 )
       itemSelected[k].x = display.contentWidth + itemSelected[k].contentWidth * 0.5
       itemSelected[k].y = itemY
       group:insert( itemSelected[k] )
       itemY = itemY + itemSelected[k].contentHeight + 10
    end
    local selectedItemAnchor = itemSelected['To:']
    
	--local itemSelected = display.newText( "You selected item ", 0, 0, native.systemFontBold, 28 )
	
	
	-- Function to return to the list
	local function goBack( event )
		--Transition in the list, transition out the item selected text and the back button
		transition.to( tableView, { x = 0, time = 400, transition = easing.outExpo } )
		
        
        for k, v in pairs(itemSelected) do
            local item = v
            transition.to( item, { x = display.contentWidth + item.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
                
        end
        
		transition.to( event.target, { x = display.contentWidth + event.target.contentWidth * 0.5, time = 400, transition = easing.outQuad } )
	end
	
	-- Back button
	local backButton = widget.newButton
	{
		width = 198,
		height = 59,
		label = "Back",
		onRelease = goBack,
	}
	backButton.x = display.contentWidth + backButton.contentWidth * 0.5
	backButton.y = selectedItemAnchor.y + selectedItemAnchor.contentHeight + backButton.contentHeight
	group:insert( backButton )
	
	-- Listen for tableView events
	local function tableViewListener( event )
		local phase = event.phase
		
		--print( "Event.phase is:", event.phase )
	end

	-- Handle row rendering
	local function onRowRender( event )
		local phase = event.phase
		local row = event.row
		local text = "Call log page 1. All pages not shown in ex."
        if not row.isCategory then
            text = row.params.sid
        end
        
		local rowTitle = display.newText( row, text, 0, 0, nil, 14 )
		rowTitle.x = row.x - ( row.contentWidth * 0.5 ) + ( rowTitle.contentWidth * 0.5 ) + LEFT_PADDING
		rowTitle.y = row.contentHeight * 0.5
		rowTitle:setTextColor( 0, 0, 0 )
        
        --if text == "" then
        --    rowTitle.text = 
        --end
        
        --
	end
	
	-- Handle row updates
	local function onRowUpdate( event )
		local phase = event.phase
		local row = event.row
		
		--print( row.index, ": is now onscreen" )
	end
	
    
    
	-- Handle touches on the row
	local function onRowTouch( event )
		local phase = event.phase
		local row = event.target
				
		if "release" == phase then
            transition.to( tableView, { x = - tableView.contentWidth, time = 400, transition = easing.outExpo } )
            transition.to( backButton, { x = display.contentCenterX, time = 400, transition = easing.outQuad } )
            for k, v in pairs(itemSelected) do
                local item = v
                --Update the item selected text
                item.text = k.." "..row.params[rowDisplayData[k]]
                
                --Transition out the list, transition in the item selected text and the back button
                
                transition.to( item, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
                
            end
		end
	end
	
	-- Create a tableView
	tableView = widget.newTableView
	{
		top = 32,
		width = 320, 
		height = 400,
		listener = tableViewListener,
		onRowRender = onRowRender,
		onRowUpdate = onRowUpdate,
		onRowTouch = onRowTouch,
	}
	group:insert( tableView )
	
    
    -- Insert the row into the tableView
    tableView:insertRow
    {
        isCategory = true,
        rowHeight = 35,
        rowColor ={default = { 150, 160, 180, 200 }, over = { 30, 144, 255 }, },
        lineColor = { 220, 220, 220 }
    }
    
	-- Create row per call log
	for i, call in ipairs(twilio_response.calls) do
		local rowColor = 
		{ 
			default = { 255, 255, 255 },
			over = { 30, 144, 255 },
		}
		
		-- Insert the row into the tableView
		tableView:insertRow
		{
			isCategory = false,
			rowHeight = 40,
			rowColor = rowColor,
			lineColor = { 220, 220, 220 },
            params = call
		}
	end 
    
end

function scene:enterScene(event)
    tableView = nil
    local group = self.view
    
    -- Create a spinner widget
	local spinner = widget.newSpinner
	{
		left = 150,
		top = 200,
	}
	group:insert( spinner )
	
	-- Start the spinner animating
	spinner:start()
    spinner.isVisible = true
    
    local statusText = display.newText( "Retriving Twilio call logs", 60, 240, native.systemFont, 20 )
    --statusText.x = 10
    --statusText.y = 235
    statusText:setTextColor(0, 0, 0)
    group:insert( statusText )
    
    local function request_listener(event)
        if event.success then
            group:remove(spinner)
            spinner:removeSelf()
            spinner=nil
            statusText:removeSelf()
            group:remove(statusText)
            self:createTableLog(event.response)
        else
            statusText.text = "Error retriving Twilio call logs"
        end
    end
    
    local vars = {Type="Calls"} --retrieve all call logs
    R:request(vars, "GET", request_listener)
end


-- Our scene
function scene:exitScene( event )
    if tableView then
        tableView:removeSelf()
        self.view:remove(tableView)
        tableView = nil
    end
end

scene:addEventListener("enterScene")
scene:addEventListener("exitScene")
--scene:addEventListener( "createScene" )

return scene
