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



on selectedObjectChanged
   local tSelected, tSelectedOne

   put the selectedObjects into tSelected

   if tSelected is empty then
       _deleteGuides
       exit selectedObjectChanged
   end if

   # exclude all stacks but toplevel stacks
   put line 1 of tSelected into tSelectedOne
   put char (offset("stack", tSelectedOne)) to -1 of tSelectedOne into tSelectedOne

   if the mode of tSelectedOne > 1 then
       _deleteGuides
       exit selectedObjectChanged
   end if


   repeat for each line tControl in tSelected
       if tControl contains "Data Grid Templates" then next repeat -- exclude datat grid templates

       put 1 into sLastSelectedA[ tControl ]
   end repeat    

end selectedObjectChanged


on resumeStack 
   local  tSelectionStack

   _deleteGuides
   if the selectedObject is empty then exit ResumeStack

   put line 1 of the selectedObject into tSelectionStack
   put char (offset("stack", tSelectionStack)) to -1 of tSelectionStack into tSelectionStack

   if  the topStack is tSelectionStack then
       selectedObjectChanged
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
local sIsDown

on mouseDown pBtn
   put true into sIsDown
end mouseDown

on mouseMove pX, pY
   local tThisStack, tThisCard, tHalf, tMyRect, tOrigRect, tHandleSize, tHalfHandle, tHandle1Rect, tHandle2Rect, tMouseLoc, tTarget, tWidth, tHeight, tCombine
   local tX, tY, tNewXMiddleLoc, tNewYMiddleLoc, tNewXLoc, tNewYLoc, tNewXRightLoc, tNewYBotLoc, tNewLoc

   put  the name of this stack into tThisStack
   put the long id of target into tTarget


   if  word 1 of tTarget is in "stack card" or _stackNameIsIDEStack( tThisStack ) or the tool <> "pointer tool" or tThisStack <> the name of the topStack  then
       _deleteGuides
       pass MouseMove
   end if


   if there is no a grc (kDontLog &"_GrcHorz")  then _createGuides

   if mouse(1) is "up" then 
       _initializeScript

       put true into sFirstRound
       put false into sMouseDownInHandle

       _hideGuides --> hides Guides when mouse is up
       pass MouseMove
   end if

   if sDiffX = empty then _initializeScript
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

       put pX,pY into tMouseLoc

       if tMouseLoc is not within tMyRect or tMouseLoc is  within tHandle1Rect or  tMouseLoc is  within tHandle2Rect then
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
   put pX - sDiffX into tX
   put pY - sDiffY into tY

   _hideGuides

   put the long id of this card into tThisCard

   # test match for horizontal or vertical middle of any target
   put _getMiddleX( tX , tThisCard) into tNewXMiddleLoc

   # test if in vertical middle of any control
   put _getMiddleY(  tTarget, tY , tThisCard) into tNewYMiddleLoc

   # test match for left and top
   # test if left is equal
   put _getLeftX( tX ) into tNewXLoc

   # test if top is equal
   put _getTopY(  tTarget, tY ) into tNewYLoc


   # test match for right and bottom
   put _getRightX( tX ) into tNewXRightLoc
   put _getBotY( tTarget, tY ) into tNewYBotLoc

   # now build new x,y coordinate for location of target
   if tNewXMiddleLoc <> empty and tNewXLoc = empty then put tNewXMiddleLoc into tNewXLoc
   if tNewXMiddleLoc = empty and tNewXLoc = empty then put tNewXRightLoc into tNewXLoc

   if tNewYMiddleLoc <> empty and tNewYLoc = empty then put tNewYMiddleLoc into tNewYLoc
   if tNewYMiddleLoc = empty and tNewYLoc = empty then put tNewYBotLoc into tNewYLoc

   if tNewXLoc <> empty then 
       put tNewXLoc  into item 1 of tNewLoc
   else
       put tX into item 1 of tNewLoc
   end if

   if tNewYLoc <> empty then
       put tNewYLoc  into item 2 of tNewLoc
   else
       put tY into item 2 of tNewLoc
   end if

   ## here we set the loc and test guides against this new loc in drawXXX handlers
   set the loc of tTarget to tNewLoc

   # now check if matching guide objects still fit after setting the loc of the object
   # xxxNeedsDrawing means there are objects within "magnetic" tolerance, only draw if tNewLoc still fits
   if sLeftXNeedsDrawing then
       _drawLeftX tTarget, tThisCard
       put false into sLeftXNeedsDrawing
   else
       set the visible of grc (kDontLog & "_GrcLeft") to false
   end if

   if sTopYneedsDrawing then
       _drawTopY tTarget, tThisCard
       put false into sTopYneedsDrawing
   else
       set the visible of grc (kDontLog & "_GrcTop") to false
   end if

   if sXNeedsDrawing then
       _drawMiddleX tTarget, tThisCard
       put false into sXNeedsDrawing
   else
       set the visible of grc (kDontLog & "_GrcVert") to false
   end if

   if sYNeedsDrawing then
       _drawMiddleY tTarget, tThisCard
       put false into sYNeedsDrawing
   else
       set the visible of grc (kDontLog & "_GrcHorz") to false
   end if

   if sRightXNeedsDrawing then
       _drawRightX tTarget, tThisCard
       put false into sRightXNeedsDrawing
   else
       set the visible of grc (kDontLog & "_GrcRight") to false
   end if

   if sBotYneedsDrawing then
       _drawBotY tTarget, tThisCard
       put false into sBotYneedsDrawing
   else
       set the visible of grc (kDontLog & "_GrcBot")  to false
   end if

   if tCombine then
       _drawNextHorzDistanceLeft tNewLoc, tTarget, tThisCard
       _drawNextHorzDistanceRight tNewLoc, tTarget, tThisCard
       _drawNextVertDistanceTop tNewLoc, tTarget, tThisCard
       _drawNextVertDistanceBot tNewLoc, tTarget, tThisCard
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

   pass MouseMove
