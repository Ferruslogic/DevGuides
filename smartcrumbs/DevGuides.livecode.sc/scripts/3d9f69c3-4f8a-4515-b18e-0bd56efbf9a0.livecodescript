global gDevGuideLinesArray

local sControlCachingArray, sMessageID, sNeighbors, sPrevSelectedObjects
local sGuideStatus, sGridLine
local sGridSystem, sThisCard


constant  kColumnLineColor = "192,192,192"
constant kNewGuideLine = 25

on preOpenStack

    revIDESubscribe "ideToolChanged"
    
    put empty into sMessageID
    deleteGuideControls
    pass preOpenStack
end preOpenStack


on closeStack
    deleteGuideControls
    pass closeStack
end closeStack
 
 
on resizeStack pNewWidth, pNewHeight, pOldWidth, pOldHeight
    _updateSizeGuideLines  pNewWidth, pNewHeight, pOldWidth, pOldHeight
    _showGridSystem false, the long id of this card
    pass resizeStack
end resizeStack






on ideToolChanged
    if the tool is "pointer tool" then
        _restoreStatus 
    else
        _saveStatus   
    end if
end ideToolChanged


command deleteGuideControls pLongId
    local tChildControlIDs
     
    if there is a pLongId then
        delete pLongId
        exit deleteGuideControls
    end if
    
    put the childControlIDs of this card into tChildControlIDs
    
    repeat for each line tId in tChildControlIDs
        if the cDevDesigns of control id tId is true or the cGuideLine  of control id tId is true  then
            delete control id tId
        end if
    end repeat
    
end deleteGuideControls
 
 
 
on mouseMove pX, pY
    local tSelectedObjects, tThisStack, tThisCard
    
    put the selectedObjects into tSelectedObjects
    put the short name of the topstack into tThisStack
    set the defaultStack to tThisStack
    put the long id of this card into tThisCard
    
    if sMessageID is an integer  or word 1 of tSelectedObjects is in "stack card" or _stackNameIsIDEStack( tThisStack ) or the tool <> "pointer tool" or tThisStack <> the short name of the topStack  then 
        _deleteDevTempGuides
        pass mouseMove
    end if
    
    send "updateGuides tSelectedObjects, tThisCard,  pX, pY" to me in 0 sec
    put the result into sMessageID
    
end mouseMove


local sNewGuideLine
on updateGuides pSelectedObjects, pThisCard,  pX, pY 
    put empty into sMessageID
    
    lock screen; lock messages
    
    if there is a sNewGuideLine and the cDevDesignsTem of sNewGuideLine then
        delete sNewGuideLine
        put empty into sNewGuideLine
        unlock messages; unlock screen
        exit updateGuides
    end if
    
    
    if the shiftKey is down then
        switch
            case pX <= kNewGuideLine
                _newGuideLine "left", 0, pThisCard
                put the result into sNewGuideLine
                break
                
            case pY <= kNewGuideLine
                _newGuideLine "top", 0, pThisCard
                put the result into sNewGuideLine
                break
        end switch
    end if
    
    # Displaying the Grid in this card
    _showGridSystem the cDisplayingGrid of pThisCard, pThisCard
    
    if mouse( 1 ) is up and the altKey is up then
        _deleteDevTempGuides
        put empty into sGridLine
        unlock messages; unlock screen
        exit updateGuides
    end if
    
    if there is no pSelectedObjects then exit updateGuides
    
    if the cGuideLine of pSelectedObjects or there is a sGridLine and the cGuideLine of  sGridLine then
        set the selected of pSelectedObjects to true
        put pSelectedObjects into sGridLine
        exit updateGuides
    end if
    
    _controlCaching pThisCard
    
    if the num of lines of pSelectedObjects is 1 and the word 5 of pSelectedObjects is "card" then
        _updateGuides pSelectedObjects, pThisCard,  pX, pY
        
    else
        -- Calcula la recta de la union de todos los obj seleccionado
        -- pX, pY is not within tLaRectCalculada
    end if
    
    unlock messages; unlock screen
