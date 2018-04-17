NPL.load("(gl)script/ide/System/os/run.lua");
NPL.load('common');

local child_process = {
};


child_process.exec = function(command, callbackFun)
    if(command ~= nil and command ~= '') then
        System.os.runAsync(command, function(err, result)
            callbackFun(result);
        end);
    else
        callbackFun(nil);
    end;
end;


return child_process;