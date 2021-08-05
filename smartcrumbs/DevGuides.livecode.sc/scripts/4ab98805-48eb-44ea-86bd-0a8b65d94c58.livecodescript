local sWLabel, sDown

on mouseDown
    if the word 1 of the name of me is "button" then exit mouseDown
    grab me
    put true into sDown
    set the width of me to 1
    set the layer of me to top
end mouseDown


on mouseMove pNewMouseH, pNewMouseV
    if sDown is no true or  the word 1 of the name of me is "button" then exit mouseMove
    
    set the top of me to 0
    
    if there is no a graphic "wLabel" of this card then
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
    else
        put the long id of  graphic "wLabel" of this card into sWLabel
    end if
    
    if pNewMouseH + 54 < the right of this card then
        set the left of sWLabel to pNewMouseH + 3
    else
        set the right of sWLabel to pNewMouseH - 3
    end if
    
    local tNewV
    put pNewMouseV - 30 into tNewV
    
    if tNewV <= 0 then
        set top of sWLabel to 0
        
    else if tNewV >= the bottom of this card then
        set bottom of sWLabel to  the bottom of this card 
        
    else
        set top of sWLabel to tNewV
    end if
    
    set the label of sWLabel to "x "& the item 1 of the loc of me
    set the visible of sWLabel to true
end mouseMove


on mouseEnter
    if the word 1 of the name of me is "button" then exit mouseEnter
    set the width of me to 3
end mouseEnter


on mouseLeave
    if the word 1 of the name of me is "button" then exit mouseLeave
    if there is a sWLabel then delete sWLabel
    set the width of me to 1
    put false into sDown
end mouseLeave


on mouseRelease pButtonNumber
    put false into sDown
end mouseRelease


on mouseUp pButtonNumber
    local tLongId
    put false into sDown
    
    if there is a  grc  "dev-designs-guide-line" then
        delete grc  "dev-designs-guide-line"
    end if
    
    if there is a sWLabel then 
        delete sWLabel
    end if
    if not within(this card, the loc of me) then
        put the long id of me into tLongId
        send "deleteGuideControls tLongId" to stack "DevGuides" in 0 sec
    end if
end mouseUp
