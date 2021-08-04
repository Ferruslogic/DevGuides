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
    local tThisStack, tThisCard, tHalf, tMyRect, tOrigRect, tHandleSize, tHalfHandle
    local tHandle1Rect, tHandle2Rect, tMouseLoc, tTarget, tWidth, tHeight, tCombine
    local x, y, tNewXMiddleLoc, tNewYMiddleLoc, tNewXLoc, tNewYLoc, tNewXRightLoc, tNewYBotLoc
    local tNewLoc
    
    put  the name of this stack into tThisStack
    put the long id of target into tTarget
    
    if  word 1 of tTarget is in "stack card" or _stackNameIsIDEStack( tThisStack ) or the tool <> "pointer tool" or tThisStack <> the name of the topStack  then
        _deleteGuides
        pass MouseMove
    end if
    
    if there is no a grc (kDontLog &"_GrcHorz")  then _createGuides
    
    if the mouse is up then 
        _initializeScript
        
        put true into sFirstRound
        put false into sMouseDownInHandle
        
        _hideGuides --> hides Guides when mouse is up
        pass MouseMove
    end if
    
    if sDiffX = "" then _initializeScript
    if sMouseDownInHandle then pass MouseMove --> let resizing go ahead
    
    # catch mouseDown in reisize handles
    if sFirstRound then
        put the rect of tTarget into tMyRect
        put the width of tTarget into tWidth
        put the height of tTarget into tHeight
        
        put tMyRect into tOrigRect
        put false into sMouseDownInHandle
        
        # check for resize handles
        if char 1 of the version >= 8 then
            put 4 into tHandleSize
        else
            put 8 into tHandleSize
        end if
        
        put round(  tHandleSize/2 ) + 1 into tHalfHandle
        
        if tWidth >= tHeight then
            # landscape
            put round (tWidth/2) into tHalf
            
            put item 1 of tMyRect + tHalf - tHalfHandle into item 1 of tHandle1Rect
            put item 2 of tMyRect +1 into item 2 of tHandle1Rect
            
            put item 1 of tMyRect + tHalf + tHalfHandle into item 3 of tHandle1Rect
            put item 2 of tMyRect +1 + tHandleSize into item 4 of tHandle1Rect
            
            put tHandle1Rect into tHandle2Rect
            
            put item 4 of tMyRect into item 4 of tHandle2Rect
            put item 4 of tMyRect -1 - tHandleSize into item 2 of tHandle2Rect
            
            add tHandleSize to item 1 of tMyRect
            subtract tHandleSize from item 3 of tMyRect         
        else
            
            # portrait
            put round( tHeight/2 ) into tHalf
            
            put item 1 of tMyRect into item 1 of tHandle1Rect
            put item 2 of tMyRect + tHalf - tHalfHandle into item 2 of tHandle1Rect
            
            put item 1 of tMyRect + tHandleSize into item 3 of tHandle1Rect
            put item 2 of tMyRect + tHalf + tHalfHandle into item 4 of tHandle1Rect
            
            put tHandle1Rect into tHandle2Rect
            
            put item 3 of tMyRect - tHandleSize into item 1 of tHandle2Rect
            put item 3 of tMyRect into item 3 of tHandle2Rect
            
            add tHandleSize to item 2 of tMyRect
            subtract tHandleSize from item 4 of tMyRect
        end if
        
        put pX, pY into tMouseLoc
        
        if tMouseLoc is not within tMyRect or tMouseLoc is  not  within tHandle1Rect or  tMouseLoc is  not  within tHandle2Rect then
            put true into sMouseDownInHandle
            pass MouseMove
        end if
        
        put false into sFirstRound
    end if
    
    if the shiftKey is down then
        _hideGuides
        pass MouseMove
    end if
    
    # capsLockKey shows left and top distance in addition to guides
    put the capsLockKey is down into tCombine
    
    # account for offset of mouse from center of control
    put pX - sDiffX into x
    put pY - sDiffY into y
    
    _hideGuides
    
    # test match for horizontal or vertical middle of any target
    put _getMiddleX( x ) into tNewXMiddleLoc
    
    # test if in vertical middle of any control
    put _getMiddleY(  tTarget, y ) into tNewYMiddleLoc
    
    # test match for left and top
    # test if left is equal
    put _getLeftX( x ) into tNewXLoc
    
    # test if top is equal
    put _getTopY(  tTarget, y ) into tNewYLoc
    
    
    # test match for right and bottom
    put _getRightX( x ) into tNewXRightLoc
    put _getBotY( tTarget, y ) into tNewYBotLoc
    
    # now build new x,y coordinate for location of me
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
    set the loc of target to tNewLoc
    
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
    
    lock messages
    
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
    
    unlock messages
