imgDataPath = 'D:/papers/infocom2021/user_case_datasets/infocom21/';
imgDataDir  = dir(imgDataPath);             % ??????
for i = 1:length(imgDataDir)
    if(isequal(imgDataDir(i).name,'.')||... % ?????????????
            isequal(imgDataDir(i).name,'..')||...
            ~imgDataDir(i).isdir)                % ???????????
        continue;
    end
    imgDirName =([imgDataPath imgDataDir(i).name]);
    imgDir=dir(imgDirName);
    for j =1:length(imgDir)                 % ??????
        if(isequal(imgDir(j).name,'.')||... % ?????????????
                isequal(imgDir(j).name,'..')||...
                ~imgDir(j).isdir)                % ???????????
            continue;
        end        
        imgSubDir =([imgDirName '/' imgDir(j).name]);
        delete([imgSubDir '/*.txt'])  
        delete([imgSubDir '/*.pt']) 
        delete([imgSubDir '/*1.wav']) 
        delete([imgSubDir '/*2.wav']) 
        delete([imgSubDir '/*3.wav']) 
        delete([imgSubDir '/*1-48k.wav']) 
        delete([imgSubDir '/*2-48k.wav']) 
        delete([imgSubDir '/*3-48k.wav']) 
    end
end