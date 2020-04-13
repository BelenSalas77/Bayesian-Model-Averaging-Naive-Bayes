function pmps = pmpBMA(bmao, index_of_models)

if nargin<2; index_of_models=NaN; end;
if isempty(index_of_models); index_of_models=NaN; end;


    isit=is_bma(bmao,false);
    evalinR(['bmstmp= pmp.bma(bma', bmao.suffix, ')']);
    pmpstemp=rcell2mat(getRdata('bmstmp'));
    if any(isnan(index_of_models));
        index_of_models=1:size(pmpstemp,1);
    end;

    pmpstemp=pmpstemp(index_of_models,:);
    
    if nargout>0;
        pmps=pmpstemp;
    else
        pmpsdisp=c2cstr(pmpstemp);
        pmpsdisp=vertcat({'PMP (Exact)', 'PMP (MCMC)' }, pmpsdisp );
        disp(Cstr2format(pmpsdisp,1,0,3));
    end