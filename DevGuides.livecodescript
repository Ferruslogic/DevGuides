script "community.ferruslogic.plugin.devguides"
/*
* DevGuides
* ï¿½ FerrusLogic Team
* August 2021
* version 1.0.0
*
* This code is part of DevGuides extension created by FerrusLogic team to provide design guides to
* help LiveCode developers in the process of designing graphic interfaces in an easy and modern way
*/

global gDevGuideConfig

local  sMessageID, sGuideStatus,  sGridSystem, sThisCard

on extensionInitialize
   if the target is not me then  pass extensionInitialize

   insert the script of me into back
   
   set the _ideoverride of me to false

   revIDESubscribe "ideToolChanged"
   revIDESubscribe "ideMouseMove"

   put empty into sMessageID
end extensionInitialize


on extensionFinalize
   if the target is not me then  pass extensionFinalize
   revIDEUnsubscribeAll the long id of me
   remove the script of me from back
end extensionFinalize


on closeCard
   deleteDevGuides
   pass closeCard
end closeCard

on preOpenCard
   deleteDevGuides
   pass preOpenCard
end preOpenCard


on closeCard
   deleteDevGuides
   pass closeCard
end closeCard


on ideToolChanged
   if the tool is "pointer tool" then  _restoreStatus
   else _saveStatus
end ideToolChanged


on rawKeyDown
    deleteDevGuides
    pass rawKeyDown to metaCard
end rawKeyDown


on rawKeyUp pKey
    if controlKey() is down then
        local tSelectedObjects, tThisStack, tThisCard
        
        put the selectedObjects into tSelectedObjects
        put the short name of the topstack into tThisStack
        set the defaultStack to tThisStack
        put the long id of this card into tThisCard
        
        if  the tool <> "pointer tool" or sMessageID is an integer or word 1 of tSelectedObjects is in "stack card" or _stackNameIsIDEStack( tThisStack ) or  tThisStack <> the short name of the topStack then
            deleteDevGuides
            pass rawKeyUp  to metaCard
        end if
        
        if sMessageID is a number then cancel sMessageID
        send "updateDevGuides tThisCard, pX, pY" to me in 0.1 sec
        put the result into sMessageID
        
    else if controlKey() is up then
        deleteDevGuides
        pass rawKeyUp  to metaCard
    end if
    
    pass rawKeyUp to metaCard
end rawKeyUp


on ideMouseMove pX, pY
    local tSelectedObjects, tThisStack, tThisCard
    
    put the selectedObjects into tSelectedObjects
    
    if the tool <> "pointer tool" or tSelectedObjects is empty  then pass ideMouseMove
    
    put the short name of the topstack into tThisStack
    if sMessageID is an integer or word 1 of tSelectedObjects is in "stack card" or _stackNameIsIDEStack( tThisStack ) then
        deleteDevGuides empty, sThisCard
        exit ideMouseMove
    end if
    
    /*
    local tDefaultStack
    put the defaultStack into tDefaultStack
    set the defaultStack to tThisStack
    put the long id of this card into tThisCard
    set the defaultStack to tDefaultStack
    
    if sMessageID is a number then cancel sMessageID
    send "updateDevGuides tThisCard, pX, pY" to me in 10 millisec
    put the result into sMessageID
    */
end ideMouseMove


on updateDevGuides pThisCard, pX, pY
    local tSelectedObjects, tTergetProperty
    
    put pThisCard into sThisCard
    put empty into sMessageID
    put the selectedObjects into tSelectedObjects
    
    lock screen; lock messages
    
    if mouse( 1 ) is up and controlKey() is up then
        deleteDevGuides
        unlock messages; unlock screen
        exit updateDevGuides
    end if
    
    
    if tSelectedObjects is empty then exit updateDevGuides
    put _tergetProperty( pThisCard, tSelectedObjects ) into tTergetProperty
    
    try
        _drawGuides pThisCard, tSelectedObjects , tTergetProperty, pX, pY
    end try
    
    unlock messages; unlock screen
end updateDevGuides



