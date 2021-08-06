local sLabelControl, sDown, sDevDeleteGuide, sLabelControl1, sLabelControl2 , sLineControl

constant kGuideLineColor = "255,00,128"
local sThisCard, sWidthCard, sHeightCard

on mouseDown
    if the word 1 of the name of me is "button" then exit mouseDown
    -- Transormar en linea
    if the cDevDesignsTem of me is true then
        set the foregroundColor of me to kGuideLineColor
        set the backColor of me to kGuideLineColor
        set the blendLevel of me to 0
        set the cDevDesignsTem of me to false
        set the cGuideLine of me to true
        set the loc of me to the mouseLoc
        set the top of me to 0
    end if
    
    put the long id of this card into sThisCard
    put the width of this card into  sWidthCard
    put the height of this card into  sHeightCard
    
    -- CloneLine
    if the controlKey is down then
        clone me
        if there is a it then
            set the width of it to 1
            set the loc of it to the loc of me
        end if
        
        # recalc
        createCache the long id of me, sThisCard
    end if
    
    set the width of me to 1
    
    
    
    unlock screen
    
    grab me
    put true into sDown
    
    set the layer of me to top
    set the backColor of me to 0,128,24
end mouseDown


local tNewV, tX
on mouseMove pNewMouseH, pNewMouseV
    if sDown is no true or  the word 1 of the name of me is "button" then exit mouseMove

    set the top of me to 0

    # Label
    if there is no a sLabelControl then
        reset the templateGraphic

        create invisible graphic "guideLineLabel" in sThisCard
        put it into sLabelControl

        set the width of sLabelControl to 51
        set the height of sLabelControl to 25
        set the foregroundColor of sLabelControl to 192,192,192
        set the backColor of sLabelControl to 74,74,74
        set the loc of sLabelControl to the loc of me
        set the cDevDesigns of sLabelControl to true
        set the opaque of sLabelControl to true
        set the style of sLabelControl to "roundRect"
        set the roundRadius of sLabelControl to 5
        set the showName of sLabelControl to true
        set the textAlign of sLabelControl to "left"
        set the cantSelect of sLabelControl to true

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
            set the iconPath of sDevDeleteGuide to "M12,2C17.53,2 22,6.47 22,12C22,17.53 17.53,22 12,22C6.47,22 2,17.53 2,12C2,6.47 6.47,2 12,2M17,7H14.5L13.5,6H10.5L9.5,7H7V9H17V7M9,18H15A1,1 0 0,0 16,17V10H8V17A1,1 0 0,0 9,18Z"
            set the cantSelect of sDevDeleteGuide to true
            set the foregroundColor of sDevDeleteGuide to 74,74,74
        end if

        set the top of sDevDeleteGuide to the top of sLabelControl

        if tX <= 0 then
            set the left of sDevDeleteGuide to 15
        else
            set the right of sDevDeleteGuide to sWidthCard - 15
        end if
        _deleteAllTemporaryGraphi
        set the visible of sDevDeleteGuide to true
        exit mouseMove
    end if

    local tLimits, tSize

    put getLimits(3 , 1, 0, the width of this card) into tLimits
    put tLimits[ 2 ] - tLimits[ 1 ] into tSize

    # More
    if there is no a sLabelControl1 then
        _createTemporaryGraphic
        put the result into sLabelControl1
        set the showName of sLabelControl1 to true
        set the top of sLabelControl1 to 33
        #set the opaque of sLabelControl1 to true
        set the backColor of sLabelControl1 to 255,255,255
        set the visible of sLabelControl1 to true
    end if

    local tDis = 0
    put tX  - tLimits[ 1 ] into tDis
    put tX - tDis/2   into tNewV
    set the label of sLabelControl1 to tDis
    set the left of sLabelControl1 to tNewV - 25

    # sLabelControl2
    if there is no a sLabelControl2 then
        _createTemporaryGraphic
        put the result into sLabelControl2
        set the showName of sLabelControl2 to true
        set the top of sLabelControl2 to 33
        #set the opaque of sLabelControl2 to true
        set the backColor of sLabelControl2 to 255,255,255
        set the visible of sLabelControl2 to true
    end if

    put  tLimits[ 2 ] - tX   into tDis
    put tX + tDis/2   into tNewV
    set the label of sLabelControl2 to tDis
    set the left of sLabelControl2 to tNewV  - 25

    if there is no a sLineControl then
        _createTemporaryGraphic
        put the result into sLineControl
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
end mouseMove


on mouseEnter
    if the word 1 of the name of me is "button" or  the cDevDesignsTem of me is true  then exit mouseEnter
    set the width of me to 3
end mouseEnter


on mouseLeave
    local tLongId
    _deleteAllTemporaryGraphi
    if the word 1 of the name of me is "button" then exit mouseLeave
    if there is a sLabelControl then delete sLabelControl
    if there is a sDevDeleteGuide then delete sDevDeleteGuide

    set the foregroundColor of me to kGuideLineColor
    set the backColor of me to kGuideLineColor

    set the width of me to 1
    put false into sDown

    if the cDevDesignsTem of me then
        put the long id of me into tLongId
        send "deleteGuideControls tLongId" to stack "DevGuides" in 0 sec
    end if
end mouseLeave


on mouseRelease pButtonNumber
    set the foregroundColor of me to kGuideLineColor
    set the backColor of me to kGuideLineColor
    _deleteAllTemporaryGraphi
    put false into sDown
    if there is a sDevDeleteGuide then delete sDevDeleteGuide
end mouseRelease


on mouseUp pButtonNumber
    local tLongId
    
    put false into sDown
    
    set the foregroundColor of me to kGuideLineColor
    set the backColor of me to kGuideLineColor
    
    if there is a sLabelControl then delete sLabelControl
    if there is a sDevDeleteGuide then  delete sDevDeleteGuide
    _deleteAllTemporaryGraphi
    
    put the long id of me into tLongId    
    
    set the height of me to the height of this card
    set the top of me to 0
    
    if  the left of me > the right of this card or the right of me < 0 then
        send "deleteGuideControls tLongId" to stack "DevGuides" in 0 sec
    end if
    
end mouseUp

getProp cGuideLineType
    return "vertical"
end cGuideLineType

    private command _deleteAllTemporaryGraphi
    if there is a sLabelControl1 then delete sLabelControl1
    if there is a sLabelControl2 then delete sLabelControl2
    if there is a sLineControl then delete sLineControl
end _deleteAllTemporaryGraphi

private command _createTemporaryGraphic
    local tGrc
    create invisible graphic in sThisCard
    put it into tGrc
    set the cDevDesigns of tGrc to true
    set the width of tGrc to 50
    set the height of tGrc to 20
    set the textAlign of tGrc to "center"
    set the blendLevel of tGrc to 0
    set the lineSize of tGrc to 0
    set the cantSelect of tGrc to true
    set the backColor of tGrc to 0,0,255
    set the foregroundColor of tGrc to 0,0,255
    set the opaque of tGrc to false
    set the style of tGrc to "roundRect"
    set the roundRadius of tGrc to 5
    return tGrc
end _createTemporaryGraphic
