global gDevGuideLinesArray

local sControlCachingArray, sMessageID, sNeighbors, sPrevSelectedObjects
local sGuideStatus, sGridLine
local sGridSystem, sThisCard
local sNewGuideLine


constant kColumnLineColor = "192,192,192", kNewGuideLine = 25 , kTolerance = 3

on preOpenStack
    
    revIDESubscribe "ideToolChanged"
    
    put empty into sMessageID
    deleteGuideControls
    pass preOpenStack
end preOpenStack


on closeStack
    deleteGuideControls
    pass closeStack
end closeStack


on resizeStack pNewWidth, pNewHeight, pOldWidth, pOldHeight
    _updateSizeGuideLines  pNewWidth, pNewHeight, pOldWidth, pOldHeight
    pass resizeStack
end resizeStack



on ideToolChanged
    if the tool is "pointer tool" then
        _restoreStatus 
    else
        _saveStatus   
    end if
end ideToolChanged



on mouseMove pX, pY
    local tSelectedObjects, tThisStack, tThisCard
    
    put the selectedObjects into tSelectedObjects
    put the short name of the topstack into tThisStack
    set the defaultStack to tThisStack
    put the long id of this card into tThisCard
    
    if sMessageID is an integer or word 1 of tSelectedObjects is in "stack card" or _stackNameIsIDEStack( tThisStack ) or the tool <> "pointer tool" or tThisStack <> the short name of the topStack  then 
        delete variable sControlCachingArray
        _deleteDevTempGuides
        pass mouseMove
    end if
    
    if sMessageID is a number then cancel sMessageID
    send "updateGuides  tThisCard,  pX, pY" to me in 0.1 sec
    put the result into sMessageID
end mouseMove


on updateGuides  pThisCard,  pX, pY 
    local tSelectedObjects
    # lock screen; lock messages
    put empty into sMessageID
    put the SelectedObjects into tSelectedObjects
    
    if there is a sNewGuideLine and the cDevDesignsTem of sNewGuideLine then
        delete sNewGuideLine
        put empty into sNewGuideLine
        #unlock messages; unlock screen
        exit updateGuides
    end if
    
    
    if the shiftKey is down then
        switch
            case pX <= kNewGuideLine
                _newGuideLine "left", 0, pThisCard
                put the result into sNewGuideLine
                break
                
            case pY <= kNewGuideLine
                _newGuideLine "top", 0, pThisCard
                put the result into sNewGuideLine
                break
        end switch
    end if
    
    
    if mouse( 1 ) is up and the altKey is up then
        _deleteDevTempGuides
        put empty into sGridLine
        #unlock messages; unlock screen
        exit updateGuides
    end if
    
    
    if tSelectedObjects is empty then exit updateGuides
    
    local tTergetProperty
    put _tergetProperty( pThisCard, tSelectedObjects ) into tTergetProperty
    
    _updateDevGuides pThisCard, tSelectedObjects , tTergetProperty, pX, pY
#unlock screen
end updateGuides



command deleteGuideControls pLongId
    local tChildControlIDs
    
    if there is a pLongId then
        delete pLongId
        exit deleteGuideControls
    end if
    
    put the childControlIDs of this card into tChildControlIDs
    
    repeat for each line tId in tChildControlIDs
        if the cDevDesigns of control id tId is true or the cGuideLine  of control id tId is true  then
            delete control id tId
        end if
    end repeat
    
end deleteGuideControls



