script "community.ferruslogic.plugin.devguides"
/*
* DevGuides
* ( c ) FerrusLogic Team
* August 2021
* version 1.0.6
*
* This code is part of DevGuides extension created by FerrusLogic team to provide design guides to
* help LiveCode developers in the process of designing graphic interfaces in an easy and modern way
*/

local  sMessageID,  sGridSystem, sThisCard, sControls, sLabels
constant kGuideLineColor = "255,0,255", kGuideLabelColor = "56,56,255", kGuideLineCardColor = "255,128,0", kGuideLabelCardColor = "0,128,0"

on extensionInitialize
    if the target is not me or the long id  of me is among the lines of the backscripts then  pass extensionInitialize

    insert the script of me into back
    set the _ideoverride of me to true

    revIDESubscribe "ideToolChanged"
    revIDESubscribe "ideMouseMove"
    revIDESubscribe "ideSelectedObjectChanged"
    revIDESubscribe "ideOpenStack"

    put empty into sMessageID
end extensionInitialize


on extensionFinalize
    if the target is not me then  pass extensionFinalize
    revIDEUnsubscribeAll the long id of me
    remove the script of me from back
end extensionFinalize


on closeCard
    _deleteDevGuides
    pass closeCard
end closeCard

on preOpenCard
    _deleteDevGuides
    pass preOpenCard
end preOpenCard


on closeCard
    _deleteDevGuides
    pass closeCard
end closeCard


on ideToolChanged
    _deleteDevGuides
end ideToolChanged


on ideSelectedObjectChanged
    _deleteDevGuides
end ideSelectedObjectChanged


on rawKeyDown pKeyCode
    if pKeyCode >= 65361 and pKeyCode <= 65364 then
        _arrowKeyUp
    end if

    pass rawKeyDown
end rawKeyDown


on rawKeyUp pKeyCode
    if not(pKeyCode >= 65361 and pKeyCode <= 65364) then
        _deleteDevGuides
        if sMessageID is a number then
            cancel sMessageID
        end if

    else if the controlKey is "up" then
        _deleteDevGuides

        repeat for each line tMessage in the pendingMessages
            if item 3 of tMessage is "updateDevGuides" then
                cancel item 1 of tMessage
            end if
        end repeat
    end if

    pass rawKeyUp
end rawKeyUp


on ideMouseMove pX, pY
   local tSelectedObjects, tThisStack, tThisCard, tDefaultStack

   put the selectedObjects into tSelectedObjects

   if the tool <> "pointer tool" or tSelectedObjects is empty then exit ideMouseMove
   put _myStack(line 1 of tSelectedObjects) into tThisStack

   if word 1 of tSelectedObjects is in "stack card" or _stackNameIsIDEStack( tThisStack ) then
      _deleteDevGuides empty, sThisCard
      exit ideMouseMove
   end if

   put the defaultStack into tDefaultStack
   set the defaultStack to tThisStack
   put the long id of this card into tThisCard
   set the defaultStack to tDefaultStack

   if sMessageID is a number then cancel sMessageID

   lock screen
   send "updateDevGuides tThisCard" to me in 0 millisec
   put the result into sMessageID
   unlock screen
end ideMouseMove


on updateDevGuides pThisCard
   local tSelectedObjects, tTergetProperty

   put pThisCard into sThisCard
   put empty into sMessageID
   put the selectedObjects into tSelectedObjects

   lock screen; lock messages

   _deleteDevGuides

   if the tool <> "pointer tool" then
      unlock messages; unlock screen
      exit updateDevGuides

   else  if  mouse() is up and controlKey() is up then
      unlock messages; unlock screen
      exit updateDevGuides

   else if _myStack(line 1 of tSelectedObjects) is not _myStack(_mouseControl()) then
      unlock messages; unlock screen
      exit updateDevGuides
   end if

   if tSelectedObjects is empty then
      exit updateDevGuides
   end if

   try
      put _tergetProperty( pThisCard, tSelectedObjects ) into tTergetProperty
      _drawGuides pThisCard, tSelectedObjects , tTergetProperty
   end try

   unlock messages; unlock screen
end updateDevGuides


