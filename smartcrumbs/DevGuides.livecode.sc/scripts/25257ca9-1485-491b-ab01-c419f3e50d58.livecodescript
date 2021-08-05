local sWLabel, sDown, tDevDeleteGuide

constant kGuideLineColor = "255,00,128", kMargins = 5

on mouseDown
    if the word 1 of the name of me is "button" then exit mouseDown
    -- CloneLine
    if the controlKey is down then
        clone me
        if there is a it then
            set the loc of it to the loc of me
            set the height of it to 1
        end if
    end if
    
    lock screen
    set the height of me to 1
    
    -- Transormar en linea
    if the cDevDesignsTem of me is true then
        set the foregroundColor of me to kGuideLineColor
        set the backColor of me to kGuideLineColor
        set the blendLevel of me to 0
        set the cDevDesignsTem of me to false
        set the cGuideLine of me to true
        set the loc of me to the mouseLoc
        set the left of me to 0
    end if
    
    unlock screen
    
    grab me
    put true into sDown
    
    set the layer of me to top
    set the backColor of me to 0,128,24
end mouseDown


local tNewH, tY
on mouseMove pNewMouseH, pNewMouseV
    if sDown is no true or  the word 1 of the name of me is "button" then exit mouseMove
    lock screen
    set the left of me to 0
    
    if there is no a graphic "wLabel" of this card then
        reset the templateGraphic
        create invisible graphic "wLabel" in this card
        put it into sWLabel
        
        set the width of sWLabel to 51
        set the height of sWLabel to 25
        set the foregroundColor of sWLabel to 192,192,192
        set the backColor of sWLabel to 74,74,74
        set the loc of sWLabel to the loc of me
        set the cDevDesigns of sWLabel to true
        set the opaque of sWLabel to true
        set the style of sWLabel to "roundRect"
        set the roundRadius of sWLabel to 5
        set the showName of sWLabel to true
        set the textAlign of sWLabel to "left"
        set the cantSelect of sWLabel to true
    else
        put the long id of  graphic "wLabel" of this card into sWLabel
    end if
    
    
    if pNewMouseV - 30  > 0 then
        set the bottom of sWLabel to pNewMouseV - 3
    else
        set the top of sWLabel to pNewMouseV + 3
    end if
    
    
    put pNewMouseH +10 into tNewH
    if tNewH > 0 and tNewH < the right of this card - 51 then
        set left of sWLabel to tNewH
    end if
    
    
    put the item 2 of the loc of me into tY
    set the label of sWLabel to "y" && tY
    
    if tY > 0 and tY < the height of this card  then
        set the layer of sWLabel to top
        set the visible of sWLabel to true
        
        if there is a tDevDeleteGuide then
            delete tDevDeleteGuide
        end if
    else
        set the visible of sWLabel to false
        
        if there is no a tDevDeleteGuide then
            create invisible widget "delete-guide" as "com.livecode.widget.svgpath" in this card
            put it into tDevDeleteGuide
            set the cDevDesigns of tDevDeleteGuide to true
            set the width of tDevDeleteGuide to 20
            set the height of tDevDeleteGuide to 25
            set the iconPath of tDevDeleteGuide to "M12,2C17.53,2 22,6.47 22,12C22,17.53 17.53,22 12,22C6.47,22 2,17.53 2,12C2,6.47 6.47,2 12,2M17,7H14.5L13.5,6H10.5L9.5,7H7V9H17V7M9,18H15A1,1 0 0,0 16,17V10H8V17A1,1 0 0,0 9,18Z"
            set the cantSelect of tDevDeleteGuide to true
            set the foregroundColor of tDevDeleteGuide to 74,74,74
            set the left of tDevDeleteGuide to pNewMouseH
        end if
        
        set the left of tDevDeleteGuide to  _clamp( pNewMouseH, kMargins, the width of this card - (20 + kMargins))
        
        if pNewMouseV <= 0 then
            set the top of tDevDeleteGuide to kMargins + 10
        else
            set the bottom of tDevDeleteGuide to the bottom of this card - (kMargins + 10)
        end if
        
        set the layer of tDevDeleteGuide to top
        set the visible of tDevDeleteGuide to true
    end if
    unlock screen
end mouseMove


on mouseEnter
    if the word 1 of the name of me is "button" or  the cDevDesignsTem of me is true  then exit mouseEnter
    set the height of me to 3
end mouseEnter


on mouseLeave
    local tLongId
    
    if the word 1 of the name of me is "button" then exit mouseLeave
    if there is a sWLabel then delete sWLabel
    if there is a tDevDeleteGuide then delete tDevDeleteGuide
    
    set the foregroundColor of me to kGuideLineColor
    set the backColor of me to kGuideLineColor
    
    set the height of me to 1
    put false into sDown
    
    if the cDevDesignsTem of me then
        put the long id of me into tLongId
        send "deleteGuideControls tLongId" to stack "DevGuides" in 0 sec
    end if
end mouseLeave


on mouseRelease pButtonNumber
    set the foregroundColor of me to kGuideLineColor
    set the backColor of me to kGuideLineColor
    
    put false into sDown
    if there is a tDevDeleteGuide then delete tDevDeleteGuide
end mouseRelease


on mouseUp pButtonNumber
    local tLongId
    
    put false into sDown
    
    set the foregroundColor of me to kGuideLineColor
    set the backColor of me to kGuideLineColor
    
    if there is a sWLabel then delete sWLabel
    if there is a tDevDeleteGuide then  delete tDevDeleteGuide
    
    if not within( this card, the loc of me ) then
        put the long id of me into tLongId
        send "deleteGuideControls tLongId" to stack "DevGuides" in 0 sec
    end if
    
end mouseUp


private function _clamp pNumber, pLower, pUpper    
    if pNumber >= pLower and pNumber <= pUpper then 
        return pNumber
    else if pNumber < pLower then
        return pLower
    else if pNumber > pUpper then
        return pUpper
    end if
end _clamp
