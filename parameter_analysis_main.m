% MAIN
% Version 30-Nov-2019
% Help on http://liecn.github.com
clear;
% clc;
close all;
%% Set Parameters for Transceivers
wave_length = 299792458 / 5.825e9;
sample_rate=1000;
n_receivers = 2;    % Receiver count
n_antennas = 3;    % Antenna count for each receiver
n_subcarriers=30;

%% Set Parameters for Data Description
total_user=12;
total_gait = 1;
total_track = 6;
total_instance = 4;

lineA=["-",":","--",'-.'];
lineB=["r","b","m","g"];
lineC=["*","s","o","^","+","s"];
lineS=["-.r","--m",":b"];
%% Set Parameters for Loading Data
data_root = 'H:\mobisys2020/';

data_type=["20191205_office","20191206_classroom","20191210_corridor"];

error_matrix_total=zeros(3,3,total_track,total_instance);
for ii=1:3
    error_dir = [data_root,'ERROR/',data_type(ii), '.mat'];
    error_path = string(join(error_dir,''));
    load(error_path);
    error_matrix_total(ii,:,:,:)=error_matrix;
end

%% user_scenarios
% user_1_1=((squeeze(error_matrix_total(2,1,:,:))));
% a=user_1_1(:);
% [prctile(a,0),prctile(a,25),prctile(a,50),prctile(a,75),prctile(a,100)]
% user_1_2=sort(mean(squeeze(error_matrix_total(3,1,:,:)),2))'
% a=user_1_2(:);
% [prctile(a,0),prctile(a,25),prctile(a,50),prctile(a,75),prctile(a,100)]
% user_6_1=mean(squeeze(error_matrix_total(1,2,:,:)),2)'
% a=user_6_1(:);
% [prctile(a,0),prctile(a,25),prctile(a,50),prctile(a,75),prctile(a,100)]
% user_6_2=mean(squeeze(error_matrix_total(2,2,:,:)),2)'
% a=user_6_2(:);
% [prctile(a,0),prctile(a,25),prctile(a,50),prctile(a,75),prctile(a,100)]
% user_8_1=mean(squeeze(error_matrix_total(2,3,:,:)),2)'
% a=user_8_1(:);
% [prctile(a,0),prctile(a,25),prctile(a,50),prctile(a,75),prctile(a,100)]
% user_8_2=mean(squeeze(error_matrix_total(3,2,:,:)),2)'
% a=user_8_2(:);
% [prctile(a,0),prctile(a,25),prctile(a,50),prctile(a,75),prctile(a,100)]

%% figures in matlab
fig=figure;
set(fig,'DefaultAxesFontSize',18);
set(fig,'DefaultAxesFontWeight','bold');
set(fig,'PaperSize',[17 10]);
maker_idx=1:10:1000;

