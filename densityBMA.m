function denscell = densityBMA(bmao, reg, std_coefs, n, doplot)

 is_bma(bmao,false);

  if nargin<2; reg=NaN; end; if isempty(reg); reg=NaN; end
  if nargin<3; std_coefs=NaN; end; if isempty(std_coefs); std_coefs=NaN; end
  if nargin<4; n=NaN; end; if isempty(n); n=NaN; end
  if nargin<5; doplot=NaN; end; if isempty(doplot); doplot=NaN; end
  
  if isnan(std_coefs); std_coefs=false; end;
  if isnan(n); n=300; end;
  if isnan(reg); reg=1:size(bmao.coef,1); end;
  if isnan(doplot); doplot=true; end;
   
  K=size(bmao.coef,1);
  errmsg=['reg must be vector or scalar of integers between 0 and ' num2str(K)];
  if ~isnumeric(reg); error(ermsg); end;
  reg=floor(reg);
  if any(reg<1)| any(reg>K); error(ermsg); end;
  
  try 
    std_coefs=logical(std_coefs(1));    
  catch
      error('std_coefs must be logical scalar');
  end
  
  try 
    doplot=logical(doplot(1));    
  catch
      error('doplot must be logical scalar');
  end
  
  pips=sortrows(bmao.coef,5); pips=pips(:,1);
  vblnames=c2cstr(reg);
  try
      vblnames = bmao.data.Properties.VarNames;
      vblnames = vblnames(:); vblnames=vblnames(2:end);
  end;
  
  outcell=cell(1,length(pips));  

  if (length(reg)>1) && doplot ; disp('click or press key for next density plot...'); end
  for i=reg
     outcell{i}=singledensity(bmao, i, std_coefs,n);     
     if doplot; 
         if size(outcell{i},1)==1; 
              warning(['no density plot for variable ' num2str(i) ' produced']); 
          else
             plot(outcell{i}(:,1),outcell{i}(:,2));
             
             title(['Marginal Density: Variable ''', vblnames{i},  ''' (PIP ', num2str(round(pips(i)*10000)/100), '%)']);
             xlabel('Coefficient'); ylabel('Density');
             condev=sum(outcell{i}(:,1).*outcell{i}(:,2)/sum(outcell{i}(:,2)));
              line([condev,condev],[0,outcell{i}(sum(outcell{i}(:,1)<condev)+1,2)]);
             if i~=reg(end);  waitforbuttonpress ; end
         end
     end     
    
  end
  
  if nargout>0;   denscell=outcell; end;
  
function densmat = singledensity(bmao, i, std_coefs, n)
    evalinR(['bmstmp=densitybma_single_matlab(bma' bmao.suffix ', reg=' num2str(i) ', std.coefs=' num2str(std_coefs) ', n=' num2str(n) ');']);
    densmat=getRdata('bmstmp');
    
    