private command _arrowKeyUp
    lock screen
    ideMouseMove
    unlock screen
end _arrowKeyUp


private command _deleteDevGuides
    if sControls is an array then
        repeat for each element tControl in sControls
            if there is a tControl then delete tControl
        end repeat
        delete variable sControls
    end if
    put empty into sThisCard
end _deleteDevGuides


private command _childControlIDs @pThisCard, @pChildControlIDs, pSelectedObjects
    local tNumControl, tLongId, tOwner, tOwners

    if pSelectedObjects is no empty then
        put the selectedObjects into pSelectedObjects

        repeat for each line tLine in pSelectedObjects
            put  _biggestOwner( tLine ) into tOwner
            if tOwner is not empty and tOwner is no pThisCard then
                put tOwner & cr after tOwners
            end if
        end repeat
    end if

    put empty into tOwner
    put the number of controls of pThisCard into tNumControl

    repeat with x = 1 to tNumControl
        put the long id of control x of pThisCard into tLongId
        put  _biggestOwner( tLongId ) into tOwner

        if tLongId is among the lines of pSelectedObjects or  tOwner is among the lines of pSelectedObjects then next repeat
        if tOwner is pThisCard  or (tOwners is no empty and tOwner is among the lines of tOwners) then
            put tLongId & cr after pChildControlIDs
        end if
    end repeat

end _childControlIDs


