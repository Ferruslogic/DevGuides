local sControlCachingArray, sMessageID, sNeighbors, sPrevSelectedObjects
local sGuideLine = 0

constant  kColumnLineColor = "192,192,192", kGuideLineColor = "255,00,128"
constant kNewGuideLine = 25

on preOpenStack
    revIDESubscribe "ideNewControl"
    revIDESubscribe "ideControlDeleted"
    revIDESubscribe "ideSelectedObjectChanged"
    revIDESubscribe "ideToolChanged"
    revIDESubscribe "ideWindowsChanged"
    revIDESubscribe "ideMouseMove"
    
    put empty into sMessageID
end preOpenStack

on resizeStack pNewWidth, pNewHeight, pOldWidth, pOldHeight
    updateGuides the SelectedObjects, the long id of this card,  the mouseH,  the mouseV
    pass resizeStack
end resizeStack

    
on ideToolChanged
    if the tool is "pointer tool" then exit ideToolChanged
    local tChildControlIDs
    
    put the childControlIDs of this card into tChildControlIDs
    
    repeat for each line tId in tChildControlIDs
        if the cDevDesigns of control id tId is true or the cGuideLine  of control id tId is true  then
            delete control id tId
        end if
    end repeat  
end ideToolChanged



--on selectedObjectChanged
--    local tSelectedObjects
--    lock screen; lock messages

--    put the selectedObjects into tSelectedObjects
--    if sPrevSelectedObjects is tSelectedObjects then exit selectedObjectChanged
--    put tSelectedObjects into sPrevSelectedObjects

--    updateGuides the selectedObjects, the long id of this card,  the mouseH,  the mouseV
--    unlock messages; unlock screen

--end selectedObjectChanged


on ideMouseMove pX, pY
    local tSelectedObjects, tThisStack, tThisCard
    
    put the selectedObjects into tSelectedObjects
    put the short name of this stack into tThisStack
    put the long id of this card into tThisCard
    
    if there is a grc "dev-designs-guide-line" of tThisCard  and pX, pY is no within  the rect of grc "dev-designs-guide-line" of tThisCard then         delete grc "dev-designs-guide-line" of tThisCard
    
    
    if sMessageID is an integer  or word 1 of tSelectedObjects is in "stack card" or _stackNameIsIDEStack( tThisStack ) or the tool <> "pointer tool" or tThisStack <> the short name of the topStack  then exit ideMouseMove
    
    send "updateGuides tSelectedObjects, tThisCard,  pX, pY" to me in 0 sec
    put the result into sMessageID
    
end ideMouseMove


local sGridLine
on updateGuides pSelectedObjects, pThisCard,  pX, pY
    
    # if there is a pSelectedObjects and the cGuideLine  of pSelectedObjects is true then exit updateGuides
    
    lock screen; lock messages
    -- Crear gias
    if the shiftKey is down then
        switch
            case pX <= kNewGuideLine
                _newGuideLine "left", 0, pThisCard
                break
                
            case pX >= the right of pThisCard - kNewGuideLine
                _newGuideLine "right", the right of pThisCard, pThisCard
                break
                
            case pY <= kNewGuideLine
                _newGuideLine "top", 0, pThisCard
                break
                
            case pY >= the bottom of pThisCard - kNewGuideLine 
                _newGuideLine "bottom", the bottom of pThisCard, pThisCard
                break
        end switch
    end if
    
    # Displaying the Grid in this card
    _showGridSystem the cDisplayingGrid of pThisCard, pThisCard
    
    put empty into sMessageID
    if mouse( 1 ) is up and the altKey is up then
        _deleteDevGuides
        put empty into sGridLine
        unlock messages; unlock screen
        exit updateGuides
    end if
    
    
    if there is a grc "dev-designs-guide-line" of pThisCard then
        if pX, pY is within  the rect of grc "dev-designs-guide-line" of pThisCard then
            _createGuideLine pThisCard, the width this cd, the height this cd, the cType of  grc "dev-designs-guide-line", pX, pY
            if there is a  grc  "dev-designs-guide-line" then delete  grc  "dev-designs-guide-line"
            unlock messages; unlock screen
            exit updateGuides
        end if
        
        delete grc "dev-designs-guide-line" of pThisCard
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


function _mouseControl
    local tMouseControl
    
    put mouseControl() into tMouseControl
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


private command _deleteDevGuides
    