private command _updateDevGuides pLongIdCd, tSelectedObjects , tTergetProperty, pX, pY
    local tChildControlIDs, tLongId, tLoc, tX, tY,  tValue, tDevGravity
    local tVerticalPoint1, tVerticalPoint2, tVerticalPoint3
    local tHorizontalPoint1, tHorizontalPoint2, tHorizontalPoint3
    local tWidthCard, tHeightCard
    local tGuideLine
    
    
    put the childControlIDs of pLongIdCd into tChildControlIDs
    put the width of pLongIdCd into tWidthCard
    put the height of pLongIdCd into tHeightCard
    
    put empty into tVerticalPoint1
    put empty into tVerticalPoint2
    put empty into tVerticalPoint3
    
    put false into tVerticalPoint1[ "create" ]
    put false into tVerticalPoint2[ "create" ]
    put false into tVerticalPoint3[ "create" ]
    
    put tTergetProperty[ "top" ]  into tVerticalPoint1[ "min" ]
    put tTergetProperty[ "bottom" ]  into tVerticalPoint1[ "max" ]
    put 0 into tVerticalPoint1[ "limitUp" ]
    put tHeightCard into tVerticalPoint1[ "limitDown" ]
    put false into tVerticalPoint1[ "drawLimitUp" ]
    put false into tVerticalPoint1[ "drawLimitDown" ]
    
    --------------------------------------------------------------
    -- Calc 
    repeat for each line tId in tChildControlIDs
        put the long id of control id tId of pLongIdCd into tLongID
        
        -- Ignora a los objetos seleccionados.
        if the visible of tLongID is false or tTergetProperty["ignore"][tLongID] is true  then  next repeat
        
        -- Elimina los posibles residuos de DevGuides
        if the cTemporaryGraphic of tLongId is true then
            delete tLongId
            next repeat
        end if
        
        put  the cGuideLine of tLongId into tGuideLine 
        
        # the loc of this control
        put the loc of tLongId into tLoc
        
        # Gravity
        if  tGuideLine is true then
            put 5 into tDevGravity
        else
            put 2 into tDevGravity
        end if
        
        put tDevGravity into tVerticalPoint1["distance"]
        put tDevGravity into tVerticalPoint2["distance"]
        put tDevGravity into tVerticalPoint3["distance"]
        
        ---> Vertical guides <---
        # Left
        _calcGuideLineProp  "left", "right", "top", "bottom", "min", "max",1, tTergetProperty, tLongId, tLoc, tVerticalPoint1, tGuideLine
        
        # X
        #_calcGuideLineProp  "left", "right", "top", "bottom", "min", "max", 1, tTergetProperty, tLongId, tLoc, tVerticalPoint2, tGuideLine
        
        # right
        #_calcGuideLineProp  "left", "right", "top", "bottom", "min", "max", 1, tTergetProperty, tLongId, tLoc, tVerticalPoint3, tGuideLine
        
    end repeat
    
    
    -- Incluir el calculo con respecto a la targeta aqui
    --    tVerticalPoint3, tVerticalPoint3,tVerticalPoint3,...
    
    -- Show guide lines
    -- Busco la distancia dentro de los tres PV. Luego si y solo si el valor minimo es el de la distancia del PV y esta en true lo de dibujar
    -- Dibujo la linea
    
    
    if tVerticalPoint1[ "create" ] is true then
        _drawVerticalGuide tVerticalPoint1, tTergetProperty    --> Guia de todoos los controles
        
        put JSONStringify(tVerticalPoint1, , true)
    else
        put empty
    end if
    
    
    if the num of lines of tSelectedObjects is no 1 then exit _updateDevGuides ---> Borrar
    -- TODO: HACER PARA multiples objetos
    if tVerticalPoint1["hook-left"] is an integer then set the left of tSelectedObjects to tVerticalPoint1["hook-left"]
    
    -- Fijar a el o los objs selccionados. Con la diferencia recorer y sumarcelo a cada lado que tenga guia
    
end _updateDevGuides



private command _drawVerticalGuide @pVerticalPoint, pTergetProperty
    local tLongId, tLoc
    
    put pVerticalPoint["max"] - pVerticalPoint["min"] into pVerticalPoint["size"]
    put _createTemporaryGraphic() into tLongId
    set the height of tLongId to pVerticalPoint["size"]
    set the top of tLongId to pVerticalPoint["min"]
    set the left of tLongId to pVerticalPoint["hook-left"]
    set the backColor of tLongId to "255,0,255"    
    set the foregroundColor of tLongId to "255,0,255"    
    set the visible of tLongId to true
    
    
    if  pVerticalPoint[ "drawLimitUp" ] is true then
        # Back of label 1
        put pTergetProperty["top"] - pVerticalPoint[ "LimitUp" ] into pVerticalPoint[ "sizeLimitUp" ]
        put (pTergetProperty[ "top" ] - pVerticalPoint["min"])  into pVerticalPoint[ "label-1" ]
        put _createTemporaryGraphic() into tLongId
        set the height of tLongId to pVerticalPoint["sizeLimitUp"]
        set the top of tLongId to pVerticalPoint["LimitUp"]
        set the left of tLongId to pVerticalPoint["hook-left"]
        set the backColor of tLongId to  56,56,255
        set the foregroundColor of tLongId to  56,56,255
        set the visible of tLongId to true
        put the loc of tLongId into tLoc
        
        # Label 1
        put _createTemporaryGraphic() into tLongId
        set the height of tLongId to 20
        set the width of tLongId to 50
        set the backColor of tLongId to 56,56,255
        set the foregroundColor of tLongId to 56,56,255
        set the opaque of tLongId to false
        set the showName of tLongId to true
        set the label of tLongId to pVerticalPoint[ "label-1" ]
        
        if pVerticalPoint["hook-left"] < 50 then
            set the textAlign of tLongId to "left"
            add 28 to the item 1 of tLoc
        else
            subtract 28 from the item 1 of tLoc
            set the textAlign of tLongId to "right"
        end if
        
        set the loc of tLongId to tLoc
        set the visible of tLongId to true
        
    end if