private command _drawGuides pLongIdCd, pSelectedObjects ,pTergetProperty, pX, pY
   local tChildControlIDs, tLongId, tLoc, tX, tY,tValue, tRect
   local tVerticalPoint1, tVerticalPoint2, tVerticalPoint3, tHorizontalPoint1, tHorizontalPoint2, tHorizontalPoint3
   local tWidthCard, tHeightCard, tDisMinV = 0, tDisMinH = 0, tDifferenceV, tDifferenceH, tDrawLimitUp = true, tDrawLimitDown = true

   _childControlIDs pLongIdCd, tChildControlIDs, pSelectedObjects

   put the width of pLongIdCd into tWidthCard
   put the height of pLongIdCd into tHeightCard

   # the loc of this card
   put the loc of pLongIdCd into tLoc

   # the rect of this card
   put the left of pLongIdCd into tRect["left"]
   put the top of pLongIdCd into tRect["top"]
   put the right of pLongIdCd into tRect["right"]
   put the bottom of pLongIdCd into tRect["bottom"]

   put the item 1 of tLoc into tRect["x"]
   put the item 2 of tLoc into tRect["y"]

   # Left
   _calcGuideLineProp pLongIdCd, "left", "left", "right", "top", "bottom", "min", "max","x", pTergetProperty, tRect, tVerticalPoint1,  tHeightCard, tDisMinV, tDifferenceV
   # X
   _calcGuideLineProp pLongIdCd, "x", "left", "right", "top", "bottom", "min", "max","x", pTergetProperty, tRect, tVerticalPoint2,  tHeightCard, tDisMinV, tDifferenceV
   # Right
   _calcGuideLineProp pLongIdCd, "right", "left", "right", "top", "bottom", "min", "max","x", pTergetProperty, tRect, tVerticalPoint3,  tHeightCard, tDisMinV, tDifferenceV
   # Top
   _calcGuideLineProp pLongIdCd, "top", "top", "bottom", "left", "right", "min", "max","y", pTergetProperty, tRect, tHorizontalPoint1,  tWidthCard, tDisMinH, tDifferenceH
   # y
   _calcGuideLineProp pLongIdCd, "y", "top", "bottom", "left", "right", "min", "max","y", pTergetProperty, tRect, tHorizontalPoint2,  tWidthCard, tDisMinH, tDifferenceH
   # bottom
   _calcGuideLineProp pLongIdCd, "bottom", "top", "bottom", "left", "right", "min", "max","y", pTergetProperty, tRect, tHorizontalPoint3,  tWidthCard, tDisMinH, tDifferenceH


   # Calc
   repeat for each line tLongID in tChildControlIDs
      # Ignore selected objects
      if the visible of tLongID is false or pTergetProperty["ignore"][tLongID] is true then next repeat

      # Eliminate potential DevGuides waste
      if the cTemporaryGraphic of tLongId is true then
         try
            delete tLongId
         end try
         next repeat
      end if

      # the loc of this control
      put the loc of tLongId into tLoc

      # the rect of this control
      put the left of tLongId into tRect["left"]
      put the top of tLongId into tRect["top"]
      put the right of tLongId into tRect["right"]
      put the bottom of tLongId into tRect["bottom"]
      put the item 1 of tLoc into tRect["x"]
      put the item 2 of tLoc into tRect["y"]

      ---> Vertical guides <---
      # Left
      _calcGuideLineProp tLongId, "left", "left", "right", "top", "bottom", "min", "max","x", pTergetProperty, tRect, tVerticalPoint1, tHeightCard, tDisMinV, tDifferenceV
      # Right
      _calcGuideLineProp tLongId, "right", "left", "right", "top", "bottom", "min", "max","x", pTergetProperty, tRect, tVerticalPoint3, tHeightCard, tDisMinV, tDifferenceV
      # X
      _calcGuideLineProp tLongId, "x", "left", "right", "top", "bottom", "min", "max","x", pTergetProperty, tRect, tVerticalPoint2,   tHeightCard, tDisMinV, tDifferenceV

      --> Horizontal guides <---
      # Top
      _calcGuideLineProp tLongId, "top", "top", "bottom", "left", "right", "min", "max","y", pTergetProperty, tRect, tHorizontalPoint1,   tWidthCard, tDisMinH, tDifferenceH
      # y
      _calcGuideLineProp tLongId, "y", "top", "bottom", "left", "right", "min", "max","y", pTergetProperty, tRect, tHorizontalPoint2,   tWidthCard, tDisMinH, tDifferenceH
      # bottom
      _calcGuideLineProp tLongId, "bottom", "top", "bottom", "left", "right", "min", "max","y", pTergetProperty, tRect, tHorizontalPoint3,  tWidthCard, tDisMinH, tDifferenceH
   end repeat

   -- draw limit
   _drawLimit tVerticalPoint1, tVerticalPoint2, tVerticalPoint3, tDisMinV
   _drawLimit tHorizontalPoint1, tHorizontalPoint2, tHorizontalPoint3, tDisMinH

   -- Vertical-- ( Left | center | right)
   if tVerticalPoint1[ "create" ] is true and tVerticalPoint1["distance"] is tDisMinV then
      _drawingGuideLine tVerticalPoint1, pTergetProperty, "height", "top", "left", 0, tWidthCard, tHeightCard
   else
      put false into tVerticalPoint1[ "create" ]
   end if

   if tVerticalPoint2[ "create" ] is true and tVerticalPoint2["distance"] is tDisMinV then
      add (pTergetProperty["x"] - pTergetProperty["left"]) to tVerticalPoint2["hook"]
      _drawingGuideLine tVerticalPoint2, pTergetProperty, "height", "top", "left", 0, tWidthCard, tHeightCard
   else
      put false into tVerticalPoint2[ "create" ]
   end if

   if tVerticalPoint3[ "create" ] is true and tVerticalPoint3["distance"] is tDisMinV then
      add pTergetProperty["width"] to tVerticalPoint3["hook"]
      _drawingGuideLine tVerticalPoint3, pTergetProperty, "height", "top", "left", 0, tWidthCard, tHeightCard
   else
      put false into tVerticalPoint3[ "create" ]
   end if

   -- Horizontal -- ( top | center | bottom)
   if tHorizontalPoint1[ "create" ] is true and tHorizontalPoint1["distance"] is tDisMinH then
      _drawingGuideLine tHorizontalPoint1, pTergetProperty, "width", "left", "top", 10, tWidthCard, tHeightCard
   else
      put false into tHorizontalPoint1[ "create" ]
   end if

   if tHorizontalPoint2[ "create" ] is true and tHorizontalPoint2["distance"] is tDisMinH then
      add (pTergetProperty["y"] - pTergetProperty["top"]) to tHorizontalPoint2["hook"]
      _drawingGuideLine tHorizontalPoint2, pTergetProperty, "width", "left", "top", 10, tWidthCard, tHeightCard
   else
      put false into tHorizontalPoint2[ "create" ]
   end if

   if tHorizontalPoint3[ "create" ] is true and tHorizontalPoint3["distance"] is tDisMinH then
      add pTergetProperty["height"] to tHorizontalPoint3["hook"]
      _drawingGuideLine tHorizontalPoint3, pTergetProperty, "width", "left", "top", 10, tWidthCard, tHeightCard
   else
      put false into tHorizontalPoint3[ "create" ]
   end if

