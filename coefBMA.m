function estimates=coefBMA(bmao, exact, order_by_pip, include_constant, incl_possign, std_coefs, condi_coef)

is_bma(bmao,false);
    
if nargin<2; exact=NaN; end; if isempty(exact); exact=NaN; end;
if nargin<3; order_by_pip=NaN; end; if isempty(order_by_pip); order_by_pip=NaN; end;
if nargin<4; include_constant=NaN; end; if isempty(include_constant); include_constant=NaN; end;
if nargin<5; incl_possign=NaN; end; if isempty(incl_possign); incl_possign=NaN; end;
if nargin<6; std_coefs=NaN; end; if isempty(std_coefs); std_coefs=NaN; end;    
if nargin<7; condi_coef=NaN; end; if isempty(condi_coef); condi_coef=NaN; end;        
    
exact=test4bool('exact');  
order_by_pip=test4bool('order_by_pip');  
include_constant=test4bool('include_constant');  
incl_possign=test4bool('incl_possign');  
std_coefs=test4bool('std_coefs');  
condi_coef=test4bool('condi_coef');  


coefcmd = ['bmstmp=estimates.bma(bma' bmao.suffix ];
if ~isnan(exact); coefcmd = [coefcmd ' ,exact=' num2str(exact)]; end;
if ~isnan(order_by_pip); coefcmd = [coefcmd ' ,order.by.pip=' num2str(order_by_pip)]; end;
if ~isnan(include_constant); coefcmd = [coefcmd ' ,include.constant=' num2str(include_constant)]; end;
if ~isnan(incl_possign); coefcmd = [coefcmd ' ,incl.possign=' num2str(incl_possign)]; end;
if ~isnan(std_coefs); coefcmd = [coefcmd ' ,std.coefs=' num2str(std_coefs)]; end;    
if ~isnan(condi_coef); coefcmd = [coefcmd ' ,condi.coef=' num2str(condi_coef)]; end;    
coefcmd = [coefcmd ')'];

evalinR(coefcmd);
estimates2=rcell2mat(getRdata('bmstmp'));



if nargout==0;
     lLeadBlanks=4;
     coefcontainer=c2cstr(estimates2);
     coefcontainer = vertcat({'PIP','Post Mean','Post SD','Cond.Pos.Sign','Idx'},coefcontainer); 
     coefcontainer=horzcat(bmao.data.Properties.VarNames([0;bmao.coef(:,end)]+1),coefcontainer);
     coefcontainer{1,1}='Variable';
     disp(Cstr2format(coefcontainer,4,0,lLeadBlanks,[-1;1;1;1;1;1],0));
 else
     estimates=estimates2;
 end
 
function boolout = test4bool(boolname)
    mybool=evalin('caller',boolname);
    if any(isnan(mybool))
        boolout=NaN;
        return;
    end
    try 
        boolout=logical(mybool(1)); 
    catch 
        error(['argument ''' boolname ''' must be logical']); 
    end