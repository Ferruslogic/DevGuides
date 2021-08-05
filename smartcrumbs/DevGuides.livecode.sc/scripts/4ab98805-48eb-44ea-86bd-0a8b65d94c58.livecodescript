local sWLabel, sDown, tDevDeleteGuide

on mouseDown
    if the word 1 of the name of me is "button" then exit mouseDown
    grab me
    put true into sDown
    set the width of me to 1
    set the layer of me to top
    set the cforegroundColor of me to the foregroundColor of me
    set the foregroundColor of me to "green"
end mouseDown

local tNewV, tX
on mouseMove pNewMouseH, pNewMouseV
    if sDown is no true or  the word 1 of the name of me is "button" then exit mouseMove
    
    set the top of me to 0
    
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
    
    if pNewMouseH + 54 < the right of this card then
        set the left of sWLabel to pNewMouseH + 3
    else
        set the right of sWLabel to pNewMouseH - 3
    end if
    
    put pNewMouseV - 30 into tNewV
    
    if tNewV <= 0 then
        set top of sWLabel to 0
        
    else if pNewMouseV >= the bottom of this card then
        set bottom of sWLabel to  the bottom of this card
        
    else
        set top of sWLabel to tNewV
    end if
    
    
    put the item 1 of the loc of me into tX
    set the label of sWLabel to "x" && tX
    
    if tX > 0 and tX < the width of this card  then
        set the visible of sWLabel to true
        
        if there is a tDevDeleteGuide then
            delete tDevDeleteGuide
        end if
        
    else
        set the visible of sWLabel to false
        
        if there is no a tDevDeleteGuide then
            create invisible widget as "com.livecode.widget.svgpath" in this card
            put it into tDevDeleteGuide
            set the cDevDesigns of tDevDeleteGuide to true
            set the width of tDevDeleteGuide to 20
            set the height of tDevDeleteGuide to 20
            set the iconPath of tDevDeleteGuide to "M12,2C17.53,2 22,6.47 22,12C22,17.53 17.53,22 12,22C6.47,22 2,17.53 2,12C2,6.47 6.47,2 12,2M17,7H14.5L13.5,6H10.5L9.5,7H7V9H17V7M9,18H15A1,1 0 0,0 16,17V10H8V17A1,1 0 0,0 9,18Z"
            set the foregroundColor of tDevDeleteGuide to 255,21,21
        end if
        
        set the top of tDevDeleteGuide to the top of sWLabel
        
        if tX <= 0 then
            set the left of tDevDeleteGuide to 15
        else
            set the right of tDevDeleteGuide to the right of this card - 15
        end if
        
        set the visible of tDevDeleteGuide to true
    end if
    
end mouseMove


on mouseEnter
    if the word 1 of the name of me is "button" then exit mouseEnter
    set the width of me to 3
end mouseEnter


on mouseLeave
    if the word 1 of the name of me is "button" then exit mouseLeave
    if there is a sWLabel then delete sWLabel
    set the width of me to 1
    set the foregroundColor of me to the cforegroundColor of me
    put false into sDown
    if there is a tDevDeleteGuide then
        delete tDevDeleteGuide
    end if
    
end mouseLeave


on mouseRelease pButtonNumber
    set the foregroundColor of me to the cforegroundColor of me
    put false into sDown
    if there is a tDevDeleteGuide then
        delete tDevDeleteGuide
    end if
    
end mouseRelease


on mouseUp pButtonNumber
    local tLongId
    put false into sDown
    
    set the foregroundColor of me to the cforegroundColor of me
    
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
    
    if there is a tDevDeleteGuide then
        delete tDevDeleteGuide
    end if
    
end mouseUp
