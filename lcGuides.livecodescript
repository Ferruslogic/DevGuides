script "lcGuides"
-- Codigo origuinal por ---
# bnGuides
# ©Bernd Niggemann
# Mar 2016 to Mar 2019
# version 0.5.0
# this stack shows guides for objects when moving objects around in Edit-Mode.
# use it as plugin
----------------------------------------
# Actualizado por FerrusLogic 2021

local sLastSelectedA -- the selected objects
local sActualObjectForBehaviorArray -- the object at the top of behavior chain
local sStacksWithGuidesA -- the stack(s) that have guides placed upon

local sGuideBehaviorRugged -- the rugged id of the button of this stack that contains the behavior script
local sGuideBehaviorLID -- the long id of the button of this stack that contains the behavior script
----------------------------------------------

local sDistCenterToLeft, sDistCenterToTop, sDistCenterToRight, sDistCenterToBot
local sFirstRound
local sCardX, sCardY
local sNeighbors, sAllControls


# for display lines beyond the boundaries of objects
constant kOvershoot = 16, kOvershootOffset =  9
constant kDontLog = "bnGuide"
constant kGuides = "_GrcHorz,_GrcTop,_GrcBot,_GrcDistRight,_GrcVert,_GrcLeft,_GrcRight,_GrcDistBot,_GrcDistNumTop,_GrcDistNumLeft,_GrcDistNumBot,_GrcDistNumRight"

local sDiffX = "", sDiffY = ""

local sXNeedsDrawing, sMiddleXList
local sYNeedsDrawing, sMiddleYList
local sTopYneedsDrawing, sTopYList
local sLeftXNeedsDrawing, sLeftXList
local sRightXNeedsDrawing, sRightXList
local sBotYneedsDrawing, sBotYList

local sMouseDownInHandle = false

# the "magnetic" zone ± kTolerance
constant kTolerance = 3

on preOpenStack
    revIDESubscribe "ideNewControl"
    revIDESubscribe "ideControlDeleted"
    revIDESubscribe "ideSelectedObjectChanged"
    revIDESubscribe "ideToolChanged"
    revIDESubscribe "ideWindowsChanged"
end preOpenStack

on ideNewControl
    _deleteGuides
end ideNewControl

on ideControlDeleted
    _deleteGuides
end ideControlDeleted

on ideToolChanged
    if  the tool is no "pointer tool" then
        _deleteGuides
    end if
end ideToolChanged

on closeCard
    _deleteGuides
    pass closeCard
end closeCard

on ideSelectedObjectChanged
    local tSelected, tSelectedOne
    
    put the selectedObjects into tSelected
    
    if tSelected is empty then
        _deleteGuides
        exit ideSelectedObjectChanged
    end if
    
    # exclude all stacks but toplevel stacks
    put line 1 of tSelected into tSelectedOne
    put char (offset("stack", tSelectedOne)) to -1 of tSelectedOne into tSelectedOne
    
    if the mode of tSelectedOne > 1 then
        _deleteGuides
        exit ideSelectedObjectChanged
    end if
    
    
    repeat for each line tControl in tSelected
        if tControl contains "Data Grid Templates" then next repeat -- exclude datat grid templates
        
        put 1 into sLastSelectedA[ tControl ]
    end repeat    
    
end ideSelectedObjectChanged


on resumeStack 
    local  tSelectionStack
    
    _deleteGuides
    if the selectedObject is empty then exit ResumeStack
    
    put line 1 of the selectedObject into tSelectionStack
    put char (offset("stack", tSelectionStack)) to -1 of tSelectionStack into tSelectionStack
    
    if  the topStack is tSelectionStack then
        ideSelectedObjectChanged
    end if
    
    pass resumeStack
end resumeStack


on saveStackRequest
    _deleteGuides
    pass saveStackRequest
end saveStackRequest



----------------------------------------------------------------------------
------------------------ CORE OF PLUGIN -------------------------------
----------------------------------------------------------------------------


