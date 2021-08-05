global gDevGuideLinesArray

local sLongId
constant kGuideLineColor = "255,00,128"

on mouseDown pButtonNumber
    lock screen; lock messages
    _createGuideLine the long id of this card, the width of this cd, the height of this cd, the cType of me,  the mouseh, the mouseV
    unlock screen;  unlock messages
    call "mouseDown" of sLongId
    grab sLongId
    pass mouseDown
end mouseDown


private command _createGuideLine pThisCard, pWidthCd, pHeightCd, pValue,  pX, pY
    
    reset templateGraphic
    
    create graphic("guide-line") in pThisCard
    put it into sLongId
    
    set the lineSize of sLongId to 0
    set the foregroundColor of sLongId to kGuideLineColor
    set the backColor of sLongId to kGuideLineColor
    set the blendLevel of sLongId to 0
    set the bottomRight of sLongId to 0,0
    set the opaque of sLongId to true
    set the cGuideLine of sLongId to true
    set the style of sLongId to "rectangle"
    set the lockloc of sLongId to false
    set the cantSelect of sLongId to true
    
    switch pValue
        case "left"
            set the width of sLongId to  1
            set the height of sLongId to pHeightCd
            set the loc of sLongId to pX, trunc(pHeightCd/2)
            set the behavior of sLongId to _guideLineBehavior("w")
            
            if gDevGuideLinesArray["vertical"]["num"] is no an integer then
                put 0 into gDevGuideLinesArray["vertical"]["num"]
            else
                add 1 to gDevGuideLinesArray["vertical"]["num"]
            end if
            
            put sLongId into gDevGuideLinesArray["vertical"][ pThisCard ]
            break
            
            
        case "top"
            set the width of sLongId to pWidthCd
            set the height of sLongId to 1
            set the loc of sLongId to trunc(pWidthCd/2), pY
            set the behavior of sLongId to _guideLineBehavior("h")
            
            if gDevGuideLinesArray["horizontal"]["num"] is no an integer then
                put 0 into gDevGuideLinesArray["horizontal"]["num"]
            else
                add 1 to gDevGuideLinesArray["horizontal"]["num"]
            end if
            
            put sLongId into gDevGuideLinesArray["horizontal"][ pThisCard ]
            
            break
            
            
    end switch
    
    if gDevGuideLinesArray["all"]["num"] is no an integer then
        put 0 into gDevGuideLinesArray["all"]["num"]
    else
        add 1 to gDevGuideLinesArray["all"]["num"]
    end if
    return sLongId
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
 