%% column_trails
% error_dir = [data_root,'ERROR/20191124_preliminaryssd_widir.mat'];
% error_path = string(join(error_dir,''));
% load(error_path);
%
% up=[];
% down=[];
% sta_1=[];
% sta_2=[];
% for ii=1:3
%     for jj=1:4
%         if mod(jj,2)==1
%             up=[up error_matrix{ii,jj}'];
%         else
%             down=[down error_matrix{ii,jj}'];
%         end
%     end
% end
%
% for ii=[4,6,8]
%     for jj=1:4
%           if mod(jj,2)==1
%             sta_1=[sta_1 error_matrix{ii,jj}'];
%         else
%             sta_2=[sta_2 error_matrix{ii,jj}'];
%         end
%     end
% end
%
%
%
% bar_sign=zeros(4,3);
% y=(up(:));
% for ii=1:3
%     bar_sign(1,ii)=numel(find(y==ii));
% end
%
% b=(down(:));
% for ii=1:3
%     bar_sign(2,ii)=numel(find(b==ii));
% end
%
% a=(sta_1(:));
% for ii=1:3
%     bar_sign(3,ii)=numel(find(a==ii));
% end
%
% d=(sta_2(:));
% for ii=1:3
%     bar_sign(4,ii)=numel(find(d==ii));
% end
%
% b = bar(bar_sign,'FaceColor','flat');
% for k = 1:size(y,2)
%     b(k).CData = lineB(k);
% end
%
% legend(['Toward (-1)'],['Static (0)'],['Away  (+1)'])
% xlabel('Sign distribution of delay'); % x label
% xticklabels({'Path 1','Path 2','Path 3','Path 4'})
% ylabel('Sampling Points'); % y label
% xlim([0 5])
% title('')
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"D:\papers\mobisys2020\paper\figs\cdf_ssd_widir.pdf")

%% column_trails
% error_dir = [data_root,'ERROR/20191124_preliminary.mat'];
% error_path = string(join(error_dir,''));
% load(error_path);
% 
% error_matrix_angel_resolution=cell(7,1);
% 
% error_matrix_angel_resolution{1}=roundn(sort(error_matrix(1,:)),-4);
% 
% error_matrix_angel_resolution{2}=roundn(sort(error_matrix(2,:)),-4);
% 
% error_matrix_angel_resolution{3}=roundn(sort(error_matrix(3,:)),-4) ;
% 
% error_matrix_angel_resolution{4}=roundn(sort(error_matrix(4,:)),-4);
% 
% error_matrix_angel_resolution{5}=roundn(sort(error_matrix(5,:)),-4);
% 
% error_matrix_angel_resolution{6}=roundn(sort(error_matrix(6,:)),-4) ;
% error_matrix_angel_resolution{7}=roundn(sort(error_matrix(7,:)),-4);
% x = [error_matrix_angel_resolution{1}; error_matrix_angel_resolution{2}; error_matrix_angel_resolution{3};error_matrix_angel_resolution{4}; error_matrix_angel_resolution{5}; error_matrix_angel_resolution{6};error_matrix_angel_resolution{7}];
% 
% g1 = repmat({'-3'},size(error_matrix_angel_resolution{1},1),1);
% g2 = repmat({'-2'},size(error_matrix_angel_resolution{2},1),1);
% g3 = repmat({'-1'},size(error_matrix_angel_resolution{3},1),1);
% g4 = repmat({'0'},size(error_matrix_angel_resolution{4},1),1);
% g5 = repmat({'1'},size(error_matrix_angel_resolution{5},1),1);
% g6 = repmat({'2'},size(error_matrix_angel_resolution{6},1),1);
% g7 = repmat({'3'},size(error_matrix_angel_resolution{7},1),1);
% g = [g1; g2; g3;g4;g5; g6;g7];
% boxplot(x',g)
% xlabel('Horizontal shift to the perpendicular line'); % x label
% ylabel('Location Error(m)'); % y label
% title('')
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"D:\papers\mobisys2020\paper\figs\straight_trails.pdf")


%% cdf_ablation
% error_matrix_total_novoter=zeros(3,3,total_track,total_instance);
% error_matrix_total_nomodel=zeros(3,3,total_track,total_instance);
% for ii=1:3
%     error_dir = [data_root,'ERROR/',data_type(ii), 'novoter.mat'];
%     error_path = string(join(error_dir,''));
%     load(error_path);
%     error_matrix_total_novoter(ii,:,:,:)=error_matrix;
% end
% for ii=1:3
%     error_dir = [data_root,'ERROR/',data_type(ii), 'nomodel.mat'];
%     error_path = string(join(error_dir,''));
%     load(error_path);
%     error_matrix_total_nomodel(ii,:,:,:)=error_matrix;
% end
% maker_idx=1:20:500;
% y=(error_matrix_total(:));
% h=cdfplot(y(:));
% % h.LineStyle=lineA(1);
% h.Color=lineB(1);
% h.Marker=lineC(1);
% h.LineWidth=2;
% h.MarkerIndices=maker_idx;
%
% hold on
%
% b=(error_matrix_total_novoter(:));
% h=cdfplot(b(:));
% % h.LineStyle=lineA(3);
% h.Color=lineB(3);
% h.Marker=lineC(3);
% % h.LineWidth=2;
% h.MarkerIndices=maker_idx;
%
%
% a=(error_matrix_total_nomodel(:));
% h=cdfplot(a(:));
% % h.LineStyle=lineA(2);
% h.Color=lineB(2);
% h.Marker=lineC(2);
% % h.LineWidth=2;
% h.MarkerIndices=maker_idx;
% hold on;
% title('')
% legend(['WiStereo'],['wo Voting'],['wo Geometrical Model'])
% xlabel('Location Error(m)'); % x label
% ylabel('CDF'); % y label
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"D:\papers\mobisys2020\paper\figs\cdf_ablation.pdf")

%% angel_resolution
% error_matrix_angel_resolution=cell(4,1);
%
% error_matrix_angel_resolution{1}=cat(3,(error_matrix_total(3,:,[1,2,5],:)),(error_matrix_total(2,:,[1,2,3],:)),(error_matrix_total(1,:,[1,2],:)));
%
% error_matrix_angel_resolution{1}=roundn(sort(error_matrix_angel_resolution{1}(:)),-4);
%
%
% error_matrix_angel_resolution{2}=cat(3,(error_matrix_total(3,:,3,:)),(error_matrix_total(2,:,5,:)),(error_matrix_total(1,:,[3,6],:)));
%
% error_matrix_angel_resolution{2}=roundn(sort(error_matrix_angel_resolution{2}(:)),-4);
%
%
% error_matrix_angel_resolution{3}=cat(3,(error_matrix_total(3,:,[4,6],:)),(error_matrix_total(1,:,4,:)));
%
% error_matrix_angel_resolution{3}=roundn(sort(error_matrix_angel_resolution{3}(:)),-4) ;
%
%
% error_matrix_angel_resolution{4}=cat(3,(error_matrix_total(1,:,5,:)),(error_matrix_total(2,:,[4,6],:)));
%
% error_matrix_angel_resolution{4}=roundn(sort(error_matrix_angel_resolution{4}(:)),-4);
%
% x = [error_matrix_angel_resolution{1}; error_matrix_angel_resolution{2}; error_matrix_angel_resolution{3};error_matrix_angel_resolution{4}];
% g1 = repmat({'0'},size(error_matrix_angel_resolution{1},1),1);
% g2 = repmat({'1'},size(error_matrix_angel_resolution{2},1),1);
% g3 = repmat({'2'},size(error_matrix_angel_resolution{3},1),1);
% g4 = repmat({'>2'},size(error_matrix_angel_resolution{4},1),1);
% g = [g1; g2; g3;g4];
% boxplot(x,g)
% xlabel('Number of Turning Points'); % x label
% ylabel('Location Error(m)'); % y label
% title('')
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"D:\papers\mobisys2020\paper\figs\angel_resolution.pdf")


%% cdf_scenarios (cdf of errors in different sceneraios)
% for tt=1:3
%     y=squeeze(error_matrix_total(tt,:,:,:));
%     h=cdfplot(y(:));
%     %     h.LineStyle=lineA(tt);
%     h.Color=lineB(tt);
%     %     h.LineWidth=2;
%     h.Marker=lineC(tt);
%     h.MarkerIndices=maker_idx;
%     hold on
% end
% legend(['Office'],['Classroom'],['Corridor'])
% xlabel('Location Error(m)'); % x label
% ylabel('CDF'); % y label
% title('')
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"D:\papers\mobisys2020\paper\figs\cdf_scenarios.pdf")

