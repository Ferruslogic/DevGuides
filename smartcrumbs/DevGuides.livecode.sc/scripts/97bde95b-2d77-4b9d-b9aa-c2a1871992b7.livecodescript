local sLongId
constant kGuideLineColor = "255,00,128"

on mouseDown pButtonNumber
    lock screen; lock messages
    _createGuideLine the long id of this card, the width of this cd, the height of this cd, the cType of me,  the mouseh, the mouseV
    unlock screen;  unlock messages
    call "mouseDown" of sLongId
    select sLongId
    set the selected of sLongId to false
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
            set the behavior of sLongId to _guideLineBehavior("v")
            set the cGuideLineType of  sLongId to "v"
            break
            
        case "top"
            set the width of sLongId to pWidthCd
            set the height of sLongId to 1
            set the loc of sLongId to trunc(pWidthCd/2), pY
            set the behavior of sLongId to _guideLineBehavior("h")
            
            set the cGuideLineType of  sLongId to "h"
            
            break
            
    end switch
end _createGuideLine


private function _guideLineBehavior pType
    
    if pType is "v" then
        return the long id of button "bwGudeLine" of stack "DevGuides"
    else if pType is "h" then
        return the long id of button "bhGudeLine" of stack "DevGuides"
    end if
end _guideLineBehavior
 