end _drawVerticalGuide
    
    
private command _calcGuideLineProp pMainStart, pMainEnd, pCrossStart, pCrossEnd, pMainV, pMainV2, pItem , @pTergetProperty,  pLongId, pLoc, @pVerticalPoint1, @pGuideLine
    local tValue, tTem1, tTem2, tLimitMax, tLimitMin
    
    if the cGuideLineType of pLongId is "horizontal" and pMainStart is in "left right" then
        exit _calcGuideLineProp
    end if
    
    put _hook( pTergetProperty[ pMainStart ], the pMainStart of pLongId, the item pItem of pLoc, the pMainEnd  of pLongId, pMainV) into tValue
    
    if tValue["distance"] <= pVerticalPoint1["distance"] then
        -- Si es una linea guia no creo esto
        put pGuideLine is no true into pVerticalPoint1[ "create" ]
        
        put  pTergetProperty[ pMainStart ]  + tValue["difference"]  into pVerticalPoint1[ "hook-" & pMainStart ]
        put tValue["distance"] into pVerticalPoint1["distance"] 
        
        if  pVerticalPoint1[ "create" ] is false then exit _calcGuideLineProp
        -----------------------------------------------
        put the pCrossStart of pLongId into tTem1
        if pVerticalPoint1[ "min" ] > tTem1 then
            put tTem1 into pVerticalPoint1[ "min" ]
        end if
        ---
        put the pCrossEnd of pLongId into tTem2
        if pVerticalPoint1[ "max" ] < tTem2 then
            put tTem2 into pVerticalPoint1[ "max" ] 
        end if
        ---------------------------------------------
        
        put max( tTem1, tTem2) into tLimitMax
        put min( tTem1, tTem2) into tLimitMin
        
        # Limit Up
        if tLimitMax > pVerticalPoint1[ "limitUp" ] and tLimitMax < pTergetProperty[pCrossStart] then
            put tLimitMax into pVerticalPoint1[ "limitUp" ]
            put true into pVerticalPoint1[ "drawLimitUp" ]
            
        else  if tLimitMin > pVerticalPoint1[ "limitUp" ] and tLimitMin < pTergetProperty[pCrossStart] then
            put tLimitMin into pVerticalPoint1[ "limitUp" ]
            put true into pVerticalPoint1[ "drawLimitUp" ]
            
        end if
        
        
        # Limit Down
        if tLimitMin < pVerticalPoint1[ "limitDown" ] and tLimitMin > pTergetProperty[pCrossEnd] then
            put tLimitMin into pVerticalPoint1[ "limitDown" ]
            put true into pVerticalPoint1[ "drawLimitDown" ]
            
        else  if tLimitMax < pVerticalPoint1[ "limitDown" ] and tLimitMax > pTergetProperty[pCrossEnd] then
            put tLimitMax into pVerticalPoint1[ "limitDown" ]
            put true into pVerticalPoint1[ "drawLimitDown" ]
            
        end if
        
        
    end if
    
end _calcGuideLineProp


private command _toHook pControls, pProp, pDiff
    -- Left actual - left del objeto = dfO
    -- new left + dfO
    
    
    --    if pDiff is no an integer or pDiff is 0 then exit _toHook
    
    --    repeat for each line tControl in pControls
    --        set the pProp of tControl to (the pProp of tControl - pDiff)
    --    end repeat
end _toHook


