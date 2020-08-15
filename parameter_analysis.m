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


%% differnt noise
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

% %% differnt noise
% sheet_list=["focus_test_","hide_test_"];
% data_type=["merged-joint","merged-conv","merged-babble","merged-factory","merged-volvo"];
% metric = ["WER", "SDR"];
% table_num=data_type.size(2);
% sheet_num=2;%item_per_xaxis_num
% xaxis_num=5;
% metric_num=2;
%
% error_matrix_total=cell(table_num,sheet_num);
% for aa=2:sheet_num
%     item_selection=sheet_list(aa);
%     for ii=1:table_num
%         error_dir = [data_root item_selection 'excels/',data_type(ii), '.xlsx'];
%         error_path = string(join(error_dir,''));
%         [~,sheet_name]=xlsfinfo(error_path);
%         for k=1:sheet_num
%             T=xlsread(error_path,sheet_name{k});
%             error_matrix_total{ii,k}=T(:,[5,9]);
%         end
%     end
%
%     raw_data=cell(xaxis_num,sheet_num);
%     raw_data_mean=zeros(xaxis_num,sheet_num);
%     for jj=1:metric_num
%         for ii=1:table_num
%             for kk=1:sheet_num
%                 data_per_noise=error_matrix_total{ii,kk};
%                 raw_data{ii,kk}=data_per_noise(:,jj);
%             end
%         end
%
%         xlab={'Joint','Conv.','Babble','Factory','Vehicle'};
%         col=[102,255,255, 200;
%             51,153,255, 200];
%         col=col/255;
%
%         multiple_boxplot(raw_data,xlab,{'Our system', 'Mixed'},col')
%         ylabel(metric(jj));
%         if jj==1
%             ylim([-1,6]);
%         end
%         set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
%         save_path=['boxplot_benchmark_',item_selection,int2str(jj),'.png'];
%         save_path = string(join(save_path,''));
%         saveas(gcf,save_path)
%         for iii=1:xaxis_num
%             for jjj=1:sheet_num
%                 raw_data_mean(iii,jjj)=mean(raw_data{iii,jjj});
%             end
%         end
%         mean(raw_data_mean)
%     end
% end

%% user cases
% dir_list=["user_case_1_","user_case_2_"];
% data_type=["joint","babble","vehicle";"conversation","babble","vehicle"];
% x_lab_text={'Joint','Babble','Vehicle';'Conversation','Babble','Vehicle'};
% metric = ["SDR"];
% table_num=data_type.size(2);
% sheet_num=2;%item_per_xaxis_num
% xaxis_num=3;
% metric_num=1;
%
% error_matrix_total=cell(table_num,sheet_num);
%
% for aa=1:dir_list.size(2)
%     item_selection=dir_list(aa);
%     for ii=1:table_num
%         error_dir = [data_root item_selection 'excel/',data_type(aa,ii), '.xlsx'];
%         error_path = string(join(error_dir,''));
%         [~,sheet_name]=xlsfinfo(error_path);
%         for k=1:sheet_num
%             T=xlsread(error_path,sheet_name{k});
%             error_matrix_total{ii,k}=T(:,[4]);
%         end
%     end
%
%     raw_data=cell(xaxis_num,sheet_num);
%     raw_data_mean=zeros(xaxis_num,sheet_num);
%     for jj=1:metric_num
%         for ii=1:table_num
%             for kk=1:sheet_num
%                 data_per_noise=error_matrix_total{ii,kk};
%                 raw_data{ii,kk}=data_per_noise(:,jj);
%             end
%         end
%
%         xlab=x_lab_text(aa,:);
%         % xlab={'Joint','Conv.','Babble','Factory','Vehicle'};
%         col=[102,255,255, 200;
%             51,153,255, 200];
%         col=col/255;
%
%         multiple_boxplot(raw_data,xlab,{'Our system', 'Mixed'},col')
%         ylabel(metric(jj));
% %         if jj==1
% %             ylim([-1,6]);
% %         end
%         set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
%         save_path=['boxplot_',item_selection,int2str(jj),'.png'];
%         save_path = string(join(save_path,''));
%         saveas(gcf,save_path)
%         for iii=1:xaxis_num
%             for jjj=1:sheet_num
%                 data_mean=raw_data{iii,jjj};
%                 data_mean(isnan(data_mean))=[];
%                 raw_data_mean(iii,jjj)=mean(data_mean);
%             end
%         end
%         mean(raw_data_mean)
%     end
% end

%% user cases score + person diversity
% dir_list=["user_case_1_","user_case_2_"];
% x_lab_text={'Babble','Joint','Vehicle';'Babble','Conv.','Vehicle'};
% x_legend_text={'Babble-M','Babble-R','Joint-M','Joint-R','Vehicle-M','Vehicle-R';'Babble-M','Babble-R','Conv.-M','Conv.-R','Vehicle-M','Vehicle-R'};
% table_num=10;
% sheet_num=3;%item_per_xaxis_num
% xaxis_num=3;
% metric_num=1;
%
% error_matrix_total=zeros(table_num,sheet_num,2,4,10);
%
% set(fig,'defaultAxesColorOrder',[[66, 188, 245];[245, 66, 66];[66, 117, 245];[245, 105, 66];[93, 66, 245];[245, 173, 66]]./255);
% data_plot_person=zeros(4,10);
% for aa=1:dir_list.size(2)
%     item_selection=dir_list(aa);
%     for ii=1:table_num
%         error_dir = [data_root item_selection 'excel/user',int2str(ii), '.xlsx'];
%         error_path = string(join(error_dir,''));
%         [~,sheet_name]=xlsfinfo(error_path);
%         for k=1:sheet_num
%             T=xlsread(error_path,sheet_name{k});
%             error_matrix_total(ii,k,1,:,:)=T(1:2:8,1:10);
%             error_matrix_total(ii,k,2,:,:)=T(2:2:8,1:10);
%         end
%     end
%
%     data_plot_stacked=mean(error_matrix_total,[4 5]);
%     data_plot_stacked(:,:,2)=data_plot_stacked(:,:,2)-data_plot_stacked(:,:,1);
%     data_plot_person((aa-1)*2+1:aa*2,:)=squeeze(mean(error_matrix_total,[1 2 4]));
%
%     set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
%     %
%     groupLabels={'1','2','3','4','5','6','7','8','9','10'};
%     ylabel("URS");
%     xlabel("Reviewer ID");
%     ylim([1,5.5]);
%     plotBarStackGroups(data_plot_stacked,groupLabels)
%     lgd=legend(x_legend_text(aa,:),'NumColumns',3);
%     lgd.FontSize = 10;
%     save_path=['URS_',item_selection,int2str(aa),'.png'];
%     save_path = string(join(save_path,''));
%     %         saveas(gcf,save_path)
%     mean(data_plot_stacked,[1 2])
%
% end
% lineA=["-*",":s","-*",':s'];
% for kkk=1:4
%     plot(data_plot_person(kkk,:),lineA(kkk),'LineWidth',2);
%     hold on;
% end
% save_path=['person.pdf'];
% save_path = string(join(save_path,''));
% ylim([1,5]);
% xlim([1,10]);
% legend({['UC-1-M'],['UC-1-R'],['UC-2-M'],['UC-2-R']},'NumColumns',4)
% xticks(1:10)
% xlabel('Volunteer ID'); % x label
% ylabel('URS'); % y label
% title('')
% % saveas(gcf,save_path)

%% comparison SDR
dir_list=["user_case_2_"];
data_type=["comparison"];
x_lab_text={'Babble','Conv.','Vehicle'};
x_legend_text={'Ear-M','Ear-S','ANC-M','ANC-S'};
table_num=data_type.size(2);
sheet_num=3;%item_per_xaxis_num
xaxis_num=3;
metric_num=1;

error_matrix_total=zeros(table_num,10,sheet_num,2,2,4);
set(fig,'defaultAxesColorOrder',[[66, 188, 245];[245, 66, 66];[66, 117, 245];[245, 105, 66]]./255);
% set(fig,'defaultAxesColorOrder',linspecer(4));
for aa=1:dir_list.size(2)
    item_selection=dir_list(aa);
    for ii=1:table_num
        error_dir = [data_root item_selection 'excel/',data_type(aa,ii), '.xlsx'];
        error_path = string(join(error_dir,''));
        [~,sheet_name]=xlsfinfo(error_path);
        for k=1:sheet_num
            T=xlsread(error_path,sheet_name{k});
            error_matrix_total(ii,:,k,1,1,:)=T(1:4,2:11)';
            error_matrix_total(ii,:,k,1,2,:)=T(5:8,2:11)';
            error_matrix_total(ii,:,k,2,1,:)=T(9:12,2:11)';
            error_matrix_total(ii,:,k,2,2,:)=T(13:16,2:11)';
        end
    end
    
    data_plot_stacked=squeeze(mean(error_matrix_total,[3 6]));
    data_plot_stacked(:,:,2)=data_plot_stacked(:,:,2)-data_plot_stacked(:,:,1);
    set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
    
     groupLabels={'1','2','3','4','5','6','7','8','9','10'};
    ylabel("SDR");
    
    plotBarStackGroups(data_plot_stacked, groupLabels)
    legend(x_legend_text(aa,:),'NumColumns',4)
    save_path=['comparison.pdf'];
    save_path = string(join(save_path,''));
    xticks(1:10)
    xlabel('Volunteer ID'); % x label
    ylim([-35,0]);
    saveas(gcf,save_path)
    %     mean(data_plot_stacked)
    
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