end MouseMove

on mouseUp pButtonNumber
   put false into sIsDown
   pass mouseUp
end mouseUp

on mouseRelease pButtonNumber
   put false into sIsDown
   pass mouseRelease
end mouseRelease



private function _stackNameIsIDEStack pStackName
   if there is no a stack pStackName  then return false
   return  the _ideoverride of stack pStackName or pStackName begins with "rev"or pStackName is among the items of "message box,answer dialog,ask dialog,home" or pStackName begins with "com.livecode."
end _stackNameIsIDEStack



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

       # exclude "guide" objects, the target and invisibles
       if tShortName begins with kDontLog or tShortID is tMyID or the visible of tLongID is false 
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


private function _getMiddleX  @pMyX, @pThisCard
   local tLower, tUpper, tReturnValue, aX

   put pMyX - kTolerance into tLower
   put pMyX + kTolerance into tUpper   

   put empty into sMiddleXList
   put empty into tReturnValue

   repeat for each key anObject in sAllControls
       put item 1 of sAllControls[anObject]["loc"] into aX

       if aX >= tLower and aX <= tUpper then 
           put anObject & cr after sMiddleXList
           put aX into tReturnValue
       end if
   end repeat

   if sCardX >= tLower and sCardX <= tUpper then
       put pThisCard & return into sMiddleXList
       put sCardX into tReturnValue
   end if

   if sMiddleXList <> empty then
       delete char - 1 of sMiddleXList
       put true into sXNeedsDrawing
   else
       put false into sXNeedsDrawing
   end if

   return tReturnValue
end _getMiddleX


