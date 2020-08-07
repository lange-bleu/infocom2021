% MAIN
% Version 30-Nov-2019
% Help on http://liecn.github.com
clear;
% clc;
close all;

%% Set Parameters for Loading Data
lineA=["-",":","--",'-.'];
% lineB=[left_color,"b","m","g"];
lineC=["*","s","o","^","+","s"];
lineS=["-.r","--m",":b"];

fig=figure;
set(fig,'DefaultAxesFontSize',18);
set(fig,'DefaultAxesFontWeight','bold');
%tailor the pdf
left_color = [0.929 0.262 0.564];
right_color = [0.439, 0.188, 0.627];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

set(fig,'PaperSize',[7.5 3.8]);

data_root = './pic_making/';


% %% differnt noise
% data_type=["joint-[0dB]","noise-babble-[0dB]","noise-buccaneer1-[0dB]","noise-factory2-[0dB]","noise-leopard-[0dB]"];
%
% error_matrix_total=cell(data_type.size(2),4);
% for ii=1:data_type.size(2)
%     error_dir = [data_root,data_type(ii), '.xlsx'];
%     error_path = string(join(error_dir,''));
%     [~,sheet_name]=xlsfinfo(error_path);
%     for k=1:numel(sheet_name)
%         T=xlsread(error_path,sheet_name{k});
%         error_matrix_total{ii,k}=T(:,[7,8,11]);
%     end
% end
%
% raw_data=cell(5,2);
% for jj=1:3
%     for ii=1:data_type.size(2)
%         index=1;
%         for kk=[1,4]
%             data_per_noise=error_matrix_total{ii,kk};
%             raw_data{ii,index}=data_per_noise(:,jj);
%             index=index+1;
%         end
%     end
%
%     xlab={'Joint','Babble','Jet','Factory2','Leopard'};
%     col=[102,255,255, 200;
%         51,153,255, 200];
%     col=col/255;
%
%     multiple_boxplot(raw_data,xlab,{'Purified', 'Mixed'},col')
%
%     set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
%     saveas(gcf,['boxplot_noise_',int2str(jj),'.pdf'])
% end

% %% confidence
% data_type=["confident_result_small"];
% xasix_num=5;
% error_matrix_total=cell(data_type.size(2),xasix_num);
% for ii=1:data_type.size(2)
%     error_dir = [data_root,data_type(ii), '.xlsx'];
%     error_path = string(join(error_dir,''));
%     [~,sheet_name]=xlsfinfo(error_path);
%     index=1;
%     for k=[1:5]
%         T=xlsread(error_path,sheet_name{index});
%         error_matrix_total{ii,index}=T(:,[2,3,4]);
%         index=1+index;
%     end
% end
%
% raw_data=cell(xasix_num,3);
%
% for ii=1:data_type.size(2)
%     for kk=1:xasix_num
%         data_per_noise=error_matrix_total{ii,kk};
%         for jj=1:3
%             raw_data{kk,jj}=data_per_noise(:,jj);
%         end
%     end
%
% xlab={'Joint','Conversation','Babble','Factory','Vehicle'};
% col=[102,255,255, 200;
% 51,153,255, 200;
% 0, 0, 255, 200];
% col=col/255;
%
% multiple_boxplot(raw_data,xlab,{'Our system', 'Mixed', 'voiceFilter'},col')
%
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,[data_root,'confidence.pdf'])
% end

% differnt noise
data_type=["merged-joint","merged-conv","merged-babble","merged-factory","merged-volvo"];
metric = ["WER", "SDR"];
table_num=data_type.size(2);
sheet_num=2;%item_per_xaxis_num
xaxis_num=5;
metric_num=2;
item_selection='hide_train_';

error_matrix_total=cell(table_num,sheet_num);
for ii=1:table_num
    error_dir = [data_root item_selection 'excels/',data_type(ii), '.xlsx'];
    error_path = string(join(error_dir,''));
    [~,sheet_name]=xlsfinfo(error_path);
    for k=1:sheet_num
        T=xlsread(error_path,sheet_name{k});
        error_matrix_total{ii,k}=T(:,[5,9]);
    end
end

raw_data=cell(xaxis_num,sheet_num);
for jj=1:metric_num
    for ii=1:table_num
        for kk=1:sheet_num
            data_per_noise=error_matrix_total{ii,kk};
            raw_data{ii,kk}=data_per_noise(:,jj);
        end
    end

    xlab={'Joint','Conv.','Babble','Factory','Vehicle'};
    col=[102,255,255, 200;
        51,153,255, 200];
    col=col/255;

    multiple_boxplot(raw_data,xlab,{'Our system', 'Mixed'},col')
    ylabel(metric(jj));
    if jj==1
        ylim([-1,4]);
    end
    set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
    saveas(gcf,['boxplot_benchmark_',item_selection,int2str(jj),'.png'])
end

%% correlation_matrix
% error_dir = [data_root,'matrix.mat'];
% load(error_dir);
% signal=speakers;
% colormap(jet);
% surf(1:size(signal,2),1:size(signal,1),signal(:,:));view([0,90]);
% xlim([1,size(signal,2)]);ylim([1,size(signal,1)]);
% % xlabel('Speakers'); % x label
% % ylabel('Speakers'); % y label
% xticks([5 15 25 35])
% xticklabels({'A','B','C','D'});
% yticks([5 15 25 35])
% yticklabels({'A','B','C','D'});
% colorbar; %Use colorbar only if necessary
% 
% line_x=[-5,10,20,30,45];
% line_y=[11,11,11,11,11];
% for i=1:3
%     hold on;
%     plot3(line_x,line_y+10*(i-1),ones(5,1),"k",'LineWidth',5);
% end
% for i=1:3
%     hold on;
%     plot3(line_y+10*(i-1),line_x,ones(5,1),"k",'LineWidth',5);
% end
% 
% set(gcf,'WindowStyle','normal','Position', [200,200,480,360]);
% saveas(gcf,['./fig/correlation_matrix.pdf'])