end _drawGuides


private command _drawLimit @pPoint1, @pPoint2, @pPoint3, @pDis
    # Draw limit up
    if pPoint1["distance"] is pDis and pPoint1["drawLimitUp"] is true and  pPoint2["drawLimitUp"] is true then
        put false into pPoint2["drawLimitUp"]
    end if

    if pPoint1["distance"] is pDis and  pPoint1["drawLimitUp"] is true and pPoint3["drawLimitUp"] is true  or\
        pPoint2["distance"] is pDis and  pPoint2["drawLimitUp"] is true and pPoint3["drawLimitUp"] is true  then
        put false into pPoint3["drawLimitUp"]
    end if

    # Draw limit down
    if pPoint1["distance"] is pDis and  pPoint1["drawLimitDown"] is true and pPoint2["drawLimitDown"] is true then
        put false into pPoint2["drawLimitDown"]
    end if

    if pPoint1["distance"] is pDis and  pPoint1["drawLimitDown"] is true and pPoint3["drawLimitDown"] is true  or\
        pPoint2["distance"] is pDis and  pPoint2["drawLimitDown"] is true and pPoint3["drawLimitDown"] is true then
        put false into pPoint3["drawLimitDown"]
    end if

end _drawLimit


private command _drawingGuideLine @pPointArray, @pTergetProperty, pMainSize, pCrossStart, pMainStart, pSpace, @pWidthCard, @pHeightCard
   local tLongId, tLoc, tCrossEnd, tY, tGuideLineColor, tGuideLabelColor

   put pPointArray["max"] - pPointArray["min"] into pPointArray["size"]
   put _createTemporaryGraphic() into tLongId

   if pCrossStart is "top" then
      put "bottom" into tCrossEnd

      if pPointArray["size"] is pHeightCard and (0 is pPointArray["hook"] or (pWidthCard/2) is pPointArray["hook"] or pWidthCard is pPointArray["hook"]) then
        put kGuideLineCardColor into tGuideLineColor
        put kGuideLabelCardColor into tGuideLabelColor
      else
        put kGuideLineColor into tGuideLineColor
        put kGuideLabelColor into tGuideLabelColor
      end if

   else  if pCrossStart is "left" then
      put "right" into tCrossEnd

     if pPointArray["size"] is pWidthCard and (0 is pPointArray["hook"] or (pHeightCard/2) is pPointArray["hook"] or pHeightCard is pPointArray["hook"]) then
        put kGuideLineCardColor into tGuideLineColor
        put kGuideLabelCardColor into tGuideLabelColor
      else
        put kGuideLineColor into tGuideLineColor
        put kGuideLabelColor into tGuideLabelColor
      end if
   end if

   set the pMainSize of tLongId to pPointArray["size"]
   set the pCrossStart of tLongId to pPointArray["min"]
   set the pMainStart of tLongId to pPointArray["hook"]
   set the backColor of tLongId to tGuideLineColor
   set the foregroundColor of tLongId to tGuideLineColor
   set the visible of tLongId to true

   if pPointArray[ "drawLimitUp" ] is true then
      # Back of label 1
      put pTergetProperty[ pCrossStart ] - pPointArray[ "LimitUp" ] into pPointArray[ "sizeLimitUp" ]
      put pPointArray[ "sizeLimitUp" ] into pPointArray[ "label-1" ]
      put _createTemporaryGraphic() into tLongId
      try
         set the pMainSize of tLongId to pPointArray["sizeLimitUp"]
         set the pCrossStart of tLongId to pPointArray["LimitUp"]
         set the pMainStart of tLongId to pPointArray["hook"]
         set the backColor of tLongId to tGuideLabelColor
         set the foregroundColor of tLongId to tGuideLabelColor
         set the visible of tLongId to true
         put the loc of tLongId into tLoc
      end try

      if there is no a tLongId then exit _drawingGuideLine

      if item 2 of tLoc > 25 then
         subtract pSpace from item 2 of tLoc

      else if pCrossStart is not "left" then
         add pSpace to item 2 of tLoc

      end if

      # Label 1
      put _createTemporaryGraphic() into tLongId

      try
         set the height of tLongId to 20
         set the width of tLongId to 50
         set the backColor of tLongId to tGuideLabelColor
         set the foregroundColor of tLongId to tGuideLabelColor
         set the opaque of tLongId to false
         set the showName of tLongId to true
         set the label of tLongId to abs(pPointArray[ "label-1" ])
         put tLongId into sLabels[1][pCrossStart]
      end try

      if pPointArray["hook"] < 50 then
         set the textAlign of tLongId to "left"
         add 28 to the item 1 of tLoc
      else
         subtract 28 from the item 1 of tLoc
         set the textAlign of tLongId to "right"
      end if

      set the loc of tLongId to tLoc
      _accommodateIntoScreen tLongId
      set the visible of tLongId to true
   end if

   if pPointArray[ "drawLimitDown" ] is true then
      # Back of label 2
      put pPointArray[ "LimitDown" ] - pTergetProperty[ tCrossEnd ] into pPointArray[ "sizeLimitDown" ]
      put pPointArray[ "sizeLimitDown" ] into pPointArray[ "label-2" ]
      put _createTemporaryGraphic() into tLongId

      set the pMainSize of tLongId to pPointArray["sizeLimitDown"]
      set the tCrossEnd of tLongId to pPointArray["LimitDown"]
      set the pMainStart of tLongId to pPointArray["hook"]
      set the backColor of tLongId to tGuideLabelColor
      set the foregroundColor of tLongId to tGuideLabelColor
      set the visible of tLongId to true
      put the loc of tLongId into tLoc

      if item 2 of tLoc > 25 then
         subtract pSpace from item 2 of tLoc
      else  if pCrossStart is not "left" then
         add pSpace to item 2 of tLoc
      end if

      # Label 2
      put _createTemporaryGraphic() into tLongId

      set the height of tLongId to 20
      set the width of tLongId to 50
      set the backColor of tLongId to tGuideLabelColor
      set the foregroundColor of tLongId to tGuideLabelColor
      set the opaque of tLongId to false
      set the showName of tLongId to true
      set the label of tLongId to abs( pPointArray[ "label-2" ])
      put tLongId into sLabels[2][pCrossStart]

      if pCrossStart is "left" then
         set the textAlign of tLongId to "center"
      else if pPointArray["hook"] < 50 then
         set the textAlign of tLongId to "left"
         add 28 to the item 1 of tLoc
      else
         subtract 28 from the item 1 of tLoc
         set the textAlign of tLongId to "right"
      end if

      set the loc of tLongId to tLoc
      _accommodateIntoScreen tLongId
      set the visible of tLongId to true
   end if