%% duration
% error_matrix_duration=cell(5,1);
%
% error_matrix_duration{1}=cat(3,(error_matrix_total(1,:,[1,2],:)),(error_matrix_total(2,:,[1,2,3],:)));
%
%
% error_matrix_duration{1}=roundn(sort(error_matrix_duration{1}(:)),-4);
%
%
% error_matrix_duration{2}=cat(3,(error_matrix_total(1,:,3,:)),(error_matrix_total(3,:,[1,2],:)));
% error_matrix_duration{2}=roundn(sort(error_matrix_duration{2}(:)),-4);
% % cdfplot(error_matrix_duration_near);
% % cdfplot(error_matrix_duration_far);
%
% error_matrix_duration{3}=cat(3,(error_matrix_total(1,:,[4,6],:)),(error_matrix_total(3,:,[3,5],:)));
% error_matrix_duration{3}=roundn(sort(error_matrix_duration{3}(:)),-4) ;
% % cdfplot(error_matrix_duration_near);
% % cdfplot(error_matrix_duration_far);
%
% error_matrix_duration{4}=cat(3,(error_matrix_total(1,:,5,:)),(error_matrix_total(2,:,[4,5],:)));
% error_matrix_duration{4}=roundn(sort(error_matrix_duration{4}(:)),-4);
% % cdfplot(error_matrix_duration_near);
% % cdfplot(error_matrix_duration_far);
%
% error_matrix_duration{5}=cat(3,(error_matrix_total(2,:,6,:)),(error_matrix_total(3,:,[4,6],:)));
% error_matrix_duration{5}=roundn(sort(error_matrix_duration{5}(:)),-4);
% % cdfplot(error_matrix_duration_near);
% % cdfplot(error_matrix_duration_far);
%
% lineS=["-.rs","--mo",":b*"];
% x = [error_matrix_duration{1}; error_matrix_duration{2}; error_matrix_duration{3};error_matrix_duration{4};error_matrix_duration{5}];
% g1 = repmat({'<5'},size(error_matrix_duration{1},1),1);
% g2 = repmat({'5-10'},size(error_matrix_duration{2},1),1);
% g3 = repmat({'10-15'},size(error_matrix_duration{3},1),1);
% g4 = repmat({'15-20'},size(error_matrix_duration{4},1),1);
% g5 = repmat({'>20'},size(error_matrix_duration{5},1),1);
% g = [g1; g2; g3;g4;g5];
% boxplot(x,g)
% xlabel('Movement Duration(s)'); % x label
% ylabel('Location Error(m)'); % y label
% title('')
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"D:\papers\mobisys2020\paper\figs\duration.pdf")