private function _hook pCurrentValue, pPoint1, pPoint2, pPoint3, pMinOrMax
    local tDis1, tDis2, tDis3 , tDifference1, tDifference2, tDifference3, tValue
    
    put pCurrentValue - pPoint1 into tDifference1
    put pCurrentValue - pPoint2 into tDifference2
    put pCurrentValue - pPoint3 into tDifference3
    
    put abs(tDifference1 ) into tDis1
    put abs(tDifference2) into tDis2
    put abs(tDifference3) into tDis3
    
    if pMinOrMax is "max" then
        put  max( tDis1, tDis2, tDis3) into tValue
    else
        put  min( tDis1, tDis2, tDis3) into tValue
    end if
    
    switch tValue
        case tDis1
            put pPoint1 into tValue["value"]
            put tDis1 into tValue["distance"]
            put tDifference1 * -1 into tValue["difference"]
            break
            
        case tDis2
            put pPoint2 into tValue["value"]
            put tDis2 into tValue["distance"]     
            put tDifference2* -1 into tValue["difference"]      
            break
            
        case tDis3
            put pPoint3 into tValue["value"]
            put tDis3 into tValue["distance"]
            put tDifference3 * -1 into tValue["difference"]
            break
            
    end switch
    
    return tValue
end _hook






private command _saveStatus
    local tLongID, tChildControlIDs
    lock screen; lock messages
    
    put the long id of this card into tLongID
    
    put the childControlIDs of  tLongID into tChildControlIDs
    put tLongID into sGuideStatus["card"]
    
    repeat for each line tId in tChildControlIDs
        put the long id of control id tId into tLongID
        
        if the cDevDesigns of tLongID is true and the cTemporaryGraphic  of tLongID is no true  then
            put the properties of tLongID into sGuideStatus["controls"][ tLongID ]
            delete control id tId
        end if
    end repeat 
    unlock screen; unlock messages
end _saveStatus


private command _restoreStatus
    local tLongID, tChildControlIDs
    
    lock screen; lock messages
    
    put the long id of this card into tLongID
    put the childControlIDs of  tLongID into tChildControlIDs
    
    if tLongID is no sGuideStatus["card"] then exit _restoreStatus
    
    repeat for each element tControl in sGuideStatus["controls"]
        if there is a graphic id tControl["id"] of sGuideStatus["card"] then next repeat
        
        create invisible graphic in sGuideStatus["card"]
        put it into tLongID
        
        set the properties of tLongID to tControl
        set the cDevDesigns of tLongID to true
    end repeat
    
    put empty into sGuideStatus
    
    unlock screen; unlock messages
end _restoreStatus



private function _mouseControl
    local tMouseControl
    
    put the mouseControl into tMouseControl
    if there is not a tMouseControl then return empty
    return _biggestOwner( the long id of tMouseControl )
end _mouseControl


private function _tergetProperty pThisCard, pControls
    local tLongId, tLeft, tTop, tRight, tBottom, tX, tY, tResult, tOwner
    
    put the right of pThisCard into tLeft
    put the bottom of pThisCard into tTop
    put the left of pThisCard into tRight
    put the top of pThisCard into tBottom
    
    repeat for each line tControl in pControls
        
        # calc the Left of rectangle
        if the left of tControl < tLeft then
            put the left of tControl into tLeft
        end if
        
        # calc the top of rectangle
        if the top of tControl < tTop then
            put the top of tControl into tTop
        end if
        
        # calc the right of rectangle
        if the right of tControl > tRight then
            put the right of tControl into tRight
        end if
        
        # calc the bottom of rectangle
        if the bottom of tControl > tBottom then
            put the bottom of tControl into tBottom
        end if
        
        -- Para ignorar los objetos seleccionados a la hora de calcular.
        -- Ojo si tengo un objeto que este dentro de un grupo se ignora el grupo entero
        put _biggestOwner(tControl) into tOwner
        
        if word 1 of tOwner is not "card" then
            //TODO: Poner una bandera que muestre un cartelito que diga que seleciono un objeto que esta dento de un grupo...
            --- DevGuides usar al grupo como referencia y no a sus hijos....
            put true into tResult["ignore"][tOwner]
        else
            put true into tResult["ignore"][tControl]
        end if
        
    end repeat
    
    put trunc( tLeft + (tRight - tLeft)/ 2 ) into tX
    put trunc( tTop + (tBottom - tTop)/2 ) into tY
    
    put tLeft into tResult["left"]
    put tTop into tResult["top"]
    put tRight into tResult["right"]
    put tBottom into tResult["bottom"]
    put tX into tResult["x"]
    put tY into tResult["y"]
    
    return tResult
