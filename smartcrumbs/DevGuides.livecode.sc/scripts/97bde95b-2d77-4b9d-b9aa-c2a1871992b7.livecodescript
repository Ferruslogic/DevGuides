
constant kGuideLineColor = "255,00,128"

on mouseDown pButtonNumber
    lock screen; lock messages
    _createGuideLine the long id of this card, the width of this cd, the height of this cd, the cType of me,  the mouseh, the mouseV
    unlock screen;  unlock messages
end mouseDown


private command _createGuideLine pThisCard, pWidthCd, pHeightCd, pValue,  pX, pY
    local tLongId, tGroup
    
    reset templateGraphic
    
    create graphic("guide-line") in pThisCard
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
    
    call "mouseDown" of tLongId
    hide me
end _createGuideLine


private function _guideLineBehavior pType
    local tCd
    put the long id of the owner of me into tCd
    
    if pType is "w" then
        return the long id of button "bwGudeLine" of tCd
        
    else if pType is "h" then
        return the long id of button "bhGudeLine" of tCd
    end if
end _guideLineBehavior