end _createGuides


private command _deleteGuides
    local tCard
    
    lock messages
    put the long id of this card into tCard
    
    repeat for each item i in kGuides
        if there is a graphic (kDontLog & i) of tCard then
            delete graphic (kDontLog & i) of tCard
        end if
    end repeat
    
    unlock messages
end _deleteGuides


private command _initializeScript
    local  tTarget, tThisCd, tMyLoc, tMyId, tIAmSelected, tShortName, tLongID, tChildIDs
    
    put the long id of target into tTarget
    if word 1 of tTarget is in "stack card" or the tool is no "pointer tool" or there is no a grc  (kDontLog &"_GrcHorz") then exit _initializeScript
    
    put empty into sNeighbors
    put empty into sAllControls
    
    put the long id of this card into tThisCd
    put the childControlIDs of tThisCd into tChildIDs
    
    put the loc of tTarget into tMyLoc
    put short id of tTarget into tMyID
    put the selected of tTarget into tIAmSelected
    
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
    
    # for middle of card horizontal and vertical guides
    put item 1 of tMyLoc - the left of tTarget into sDistCenterToLeft
    put item 2 of tMyLoc - the top of tTarget into sDistCenterToTop
    put item 1 of tMyLoc - the right of tTarget into sDistCenterToRight
    put item 2 of tMyLoc - the bottom of tTarget into sDistCenterToBot
    
    put the mouseH - item 1 of tMyLoc into sDiffX
    put the mouseV - item 2 of tMyLoc into sDiffY
    
    put true into sFirstRound
    put false into sMouseDownInHandle
    
    put item 1 of the loc of tThisCd into sCardX
    put item 2 of the loc of tThisCd into sCardY
    
    put false into sXNeedsDrawing
    put false into sYNeedsDrawing
    put false into sLeftXNeedsDrawing
    put false into sTopYneedsDrawing
    put false into sRightXNeedsDrawing
    put false into sBotYneedsDrawing
    
end _initializeScript


private command _hideGuides 
    local tCard
    
    lock messages
    put the long id of this card into tCard
    
    repeat for each item i in kGuides
        if there is a graphic (kDontLog & i) of tCard then
            set the visible of graphic (kDontLog & i) of tCard to false
        end if
    end repeat
    
    unlock messages
end _hideGuides


private function _getMiddleX  @pMyX
    local tLower, tUpper, tReturnValue, aX
    
    put pMyX - kTolerance into tLower
    put pMyX + kTolerance into tUpper   
    
    put "" into sMiddleXList
    put "" into tReturnValue
    
    repeat for each key anObject in sAllControls
        put item 1 of sAllControls[anObject]["loc"] into aX
        
        if aX >= tLower and aX <= tUpper then 
            put anObject & cr after sMiddleXList
            put aX into tReturnValue
        end if
    end repeat
    
    if sCardX >= tLower and sCardX <= tUpper then
        put the long id of this card & return into sMiddleXList
        put sCardX into tReturnValue
    end if
    
    if sMiddleXList <> "" then
        delete char - 1 of sMiddleXList
        put true into sXNeedsDrawing
    else
        put false into sXNeedsDrawing
    end if
    
    return tReturnValue
end _getMiddleX


private function _getMiddleY  @pTarget, @pMyY
    local tLowerY, tUpperY, tReturnValue, tMyYLoc, aY
    
    put pMyY - kTolerance into tLowerY
    put pMyY + kTolerance into tUpperY
    
    put "" into sMiddleYList
    put "" into tReturnValue
    
    put item 2 of the loc of pTarget into tMyYLoc
    
    repeat for each key anObject in sAllControls
        put item 2 of sAllControls[anObject]["loc"] into aY
        if aY >= tLowerY and aY <= tUpperY then 
            put anObject & cr after sMiddleYList
            put aY into tReturnValue
        end if
    end repeat
    
    if sCardY >= tLowerY and sCardY <= tUpperY then
        put the long id of this card & return into sMiddleYList
        put sCardY into tReturnValue
    end if
    
    if sMiddleYList <> "" then
        delete char - 1 of sMiddleYList
        put true into sYNeedsDrawing
    else
        put false into sYNeedsDrawing
    end if
    
    return tReturnValue