on mouseMove pX, pY
    local tThisStack, tThisCard
    local tHalf, tMyRect, tOrigRect, tHandleSize, tHalfHandle
    local tHandle1Rect, tHandle2Rect
    local tMouseLoc
    
    put  the name of this stack into tThisStack
    
    if  _stackNameIsIDEStack( tThisStack ) or the tool <> "pointer tool" or tThisStack <> the name of the topStack  then
        _deleteGuides
        pass MouseMove
    end if
    
    if there is no a grc (kDontLog &"_GrcHorz")  then _createGuides
    
    if the mouse is up then 
        _initializeScript
        
        put true into sFirstRound
        put false into sMouseDownInHandle
        
        _hideGuides --> hides Guides when mouse is up
        exit MouseMove
    end if
    
    if sDiffX = "" then _initializeScript
    if sMouseDownInHandle then pass MouseMove --> let resizing go ahead
    
    
   # catch mouseDown in reisize handles
    if sFirstRound then
        
        put the rect of target into tMyRect
        put tMyRect into tOrigRect
        put false into sMouseDownInHandle
        
        # check for resize handles
        if char 1 of the version >= 8 then
            put 4 into tHandleSize
        else
            put 8 into tHandleSize
        end if
        
        put round(tHandleSize/2) + 1 into tHalfHandle
        
        if (item 3 of tMyRect - item 1 of tMyRect) >= (item 4 of tMyRect - item 2 of tMyRect) then
            # landscape
            put round ((item 3 of tMyRect - item 1 of tMyRect)/2) into tHalf
            put item 1 of tMyRect + tHalf - tHalfHandle into item 1 of tHandle1Rect
            put item 2 of tMyRect +1 into item 2 of tHandle1Rect
            put item 1 of tMyRect + tHalf + tHalfHandle into item 3 of tHandle1Rect
            put item 2 of tMyRect +1 + tHandleSize into item 4 of tHandle1Rect
            put tHandle1Rect into tHandle2Rect
            put item 4 of tMyRect into item 4 of tHandle2Rect
            put item 4 of tMyRect -1 - tHandleSize into item 2 of tHandle2Rect
            add tHandleSize to item 1 of tMyRect; subtract tHandleSize from item 3 of tMyRect         
        else
            -- portrait
            put round((item 4 of tMyRect - item 2 of tMyRect)/2) into tHalf
            put item 1 of tMyRect into item 1 of tHandle1Rect
            put item 2 of tMyRect + tHalf - tHalfHandle into item 2 of tHandle1Rect
            put item 1 of tMyRect + tHandleSize into item 3 of tHandle1Rect
            put item 2 of tMyRect + tHalf + tHalfHandle into item 4 of tHandle1Rect
            put tHandle1Rect into tHandle2Rect
            put item 3 of tMyRect - tHandleSize into item 1 of tHandle2Rect
            put item 3 of tMyRect into item 3 of tHandle2Rect
            add tHandleSize to item 2 of tMyRect; subtract tHandleSize from item 4 of tMyRect
        end if
        
        put pX, pY into tMouseLoc
        if not (tMouseLoc is within tMyRect) or (tMouseLoc is within tHandle1Rect) or (tMouseLoc is within tHandle2Rect)  then
            put true into sMouseDownInHandle
            pass MouseMove
        end if
        -- end test for mouseDown in resize handles
        put false into sFirstRound
    end if -- first round
    
    if the shiftKey is down then
        _hideGuides
        pass MouseMove
    end if
    
    local tCombine
    if (the capsLockKey is down) then -- capsLockKey shows left and top distance in addition to guides
        put true into tCombine
    else
        put false into tCombine
    end if -- capsLockKey is down
    
    
    local x, y, tNewXMiddleLoc, tNewYMiddleLoc, tNewXLoc, tNewYLoc, tNewXRightLoc, tNewYBotLoc
    local tNewLoc
    -- account for offset of mouse from center of control
    put pX - sDiffX into x
    put pY - sDiffY into y
    -- end account for offset of mouse
    
    _hideGuides
    
    -- test match for horizontal or vertical middle of any target
    put getMiddleX(x) into tNewXMiddleLoc
    
    -- test if in vertical middle of any control
    put getMiddleY(y) into tNewYMiddleLoc -- test for middle Y
    -- end test for middle
    
    -- test match for left and top
    -- test if left is equal
    put getLeftX(x) into tNewXLoc
    -- test if top is equal
    put getTopY(y) into tNewYLoc
    -- end test for left and top
    
    -- test match for right and bottom
    put getRightX(x) into tNewXRightLoc
    put getBotY(y) into tNewYBotLoc
    -- end test for right and bottom
    
    -- now build new x,y coordinate for location of me
    if tNewXMiddleLoc <> "" and tNewXLoc = "" then put tNewXMiddleLoc into tNewXLoc
    if tNewXMiddleLoc = "" and tNewXLoc = "" then put tNewXRightLoc into tNewXLoc
    
    if tNewYMiddleLoc <> "" and tNewYLoc = "" then put tNewYMiddleLoc into tNewYLoc
    if tNewYMiddleLoc = "" and tNewYLoc = "" then put tNewYBotLoc into tNewYLoc
    
    if tNewXLoc <> "" then 
        put tNewXLoc  into item 1 of tNewLoc
    else
        put x into item 1 of tNewLoc
    end if
    if tNewYLoc <> "" then
        put tNewYLoc  into item 2 of tNewLoc
    else
        put y into item 2 of tNewLoc
    end if
    -- end build location
    
    ## here we set the loc and test guides against this new loc in drawXXX handlers
    set the loc of me to tNewLoc
    
    -- now check if matching guide objects still fit after setting the loc of the object
    -- xxxNeedsDrawing means there are objects within "magnetic" tolerance, only draw if tNewLoc still fits
    if sLeftXNeedsDrawing then
        DrawLeftX
        put false into sLeftXNeedsDrawing
    else
        set the visible of grc "bnGuidegrcLeft" to false
    end if
    
    if sTopYneedsDrawing then
        drawTopY
        put false into sTopYneedsDrawing
    else
        set the visible of grc "bnGuidegrcTop" to false
    end if
    
    if sXNeedsDrawing then
        drawMiddleX
        put false into sXNeedsDrawing
    else
        set the visible of grc "bnGuidegrcVert" to false
    end if
    
    if sYNeedsDrawing then
        drawMiddleY
        put false into sYNeedsDrawing
    else
        set the visible of grc "bnGuidegrcHorz" to false
    end if
    
    if sRightXNeedsDrawing then
        drawRightX
        put false into sRightXNeedsDrawing
    else
        set the visible of grc "bnGuidegrcRight" to false
    end if
    
    if sBotYneedsDrawing then
        DrawBotY
        put false into sBotYneedsDrawing
    else
        set the visible of grc "bnGuidegrcBot" to false
    end if
    
    if tCombine then
        drawNextHorzDistanceLeft tNewLoc
        drawNextHorzDistanceRight tNewLoc
        drawNextVertDistanceTop tNewLoc
        drawNextVertDistanceBot tNewLoc
    end if
    
    local tNeighborLoc
    
    -- in case of multiple controls selected set their new loc now
    if sNeighbors is an array then -- multiple controls selected
        repeat for each key aNeighbor in sNeighbors
            put item 1 of tNewLoc - sNeighbors[aNeighbor]["XDiff"] into item 1 of tNeighborLoc
            put item 2 of tNewLoc - sNeighbors[aNeighbor]["YDiff"] into item 2 of tNeighborLoc
            set the loc of aNeighbor to tNeighborLoc
        end repeat
    end if
    -- end mulitiple controls selected
    
    pass MouseMove
