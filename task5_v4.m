scan_image_in_sections('飞行器视觉汇报课题20241020.jpg');

function scan_image_in_sections(imageFile)
    % 读取图像
    img = imread(imageFile);
    [height, width, ~] = size(img);

    % 确认图像宽度符合要求
%     if width ~= 725
%         error('图像宽度必须为725像素。');
%     end

    % 设置颜色阈值
    redThreshold = [100, 80, 80];
    greenThreshold = [80, 100, 80];
    blueThreshold = [80, 80, 90];

    % 定义分段的宽度范围
    sections = [0, ceil(width/6); 
                ceil(width/6)+1, ceil(width*2/6); 
                ceil(width*2/6)+1, ceil(width*3/6);
                ceil(width*3/6)+1, ceil(width*4/6);
                ceil(width*4/6)+1, ceil(width*5/6);
                ceil(width*5/6)+1, width-1];
    targetHeight = 1107; % 指定补齐的目标高度

    % 初始化扫描结果图像
    scannedSections = [];

    % 循环遍历每个分段
    for i = 1:size(sections, 1)
        % 获取当前分段的宽度范围
        colStart = sections(i, 1) + 1; % MATLAB索引从1开始
        colEnd = sections(i, 2) + 1;

        % 初始化停止行
        stopRow = height;

        % 扫描当前分段的图像
        for row = 1:height
            for col = colStart:colEnd
                pixel = squeeze(img(row, col, :));

                % 检测红色、绿色或蓝色
                if (pixel(1) >= redThreshold(1) && pixel(2) <= redThreshold(2) && pixel(3) <= redThreshold(3)) || ...
                   (pixel(1) <= greenThreshold(1) && pixel(2) >= greenThreshold(2) && pixel(3) <= greenThreshold(3)) || ...
                   (pixel(1) <= blueThreshold(1) && pixel(2) <= blueThreshold(2) && pixel(3) >= blueThreshold(3))
                    stopRow = row;
                    break; % 退出循环
                end
            end
            if stopRow ~= height
                break; % 找到颜色，跳出行循环
            end
        end

        % 提取扫描过的部分图像并补齐高度
        scannedImagePart = img(1:stopRow, colStart:colEnd, :);

        % 如果扫描到的部分不足1107行，进行补齐
        if stopRow < targetHeight
            % 创建补齐部分的黑色背景
            padding = uint8(255 * ones(targetHeight - stopRow, colEnd - colStart + 1, 3));
            % 在图像下方补齐到目标高度
            scannedImagePart = [scannedImagePart; padding];
        end

        % 合并扫描部分到最终图像中
        if isempty(scannedSections)
            scannedSections = scannedImagePart;
        else
            % 左右合并
            scannedSections = [scannedSections, scannedImagePart];
        end
    end

    % 显示和保存最终合并图像
    figure;
    imshow(scannedSections);
    title('Scanned Portions of Image in Sections with Padding');

    outputFileName = 'scanned_sections_padded.png';
    imwrite(scannedSections, outputFileName);
    disp('扫描完成，已保存为：scanned_sections_padded.png');
end