end updateGuides



private command _saveStatus
    local tLongID, tChildControlIDs
    lock screen; lock messages
    
    put the long id of this card into tLongID
    _showGridSystem false, tLongID
    
    put the childControlIDs of  tLongID into tChildControlIDs
    put tLongID into sGuideStatus["card"]
    
    repeat for each line tId in tChildControlIDs
        put the long id of control id tId into tLongID
        
        if the cDevDesigns of tLongID is true or the cGuideLine  of tLongID is true  then
            put the properties of tLongID into sGuideStatus["controls"][ tLongID ]
            delete control id tId
        end if
    end repeat 
    unlock screen; unlock messages
end _saveStatus


private command _restoreStatus
    local tLongID, tChildControlIDs
    lock screen; lock messages
    put the long id of this card into tLongID
    
    # Displaying the Grid in this card
    _showGridSystem the cDisplayingGrid of tLongID, tLongID
    
    put the childControlIDs of  tLongID into tChildControlIDs
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
    
    put the long id of tMouseControl into tMouseControl
    
    if word 5 of tMouseControl is "group" then
        return word 5 to -1  of  tMouseControl
    end if
    
    return tMouseControl
end _mouseControl


private command _controlCaching pLongIdCd
    local tChildControlIDs, tLongID
    
    put the childControlIDs of pLongIdCd into tChildControlIDs
    
    repeat for each line tId in tChildControlIDs
        put the long id of control id tId of pLongIdCd into tLongID
        
        if the visible of tLongID is false or long id of (the owner of tLongID)  is no pLongIdCd then next repeat
        put the rect of tLongId into sControlCachingArray[ tLongID ]["rect"]
        put the loc of tLongId into sControlCachingArray[ tLongID ]["loc"]
        put sControlCachingArray[ tLongID ]["loc"] into sControlCachingArray[ tLongID ]["locArray"]
        split  sControlCachingArray[ tLongID ]["locArray"] by comma
        
        put sControlCachingArray[ tLongID ]["rect"] into sControlCachingArray[ tLongID ]["rectArray"]
        split  sControlCachingArray[ tLongID ]["rectArray"] by comma
    end repeat
    
end _controlCaching


private function _stackNameIsIDEStack pStackName
    if there is no a stack pStackName  then return false
    return  the _ideoverride of stack pStackName or pStackName begins with "rev"or pStackName is among the items of "message box,answer dialog,ask dialog,home" or pStackName begins with "com.livecode."
end _stackNameIsIDEStack


private command _deleteDevTempGuides
    local tChildControlIDs, tLongId
    put the childControlIDs of this card into tChildControlIDs
    
    repeat for each line tId in tChildControlIDs
        put the long id of control id tId into tLongId
        if word 1 of tLongId is "graphic" and the cDevDesigns of tLongId and the cTemporaryGraphic of tLongId then
            try
                delete control id tId
            end try
        end if
    end repeat
end _deleteDevTempGuides
    
    
private command _updateGuides pLongId, pThisCard, pMouseX, pMouseY
    local tControlCachingArray, tWidth, tHeight
    
    put the width of pLongId into tWidth
    put the height of pLongId into tHeight
    
    put sControlCachingArray into tControlCachingArray
    delete variable tControlCachingArray[ pLongId ]
    
    
    -- Calcular 
    repeat for each key tLongID in tControlCachingArray
        put sControlCachingArray[ pLongId ]["locArray"][ 1 ] - sControlCachingArray[ tLongID ]["locArray"][ 1 ] into sNeighbors[ tLongID ]["XDiff"]
        put  sControlCachingArray[ pLongId ]["locArray"][ 2 ] -  sControlCachingArray[ tLongID ]["locArray"][ 2 ] into sNeighbors[ tLongID ]["YDiff"]
        
    end repeat
    
    
