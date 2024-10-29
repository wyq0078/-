detect_clown_face_advanced('飞行器视觉汇报课题20241020.jpg');

function detect_clown_face_advanced(imageFile)
    % 读取图像
    inputImage = imread(imageFile);

    % 创建人脸检测器对象，并设定参数
    faceDetector = vision.CascadeObjectDetector(...
        'ClassificationModel', 'FrontalFaceCART', ... % 使用正面人脸模型
        'MergeThreshold', 2, ...                      % 降低阈值以检测更多区域
        'MinSize', [100, 100], ...                    % 最小检测尺寸
        'MaxSize', [500, 500] ...                     % 最大检测尺寸
    );
    
    % 检测人脸
    boundingBoxes = step(faceDetector, inputImage);

    % 如果初次检测效果不佳，尝试使用其他分类器，例如眼睛或鼻子检测
    if isempty(boundingBoxes)
        disp('未检测到人脸，尝试使用眼睛分类器...');
        eyeDetector = vision.CascadeObjectDetector('EyePairBig', 'MergeThreshold', 2);
        boundingBoxes = step(eyeDetector, inputImage);
        
        % 检测到眼睛区域后，可以假设人脸区域在眼睛的周围
        if ~isempty(boundingBoxes)
            % 根据眼睛框位置估算脸部区域并进一步调整
            boundingBoxes = adjustBoundingBox(boundingBoxes, 300, -40, 400, 80);
        end
    else
        % 对检测到的人脸框进一步调整位置和大小
        boundingBoxes = adjustBoundingBox(boundingBoxes, 80, 10, 20, 30);
    end
    
    % 检测并标记人脸区域
    detectedImage = insertObjectAnnotation(inputImage, 'rectangle', boundingBoxes, 'Face');
    
    % 显示检测结果
    figure;
    imshow(detectedImage);
    title('Detected Clown Face(s)');

    % 保存检测结果为图像文件
    outputImageFile = 'detected_clown_face_advanced.png';
    imwrite(detectedImage, outputImageFile);
    
    % 输出检测到的人脸区域位置（矩形框的坐标）
    disp('Detected face bounding boxes:');
    disp(boundingBoxes);
end

function boundingBoxes = adjustBoundingBox(boundingBoxes, xAdjust, yAdjust, widthAdjust, heightAdjust)
    % 调整每个检测框的位置和大小
    boundingBoxes(:, 1) = boundingBoxes(:, 1) + xAdjust;    % 水平位置调整
    boundingBoxes(:, 2) = boundingBoxes(:, 2) + yAdjust;    % 垂直位置调整
    boundingBoxes(:, 3) = boundingBoxes(:, 3) + widthAdjust; % 宽度调整
    boundingBoxes(:, 4) = boundingBoxes(:, 4) + heightAdjust; % 高度调整
end
