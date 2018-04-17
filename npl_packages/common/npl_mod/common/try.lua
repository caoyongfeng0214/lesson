_G.try = function(fn, successFn, errorFn)
    local state, result = pcall(fn);
    if(state) then
        successFn(result);
    else
        errorFn(result);
    end
end;


return try;