end MouseMove


private command _createGuides
    local tGuidePlace
    
    lock screen; lock messages
    
    reset the templateGraphic
    set the opaque of the templateGraphic to true
    set the antialiased of the templateGraphic to true
    set the cantSelect of the templateGraphic to true
    
    set the style of the templateGraphic to "line"
    set the points of the templateGraphic to "20,0" & cr & "10,0"
    create invisible grc kDontLog & "_GrcHorz"
    create invisible grc kDontLog &"_GrcTop"
    create invisible grc kDontLog &"_GrcBot"
    
    create invisible grc kDontLog &"_GrcDistRight"
    set the points of the templateGraphic to "0,20" & cr & "0,10"
    create invisible grc kDontLog &"_GrcVert"
    create invisible grc kDontLog &"_GrcLeft"
    create invisible grc kDontLog &"_GrcRight"
    create invisible grc kDontLog &"_GrcDistBot"
    
    set the style of the templateGraphic to "roundRect"
    set the backgroundColor of the templateGraphic to "150,210,255"
    set the lineSize of the templateGraphic to 0
    set the width of the templateGraphic to 28
    set the height of the templateGraphic to 17
    set the textSize of the templateGraphic to 11
    set the showName of the templateGraphic to true
    set the label of the templateGraphic to space
    create invisible grc kDontLog &"_GrcDistNumTop"
    create invisible grc kDontLog &"_GrcDistNumLeft"
    create invisible grc kDontLog &"_GrcDistNumBot"
    create invisible grc kDontLog &"_GrcDistNumRight"
    reset the templateGraphic
    
    put it into tGuidePlace
    put _getOwningStackName(tGuidePlace) into tGuidePlace
    
    _addToStacksWithGuides tGuidePlace -- register
    
    unlock messages;  unlock screen