end _updateGuides


# Displaying the Grid
private command _showGridSystem pDisplaying, pThisCard
    local tWidthCd, tHeightCd, tLongId, tGrid, tLeft = 0
    lock screen
    repeat with x = 1 to 13
        if there is a sGridSystem[x] then
            delete variable sGuideStatus["controls"][ sGridSystem[ x ]]
            delete  sGridSystem[ x ]
        end if
        
        if there is a  grc("dev-designs-gridSystem-" & x) of pThisCard then
            delete variable sGuideStatus["controls"][  the long id of  grc("dev-designs-gridSystem-" & x) of pThisCard ]
            delete  grc("dev-designs-gridSystem-" & x) of pThisCard
        end if
        
    end repeat
    
    if pDisplaying is true then
        put the width of pThisCard into tWidthCd
        put the height of pThisCard into tHeightCd
        put round(tWidthCd/12) into tGrid
        
        repeat with x = 1 to 13
            create  grc("dev-designs-gridSystem-" & x) in pThisCard
            put it into tLongId
            
            put tLongId into sGridSystem[ x ]
            set the foregroundColor of tLongId to kColumnLineColor
            set the width of tLongId to 1
            set the height of tLongId to tHeightCd
            set the topLeft of tLongId to tLeft,0
            set the layer of tLongId to top
            set the cGuideLine of tLongId to true
            set the cantSelect of tLongId to true
            set the cName of tLongId to the short name of tLongId
            set the cGuideLineType of  tLongId to "v"
            
            add tGrid to tLeft
        end repeat
    end if
    
    unlock screen
end _showGridSystem


private command _newGuideLine pProperty, pValue, pThisCard
    local tWidthCd, tHeightCd, tLongId
    
    put the width of pThisCard into tWidthCd
    put the height of pThisCard into tHeightCd
    
    create  grc "guide-line" in pThisCard
    put it into tLongId
    
    set the lineSize of tLongId to 0
    set the backColor of tLongId to "170,170,170"
    set the blendLevel of tLongId to 50
    set the bottomRight of tLongId to 0,0
    set the opaque of tLongId to true
    set the layerMode of tLongId to "dynamic"
    set the cDevDesigns of tLongId to true
    set the cDevDesignsTem of tLongId to true
    
    set the cantSelect of tLongId to true
    
    switch pProperty
        case "left"
            set the width of tLongId to  kNewGuideLine
            set the height of tLongId to tWidthCd
            set the topLeft of tLongId to 0,0
            set the behavior of tLongId to _newGuideLineBehavior("v")            
            break
            
        case "top"
            set the width of tLongId to tWidthCd
            set the height of tLongId to kNewGuideLine
            set the topLeft of tLongId to 0,0
            set the behavior of tLongId to _newGuideLineBehavior("h")
            set the cGuideLineType  of tLongId to "horizontal"
            break
    end switch
    
    show tLongId
    return tLongId
end _newGuideLine


private function _newGuideLineBehavior pType
    if pType is "v" then
        return the long id of button "bVerticalGuideLine" of me
    else if pType is "h" then
        return the long id of button "bHorizontalGuideLine" of me
    end if
end _newGuideLineBehavior


private command _updateSizeGuideLines  pNewWidth, pNewHeight, pOldWidth, pOldHeight
    local tChildControlIDs
    
    put the childControlIDs of this card into tChildControlIDs
    
    repeat for each line tId in tChildControlIDs
            
            if the cGuideLineType  of control id tId is "horizontal"  then
                set the width  of control id tId to pNewWidth
                set the left  of control id tId to 0
                
            else if  the cGuideLineType  of control id tId is "vertical"  then
                set the height  of control id tId to pNewHeight
                set the top  of control id tId to 0
                
            end if
    end repeat
    
end _updateSizeGuideLines
