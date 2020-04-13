function [bmsstatus, msg] = libraryBMS()


bmsstatus = false;
msg = '';
global RBMS_LinkHandle
openup=false;

if isempty(RBMS_LinkHandle)
    try
        RBMS_LinkHandle = actxserver('StatConnectorSrv.StatConnector');
        RBMS_LinkHandle.Init('R');
        openup=true;
    catch
        bmsstatus = false;
        RBMS_LinkHandle = [];
        if nargout <1
            error('Cannot connect to R.\n%s',lasterr);
        else
            msg = lasterr;
        end
    end
end
  

  RBMS_LinkHandle.EvaluateNoReturn('bmsloaded=require(BMS)');
  bmsstatus=RBMS_LinkHandle.GetSymbol('bmsloaded');
  
  if not(bmsstatus) 
        msg = 'BMS library seems to be not installed. Trying to install...';
        if nargout <1
            warning(msg); msg='';
        end
        RBMS_LinkHandle.EvaluateNoReturn('install.packages(''BMS'',repos=''http://cran.r-project.org'')');
        RBMS_LinkHandle.EvaluateNoReturn('bmsloaded=require(BMS)');
        bmsstatus=RBMS_LinkHandle.GetSymbol('bmsloaded');
  end
  

   if not(bmsstatus) 
        if nargout <1
            error('Cannot load BMS library');
        else
            msg = lasterr;
        end
    end

    
    
    
   if openup
        sfilepath=mfilename('fullpath');
        sfilename=mfilename;
        sfilepath=sfilepath(1:(end-length(sfilename)));
        sfilepath=strrep(sfilepath,'\','/');
        RBMS_LinkHandle.EvaluateNoReturn(['source(''', sfilepath, 'other/matlab_BMS.r'')']);
        scdpath=pwd; scdpath=strrep(scdpath,'\','/');
        RBMS_LinkHandle.EvaluateNoReturn(['setwd(''', scdpath , ''')']);
        
        addpath(sfilepath); addpath([sfilepath 'other/']);
    end