private function _getMiddleY  @pTarget, @pMyY, @pThisCard
   local tLowerY, tUpperY, tReturnValue, tMyYLoc, aY

   put pMyY - kTolerance into tLowerY
   put pMyY + kTolerance into tUpperY

   put empty into sMiddleYList
   put empty into tReturnValue

   put item 2 of the loc of pTarget into tMyYLoc

   repeat for each key anObject in sAllControls
       put item 2 of sAllControls[anObject]["loc"] into aY
       if aY >= tLowerY and aY <= tUpperY then 
           put anObject & cr after sMiddleYList
           put aY into tReturnValue
       end if
   end repeat

   if sCardY >= tLowerY and sCardY <= tUpperY then
       put pThisCard & return into sMiddleYList
       put sCardY into tReturnValue
   end if

   if sMiddleYList <> empty then
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

   put empty into sLeftXList
   put empty into tReturnValue

   repeat for each key anObject in sAllControls
       put item 1 of sAllControls[anObject]["rect"] into aLeftX

       if aLeftX >= tLower and aLeftX <= tUpper then 
           put anObject & cr after sLeftXList
           put aLeftX + sDistCenterToLeft into tReturnValue
       end if
   end repeat

   if sLeftXList <> empty then
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

   put empty into sTopYList
   put empty into tReturnValue

   put item 2 of the loc of pTarget into tMyYLoc
   put item 1 of the loc of pTarget into tMyMidX

   repeat for each key anObject in sAllControls
       put item 2 of sAllControls[anObject]["rect"] into aY

       if aY >= tLowerY and aY <= tUpperY then 
           put anObject & cr after sTopYList
           put aY + sDistCenterToTop into tReturnValue
       end if

   end repeat

   if sTopYList <> empty then
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

   put empty into sRightXList
   put empty into tReturnValue

   repeat for each key anObject in sAllControls
       put item 3 of sAllControls[anObject]["rect"] into aRightX

       if aRightX >= tLower and aRightX <= tUpper then 
           put anObject & cr after sRightXList
           put aRightX + sDistCenterToRight into tReturnValue
       end if

   end repeat

   if sRightXList <> empty then
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

   put empty into sBotYList
   put empty into tReturnValue

   put the bottom of pTarget into tMyBotYLoc
   put item 1 of the loc of pTarget into tMyMidX

   repeat for each key anObject in sAllControls
       put item 4 of sAllControls[anObject]["rect"] into aY
       if aY >= tLowerY and aY <= tUpperY then 
           put anObject & cr after sBotYList
           put aY + sDistCenterToBot into tReturnValue
       end if
   end repeat

   if sBotYList <> empty then
       delete char - 1 of sBotYList
       put true into sBotYneedsDrawing
   else
       put false into sBotYneedsDrawing
   end if

   return tReturnValue
end _getBotY


private command _drawLeftX @pTarget, @pThisCard
   local tMinY, tMin, tMyXLeft, tMyY, aX, tY, tAbsY, tWhich, tGrcTopLoc, tDistance
   local tNameGrc

   put empty into tMinY
   put the height of pThisCard into tMin
   put left of pTarget into tMyXLeft
   put item 2 of the loc of pTarget into tMyY

   repeat for each line anObject in sLeftXList
       put item 1 of sAllControls[anObject]["rect"] into aX

       if aX = tMyXLeft then
           put item 2 of sAllControls[anObject]["loc"] into tY
           put abs(tMyY - tY) into tAbsY

           if tAbsY <= tMin then
               put tAbsY into tMIn
               put anObject into tWhich
               put tY into tMinY
           end if
       end if

   end repeat

   if tMinY <> empty then

       # draw all over objects
       put  min(the top of pTarget,the top of tWhich) into tGrcTopLoc
       put max(abs(tGrcTopLoc - the bottom of pTarget), abs( tGrcTopLoc - the bottom of tWhich)) into tDistance

       put kDontLog & "_GrcLeft" into tNameGrc
       put the long id of grc tNameGrc of pThisCard into tNameGrc

       set the height of tNameGrc to tDistance + kOvershoot
       set the left of tNameGrc to tMyXLeft - 1
       set the top of tNameGrc to tGrcTopLoc - kOvershootOffset

       set the layer of tNameGrc to top
       set the foreColor of tNameGrc to "red"
       set the visible of tNameGrc to true
   else
       set the visible of grc (kDontLog & "_GrcVert") to false
       exit _drawLeftX
   end if
