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
        set the left of me to 0
    end if
    
    put the long id of this card into sThisCard
    put the width of this card into  sWidthCard
    put the height of this card into  sHeightCard
    
    # Clone this line
    if the controlKey is down then
        lock messages
        clone me
        if there is a it then
            set the height of it to 1
            set the loc of it to the loc of me
        end if
        
        # recalc
        _createCache the long id of me, sThisCard
        unlock messages
    end if
    
    set the height of me to 1
    unlock screen
    
    grab me
    
    put true into sDown
    
    set the layer of me to top
    set the backColor of me to _hilitedColor()
end mouseDown


local tNewH, tY, tDis = 0

on mouseMove pNewMouseH, pNewMouseV
    lock screen
    if sDown is no true or  the word 1 of the name of me is "button" then exit mouseMove
    set the left of me to 0
    
    # Label
    if there is no a sLabelControl then
        put _createTemporaryGraphic() into sLabelControl
        set the foregroundColor of sLabelControl to _labelTextColor()
        set the backColor of sLabelControl to _labelBackColor()
        set the opaque of sLabelControl to true
        set the showName of sLabelControl to true
        set the textAlign of sLabelControl to "left"
    end if
    
    if pNewMouseV - 25<= 0 then
        set the top of sLabelControl to pNewMouseV + 3
    else
        set the bottom of sLabelControl to pNewMouseV - 3
    end if
    
    put pNewMouseH + 10 into tNewH
    
    if tNewH <= 0 then
        set left of sLabelControl to 0
        
    else if pNewMouseH + 59 >= sWidthCard then
        set right of sLabelControl to  sWidthCard
        
    else
        set left of sLabelControl to tNewH
    end if
    
    
    put the item 2 of the loc of me into tY
    set the label of sLabelControl to "y" && tY
    
    if tY > 0 and tY < sHeightCard  then
        set the visible of sLabelControl to true
        
        if there is a sDevDeleteGuide then
            delete sDevDeleteGuide
        end if        
    else
        set the visible of sLabelControl to false
        # Delelte  
        
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
        
        set the loc of sDevDeleteGuide to the loc of sLabelControl 
        
        if tY <= 0 then
            set the top of sDevDeleteGuide to 3
        else
            set the bottom of sDevDeleteGuide to sHeightCard - 3
        end if
        
        _deleteAllTemporaryGraphic
        set the visible of sDevDeleteGuide to true
        exit mouseMove
    end if
    
    local tLimits, tSize, tLeft
    
    put _getLimits(2 ,4, 0, sHeightCard) into tLimits
    put tLimits[ 2 ] - tLimits[ 1 ] into tSize
    put sWidthCard - 85 into tLeft
    
    # More
    if there is no a sLabelControl1 then
        put _createTemporaryGraphic() into sLabelControl1
        set the showName of sLabelControl1 to true
        set the left of sLabelControl1 to tLeft
        set the visible of sLabelControl1 to true
    end if
    
    
    put tY  - tLimits[ 1 ]  into tDis
    put tY - tDis/2 into tNewH
    
    set the label of sLabelControl1 to tDis
    set the top of sLabelControl1 to tNewH - 10
    
    # sLabelControl2
    if there is no a sLabelControl2 then
        put _createTemporaryGraphic() into sLabelControl2
        set the showName of sLabelControl2 to true
        set the left of sLabelControl2 to tLeft
        set the visible of sLabelControl2 to true
    end if
    
    put  tLimits[ 2 ] - tY   into tDis
    put tY+ tDis/2   into tNewH
    set the label of sLabelControl2 to tDis
    set the top of sLabelControl2 to tNewH  - 10
    
    if there is no a sLineControl then
        put _createTemporaryGraphic() into sLineControl
        set the width of sLineControl to 1
        set the left of sLineControl to tLeft - 3
        set the roundRadius of sLineControl to 0
        set the opaque of sLineControl to true
        set the visible of sLineControl to true
    end if
    
    set the height of sLineControl to tSize
    set the top of sLineControl to tLimits[ 1 ]
    
    if there is a sDevDeleteGuide then set the layer of sDevDeleteGuide to top
    set the layer of sLabelControl to top
    unlock screen
end mouseMove


on mouseEnter
    if the word 1 of the name of me is "button" or  the cDevDesignsTem of me is true  then exit mouseEnter
    set the height of me to 3
end mouseEnter


on mouseLeave
   local tLongId
   _deleteAllTemporaryGraphic
   
   if the word 1 of the name of me is "button" or the cDevDesignsTem of me is true then exit mouseLeave
   if there is a sLabelControl then delete sLabelControl
   if there is a sDevDeleteGuide then delete sDevDeleteGuide
   
   
   put false into sDown
   
   if the cDevDesignsTem of me then
      put the long id of me into tLongId
      send "deleteGuideControls tLongId" to stack "DevGuides" in 0 sec
   else
      set the foregroundColor of me to _backColor()
      set the backColor of me to _backColor()
      
      set the height of me to 1
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
    
    set the width of me to sWidthCard 
    set the left of me to 0
    
    if  the bottom of me < 0 or the top of me > sHeightCard then
        send "deleteGuideControls tLongId" to stack "community.ferruslogic.library.devguides" in 0 sec
    end if
end mouseUp

getProp cGuideLineType
    return "horizontal"
end cGuideLineType
