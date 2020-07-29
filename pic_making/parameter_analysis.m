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

data_root = './';


%% differnt noise
data_type=["joint-[0dB]","noise-babble-[0dB]","noise-buccaneer1-[0dB]","noise-factory2-[0dB]","noise-leopard-[0dB]"];

error_matrix_total=cell(data_type.size(2),4);
for ii=1:data_type.size(2)
    error_dir = [data_root,data_type(ii), '.xlsx'];
    error_path = string(join(error_dir,''));
    [~,sheet_name]=xlsfinfo(error_path);
    for k=1:numel(sheet_name)
        T=xlsread(error_path,sheet_name{k});
        error_matrix_total{ii,k}=T(:,[7,8,11]);
    end
end

raw_data=cell(5,2);
for jj=1:3
    for ii=1:data_type.size(2)
        index=1;
        for kk=[1,4]
            data_per_noise=error_matrix_total{ii,kk};
            raw_data{ii,index}=data_per_noise(:,jj);
            index=index+1;
        end
    end
   
    xlab={'Joint','Babble','Jet','Factory2','Leopard'};
    col=[102,255,255, 200;
        51,153,255, 200];
    col=col/255;
    
    multiple_boxplot(raw_data,xlab,{'Purified', 'Mixed'},col')
    
    set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
    saveas(gcf,['boxplot_noise_',int2str(jj),'.pdf'])
end