end _drawLeftX

private command _drawTopY @pTarget, @pThisCard
   local tMinX, tMin, tMyX, tMyTopY, aY, tX, tAbsX, tWhich, tLeftOfGrc
   local tNameGrc

   put empty into tMinX
   put the width of pThisCard into tMin
   put item 1 of the loc of pTarget into tMyX
   put the top of pTarget into tMyTopY

   put kDontLog & "_GrcTop" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   repeat for each line anObject in sTopYList
       put item 2 of sAllControls[anObject]["rect"] into aY

       if aY = tMyTopY then
           put item 1 of sAllControls[anObject]["loc"] into tX
           put abs(tMyX - tX) into tAbsX

           if tAbsX <= tMin then
               put tAbsX into tMIn
               put anObject into tWhich
               put tX into tMinX
           end if
       end if
   end repeat

   if tMinX <> empty then
       # draw all over objects
       put min(the left of tWhich, the left of pTarget) into tLeftOfGrc
       put max(abs(tLeftOfGrc - the right of tWhich), abs(tLeftOfGrc - the right of pTarget)) into tMin
       set the width of tNameGrc to tMin + kOvershoot
       set the left of tNameGrc to tLeftOfGrc - kOvershootOffset

       set the layer of tNameGrc to top
       set the top of tNameGrc to tMyTopY - 1
       set the foreColor of tNameGrc to "red"
       set the visible of tNameGrc to true
   else
       set the visible of tNameGrc to false
       exit _drawTopY
   end if
end _drawTopY


private command _drawMiddleX  @pTarget, @pThisCard
   local tMin, tMyX, tMyY, tMinY, aX, tY, tAbsY, tWhich, tNameGrc, tGrcTopLoc, tDistance

   put "" into tMinY
   put the height of pThisCard into tMin
   put item 1 of the loc of pTarget into tMyX
   put item 2 of the loc of pTarget into tMyY

   put kDontLog & "_GrcVert" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   # let card middle override all
   if word 1 of sMiddleXList = "card" and tMyX = sCardX then
       set the height of tNameGrc to tMin + 1
       set the left of tNameGrc to sCardX - 1
       set the top of tNameGrc to -1
       set the foreColor of tNameGrc to "blue"
       set the layer of tNameGrc to top
       set the visible of tNameGrc to true
       exit _drawMiddleX
   end if

   repeat for each line anObject in sMiddleXList
       put item 1 of sAllControls[anObject]["loc"] into aX
       if aX = tMyX then
           put item 2 of sAllControls[anObject]["loc"] into tY
           put abs(tMyY - tY) into tAbsY
           if tAbsY <= tMin then
               put tAbsY into tMIn
               put anObject into tWhich
               put tY into tMinY
           end if
       end if
   end repeat

   if tMinY <> "" then
       # draw all over objects
       put (min(the top of pTarget,the top of tWhich)) into tGrcTopLoc
       put max(abs(tGrcTopLoc - the bottom of pTarget), abs(tGrcTopLoc - the bottom of tWhich)) into tDistance

       set the height of tNameGrc to tDistance + kOvershoot
       set the left of tNameGrc to tMyX - 1
       set the top of tNameGrc to tGrcTopLoc - kOvershootOffset

       set the layer of tNameGrc to top
       set the foreColor of tNameGrc to "blue"
       set the visible of tNameGrc to true
   else
       set the visible of tNameGrc to false
       exit _drawMiddleX
   end if
end _drawMiddleX


