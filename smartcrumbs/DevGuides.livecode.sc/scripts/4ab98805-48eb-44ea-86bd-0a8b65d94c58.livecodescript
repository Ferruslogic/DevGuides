/*
* DevGuides
* © FerrusLogic Team
* August 2021
* version 1.0.0
*
* This code is part of DevGuides extension created by FerrusLogic team to provide design guides to
* help LiveCode developers in the process of designing graphic interfaces in an easy and modern way
*/

local sDown --> Bandera para saber si elusuario tiene el precionado el click
local sLabelControl, sDevDeleteGuide, sLabelControl1, sLabelControl2 , sLineControl --> id largo de los graficos temporales
local sThisCard, sWidthCard, sHeightCard --> Propiedades de la targeta que se usan con frecuencia.

on mouseDown pButtonNumber
    if the word 1 of the name of me is "button" or pButtonNumber <> 1 then exit mouseDown
    
    if the cDevDesignsTem of me is true then
        set the foregroundColor of me to _backColor()
        set the backColor of me to _backColor()
        set the blendLevel of me to 0
        set the cDevDesignsTem of me to false
        set the cGuideLine of me to true
        set the loc of me to the mouseLoc
        set the top of me to 0
    end if
    
    put the long id of this card into sThisCard
    put the width of this card into  sWidthCard
    put the height of this card into  sHeightCard
    
    # Clone this line
    if the controlKey is down then
        lock messages
        clone me
        if there is a it then
            set the width of it to 1
            set the loc of it to the loc of me
        end if
        
        # recalc
        _createCache the long id of me, sThisCard
        unlock messages
    end if
    
    set the width of me to 1
    unlock screen
    
    grab me
    
    put true into sDown
    
    set the layer of me to top
    set the backColor of me to _hilitedColor()
end mouseDown


local tNewV, tX, tDis = 0

on mouseMove pNewMouseH, pNewMouseV
    
    if sDown is no true or  the word 1 of the name of me is "button" then exit mouseMove
    set the top of me to 0
    
    # Label
    if there is no a sLabelControl then
        put _createTemporaryGraphic() into sLabelControl
        set the foregroundColor of sLabelControl to _labelTextColor()
        set the backColor of sLabelControl to _labelBackColor()
        set the opaque of sLabelControl to true
        set the showName of sLabelControl to true
        set the textAlign of sLabelControl to "left"
    end if
    
    if pNewMouseH + 54 < sWidthCard then
        set the left of sLabelControl to pNewMouseH + 3
    else
        set the right of sLabelControl to pNewMouseH - 3
    end if
    
    put pNewMouseV - 30 into tNewV
    
    if tNewV <= 0 then
        set top of sLabelControl to 0
        
    else if pNewMouseV >= sHeightCard then
        set bottom of sLabelControl to  sHeightCard
        
    else
        set top of sLabelControl to tNewV
    end if
    
    
    put the item 1 of the loc of me into tX
    set the label of sLabelControl to "x" && tX
    
    if tX > 0 and tX < sWidthCard  then
        set the visible of sLabelControl to true
        
        if there is a sDevDeleteGuide then
            delete sDevDeleteGuide
        end if
        
    else
        
        # Delelte
        set the visible of sLabelControl to false
        
        if there is no a sDevDeleteGuide then
            create invisible widget as "com.livecode.widget.svgpath" in sThisCard
            put it into sDevDeleteGuide
            set the cDevDesigns of sDevDeleteGuide to true
            set the width of sDevDeleteGuide to 20
            set the height of sDevDeleteGuide to 25
            set the iconPath of sDevDeleteGuide to _trashIconPath()
            set the cantSelect of sDevDeleteGuide to true
            set the foregroundColor of sDevDeleteGuide to _trashIconColor()
        end if
        
        set the top of sDevDeleteGuide to the top of sLabelControl
        
        if tX <= 0 then
            set the left of sDevDeleteGuide to 15
        else
            set the right of sDevDeleteGuide to sWidthCard - 15
        end if
        _deleteAllTemporaryGraphic
        set the visible of sDevDeleteGuide to true
        exit mouseMove
    end if
    
    local tLimits, tSize
    
    put _getLimits(3 , 1, 0, sWidthCard) into tLimits
    put tLimits[ 2 ] - tLimits[ 1 ] into tSize
    
    # More
    if there is no a sLabelControl1 then
        put _createTemporaryGraphic() into sLabelControl1
        set the showName of sLabelControl1 to true
        set the top of sLabelControl1 to 33
        set the visible of sLabelControl1 to true
    end if
    
    put tX  - tLimits[ 1 ] into tDis
    put tX - tDis/2   into tNewV
    
    set the label of sLabelControl1 to tDis
    set the left of sLabelControl1 to tNewV - 25
    
    # sLabelControl2
    if there is no a sLabelControl2 then
        put _createTemporaryGraphic() into sLabelControl2
        set the showName of sLabelControl2 to true
        set the top of sLabelControl2 to 33
        set the visible of sLabelControl2 to true
    end if
    
    put  tLimits[ 2 ] - tX   into tDis
    put tX + tDis/2   into tNewV
    set the label of sLabelControl2 to tDis
    set the left of sLabelControl2 to tNewV  - 25
    
    if there is no a sLineControl then
        put _createTemporaryGraphic() into sLineControl
        set the height of sLineControl to 1
        set the top of sLineControl to 30
        set the roundRadius of sLineControl to 0
        set the opaque of sLineControl to true
        set the visible of sLineControl to true
    end if
    
    set the width of sLineControl to tSize
    set the left of sLineControl to tLimits[ 1 ]
    
    if there is a sDevDeleteGuide then set the layer of sDevDeleteGuide to top
    set the layer of sLabelControl to top
    
    unlock screen
end mouseMove


on mouseEnter
    if the word 1 of the name of me is "button" or the cDevDesignsTem of me is true  then exit mouseEnter
    set the width of me to 3
end mouseEnter


on mouseLeave
    local tLongId
    
    _deleteAllTemporaryGraphic
    if the word 1 of the name of me is "button"  or the cDevDesignsTem of me is true then exit mouseLeave
    if there is a sLabelControl then delete sLabelControl
    if there is a sDevDeleteGuide then delete sDevDeleteGuide
    
    set the foregroundColor of me to _backColor()
    set the backColor of me to _backColor()
    
    set the width of me to 1
    put false into sDown
    
    if the cDevDesignsTem of me then
        put the long id of me into tLongId
        send "deleteGuideControls tLongId" to stack "DevGuides" in 0 sec
    end if
end mouseLeave


on mouseRelease
    set the foregroundColor of me to _backColor()
    set the backColor of me to _backColor()
    
    _deleteAllTemporaryGraphic
    
    put false into sDown
    if there is a sDevDeleteGuide then delete sDevDeleteGuide
end mouseRelease


on mouseUp pButtonNumber
    local tLongId
    if pButtonNumber <> 1 then exit mouseUp
    put false into sDown
    
    set the foregroundColor of me to _backColor()
    set the backColor of me to _backColor()
    
    if there is a sLabelControl then delete sLabelControl
    if there is a sDevDeleteGuide then  delete sDevDeleteGuide
    _deleteAllTemporaryGraphic
    
    put the long id of me into tLongId    
    
    set the height of me to sHeightCard
    set the top of me to 0
    
    if  the left of me > sWidthCard or the right of me < 0 then
        send "deleteGuideControls tLongId" to stack "DevGuides" in 0 sec
    end if
    
end mouseUp




getProp cGuideLineType
    return "vertical"
end cGuideLineType