end _deleteDevGuides


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
    
    if pDisplaying is true then
        put the width of pThisCard into tWidthCd
        put the height of pThisCard into tHeightCd
        put round(tWidthCd/12) into tGrid
        
        repeat with x = 1 to 13
            
            if there is not a  grc("dev-designs-gridSystem-" & x) of pThisCard then
                create  grc("dev-designs-gridSystem-" & x) in pThisCard
                put it into tLongId
            else
                put the long id of grc("dev-designs-gridSystem-" & x) of pThisCard into tLongId
            end if
            
            set the foregroundColor of tLongId to kColumnLineColor
            set the width of tLongId to 1
            set the height of tLongId to tHeightCd
            set the topLeft of tLongId to tLeft,0
            set the layer of tLongId to top
            set the cDevDesigns of tLongId to true
            set the cantSelect of tLongId to true
            add tGrid to tLeft
        end repeat
        
        
    else
        repeat with x = 1 to 13
            if there is a grc("dev-designs-gridSystem-" & x) of pThisCard then
                delete  grc("dev-designs-gridSystem-" & x) of pThisCard
            end if
        end repeat
    end if
end _showGridSystem


private command _newGuideLine pProperty, pValue, pThisCard
    local tWidthCd, tHeightCd, tLongId
    
    put the width of pThisCard into tWidthCd
    put the height of pThisCard into tHeightCd
    
    if there is no a grc "dev-designs-guide-line" of pThisCard then
        create  grc  "dev-designs-guide-line" in pThisCard
        put it into tLongId
    else
        put the long id of  grc "dev-designs-guide-line" of pThisCard into tLongId  
    end if
    
    set the lineSize of tLongId to 0
    set the backColor of tLongId to "blue"
    set the blendLevel of tLongId to 85
    set the bottomRight of tLongId to 0,0
    set the opaque of tLongId to true
    set the cDevDesigns of tLongId to true
    set the cantSelect of tLongId to true
    
    
    switch pProperty
        case "left"
            set the width of tLongId to  kNewGuideLine
            set the height of tLongId to tWidthCd
            set the topLeft of tLongId to 0,0
            break
            
        case "right"
            set the width of tLongId to  kNewGuideLine
            set the height of tLongId to tHeightCd
            set the topRight of tLongId to tWidthCd,0
            break
            
        case "top"
            set the width of tLongId to tWidthCd
            set the height of tLongId to kNewGuideLine
            set the topLeft of tLongId to 0,0
            break
            
        case "bottom"
            set the width of tLongId to tWidthCd
            set the height of tLongId to kNewGuideLine
            set the bottomLeft of tLongId to 0,tHeightCd
            break
            
    end switch
    
    set the cType of  tLongId to pProperty
end _newGuideLine


private command _createGuideLine pThisCard, pWidthCd, pHeightCd, pValue,  pX, pY
    local tLongId, tGroup
    
    reset templateGraphic
    
    if there is a grc "dev-designs-guide-line" and there is a grc ("dev-designs-guide-line-" & sGuideLine ) and the mouseLoc is within the rect of grc "dev-designs-guide-line"  then 
        exit _createGuideLine
    end if
    
    add 1 to sGuideLine
    create graphic("dev-designs-guide-line-" & sGuideLine) in pThisCard
    put it into tLongId
    
    set the lineSize of tLongId to 1
    set the foregroundColor of tLongId to kGuideLineColor
    set the backColor of tLongId to kGuideLineColor
    set the blendLevel of tLongId to 0
    set the bottomRight of tLongId to 0,0
    set the opaque of tLongId to true
    set the cGuideLine of tLongId to true
    set the style of tLongId to "rectangle"
    set the lockloc of tLongId to false
    set the cantSelect of tLongId to true
    
    switch pValue
        case "left"
            set the width of tLongId to  1
            set the height of tLongId to pHeightCd
            set the loc of tLongId to pX, trunc(pHeightCd/2)
            set the behavior of tLongId to _guideLineBehavior("w")
            break
            
        case "right"
            set the width of tLongId to  1
            set the height of tLongId to pHeightCd
            set the loc of tLongId to pX, trunc(pHeightCd/2)
            set the behavior of tLongId to _guideLineBehavior("w")
            break
            
        case "top"
            set the width of tLongId to pWidthCd
            set the height of tLongId to 1
            set the loc of tLongId to trunc(pWidthCd/2), pY
            set the behavior of tLongId to _guideLineBehavior("h")
            break
            
        case "bottom"
            set the width of tLongId to pWidthCd
            set the height of tLongId to 1
            set the loc of tLongId to trunc(pWidthCd/2), pY
            set the behavior of tLongId to _guideLineBehavior("h")
            break
            
    end switch
end _createGuideLine


private function _guideLineBehavior pType
    if pType is "w" then
        return the long id of button "bwGudeLine" of me
        
    else if pType is "h" then
        return the long id of button "bhGudeLine" of me
    end if
end _guideLineBehavior