private command _drawMiddleY  @pTarget, @pThisCard
   local tMinX, tMin, tMyX, tMyY, aY, tX, tAbsX, tWhich, tNameGrc

   put "" into tMinX
   put the width of pThisCard into tMin
   put item 1 of the loc of pTarget into tMyX
   put item 2 of the loc of pTarget into tMyY

   put kDontLog & "_GrcHorz" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   # let card middle override all
   if word 1 of sMiddleYList = "card" and sCardY = tMyY then
       set the layer of tNameGrc to top
       set the width of tNameGrc to tMin + 1
       set the top of tNameGrc to sCardY - 1
       set the left of tNameGrc to -1
       set the foreColor of tNameGrc to "blue"
       set the visible of tNameGrc to true
       exit _drawMiddleY
   end if

   repeat for each line anObject in sMiddleYList
       put item 2 of sAllControls[anObject]["loc"] into aY
       if aY = tMyY then
           put item 1 of sAllControls[anObject]["loc"] into tX
           put abs(tMyX - tX) into tAbsX
           if tAbsX <= tMin then
               put tAbsX into tMIn
               put anObject into tWhich
               put tX into tMinX
           end if
       end if
   end repeat

   if tMinX <> "" then
       local tLeftOfGrc
       -- draw all over objects
       put min(the left of tWhich, the left of pTarget) into tLeftOfGrc
       put max(abs(tLeftOfGrc - the right of tWhich), abs(tLeftOfGrc - the right of pTarget)) into tMin
       set the width of tNameGrc to tMin + kOvershoot
       set the left of tNameGrc to tLeftOfGrc - kOvershootOffset
       -- end all over objects

       set the layer of tNameGrc to top
       set the top of tNameGrc to tMyY - 1
       set the foreColor of tNameGrc to "blue"
       set the visible of tNameGrc to true
   else
       set the visible of tNameGrc to false
       exit _drawMiddleY
   end if
end _drawMiddleY


private command _drawRightX @pTarget, @pThisCard
   local tMinY, tMin, tMyXLeft, tMyY, aX, tY, tAbsY, tWhich, tGrcTopLoc, tDistance, tMyXRight, tNameGrc

   put "" into tMinY
   put the height of pThisCard into tMin
   put right of me into tMyXRight
   put item 2 of the loc of pTarget into tMyY


   put kDontLog & "_GrcRight" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   repeat for each line anObject in sRightXList
       put item 3 of sAllControls[anObject]["rect"] into aX
       if aX = tMyXRight then
           put item 2 of sAllControls[anObject]["loc"] into tY
           put abs(tMyY - tY) into tAbsY
           if tAbsY <= tMin then
               put tAbsY into tMIn
               put anObject into tWhich
               put tY into tMinY
           end if
       end if
   end repeat

   if tMinY <> "" then
       # draw all over objects
       put (min(the top of pTarget,the top of tWhich)) into tGrcTopLoc
       put max(abs(tGrcTopLoc - the bottom of pTarget), abs(tGrcTopLoc - the bottom of tWhich)) into tDistance

       set the height of tNameGrc to tDistance + kOvershoot
       set the left of tNameGrc to tMyXRight - 2
       set the top of tNameGrc to tGrcTopLoc - kOvershootOffset

       set the layer of tNameGrc to top
       set the foreColor of tNameGrc to "red"
       set the visible of tNameGrc to true
   else
       set the visible of tNameGrc to false
       exit _drawRightX
   end if
end _drawRightX



private command _drawBotY @pTarget, @pThisCard
   local tMinX, tMin, tMyX, tMyBottomY, aY, tX, tAbsX, tWhich
   local tLeftOfGrc, tNameGrc

   put "" into tMinX
   put the width of pThisCard into tMin
   put item 1 of the loc of pTarget into tMyX
   put the bottom of pTarget into tMyBottomY

   put kDontLog & "_GrcBot" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   repeat for each line anObject in sBotYList
       put item 4 of sAllControls[anObject]["rect"] into aY

       if aY = tMyBottomY then
           put item 1 of sAllControls[anObject]["loc"] into tX
           put abs(tMyX - tX ) into tAbsX

           if tAbsX <= tMin then
               put tAbsX into tMIn
               put anObject into tWhich
               put tX into tMinX
           end if
       end if
   end repeat

   if tMinX <> "" then
       # draw all over objects
       put min(the left of tWhich, the left of pTarget) into tLeftOfGrc
       put max(abs(tLeftOfGrc - the right of tWhich), abs(tLeftOfGrc - the right of pTarget)) into tMin
       set the width of tNameGrc to tMin + kOvershoot
       set the left of tNameGrc to tLeftOfGrc - kOvershootOffset

       set the layer of tNameGrc to top
       set the top of tNameGrc to tMyBottomY - 2
       set the foreColor of tNameGrc to "red"
       set the visible of tNameGrc to true
   else
       set the visible of tNameGrc to false
       exit _drawBotY
   end if
