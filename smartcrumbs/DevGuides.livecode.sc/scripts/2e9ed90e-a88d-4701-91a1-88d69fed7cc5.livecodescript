local sCache

# As the only one who moves is me. I create a cache of where are the other guide lines that are of my type
command createCache pLongId, pThisCard
    local tChilds, tType, tLongId, tRect
    select empty
    focus on nothing
    put the cGudeLineType of pLongId into tType
    put the childControlIDs of pThisCard into tChilds
    
    repeat for each line tControlID in tChilds
        put the long id of control id tControlID of pThisCard into tLongId
        
        if the cDevDesigns of tLongId is true and the cGudeLineType of tLongId is tType then
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
    
    repeat for each element tControlRect in sCache
        if tControlRect[ pLimitOne ] < tRect[ pLimitOne ] and tControlRect[ pLimitOne ]  > tLimitOne then
            put tControlRect[ pLimitOne ] into tLimitOne
        end if
        
        if tControlRect[ pLimitTwo ] > tRect[ pLimitTwo ] and tControlRect[ pLimitTwo ]  < tLimitTwo then
            put tControlRect[ pLimitTwo ] into tLimitTwo
        end if
    end repeat
        
    put tLimitOne into tResultArray[ 1 ]
    put tLimitTwo into tResultArray[ 2]
    return tResultArray
end getLimits


# I create the cache here
before mouseDown pButtonNumber
    createCache the long id of me, the long id of this card
end mouseDown