command deleteDevGuides pLongId
    local tChildControlIDs, tThisCard
    
    if there is a pLongId then
        delete pLongId
        exit deleteDevGuides
    end if
    
    if sThisCard is no empty and there is no sThisCard then exit deleteDevGuides
    if sThisCard is empty then put the long id of this card into tThisCard
    else put sThisCard into tThisCard
    
    put the childControlIDs of tThisCard into tChildControlIDs
    
    repeat for each line tId in tChildControlIDs
        if the cDevDesigns of control id tId of tThisCard is true then
            delete control id tId
        end if
    end repeat
    
    put empty into sThisCard
end deleteDevGuides



private command _drawGuides pLongIdCd, tSelectedObjects , tTergetProperty, pX, pY
   local tChildControlIDs, tLongId, tLoc, tX, tY,tValue, tRect
   local tVerticalPoint1, tVerticalPoint2, tVerticalPoint3, tHorizontalPoint1, tHorizontalPoint2, tHorizontalPoint3
   local tWidthCard, tHeightCard, tDisMinV, tDisMinH, tDifferenceV, tDifferenceH, tMargins, tGravity

   put 1 into tMargins
   put 1 into tGravity

   put tGravity into tDisMinV
   put tGravity into tDisMinH

   put the childControlIDs of pLongIdCd into tChildControlIDs
   put the width of pLongIdCd into tWidthCard
   put the height of pLongIdCd into tHeightCard


   # the loc of this card
   put the loc of pLongIdCd into tLoc

   # the rect of this card
   put the left of pLongIdCd + tMargins into tRect["left"]
   put the top of pLongIdCd + tMargins into tRect["top"]
   put the right of pLongIdCd - tMargins into tRect["right"]
   put the bottom of pLongIdCd - tMargins into tRect["bottom"]
   put the item 1 of tLoc into tRect["x"]
   put the item 2 of tLoc into tRect["y"]

   # Left
   _calcGuideLineProp pLongIdCd, "left", "left", "right", "top", "bottom", "min", "max","x", tTergetProperty, tRect, tVerticalPoint1,  tHeightCard, tDisMinV, tDifferenceV
   # X
   _calcGuideLineProp pLongIdCd, "x", "left", "right", "top", "bottom", "min", "max","x", tTergetProperty, tRect, tVerticalPoint2,  tHeightCard, tDisMinV, tDifferenceV
   # Right
   _calcGuideLineProp pLongIdCd, "right", "left", "right", "top", "bottom", "min", "max","x", tTergetProperty, tRect, tVerticalPoint3,  tHeightCard, tDisMinV, tDifferenceV

   # Top
   _calcGuideLineProp pLongIdCd, "top", "top", "bottom", "left", "right", "min", "max","y", tTergetProperty, tRect, tHorizontalPoint1,  tWidthCard, tDisMinH, tDifferenceH
   # y
   _calcGuideLineProp pLongIdCd, "y", "top", "bottom", "left", "right", "min", "max","y", tTergetProperty, tRect, tHorizontalPoint2,  tWidthCard, tDisMinH, tDifferenceH
   # bottom
   _calcGuideLineProp pLongIdCd, "bottom", "top", "bottom", "left", "right", "min", "max","y", tTergetProperty, tRect, tHorizontalPoint3,  tWidthCard, tDisMinH, tDifferenceH


   # Calc
   repeat for each line tId in tChildControlIDs
     put the long id of control id tId of pLongIdCd into tLongID

     -- Ignora a los objetos seleccionados.
     if the visible of tLongID is false or tTergetProperty["ignore"][tLongID] is true then next repeat

     -- Elimina los posibles residuos de DevGuides
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
       _calcGuideLineProp tLongId, "left", "left", "right", "top", "bottom", "min", "max","x", tTergetProperty, tRect, tVerticalPoint1, tHeightCard, tDisMinV, tDifferenceV
       # Right
       _calcGuideLineProp tLongId, "right", "left", "right", "top", "bottom", "min", "max","x", tTergetProperty, tRect, tVerticalPoint3, tHeightCard, tDisMinV, tDifferenceV
       # X
       _calcGuideLineProp tLongId, "x", "left", "right", "top", "bottom", "min", "max","x", tTergetProperty, tRect, tVerticalPoint2,   tHeightCard, tDisMinV, tDifferenceV


     --> Horizontal guides <---
       # Top
       _calcGuideLineProp tLongId, "top", "top", "bottom", "left", "right", "min", "max","y", tTergetProperty, tRect, tHorizontalPoint1,   tWidthCard, tDisMinH, tDifferenceH
       # y
       _calcGuideLineProp tLongId, "y", "top", "bottom", "left", "right", "min", "max","y", tTergetProperty, tRect, tHorizontalPoint2,   tWidthCard, tDisMinH, tDifferenceH
       # bottom
       _calcGuideLineProp tLongId, "bottom", "top", "bottom", "left", "right", "min", "max","y", tTergetProperty, tRect, tHorizontalPoint3,  tWidthCard, tDisMinH, tDifferenceH

   end repeat


   -- draw limit
   _drawLimit tVerticalPoint1, tVerticalPoint2, tVerticalPoint3, tDisMinV
   _drawLimit tHorizontalPoint1, tHorizontalPoint2, tHorizontalPoint3, tDisMinH

   local tNewLeft = true,  tNewTop = true, tDrawLimitUp = true, tDrawLimitDown = true

   -- Vertical
   if tVerticalPoint1[ "create" ] is true and tVerticalPoint1["distance"] is tDisMinV then
     _drawingGuideLine tVerticalPoint1, tTergetProperty, "height", "top", "left", 0

     put tVerticalPoint1["hook"] into tNewLeft
   else
     put false into tVerticalPoint1[ "create" ]
   end if

   if tVerticalPoint2[ "create" ] is true and tVerticalPoint2["distance"] is tDisMinV then
     if tNewLeft then
       put tVerticalPoint2["hook"] into tNewLeft
     end if

     add (tTergetProperty["x"] - tTergetProperty["left"]) to tVerticalPoint2["hook"]
     _drawingGuideLine tVerticalPoint2, tTergetProperty, "height", "top", "left", 0

   else
     put false into tVerticalPoint2[ "create" ]
   end if


   if tVerticalPoint3[ "create" ] is true and tVerticalPoint3["distance"] is tDisMinV then
     if tNewLeft then
       put tVerticalPoint3["hook"] into tNewLeft
     end if

     add tTergetProperty["width"] to tVerticalPoint3["hook"]
     _drawingGuideLine tVerticalPoint3, tTergetProperty, "height", "top", "left", 0

   else
     put false into tVerticalPoint3[ "create" ]
   end if


   -- Horizontal
   if tHorizontalPoint1[ "create" ] is true and tHorizontalPoint1["distance"] is tDisMinH then
     _drawingGuideLine tHorizontalPoint1, tTergetProperty, "width", "left", "top", 10

     put tHorizontalPoint1["hook"] into tNewTop
   else
     put false into tHorizontalPoint1[ "create" ]
   end if

   if tHorizontalPoint2[ "create" ] is true and tHorizontalPoint2["distance"] is tDisMinH then
     if tNewTop then
       put tHorizontalPoint2["hook"] into tNewTop
     end if

     add (tTergetProperty["y"] - tTergetProperty["top"]) to tHorizontalPoint2["hook"]

     _drawingGuideLine tHorizontalPoint2, tTergetProperty, "width", "left", "top", 10

   else
     put false into tHorizontalPoint2[ "create" ]
   end if

   if tHorizontalPoint3[ "create" ] is true and tHorizontalPoint3["distance"] is tDisMinH then
     if tNewTop then
       put tHorizontalPoint3["hook"] into tNewTop
     end if

     add tTergetProperty["height"] to tHorizontalPoint3["hook"]

     _drawingGuideLine tHorizontalPoint3, tTergetProperty, "width", "left", "top", 10
   else
     put false into tHorizontalPoint3[ "create" ]
   end if


   if tNewLeft is an integer then
     _toHook tSelectedObjects , tTergetProperty, "left", tNewLeft
   end if

   if tNewTop is an integer then
     _toHook tSelectedObjects , tTergetProperty, "top", tNewTop
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