end _drawBotY


private command _drawNextHorzDistanceLeft @pMyLoc, @pTarget, @pThisCard
   local aRight, tMyLeft, tMyMiddleY, aTop, aBottom, tMin, tXDistance, tNameGrc

   put the width of pThisCard into tMin

   put item 1 of pMyLoc - sDistCenterToLeft into tMyLeft
   put item 2 of pMyLoc into tMyMiddleY

   repeat for each key anObject in sAllControls
       put item 3 of sAllControls[anObject]["rect"] into aRight
       put item 2 of sAllControls[anObject]["rect"] into aTop
       put item 4 of sAllControls[anObject]["rect"] into aBottom

       if aRight <= tMyLeft then
           if tMyMiddleY < aBottom and tMyMiddleY >= aTop then
               if (tMyLeft - aRight) < tMin then
                   put tMyLeft - aRight into tMin
               end if
           end if
       end if
   end repeat

   if tMin = the width of pThiscard then put tMyLeft into tMin
   put tMin into tXDistance

   put kDontLog & "_GrcHorz" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   set the loc of tNameGrc to pMyLoc
   set the width of tNameGrc to max(tXDistance,0)
   set the right of tNameGrc to tMyLeft - 1
   set the layer of tNameGrc to top
   set the foreColor of tNameGrc to "blue"

   put kDontLog & "_GrcDistNumLeft" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   set the label of tNameGrc to tXDistance
   set the loc of tNameGrc to pMyLoc
   set the right of tNameGrc to tMyLeft - 2
   if the left of tNameGrc < 0 then set the left of tNameGrc to 0
   set the layer of tNameGrc to top

   set the visible of graphic ( kDontLog & "_GrcHorz") of pThisCard to true
   set the visible of tNameGrc to true
end _drawNextHorzDistanceLeft


private command _drawNextHorzDistanceRight @pMyLoc, @pTarget, @pThisCard
   local aLeft, tMyRight, tMyMiddleY, aTop, aBottom, tMin, tXDistance, tCardWidth, tNameGrc

   put the width of this card into tCardWidth
   put tCardWidth into tMin

   put item 1 of pMyLoc - sDistCenterToRight into tMyRight -- sDistCenterToRight is negative
   put item 2 of pMyLoc into tMyMiddleY

   repeat for each key anObject in sAllControls
       put item 1 of sAllControls[anObject]["rect"] into aLeft
       put item 2 of sAllControls[anObject]["rect"] into aTop
       put item 4 of sAllControls[anObject]["rect"] into aBottom

       if aLeft >= tMyRight then
           if tMyMiddleY < aBottom and tMyMiddleY >= aTop then
               if (aLeft - tMyRight) < tMin then
                   put aLeft - tMyRight into tMin
               end if
           end if
       end if
   end repeat

   if tMin = tCardWidth then put tCardWidth - tMyRight into tMin
   put tMin into tXDistance
   if tMin < 0 then put 0 into tMin

   put kDontLog & "_GrcDistRight" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   set the width of tNameGrc to min(tMin,tCardWidth)
   set the loc of tNameGrc to pMyLoc
   set the left of tNameGrc to tMyRight + 1
   set the layer of tNameGrc to top
   set the foreColor of tNameGrc to "blue"

   put kDontLog & "_GrcDistNumRigh" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   set the label of tNameGrc to tXDistance
   set the loc of tNameGrc to pMyLoc
   set the left of tNameGrc to tMyRight + 2
   if the right of tNameGrc > tCardWidth then set the right of tNameGrc to tCardWidth
   set the layer of tNameGrc to top

   set the visible of grc (kDontLog & "_GrcDistRight") of pThisCard to true
   set the visible of tNameGrc to true
