local sCache

# As the only one who moves is me. I create a cache of where are the other guide lines that are of my type
command createCache pLongId, pThisCard
    local tChilds, tType, tLongId, tRect
   
    select empty
    focus on nothing
    
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
end createCache



# Find the other guide lines that have the left, top, right, bottom closest to me
function getLimits pLimitOne, pLimitTwo, pStartOne, pStartTwo
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
end getLimits


# I create the cache here
before mouseDown pButtonNumber
    createCache the long id of me, the long id of this card
end mouseDown


function myCard pLongId
    return the word (wordOffSet("card", pLongId)) to - 1 of pLongId
end myCard