end _drawingGuideLine


private command _calcGuideLineProp pLongId, pMain, pMainStart, pMainEnd, pCrossStart, pCrossEnd, pMainV, pMainV2, pItem , @pTergetProperty,@pRect, @pPointArray,  @pMaxLimit, @pDistance, @pDifference
   local tValue

   put _hook( pTergetProperty[ pMain ], pRect[pMainStart], pRect[pItem], pRect[pMainEnd ], pMainV) into tValue

   if tValue["distance"] < pDistance then
      _resetLimit pTergetProperty, tValue, pDistance,  pPointArray, pMaxLimit, pMainStart, pCrossStart, pCrossEnd
      _updateLimit pLongId, pTergetProperty, pMainStart, pCrossStart, pCrossEnd, tValue, pPointArray

   else if tValue["distance"] = pDistance then
      if pPointArray[ "create" ] is not true then
         _resetLimit pTergetProperty, tValue, pDistance,  pPointArray, pMaxLimit, pMainStart, pCrossStart, pCrossEnd
      end if

      _updateLimit pLongId, pTergetProperty, pMainStart, pCrossStart, pCrossEnd, tValue, pPointArray

   end if
end _calcGuideLineProp


private command _resetLimit  @pTergetProperty,  @pValue,  @pDistance,  @pPointArray, @pMaxLimit, @pMainStart, @pCrossStart, @pCrossEnd
    put pValue["distance"] into pDistance
    put pValue["distance"] into pPointArray[ "distance" ]
    put pValue["difference"] into pPointArray[ "difference" ]
    put  true into pPointArray[ "create" ]
    put pTergetProperty[ pCrossStart ]into pPointArray[ "min" ]
    put pTergetProperty[ pCrossEnd ]into pPointArray[ "max" ]
    put 0 into pPointArray[ "limitUp" ]
    put pMaxLimit into pPointArray[ "limitDown" ]
    put false into pPointArray[ "drawLimitUp" ]
    put false into pPointArray[ "drawLimitDown" ]
