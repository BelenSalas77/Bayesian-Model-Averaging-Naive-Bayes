function [status,msg] = closeBMS()

global RBMS_LinkHandle

if isempty(RBMS_LinkHandle)

        if nargout ==0
            error('No open R sessions to close.');
        else
            msg = 'No open R sessions to close.';
        end
else
        handle = RBMS_LinkHandle;
end

% Close the connection and free the handle.
try
    handle.Close;
    status = true;
    clear global RBMS_LinkHandle;
catch
    if nargout ==0
        error('Cannot close R session.\n%s',lasterr);
    else
        msg = lasterr;
    end

end

% delete any temporary files
if exist('bmstemp.png')
    try
        delete('bmstemp.png')
    end
end

try
    %free up the path handles
    sbmspath = BMStoolboxPath;
    rmpath(sbmspath); rmpath([sbmspath 'other/']);
end
