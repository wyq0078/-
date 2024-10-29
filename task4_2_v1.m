img = imread('飞行器视觉汇报课题20241020.jpg'); % 替换成你的图像路径
hog_feature_with_output(img); % 计算并生成HOG特征PDF


function hog_feature_with_output(inputImage)
    % 检查输入图像是否为灰度图像
    if size(inputImage, 3) == 3
        inputImage = rgb2gray(inputImage); % 转换为灰度图像
    end
    
    % 设置HOG参数
    cellSize = [8, 8]; % 单元大小
    blockSize = [2, 2]; % 块大小
    numBins = 9; % 方向分箱数

    % 计算HOG特征和可视化
    [hogFeatures, visualization] = extractHOGFeatures(inputImage, 'CellSize', cellSize, 'BlockSize', blockSize, 'NumBins', numBins);
    
    % 将HOG特征转为文本形式
    hogTextFilename = 'hog_features.txt';
    writematrix(hogFeatures, hogTextFilename); % 将HOG特征保存为文本文件

    % 显示原始图像和HOG特征可视化图
    figure;
    subplot(1, 2, 1); imshow(inputImage); title('原始灰度图像');
    subplot(1, 2, 2); plot(visualization); title('HOG特征可视化');

    % 保存HOG可视化图像为临时文件
    hogImageFilename = 'hog_feature_image.png';
    saveas(gcf, hogImageFilename);

    % 合并图像和文本文件为PDF
    outputPDF = 'HOG_Feature_Output.pdf';
    import mlreportgen.report.*
    import mlreportgen.dom.*

    % 创建PDF报告
    report = Report(outputPDF, 'pdf');
    add(report, TitlePage('Title', 'HOG Feature Extraction', 'Author', 'Generated by MATLAB'));

    % 添加图像和HOG特征文本内容
    chapter = Chapter('Title', 'HOG Feature and Values');
    imageObj = Image(hogImageFilename);
    imageObj.Width = '5in';
    imageObj.Height = '4in';
    add(chapter, imageObj);

    % 添加HOG数值文本
    hogText = fileread(hogTextFilename); % 读取HOG值文本内容
    textObj = Text(hogText);
    add(chapter, textObj);

    % 将章节添加到报告
    add(report, chapter);

    % 关闭并生成PDF
    close(report);
    rptview(outputPDF);
end