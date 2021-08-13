/*
* DevGuides
* © FerrusLogic Team
* August 2021
* version 1.0.0
*
* This code is part of DevGuides extension created by FerrusLogic team to provide design guides to
* help LiveCode developers in the process of designing graphic interfaces in an easy and modern way
*/

local sCache, sTemporaryGraphic

# As the only one who moves is me. I create a cache of where are the other guide lines that are of my type
command _createCache pLongId, pThisCard
    local tChilds, tType, tLongId, tRect
    
    put the cGuideLineType of pLongId into tType
    put the childControlIDs of pThisCard into tChilds
    
    repeat for each line tControlID in tChilds
        put the long id of control id tControlID of pThisCard into tLongId
        
        if the cDevDesigns of tLongId is true and the cGuideLineType of tLongId is tType then
            put the rect of tLongId into tRect
            split tRect by comma
            put tRect into sCache[ tLongId ]
        end if
        
    end repeat
    
    delete variable sCache[ pLongId ]
end _createCache



# Find the other guide lines that have the left, top, right, bottom closest to me
function _getLimits pLimitOne, pLimitTwo, pStartOne, pStartTwo
    local tRect, tLimitOne, tLimitTwo, tResultArray
    
    put the rect of me into tRect
    split tRect by comma
    
    put pStartOne into tLimitOne
    put pStartTwo into tLimitTwo
    
        repeat for each key tControl in sCache
            if there is no a tControl then next repeat
            
            if sCache[tControl][ pLimitOne ] < tRect[ pLimitOne ] and sCache[tControl][ pLimitOne ]  > tLimitOne then
                put sCache[tControl][ pLimitOne ] into tLimitOne
            end if
            
            if sCache[tControl][ pLimitTwo ] > tRect[ pLimitTwo ] and sCache[tControl][ pLimitTwo ]  < tLimitTwo then
                put sCache[tControl][ pLimitTwo ] into tLimitTwo
            end if
            
        end repeat
    put tLimitOne into tResultArray[ 1 ]
    put tLimitTwo into tResultArray[ 2 ]
    
    return tResultArray
end _getLimits


# I create the cache here
before mouseDown pButtonNumber
    _createCache the long id of me, the long id of this card
end mouseDown


-------------- Colors -------------------
function _backColor
    return 255,00,128
end _backColor

function _hilitedColor
    return 0,128,24
end _hilitedColor

function _labelBackColor
    return  74,74,74
end _labelBackColor

function _labelTextColor
    return  192,192,192
end _labelTextColor

function _trashIconColor
    return  74,74,74
end _trashIconColor


function _trashIconPath
    return "M12,2C17.53,2 22,6.47 22,12C22,17.53 17.53,22 12,22C6.47,22 2,17.53 2,12C2,6.47 6.47,2 12,2M17,7H14.5L13.5,6H10.5L9.5,7H7V9H17V7M9,18H15A1,1 0 0,0 16,17V10H8V17A1,1 0 0,0 9,18Z"
end _trashIconPath
    
    



command _deleteAllTemporaryGraphic
    repeat for each key k in sTemporaryGraphic
        if there is a k then delete k
    end repeat
end _deleteAllTemporaryGraphic

function _createTemporaryGraphic
    local tGrc
    lock messages
    reset the templateGraphic
    create invisible graphic in this card
    put it into tGrc
    
    set the cDevDesigns of tGrc to true
    set the width of tGrc to 50
    set the height of tGrc to 20
    set the textAlign of tGrc to "center"
    set the blendLevel of tGrc to 0
    set the lineSize of tGrc to 0
    set the cantSelect of tGrc to true
    set the backColor of tGrc to 56,56,255
    set the foregroundColor of tGrc to 56,56,255
    set the layerMode of tGrc to "dynamic"
    set the opaque of tGrc to false
    set the style of tGrc to "roundRect"
    set the roundRadius of tGrc to 5
    put tGrc into sTemporaryGraphic[ tGrc ]
    
    unlock messages
    return tGrc
end _createTemporaryGraphic


getProp cDevGravity
    answer 333
    return 7
end cDevGravity


function _myStack pLongId
    return the word (wordOffSet("stack", pLongId)) to - 1 of pLongId
end _myStack