end _drawNextHorzDistanceRight


private command _drawNextVertDistanceTop @pMyLoc, @pTarget, @pThisCard
   local tMyTop, tMyMiddleX,  aLeft, aRight, aBottom, tMin, tYDistance, tNameGrc

   put the height of pThisCard into tMin
   put item 2 of pMyLoc - sDistCenterToTop into tMyTop
   put item 1 of pMyLoc into tMyMiddleX

   repeat for each key anObject in sAllControls
       put item 3 of sAllControls[anObject]["rect"] into aRight
       put item 1 of sAllControls[anObject]["rect"] into aLeft
       put item 4 of sAllControls[anObject]["rect"] into aBottom

       if aBottom <= tMyTop then
           if tMyMiddleX < aRight and tMyMiddleX >= aLeft then
               if (tMyTop - aBottom) < tMin then
                   put tMyTop - aBottom into tMin
               end if
           end if
       end if
   end repeat

   if tMin = the height of pThisCard then put tMyTop into tMin
   put tMin into tYDistance

   put kDontLog & "_GrcVert" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   set the loc of tNameGrc to pMyLoc
   set the height of tNameGrc to max(tYDistance,0)
   set the bottom of tNameGrc to tMyTop - 1
   set the layer of tNameGrc to top
   set the foreColor of tNameGrc to "blue"

   put kDontLog & "_GrcDistNumTop" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   set the label of tNameGrc to tYDistance
   set the loc of tNameGrc to pMyLoc
   set the bottom of tNameGrc to tMyTop - 2
   if the top of tNameGrc < 0 then set the top of tNameGrc to 0
   set the layer of tNameGrc to top

   set the visible of grc (kDontLog & "_GrcVert") of pThisCard to true
   set the visible of tNameGrc to true
end _drawNextVertDistanceTop


private command _drawNextVertDistanceBot  @pMyLoc, @pTarget, @pThisCard
   local tMyBot, tMyMiddleX, tCardHeight, aLeft, aRight, aTop, tMin, tYDistance, tNameGrc

   put the height of pThisCard into tCardHeight
   put tCardHeight into tMin
   put item 2 of pMyLoc - sDistCenterToBot into tMyBot
   put item 1 of pMyLoc into tMyMiddleX

   repeat for each key anObject in sAllControls
       put item 3 of sAllControls[anObject]["rect"] into aRight
       put item 1 of sAllControls[anObject]["rect"] into aLeft
       put item 2 of sAllControls[anObject]["rect"] into aTop

       if aTop >= tMyBot then
           if tMyMiddleX < aRight and tMyMiddleX >= aLeft then
               if (aTop - tMyBot) < tMin then
                   put aTop - tMyBot into tMin
               end if
           end if
       end if
   end repeat

   if tMin = tCardHeight then put tCardHeight - tMyBot into tMin
   put tMin into tYDistance
   if tMin < 0 then put 0 into tMin

   put kDontLog & "_GrcDistBot" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   set the loc of tNameGrc to pMyLoc
   set the height of tNameGrc to min(tMin, tCardHeight)
   set the top of tNameGrc to tMyBot + 1
   set the layer of tNameGrc to top
   set the foreColor of tNameGrc to "blue"

   put kDontLog & "_GrcDistNumBot" into tNameGrc
   put the long id of grc tNameGrc of pThisCard into tNameGrc

   set the label of tNameGrc to tYDistance
   set the loc of tNameGrc to pMyLoc
   set the top of tNameGrc to tMyBot + 2
   if the bottom of tNameGrc > tCardHeight then set the bottom of tNameGrc to tCardHeight
   set the layer of tNameGrc to top

   set the visible of grc (kDontLog & "_GrcDistBot") of pThisCard to true
   set the visible of tNameGrc to true
end _drawNextVertDistanceBot

