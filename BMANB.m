% BMA-NB Algorithm
clear all
warning off

rng('default');

% Number of sub-sampling
NumConjuntos=100;

% Number of iterations in each sub-sampling
NumRepeticiones=2;

% Name of Excel Data File
DatosCrudos=xlsread('Africa.xlsx');

NumClases=2;
MediasMatricesConfusionVal=zeros(NumClases,NumClases,NumConjuntos);
MediasAciertosVal=zeros(NumConjuntos,1);
MediasMatricesConfusionTest=zeros(NumClases,NumClases,NumConjuntos);
MediasAciertosTest=zeros(NumConjuntos,1);
RasgosElegidos=cell(NumConjuntos,2);

PermConjuntosRasgos=randperm(2^18);


% Bayesian Model Averaging (based on the work of Feldkircher and Zeugner (2010))

libraryBMS;

mm=bms(xlsread, 3000, 5000);
coef_bma(mm,'',false);
pmp_bma(mm,1:10);
ll=density_bma(mm,1);
help saveRworkspace
closeBMS;

% Naive Bayes
for NdxConjunto=1:NumConjuntos
    NdxConjunto
    ConjuntoRasgosElegido=PermConjuntosRasgos(NdxConjunto);
    VectorBinario=de2bi(ConjuntoRasgosElegido-1,18)==1;
    MisRasgosElegidos=1+find(VectorBinario);
    X=DatosCrudos(:,MisRasgosElegidos);
    Y=DatosCrudos(:,1);
    RasgosElegidos{NdxConjunto}=MisRasgosElegidos;  
    
    try       
        MatricesConfusionTest=zeros(NumClases,NumClases,NumRepeticiones);
        AciertosTest=zeros(1,NumRepeticiones);
        MatricesConfusionVal=zeros(NumClases,NumClases,NumRepeticiones);
        AciertosVal=zeros(1,NumRepeticiones);        
        
        for NdxRepeticion=1:NumRepeticiones
         
            VectAleatorio=rand(1,numel(Y));
            EntrenaIndices=find(VectAleatorio<0.8);
            ValIndices=find((VectAleatorio>=0.8) & (VectAleatorio<0.9));
            TestIndices=find(VectAleatorio>=0.9);
            O1=NaiveBayes.fit(X(EntrenaIndices,:),Y(EntrenaIndices));
            C1val=O1.predict(X(ValIndices,:));
            C1test=O1.predict(X(TestIndices,:));
            MiMatrizConfusionVal=confusionmat(Y(ValIndices,:),C1val);
            MatricesConfusionVal(:,:,NdxRepeticion)=MiMatrizConfusionVal;
            AciertosVal(NdxRepeticion)=sum(diag(MiMatrizConfusionVal))/sum(MiMatrizConfusionVal(:));            
            MiMatrizConfusionTest=confusionmat(Y(TestIndices,:),C1test);
            MatricesConfusionTest(:,:,NdxRepeticion)=MiMatrizConfusionTest;
            AciertosTest(NdxRepeticion)=sum(diag(MiMatrizConfusionTest))/sum(MiMatrizConfusionTest(:));
        end

        MediasMatricesConfusionVal(:,:,NdxConjunto)=squeeze(mean(MatricesConfusionVal,3));
        MediasAciertosVal(NdxConjunto)=mean(AciertosVal);        
        MediasMatricesConfusionTest(:,:,NdxConjunto)=squeeze(mean(MatricesConfusionTest,3));
        MediasAciertosTest(NdxConjunto)=mean(AciertosTest);
    catch MiExcepcion
        fprintf('Imposible to classify with the set of features=\r\n');
        disp(MiExcepcion.message);
        disp(MisRasgosElegidos);
    end
    
    save('ResultsNaive.mat','TraitsChosen','AveragesMatricesConfusionVal','StockingsRightsVal',...
        'StockingsMatricesConfusionTest','StockingsHitsTest','PermTraitsSets');

end

save('ResultsNaive.mat','TraitsChosen','AveragesMatricesConfusionVal','StockingsRightsVal',...
    'StockingsMatricesConfusionTest','StockingsHitsTest','PermTraitsSets');
    
[MaxAciertosVal NdxMaxAciertosVal]=max(MediasAciertosVal)
MediasAciertosTest(NdxMaxAciertosVal)
disp('Most Significant Set of Features:')
RasgosElegidos{NdxMaxAciertosVal}

NumeroVariablesIndependientes=21; % Number of independent variables
VectoresBinarios=de2bi(PermConjuntosRasgos(1:NumConjuntos)-1,NumeroVariablesIndependientes);
Correlacion=zeros(1,NumeroVariablesIndependientes);
for NdxVar=1:NumeroVariablesIndependientes
    MyCorr=corr([VectoresBinarios(:,NdxVar) MediasAciertosVal]);
    Correlacion(NdxVar)=MyCorr(4);
end
disp('Correlation between using or not each independent variable and the percentage of correct answers:')
Correlacion