%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% eXFoil
% Copyright (C) 2020 - Dilesh Vallabh - All Rights Reserved
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;

%% INPUT

Re=500000;
M=0; %0.6628;

profileNaca=true;
aerofoil='64A212';

if (profileNaca==false)
    aerofoil='Custom';
    coordX=[1,0.5,0,0.5,1];
    coordY=[0,0.02,0,-0.02,0];
end

points=500;
iter=100;
visc=false;
alphaMin=-2;
alphaMax=20;
alphaStep=0.1;
plotDragPolar=false;
saveAerofoilCoordinates=true;
saveAerofoilReport=false;
saveDataDAT=false;
coordinateSpacingMethod='Cosine';

%% Aerofoil processing
if (profileNaca==true)
    length=size(aerofoil,2);
    
    switch (length)
        case 4
            series='4';
        case 5
            series='5';
        case 6
            temp=(aerofoil(1:3)=='16-');
            if (all(temp==1))
                series='16';
            else
                series='6';
            end
        otherwise
            disp('Enter a NACA 4, 5, or 6 series aerofoil.');
    end
else
    series='Custom';
end

mkdir 'COORDINATES';

switch (series)
    case '16'
        [xu,yu,xl,yl,xc,yc]=GenerateNACASeries16Airfoil(aerofoil(aerofoil~='-'),points,coordinateSpacingMethod);
        
        x=[flip(xu);xl(2:end,:)];
        y=[flip(yu);yl(2:end,:)];
        
        figure
        hold on;
        plot(x,y,'k');
        plot(xc,yc,'k:');
        axis equal;
        hold off;
        
        headings={'x','y'};
        
        coordFile=join(['./COORDINATES/',aerofoil '_Coordinates.dat']);
        
        output=array2table([x,y],'VariableNames',headings);
        writetable(output,coordFile); % Save results as .csv file.
        initialCMD=['load\n',coordFile,'\n','NAME','\n','NACA ',aerofoil,'\n'];
    case '6'
        [xu,yu,xl,yl,xc,yc]=GenerateNACASeries6Airfoil(aerofoil,points,coordinateSpacingMethod);
        
        x=[flip(xu);xl(2:end,:)];
        y=[flip(yu);yl(2:end,:)];
        
        figure
        hold on;
        plot(x,y,'k');
        plot(xc,yc,'k:');
        axis equal;
        hold off;
        
        headings={'x','y'};
        
        coordFile=join(['./COORDINATES/',aerofoil '_Coordinates.dat']);
        
        output=array2table([x,y],'VariableNames',headings);
        writetable(output,coordFile); % Save results as .csv file.
        initialCMD=['load\n',coordFile,'\n','NAME','\n','NACA ',aerofoil,'\n'];
    case '5'
        initialCMD=['naca ',aerofoil];
        
        [xu,yu,xl,yl,xc,yc]=GenerateNACASeries5Airfoil(aerofoil,points,coordinateSpacingMethod);
        
        x=[flip(xu);xl(2:end,:)];
        y=[flip(yu);yl(2:end,:)];
        
        figure
        hold on;
        plot(x,y,'k');
        plot(xc,yc,'k:');
        axis equal;
        hold off;
        headings={'x','y'};
        
        coordFile=join(['./COORDINATES/',aerofoil '_Coordinates.dat']);
        
        output=array2table([x,y],'VariableNames',headings);
        writetable(output,coordFile); % Save results as .csv file.
    case '4'
        initialCMD=['naca ',aerofoil];
        [xu,yu,xl,yl,xc,yc]=GenerateNACASeries4Airfoil(aerofoil,points,coordinateSpacingMethod);
        
        x=[flip(xu);xl(2:end,:)];
        y=[flip(yu);yl(2:end,:)];
        
        figure
        hold on;
        plot(x,y,'k');
        plot(xc,yc,'k:');
        axis equal;
        hold off;
        headings={'x','y'};
        
        coordFile=join(['./COORDINATES/',aerofoil '_Coordinates.dat']);
        
        output=array2table([x,y],'VariableNames',headings);
        writetable(output,coordFile); % Save results as .csv file.
    case 'Custom'
        sizeXY=ceil((size(coordX,2))/2);
        xq=linspace(0,1,points);
        
        xu=coordX(1:sizeXY);
        xl=coordX(sizeXY:end);
        yu=interp1(xu,coordY(1:sizeXY),flip(xq));
        yl=interp1(xu,coordY(sizeXY:end),xq);
        
        x=[flip(xq)';xq(2:end)'];
        y=[yu';yl(2:end)'];
        
        figure
        hold on;
        plot(x,y,'k');
        %plot(xc,yc,'k:');
        axis equal;
        hold off;
        
        headings={'x','y'};
        
        coordFile=join(['./COORDINATES/',aerofoil '_Coordinates.dat']);
        
        output=array2table([x,y],'VariableNames',headings);
        writetable(output,coordFile); % Save results as .csv file.
        initialCMD=['load\n',coordFile,'\n','NAME','\n','Custom ',aerofoil,'\n'];
        
    otherwise
        disp('Enter a NACA 4, 5, or 6 series aerofoil.');
end

%% Input File Synthesis

if (visc==true)    
    outputFileDAT=['NACA',aerofoil,'_VISC-Re-',num2str(Re),'_Mach-',num2str(M),'_DATA.dat'];
    outputFileReport=['NACA',aerofoil,'_VISC-Re-',num2str(Re),'_Mach-',num2str(M),'_Report.scrptm'];