end _getMiddleY



private function _getLeftX  @pMyX
    local tLower, tUpper, tReturnValue, aLeftX
    
    put pMyX - sDistCenterToLeft - kTolerance into tLower
    put pMyX - sDistCenterToLeft + kTolerance into tUpper   
    
    put "" into sLeftXList
    put "" into tReturnValue
    
    repeat for each key anObject in sAllControls
        put item 1 of sAllControls[anObject]["rect"] into aLeftX
        
        if aLeftX >= tLower and aLeftX <= tUpper then 
            put anObject & cr after sLeftXList
            put aLeftX + sDistCenterToLeft into tReturnValue
        end if
    end repeat
    
    if sLeftXList <> "" then
        delete char - 1 of sLeftXList
        put true into sLeftXNeedsDrawing
    else
        put false into sLeftXNeedsDrawing
    end if
    
    return tReturnValue
end _getLeftX

private function _getTopY  @pTarget, @pMyY
    local tLowerY, tUpperY, tReturnValue, tMyYLoc, tMyMidX, aY
    
    put pMyY - sDistCenterToTop - kTolerance into tLowerY
    put pMyY - sDistCenterToTop + kTolerance into tUpperY
    
    put "" into sTopYList
    put "" into tReturnValue
    
    put item 2 of the loc of pTarget into tMyYLoc
    put item 1 of the loc of pTarget into tMyMidX
    
    repeat for each key anObject in sAllControls
        put item 2 of sAllControls[anObject]["rect"] into aY
        
        if aY >= tLowerY and aY <= tUpperY then 
            put anObject & cr after sTopYList
            put aY + sDistCenterToTop into tReturnValue
        end if
        
    end repeat
    
    if sTopYList <> "" then
        delete char - 1 of sTopYList
        put true into sTopYneedsDrawing
    else
        put false into sTopYneedsDrawing
    end if
    
    return tReturnValue
end _getTopY


private function _getRightX @pMyX
    local tLower, tUpper, tReturnValue, aRightX
    
    put pMyX - sDistCenterToRight - kTolerance into tLower
    put pMyX - sDistCenterToRight + kTolerance into tUpper
    
    put "" into sRightXList
    put "" into tReturnValue
    
    repeat for each key anObject in sAllControls
        put item 3 of sAllControls[anObject]["rect"] into aRightX
        
        if aRightX >= tLower and aRightX <= tUpper then 
            put anObject & cr after sRightXList
            put aRightX + sDistCenterToRight into tReturnValue
        end if
        
    end repeat
    
    if sRightXList <> "" then
        delete char - 1 of sRightXList
        put true into sRightXNeedsDrawing
    else
        put false into sRightXNeedsDrawing
    end if
    
    return tReturnValue
end _getRightX


private function _getBotY  @pTarget, @pMyY
    local tUpperY, tLowerY, tReturnValue, tMyBotYLoc, tMyMidX, aY
    
    put pMyY - sDistCenterToBot - kTolerance into tLowerY
    put pMyY - sDistCenterToBot + kTolerance into tUpperY
    
    put "" into sBotYList
    put "" into tReturnValue
    
    put the bottom of pTarget into tMyBotYLoc
    put item 1 of the loc of pTarget into tMyMidX
    
    repeat for each key anObject in sAllControls
        put item 4 of sAllControls[anObject]["rect"] into aY
        if aY >= tLowerY and aY <= tUpperY then 
            put anObject & cr after sBotYList
            put aY + sDistCenterToBot into tReturnValue
        end if
    end repeat
    
    if sBotYList <> "" then
        delete char - 1 of sBotYList
        put true into sBotYneedsDrawing
    else
        put false into sBotYneedsDrawing
    end if
    
    return tReturnValue
end _getBotY











private function _stackNameIsIDEStack pStackName
    if there is no a stack pStackName  then return false
    return  the _ideoverride of stack pStackName or pStackName begins with "rev"or pStackName is among the items of "message box,answer dialog,ask dialog,home" or pStackName begins with "com.livecode."
end _stackNameIsIDEStack