%% near_far
% near=zeros(5,1);
% far=zeros(5,1);
%
% error_matrix_duration_near=cat(3,(error_matrix_total(1,:,[1,2],[1,3])),(error_matrix_total(2,:,[1,2,3],[1,3])));
% error_matrix_duration_far=cat(3,(error_matrix_total(1,:,[1,2],[2,4])),(error_matrix_total(2,:,[1,2,3],[2,4])));
%
% near(1)=mean(error_matrix_duration_near(:));
% far(1)=mean(error_matrix_duration_far(:));
%
%
% error_matrix_duration_near=cat(3,(error_matrix_total(1,:,3,[1,3])),(error_matrix_total(3,:,[1,2],[1,3])));
% error_matrix_duration_far=cat(3,(error_matrix_total(1,:,3,[2,4])),(error_matrix_total(3,:,[1,2],[2,4])));
% near(2)=mean(error_matrix_duration_near(:));
% far(2)=mean(error_matrix_duration_far(:));
%
% error_matrix_duration_near=cat(3,(error_matrix_total(1,:,[4,6],[1,3])),(error_matrix_total(3,:,[3,5],[1,3])));
% error_matrix_duration_far=cat(3,(error_matrix_total(1,:,[4,6],[2,4])),(error_matrix_total(3,:,[3,5],[2,4])));
% near(3)=mean(error_matrix_duration_near(:));
% far(3)=mean(error_matrix_duration_far(:));
%
% error_matrix_duration_near=cat(3,(error_matrix_total(1,:,5,[1,3])),(error_matrix_total(2,:,4,[2,4])),(error_matrix_total(2,:,5,[1,3])));
% error_matrix_duration_far=cat(3,(error_matrix_total(1,:,5,[2,4])),(error_matrix_total(2,:,4,[1,3])),(error_matrix_total(2,:,5,[2,4])));
% near(4)=mean(error_matrix_duration_near(:));
% far(4)=mean(error_matrix_duration_far(:));
%
% error_matrix_duration_near=cat(3,(error_matrix_total(2,:,6,[1,3])),(error_matrix_total(3,:,[4,6],[1,3])));
% error_matrix_duration_far=cat(3,(error_matrix_total(2,:,6,[2,4])),(error_matrix_total(3,:,[4,6],[2,4])));
% near(5)=mean(error_matrix_duration_near(:));
% far(5)=mean(error_matrix_duration_far(:));
%
% lineS=["-.rs","--mo",":b*"];
%
% plot(near,lineS(1),'LineWidth',2);
% hold on;
% plot(far,lineS(2),'LineWidth',2);
% legend(['Near Side'],['Far Side'])
% xticklabels({'<5','5-10','10-15','15-20','>20'})
% xlabel('Movement Duration(s)'); % x label
% ylabel('Location Error(m)'); % y label
% title('')
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"D:\papers\mobisys2020\paper\figs\near_far.pdf")