end _tergetProperty


private function _biggestOwner pLongId
    local tOffset, tOwner
    
    put wordOffSet("card", pLongId)   into tOffset
    
    if tOffset is 5 then --> El duenno es la targeta
        return the word 5 to - 1 of pLongId
    else
        return the word tOffset - 4 to - 1 of pLongId
    end if
end _biggestOwner


private function _myCard pLongId
    return the word (wordOffSet("card", pLongId)) to - 1 of pLongId
end _myCard





private function _stackNameIsIDEStack pStackName
    if there is no a stack pStackName  then return false
    return  the _ideoverride of stack pStackName or pStackName begins with "rev"or pStackName is among the items of "message box,answer dialog,ask dialog,home" or pStackName begins with "com.livecode."
end _stackNameIsIDEStack


private command _deleteDevTempGuides
    local tChildControlIDs, tLongId
    put the childControlIDs of this card into tChildControlIDs
    
    repeat for each line tId in tChildControlIDs
        put the long id of control id tId into tLongId
        if word 1 of tLongId is "graphic" and the cDevDesigns of tLongId and the cTemporaryGraphic of tLongId then
            try
                delete control id tId
            end try
        end if
    end repeat
end _deleteDevTempGuides


private command _newGuideLine pProperty, pValue, pThisCard
    local tWidthCd, tHeightCd, tLongId
    
    put the width of pThisCard into tWidthCd
    put the height of pThisCard into tHeightCd
    
    create  grc "guide-line" in pThisCard
    put it into tLongId
    
    set the lineSize of tLongId to 0
    set the backColor of tLongId to "170,170,170"
    set the blendLevel of tLongId to 50
    set the bottomRight of tLongId to 0,0
    set the opaque of tLongId to true
    set the layerMode of tLongId to "dynamic"
    set the cDevDesigns of tLongId to true
    set the cDevDesignsTem of tLongId to true
    
    set the cantSelect of tLongId to true
    
    switch pProperty
        case "left"
            set the width of tLongId to  kNewGuideLine
            set the height of tLongId to tWidthCd
            set the topLeft of tLongId to 0,0
            set the behavior of tLongId to _newGuideLineBehavior("v")            
            break
            
        case "top"
            set the width of tLongId to tWidthCd
            set the height of tLongId to kNewGuideLine
            set the topLeft of tLongId to 0,0
            set the behavior of tLongId to _newGuideLineBehavior("h")
            set the cGuideLineType  of tLongId to "horizontal"
            break
    end switch
    
    show tLongId
    return tLongId
end _newGuideLine


private function _newGuideLineBehavior pType
    if pType is "v" then
        return the long id of button "bVerticalGuideLine" of me
    else if pType is "h" then
        return the long id of button "bHorizontalGuideLine" of me
    end if
end _newGuideLineBehavior


private command _updateSizeGuideLines  pNewWidth, pNewHeight, pOldWidth, pOldHeight
    local tChildControlIDs
    
    put the childControlIDs of this card into tChildControlIDs
    
    repeat for each line tId in tChildControlIDs
        
        if the cGuideLineType  of control id tId is "horizontal"  then
            set the width  of control id tId to pNewWidth
            set the left  of control id tId to 0
            
        else if  the cGuideLineType  of control id tId is "vertical"  then
            set the height  of control id tId to pNewHeight
            set the top  of control id tId to 0
            
        end if
    end repeat
    
end _updateSizeGuideLines



private function _createTemporaryGraphic
    local tGrc
    lock messages
    reset the templateGraphic
    create invisible graphic in this card
    put it into tGrc
    
    set the cDevDesigns of tGrc to true
    set the cTemporaryGraphic of tGrc to true
    set the width of tGrc to 1
    set the height of tGrc to 1
    set the textAlign of tGrc to "center"
    set the blendLevel of tGrc to 0
    set the lineSize of tGrc to 0
    set the cantSelect of tGrc to true
    set the opaque of tGrc to true
    set the margins of tGrc to 0
    unlock messages
    return tGrc
end _createTemporaryGraphic