end _resetLimit


private command _updateLimit @pLongId, @pTergetProperty, @pMainStart, @pCrossStart, @pCrossEnd, @pValue, @pPointArray
    local tCrossStartValue, tCrossEndValue, tLimitMax, tLimitMin

    put pTergetProperty[ pMainStart ] + pValue["difference"] into pPointArray[ "hook" ]
    put pValue["distance"] into pPointArray["distance"]

    if pPointArray[ "create" ] is false then exit _updateLimit
    -----------------------------------------------
    put the pCrossStart of pLongId into tCrossStartValue
    if pPointArray[ "min" ] >= tCrossStartValue then
        put tCrossStartValue into pPointArray[ "min" ]
    end if
    ---
    put the pCrossEnd of pLongId into tCrossEndValue
    if pPointArray[ "max" ] <= tCrossEndValue then
        put tCrossEndValue into pPointArray[ "max" ]
    end if
    -----------------------------------------------

    put max( tCrossStartValue, tCrossEndValue) into tLimitMax
    put min( tCrossStartValue, tCrossEndValue) into tLimitMin

    # Limit Up
    if tLimitMax >= pPointArray[ "limitUp" ] and tLimitMax <= pTergetProperty[pCrossStart] then
        put tLimitMax into pPointArray[ "limitUp" ]
        put true into pPointArray[ "drawLimitUp" ]
    else if tLimitMin >= pPointArray[ "limitUp" ] and tLimitMin <= pTergetProperty[pCrossStart] then
        put tLimitMin into pPointArray[ "limitUp" ]
        put true into pPointArray[ "drawLimitUp" ]
    end if

    # Limit Down
    if tLimitMin <= pPointArray[ "limitDown" ] and tLimitMin >= pTergetProperty[pCrossEnd] then
        put tLimitMin into pPointArray[ "limitDown" ]
        put true into pPointArray[ "drawLimitDown" ]

    else if tLimitMax <= pPointArray[ "limitDown" ] and tLimitMax >= pTergetProperty[pCrossEnd] then
        put tLimitMax into pPointArray[ "limitDown" ]
        put true into pPointArray[ "drawLimitDown" ]

    end if
end _updateLimit


private command _accommodateIntoScreen pLongId
    local tStack
    put _myStack(pLongId) into tStack

    if the left of pLongId < 0 then set the left of pLongId to 0
    if the top of pLongId < 0 then set the top of pLongId to 0
    if the right of pLongId > the right of tStack then set the left of pLongId to 0
    if the bottom of pLongId > the bottom of tStack then set the top of pLongId to 0

end _accommodateIntoScreen


private function _hook pCurrentValue, pPoint1, pPoint2, pPoint3, pMinOrMax
    local tDis1, tDis2, tDis3 , tDifference1, tDifference2, tDifference3, tValue

    put pCurrentValue - pPoint1 into tDifference1
    put pCurrentValue - pPoint2 into tDifference2
    put pCurrentValue - pPoint3 into tDifference3

    put abs(tDifference1 ) into tDis1
    put abs(tDifference2) into tDis2
    put abs(tDifference3) into tDis3

    if pMinOrMax is "max" then
        put max( tDis1, tDis2, tDis3) into tValue
    else
        put min( tDis1, tDis2, tDis3) into tValue
    end if

    switch tValue
        case tDis1
            put pPoint1 into tValue["value"]
            put tDis1 into tValue["distance"]
            put tDifference1 * -1 into tValue["difference"]
            break

        case tDis2
            put pPoint2 into tValue["value"]
            put tDis2 into tValue["distance"]
            put tDifference2* -1 into tValue["difference"]
            break

        case tDis3
            put pPoint3 into tValue["value"]
            put tDis3 into tValue["distance"]
            put tDifference3 * -1 into tValue["difference"]
            break

    end switch

    return tValue
