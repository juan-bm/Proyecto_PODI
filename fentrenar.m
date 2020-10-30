t1=[1 1 1 1 1 2 2 2 2 2]; %vector de resultados
%t2=[1 1 1 1 1 2 2 2 2 2]; %vector de resultados
ext1=[0 0 0 0; max(c1')]'; %para los max y min
%ext2=[0 0 0; max(c2')]'; %para los max y min
redDIF = newff(ext1,[8 15 1],{'logsig' 'tansig' 'purelin'});
redDIF.trainParam.epochs = 500;
redDIF.trainParam.goal=0.1;
redDIFBrain = train(redDIF,c1,t1);

%redDIF2 = newff(ext2,[8 15 1],{'logsig' 'tansig' 'purelin'});
%redDIF2.trainParam.epochs = 500;
%redDIF2.trainParam.goal=0.1;
%redDIFBone = train(redDIF2,c2,t2);
