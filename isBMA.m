function isit = isBMA(bmao,silent)

    if nargin<2; silent=true; end;
    errmsg1='provided argument must be ''bma'' structure as resulting from function ''bms''';
    
    
    if ~isstruct(bmao); 
        isit=false;
        if not(silent); error(errmsg1); end
        return;
    end;
    if ~isfield(bmao,'suffix'); 
        isit=false;
        if not(silent); error(errmsg1); end
        return;
    end;
    
    isit=isBMSopen(silent);
    if not(isit); return; end;
     evalinR(['bmstmp = is.bma_matlab(''bma', bmao.suffix, ''')']);
     isit = getRdata('bmstmp');
    
    if not(isit) & not(silent)
        error(['bma object ''bma', bmao.siuffix, ''' does not exist in R workspace']);
    end
    
    