%% differnt person
% for ii=1:3
%     for jj=1:3
%         y=(error_matrix_total(ii,jj,:,:));
%         h=boxplot(y(:)');
% %         h.LineStyle=lineA(1);
% %         h.Color=lineB(1);
% %         h.LineWidth=2;
%         hold on
%     end
% end
% a1=squeeze(error_matrix_total(1,1,:,:));
% a1=a1(:);
% a2=squeeze(error_matrix_total(1,2,:,:));
% a2=a2(:);
% a3=squeeze(error_matrix_total(1,3,:,:));
% a3=a3(:);
% a5=squeeze(error_matrix_total(2,2,:,:));
% a5=a5(:);
% a7=squeeze(error_matrix_total(3,1,:,:));
% a7=a7(:);
% a9=squeeze(error_matrix_total(3,3,:,:));
% a9=a9(:);
% fig=figure;
% set(fig,'DefaultAxesFontSize',18);
% set(fig,'DefaultAxesFontWeight','bold');
% set(fig,'PaperSize',[17 10]);
% h=boxplot([a7,a9,a3,a5,a3,a1],'Notch','off','Labels',{'1','2','3','4','5','6'},'Whisker',1,'Colors',['b','b','b','b','r','r'])
% xlabel('Person ID'); % x label
% ylabel('Location Error(m)'); % y label
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% box_vars = findobj(gca,'Tag','Box');
% hLegend = legend(box_vars([3,2,4]), {'Male','Female'});
% % Among the children of the legend, find the line elements
% hChildren = findall(get(hLegend,'Children'), 'Type','Line');
% % Set the horizontal lines to the right colors
% set(hChildren(1),'Color',[0 0 1])
% set(hChildren(2),'Color',[1 0 0])
% saveas(gcf,"D:\papers\mobisys2020\paper\figs\boxplot_user.pdf")

%% cdf_comparison
error_matrix_widar1=zeros(3,3,total_track,total_instance);
for ii=1:3
    error_dir = [data_root,'ERROR/',data_type(ii), '_widar1.mat'];
    error_path = string(join(error_dir,''));
    disp(['loading',error_dir]);
    load(error_path);
    error_matrix_widar1(ii,:,:,:)=errors;
end

error_matrix_widar2=zeros(3,3,total_track,total_instance);
for ii=1:3
    error_dir = [data_root,'ERROR/',data_type(ii), '_widar2.mat'];
    error_path = string(join(error_dir,''));
    disp(['loading',error_dir]);
    load(error_path);
    error_matrix_widar2(ii,:,:,:)=errors;
end

error_matrix_widir=zeros(3,3,total_track,total_instance);
for ii=1:3
    error_dir = [data_root,'ERROR/',data_type(ii), 'widir.mat'];
    error_path = string(join(error_dir,''));
    disp(['loading',error_dir]);
    load(error_path);
    error_matrix_widir(ii,:,:,:)=error_matrix;
end

error_matrix_indotrack=zeros(3,3,total_track,total_instance);
for ii=1:3
    error_dir = [data_root,'ERROR/',data_type(ii), '_indotrack.mat'];
    error_path = string(join(error_dir,''));
    disp(['loading',error_dir]);
    load(error_path);
    error_matrix_indotrack(ii,:,:,:)=final_errors;
end

error_matrix_music=zeros(3,3,total_track,total_instance);
for ii=1:3
    error_dir = [data_root,'ERROR/',data_type(ii), '_music.mat'];
    error_path = string(join(error_dir,''));
    disp(['loading',error_dir]);
    load(error_path);
    error_matrix_music(ii,:,:,:)=final_errors;
end

linewidth=1;
y=(error_matrix_total(:));
h=cdfplot(y(:));
maker_idx = 1:20:500;
% h.LineStyle=lineA(1);
h.Color=lineB(1);
h.Marker=lineC(1);
h.LineWidth=linewidth;
h.MarkerIndices=maker_idx;
% h.MarkerSize=2;
hold on

b=(error_matrix_widar1(:));
inRange = b < 5;
h=cdfplot(b(inRange));
% h.LineStyle=lineA(2);
h.Color=lineB(2);
h.Marker=lineC(2);
h.MarkerIndices=maker_idx;
h.LineWidth=linewidth;
hold on

a=(error_matrix_widar2(:));
inRange = a < 6;
h=cdfplot(a(inRange));
% h.LineStyle=lineA(3);
h.Color=lineB(3);
h.Marker=lineC(3);
h.MarkerIndices=maker_idx;
h.LineWidth=linewidth;
hold on;

c=(error_matrix_widir(:));
h=cdfplot(c(:));
% h.LineStyle=lineA(4);
h.Color=lineB(4);
h.Marker=lineC(4);
h.MarkerIndices=maker_idx;
h.LineWidth=linewidth;
hold on;

d=(error_matrix_indotrack(:));
h=cdfplot(d(:));
% h.LineStyle=lineA(4);
% h.Color=lineB(4);
h.Marker=lineC(5);
h.MarkerIndices=maker_idx;
h.LineWidth=linewidth;
hold on;

e=(error_matrix_music(:));
h=cdfplot(e(:));
% h.LineStyle=lineA(4);
% h.Color=lineB(4);
h.Marker=lineC(6);
h.MarkerIndices=maker_idx;
h.LineWidth=linewidth;
hold on;

legend(['WiStereo'],['Widar'],['Widar2.0'],['WiDir'],['IndoTrack'],['Dynamic-Music'])
xlabel('Location Error(m)'); % x label
ylabel('CDF'); % y label
xlim([0 5])
title('')
set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
saveas(gcf,"D:\papers\mobisys2020\paper\figs\cdf_comparison.pdf")