end _createGuides


private command _deleteGuides
    lock screen
    lock messages
    local tCard
    put the long id of this card into tCard
    
    repeat for each item i in kGuides
        if there is a graphic (kDontLog & i) of tCard then
            delete graphic (kDontLog & i) of tCard
        end if
    end repeat
    
    unlock messages
    unlock screen
end _deleteGuides


private command _initializeScript
    local  tTarget, tMyLoc, tMyId, tIAmSelected, tShortName, tLongID
    local tChildIDs
    
    put the long id of target into tTarget
    if word 1 of tTarget is in "stack card" or the tool is no "pointer tool" or there is no a grc  (kDontLog &"_GrcHorz") then exit _initializeScript
    
    put empty into sNeighbors
    put empty into sAllControls
    
    put the loc of target into tMyLoc
    put short id of target into tMyID
    put the selected of target into tIAmSelected
    
    put the childControlIDs of this card into tChildIDs
    
    repeat for each line tShortID in tChildIDs
        put the short name of control id tShortID into tShortName
        put the long id of control id tShortID into tLongID --> a way to know kind of control for later
        
        # exclude "guide" objects, me and invisibles
        if tShortName contains kDontLog or tShortID is tMyID or the visible of tLongID is false 
        then  next repeat
        
        # store the diff to the loc of controls we want to move along with the dragged control
        if the selected of control id tShortID and tIAmSelected then
            put item 1 of tMyLoc - item 1 of the loc of tLongID into sNeighbors[ tLongID ]["XDiff"]
            put item 2 of tMyLoc - item 2 of the loc of tLongID into sNeighbors[ tLongID ]["YDiff"]
            next repeat
        end if
        
        put the rect of tLongID into sAllControls[ tLongID ]["rect"]
        put the loc of tLongID into sAllControls[ tLongID ]["loc"]
    end repeat
    
    -- for middle of card horizontal and vertical guides
    put item 1 of tMyLoc - the left of me into sDistCenterToLeft
    put item 2 of tMyLoc - the top of me into sDistCenterToTop
    put item 1 of tMyLoc - the right of me into sDistCenterToRight
    put item 2 of tMyLoc - the bottom of me into sDistCenterToBot
    
    local tMouseLoc
    put the mouseLoc into tMouseLoc
    if tMouseLoc <> "" then
        put item 1 of tMouseLoc - item 1 of tMyLoc into sDiffX
        put item 2 of tMouseLoc - item 2 of tMyLoc into sDiffY
    end if
    put true into sFirstRound
    put false into sMouseDownInHandle
    
    put item 1 of the loc of this card into sCardX
    put item 2 of the loc of this card into sCardY
    
    put false into sXNeedsDrawing
    put false into sYNeedsDrawing
    put false into sLeftXNeedsDrawing
    put false into sTopYneedsDrawing
    put false into sRightXNeedsDrawing
    put false into sBotYneedsDrawing
    
    unlock screen
end _initializeScript


private command _hideGuides 
    // TODO:
end _hideGuides


private function _getOwningStackName   pLongId
    local tOffset, tOffset2, tStackPart, tStackName, tCard
    
    put offset("stack", pLongID) into tOffset
    put char tOffset to -1 of pLongID into tStackPart
    put the name of tStackPart into tStackName
    put offset("card", pLongID) into tOffset2
    put char tOffset2 to tOffset -1 of pLongID & tStackName into tStackName
    
    return tStackName
end _getOwningStackName


private command _addToStacksWithGuides pToAdd
    put 1 into sStacksWithGuidesA[ pToAdd ]
end _addToStacksWithGuides


private function _stackNameIsIDEStack pStackName
    if there is no a stack pStackName  then return false
    return  the _ideoverride of stack pStackName or pStackName begins with "rev"or pStackName is among the items of "message box,answer dialog,ask dialog,home" or pStackName begins with "com.livecode."
end _stackNameIsIDEStack