end _hook


private function _mouseControl
    local tMouseControl, tMouseStack

    put the mouseControl into tMouseControl
    put the mouseStack into tMouseStack
    if tMouseControl is empty then return empty
    set the defaultStack to tMouseStack
    return _biggestOwner( the long id of tMouseControl )
end _mouseControl


private function _tergetProperty pThisCard, pControls
   local tLongId, tLeft, tTop, tRight, tBottom, tX, tY, tResult, tOwner, tLockloc

   put the right of pThisCard into tLeft
   put the bottom of pThisCard into tTop
   put the left of pThisCard into tRight
   put the top of pThisCard into tBottom

   repeat for each line tControl in pControls
      if there is a no tControl then exit to top

      # calc the Left of rectangle
      if the left of tControl < tLeft then
         put the left of tControl into tLeft
      end if

      # calc the top of rectangle
      if the top of tControl < tTop then
         put the top of tControl into tTop
      end if

      # calc the right of rectangle
      if the right of tControl > tRight then
         put the right of tControl into tRight
      end if

      # calc the bottom of rectangle
      if the bottom of tControl > tBottom then
         put the bottom of tControl into tBottom
      end if

      put _biggestOwner(tControl) into tOwner

      if the lockloc of tControl is true and tLockloc is no true then
         put true into tLockloc
      end if
   end repeat

   put trunc( tLeft + (tRight - tLeft)/ 2 ) into tX
   put trunc( tTop + (tBottom - tTop)/2 ) into tY

   put tLeft into tResult["left"]
   put tTop into tResult["top"]
   put tRight into tResult["right"]
   put tBottom into tResult["bottom"]
   put tX into tResult["x"]
   put tY into tResult["y"]
   put tRight - tLeft into tResult["width"]
   put tBottom - tTop into tResult["height"]
   put tLockloc into tResult["lockloc"]

   return tResult
end _tergetProperty


private function _biggestOwner pLongId
    local tOffset, tOwner

    put wordOffSet("card", pLongId) into tOffset

    if tOffset is 5 then
        return the word 5 to - 1 of pLongId
    else
        return the word tOffset - 4 to - 1 of pLongId
    end if
end _biggestOwner


private function _myCard pLongId
    return the word (wordOffSet("card", pLongId)) to - 1 of pLongId
end _myCard


private function _myStack pLongId
    return the word (wordOffSet("stack", pLongId)) to - 1 of pLongId
end _myStack


private function _stackNameIsIDEStack pStackName
   if there is no a stack pStackName then return false
   return the style of stack pStackName is not "topLevel" or the _ideoverride of stack pStackName or pStackName begins with "rev"or pStackName is among the items of "message box,answer dialog,ask dialog,home" or pStackName begins with "com.livecode."
end _stackNameIsIDEStack


private function _createTemporaryGraphic
    local tGrc, tTopStack

    put the topStack into tTopStack
    if _stackNameIsIDEStack(tTopStack) then exit to top
    set the defaultStack to tTopStack

    lock messages
    reset the templateGraphic
    create invisible graphic in this card
    put it into tGrc

    set the cDevDesigns of tGrc to true
    set the cTemporaryGraphic of tGrc to true
    set the width of tGrc to 1
    set the height of tGrc to 1
    set the textAlign of tGrc to "center"
    set the blendLevel of tGrc to 0
    set the lineSize of tGrc to 0
    set the cantSelect of tGrc to true
    set the opaque of tGrc to true
    set the margins of tGrc to 0

    put tGrc into sControls[tGrc]
    unlock messages
    return tGrc
end _createTemporaryGraphic