else
    outputFileDAT=['NACA',aerofoil,'INVISC','_DATA.dat'];
    outputFileReport=['NACA',aerofoil,'INVISC','_Report.scrptm'];
end

warning off;
mkdir 'REPORTS';
outputFileReport=['./REPORTS/',outputFileReport];

delete(outputFileReport);

fileID = fopen('inputCMD.inp','w');

fprintf(fileID,[initialCMD,'\n']);
fprintf(fileID,'PANE\n');
fprintf(fileID,'OPER\n');
fprintf(fileID,'iter\n');
fprintf(fileID,[num2str(iter),'\n']);

if (visc==true)    
    fprintf(fileID,'VISC\n');
    fprintf(fileID,[num2str(Re),'\n']);
    fprintf(fileID,['M\n',num2str(M),'\n']);
else
    fprintf(fileID,['M\n',num2str(M),'\n']);
end

fprintf(fileID,'SEQP\n');
fprintf(fileID,['PACC\n',outputFileReport,'\n']);
fprintf(fileID,'\n');
fprintf(fileID,['aseq\n',num2str(alphaMin),'\n',num2str(alphaMax),'\n',num2str(alphaStep),'\n']);
fprintf(fileID,['PSOR 0\n','PLIS\n']);
fprintf(fileID,['0\n\n']);

fclose(fileID);

%% XFOIL execution

cmd='xfoil.exe < inputCMD.inp';
system(cmd);

%% Read Output
clc;

rawData=readtable(outputFileReport,'FileType','text');
data=table2array(rawData(5:end,1:7));
[Clmax,idx]=max(data(:,2));
[CMmax,idxM]=max(data(:,5));

headings={'Alpha [deg]' 'C_l' 'C_d' 'C_dp' 'CM' 'Top_Xtr' 'Bottom_Xtr'};
%rows=cellstr(num2str(data(:,1)));
outputTable=array2table(data(:,1:end),'VariableNames',headings);

disp(outputTable);

%% Plotting

width=15;
height=20;
figurePlotClCm=figure('Units','centimeters','Position',[0 0 width height],'PaperPositionMode','auto');
hold on;
set(gca,'Units','normalized','FontUnits','points','FontWeight','normal','FontSize',9,'FontName','Times');
ax=gca;
ax.YRuler.Exponent = 0;

t=tiledlayout(2,1);

ax1=nexttile;
%xlabel('Angle of attack, $\alpha$ [deg]','interpreter','latex');
%ylabel('$C_{l}$','interpreter','latex');
plot(data(:,1),data(:,2),'k','LineWidth',1);
title('$C_{l}$ vs $\alpha$','interpreter','latex');
%xlim([alphaMin,alphaMax*1.1]);
ylim([min(data(:,2)),Clmax*1.1]);
xline(0,'k:');

ax2=nexttile;
%xlabel('Angle of attack, $\alpha$ [deg]','interpreter','latex');
%ylabel('$C_{M}$','interpreter','latex');
plot(data(:,1),data(:,5),'k','LineWidth',1);
title('$C_{M}$ vs $\alpha$','interpreter','latex')
%xlim([alphaMin,alphaMax*1.1]);

if (CMmax<0)
    yCMlim=CMmax*0.9;
else
    yCMlim=CMmax*1.1;
end

ylim([min(data(:,5)),yCMlim]);
xline(0,'k:');

linkaxes([ax1,ax2],'x');

xlabel(t,'Angle of attack, $\alpha$ [deg]','interpreter','latex')

if (profileNaca==false)
    tempSeries='';
else
    tempSeries='NACA ';
end

if (visc==true)
    tempTitle=[tempSeries,aerofoil,'\n','Viscous Analysis','\n','$R_{e}=$',sprintf('%.3E',Re),'\n','Mach$=$',num2str(M)];
else
    tempTitle=[tempSeries,aerofoil,'\n','Inviscid Analysis'];
end

title(t,compose(tempTitle),'interpreter','latex')
hold off;

if (plotDragPolar==true)
    figurePlotClCd=figure('Units','centimeters','Position',[0 0 width height],'PaperPositionMode','auto');
    hold on;
    set(gca,'Units','normalized','FontUnits','points','FontWeight','normal','FontSize',9,'FontName','Times');
    ax=gca;
    ax.YRuler.Exponent = 0;
    
    xlabel('$C_{d}$','interpreter','latex');
    ylabel('$C_{l}$','interpreter','latex');
    plot(data(:,3),data(:,2),'k','LineWidth',1);
    title('Drag Polar','interpreter','latex');
    xlim([min(data(:,3))*0.5,max(data(:,3))*1.1]);
    ylim([min(data(:,2)),Clmax*1.1]);
    xline(0,'k:');
end

%% Misc calculations

idx0=find(data(:,1)==0);

Cla=(gradient(data(idx0:idx,2))./gradient(data(idx0:idx,1).*(pi/180)));
meanCla=mean(uniquetol(Cla((Cla-mean([Cla(1),Cla(end)]))>=0)));

summaryVariables={'C_l_max' 'C_l_alpha [/rad]'};
outputTable2=array2table([Clmax,meanCla],'VariableNames',summaryVariables);
disp(outputTable2);

%% Aerofoil coordinate & report file handling

if (saveAerofoilCoordinates==false)
    delete(coordFile);
end

if (saveAerofoilReport==false)
    delete(outputFileReport);
end

if (saveDataDAT==true)
    warning off;
    mkdir 'DATA';
    writetable(outputTable,['./DATA/',outputFileDAT]);
end