private command _drawingGuideLine @pVerticalPoint, @pTergetProperty, pMainSize, pCrossStart, pMainStart, pSpace
   local tLongId, tLoc, tCrossEnd, tY

   put pVerticalPoint["max"] - pVerticalPoint["min"] into pVerticalPoint["size"]
   put _createTemporaryGraphic() into tLongId

   if pCrossStart is "top" then
      put "bottom" into tCrossEnd

   else  if pCrossStart is "left" then
      put "right" into tCrossEnd

   end if

   set the pMainSize of tLongId to pVerticalPoint["size"]
   set the pCrossStart of tLongId to pVerticalPoint["min"]
   set the pMainStart of tLongId to pVerticalPoint["hook"]
   set the backColor of tLongId to 255,0,255
   set the foregroundColor of tLongId to 255,0,255
   set the visible of tLongId to true


   if pVerticalPoint[ "drawLimitUp" ] is true then
      # Back of label 1

      put pTergetProperty[ pCrossStart ] - pVerticalPoint[ "LimitUp" ] into pVerticalPoint[ "sizeLimitUp" ]
      put pVerticalPoint[ "sizeLimitUp" ] into pVerticalPoint[ "label-1" ]

      put _createTemporaryGraphic() into tLongId
      try
         set the pMainSize of tLongId to pVerticalPoint["sizeLimitUp"]
         set the pCrossStart of tLongId to pVerticalPoint["LimitUp"]
         set the pMainStart of tLongId to pVerticalPoint["hook"]
         set the backColor of tLongId to 56,56,255
         set the foregroundColor of tLongId to 56,56,255
         set the visible of tLongId to true
         put the loc of tLongId into tLoc
      end try

      if there is no a tLongId then exit _drawingGuideLine

      if item 2 of tLoc > 25 then
         subtract pSpace from item 2 of tLoc
      else
         add pSpace to item 2 of tLoc
      end if

      # Label 1
      put _createTemporaryGraphic() into tLongId

      try
         set the height of tLongId to 20
         set the width of tLongId to 50
         set the backColor of tLongId to 56,56,255
         set the foregroundColor of tLongId to 56,56,255
         set the opaque of tLongId to false
         set the showName of tLongId to true
         set the label of tLongId to pVerticalPoint[ "label-1" ]
      end try

      if pVerticalPoint["hook"] < 50 then
         set the textAlign of tLongId to "left"
         add 28 to the item 1 of tLoc
      else
         subtract 28 from the item 1 of tLoc
         set the textAlign of tLongId to "right"
      end if

      set the loc of tLongId to tLoc
      set the visible of tLongId to true
   end if


   if pVerticalPoint[ "drawLimitDown" ] is true then

      # Back of label 2
      put pVerticalPoint[ "LimitDown" ] - pTergetProperty[ tCrossEnd ] into pVerticalPoint[ "sizeLimitDown" ]
      put pVerticalPoint[ "sizeLimitDown" ]into pVerticalPoint[ "label-2" ]
      put _createTemporaryGraphic() into tLongId

      set the pMainSize of tLongId to pVerticalPoint["sizeLimitDown"]
      set the tCrossEnd of tLongId to pVerticalPoint["LimitDown"]
      set the pMainStart of tLongId to pVerticalPoint["hook"]
      set the backColor of tLongId to 56,56,255
      set the foregroundColor of tLongId to 56,56,255
      set the visible of tLongId to true
      put the loc of tLongId into tLoc

      if item 2 of tLoc > 25 then
         subtract pSpace from item 2 of tLoc
      else
         add pSpace to item 2 of tLoc
      end if

      # Label 2
      put _createTemporaryGraphic() into tLongId

      set the height of tLongId to 20
      set the width of tLongId to 50
      set the backColor of tLongId to 56,56,255
      set the foregroundColor of tLongId to 56,56,255
      set the opaque of tLongId to false
      set the showName of tLongId to true
      set the label of tLongId to pVerticalPoint[ "label-2" ]

      if pVerticalPoint["hook"] < 50 then
         set the textAlign of tLongId to "left"
         add 28 to the item 1 of tLoc
      else
         subtract 28 from the item 1 of tLoc
         set the textAlign of tLongId to "right"
      end if

      set the loc of tLongId to tLoc
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

   put pTergetProperty[ pMainStart ] + pValue["difference"] into pPointArray[ "hook" ]
   put pValue["distance"] into pPointArray["distance"]

   if pPointArray[ "create" ] is false then exit _updateLimit

   -----------------------------------------------
   local tCrossStartValue, tCrossEndValue, tLimitMax, tLimitMin

   put the pCrossStart of pLongId into tCrossStartValue

   if pPointArray[ "min" ] >= tCrossStartValue then
      put tCrossStartValue into pPointArray[ "min" ]
   end if
   ---
   put the pCrossEnd of pLongId into tCrossEndValue

   if pPointArray[ "max" ] <= tCrossEndValue then
      put tCrossEndValue into pPointArray[ "max" ]
   end if
   ---------------------------------------------

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



private command _toHook @pSelectedObjects , @pTergetProperty, pPropName, pNewValue
   local tOff

   put pNewValue - pTergetProperty[ pPropName ] into tOff

   if tOff is 0 then exit _toHook

   repeat for each line tControl in pSelectedObjects
      set the pPropName of tControl to (the pPropName of tControl + tOff)
   end repeat
end _toHook


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



private command _saveStatus
   local tLongID, tChildControlIDs

   lock screen; lock messages

   if sMessageID is a number then cancel sMessageID
   put empty into sMessageID

   put the long id of this card into tLongID

   put the childControlIDs of tLongID into tChildControlIDs
   put tLongID into sGuideStatus["card"]

   repeat for each line tId in tChildControlIDs
     put the long id of control id tId into tLongID

     if the cDevDesigns of tLongID is true and the cTemporaryGraphic of tLongID is no true then
       put the properties of tLongID into sGuideStatus["controls"][ tLongID ]
       delete control id tId
     end if
   end repeat

   unlock screen; unlock messages
end _saveStatus


private command _restoreStatus
   local tLongID, tChildControlIDs

   lock screen; lock messages
   put empty into sMessageID

   put the long id of this card into tLongID
   put the childControlIDs of tLongID into tChildControlIDs

   if tLongID is no sGuideStatus["card"] then exit _restoreStatus

   repeat for each element tControl in sGuideStatus["controls"]
     if there is a graphic id tControl["id"] of sGuideStatus["card"] then next repeat

     create invisible graphic in sGuideStatus["card"]
     put it into tLongID

     set the properties of tLongID to tControl
     set the cDevDesigns of tLongID to true
   end repeat

   put empty into sGuideStatus

   unlock screen; unlock messages
end _restoreStatus



private function _mouseControl
   local tMouseControl

   put the mouseControl into tMouseControl

   if there is not a tMouseControl then return empty
   return _biggestOwner( the long id of tMouseControl )
end _mouseControl


private function _tergetProperty pThisCard, pControls
   local tLongId, tLeft, tTop, tRight, tBottom, tX, tY, tResult, tOwner

   put the right of pThisCard into tLeft
   put the bottom of pThisCard into tTop
   put the left of pThisCard into tRight
   put the top of pThisCard into tBottom

   repeat for each line tControl in pControls

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

     if word 1 of tOwner is not "card" then
       put true into tResult["ignore"][tOwner]
     else
       put true into tResult["ignore"][tControl]
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
   return the _ideoverride of stack pStackName or pStackName begins with "rev"or pStackName is among the items of "message box,answer dialog,ask dialog,home" or pStackName begins with "com.livecode."
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

   unlock messages
   return tGrc
end _createTemporaryGraphic
