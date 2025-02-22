import xml.etree.ElementTree as ET
import cv2
import numpy as np
import os
import copy

def ensure_directory_exists(file_path):
    # 提取目录部分
    directory = os.path.dirname(file_path)
    
    # 检查目录是否存在
    if not os.path.exists(directory):
        # 如果目录不存在，创建目录
        os.makedirs(directory)

def pad_image(image, pad_width, pad_height):
    """
    在图像周围添加空白填充。
    :param image: 原始图像 (numpy 数组)
    :param pad_width: 在宽度方向需要的填充
    :param pad_height: 在高度方向需要的填充
    :return: 扩充后的图像和原始图像的左上角坐标
    """
    # 获取原始图像的高度和宽度
    original_height, original_width = image.shape[:2]
    
    # 创建一个新的图像，填充的部分用零（黑色）填充
    padded_image = np.zeros((original_height + pad_height, original_width + pad_width, image.shape[2]), dtype=image.dtype)
    
    # 将原始图像复制到新图像的左上角
    padded_image[:original_height, :original_width] = image
    
    # 返回扩充后的图像和原始图像的左上角坐标 (0, 0)
    return padded_image

def crop_image(padded_image, original_width, original_height):
    """
    从扩充后的图像中裁剪回原始图像区域。
    :param padded_image: 扩充后的图像 (numpy 数组)
    :param original_width: 原始图像的宽度
    :param original_height: 原始图像的高度
    :return: 裁剪回原始区域的图像
    """
    return padded_image[:original_height, :original_width]

def parse_anm2(file_path, output_path,cid = ""):
    # 解析XML文件
    tree = ET.parse(file_path)
    root = tree.getroot()

    # 拷贝一份原始的XML树
    copy_tree = copy.deepcopy(tree)
    copy_root = copy_tree.getroot()

    # 初始化Lua表
    lua_table = {}

    # 提取Spritesheets和Layers信息
    spritesheets = {}
    layers = {}
    content = root.find('Content')
    if content is not None:
        for spritesheet in content.find('Spritesheets'):
            spritesheets[spritesheet.get('Id')] = spritesheet.get('Path')
        for layer in content.find('Layers'):
            layers[layer.get('Id')] = {
                'Name': layer.get('Name'),
                'SpritesheetId': layer.get('SpritesheetId')
            }

    # 初始化一个全局的attribute_combinations字典，使用二级表
    attribute_combinations = {}  # 第一级是SpritesheetId，第二级是属性组合
    combination_id_counter = {}  # 每个SpritesheetId的组合ID计数器

    # 提取Animations
    lua_table['Animations'] = {}
    for anim in root.find('Animations'):
        anim_name = anim.get('Name')
        lua_table['Animations'][anim_name] = {
            'FrameNum': anim.get('FrameNum'),
            'Loop': anim.get('Loop'),
            'LayerAnimations': {}
        }

        # 提取LayerAnimations
        for layer_anim in anim.find('LayerAnimations'):
            layer_id = "[" + str(layer_anim.get('LayerId')) + "]"
            spritesheet_id = layers.get(layer_anim.get('LayerId'), {}).get('SpritesheetId', '0')
            lua_table['Animations'][anim_name]['LayerAnimations'][layer_id] = []
            
            # 初始化当前SpritesheetId的组合ID计数器
            if spritesheet_id not in combination_id_counter:
                combination_id_counter[spritesheet_id] = 1
                attribute_combinations[spritesheet_id] = {}  # 初始化二级表

            iframe = 0
            for frame in layer_anim:
                # 提取属性组合
                attributes = {
                    'XPivot': frame.get('XPivot'),
                    'YPivot': frame.get('YPivot'),
                    'XCrop': frame.get('XCrop'),
                    'YCrop': frame.get('YCrop'),
                    'Width': frame.get('Width'),
                    'Height': frame.get('Height')
                }

                # 生成组合的唯一键（对所有属性排序）
                combination_key = tuple(sorted(attributes.items()))

                # 如果组合不存在，则分配一个新的ID
                if combination_key not in attribute_combinations[spritesheet_id]:
                    attribute_combinations[spritesheet_id][combination_key] = combination_id_counter[spritesheet_id]
                    combination_id_counter[spritesheet_id] += 1

                # 记录组合ID
                combination_id = attribute_combinations[spritesheet_id][combination_key]

                # 记录帧数据
                frame_data = {
                    'XPosition': frame.get('XPosition'),
                    'YPosition': frame.get('YPosition'),
                    'XScale': frame.get('XScale'),
                    'YScale': frame.get('YScale'),
                    'CombinationID': combination_id,
                    'frame': iframe,
                    'Interpolated' : bool(frame.get('Interpolated')),
                }
                iframe = iframe + int(frame.get('Delay'))
                lua_table['Animations'][anim_name]['LayerAnimations'][layer_id].append(frame_data)

    # 将属性组合转换为Lua表
    lua_table['AttributeCombinations'] = {}
    for spritesheet_id, combinations in attribute_combinations.items():
        lua_table['AttributeCombinations']["[" + str(spritesheet_id) + "]"] = {}
        for combination_key, combination_id in combinations.items():
            combination_dict = dict(combination_key)
            lua_table['AttributeCombinations']["[" + str(spritesheet_id) + "]"]["[" + str(combination_id) + "]"] = combination_dict
    
    lua_table['AttributeDetail'] = {}
    for spritesheet_id, combinations in attribute_combinations.items():
        lua_table['AttributeDetail']["[" + str(spritesheet_id) + "]"] = {}
        path = spritesheets[spritesheet_id]
        image = cv2.imread(path, cv2.IMREAD_UNCHANGED)
        if image is None:
            print(f"无法加载图像: {path}")
            continue
        
        # 将图像转换为 RGBA 格式（如果尚未转换）
        if image.shape[2] == 3:  # 如果没有 Alpha 通道
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGBA)
        
        padded_image = pad_image(image, 800, 800)

        # 遍历属性组合
        for combination_key, combination_id in combinations.items():
            combination_dict = dict(combination_key)
            # 解析矩形属性
            attributes = {
                'XPivot': float(combination_dict.get('XPivot', 0)),
                'YPivot': float(combination_dict.get('YPivot', 0)),
                'XCrop': float(combination_dict.get('XCrop', 0)),
                'YCrop': float(combination_dict.get('YCrop', 0)),
                'Width': float(combination_dict.get('Width', 0)),
                'Height': float(combination_dict.get('Height', 0))
            }
            
            # 计算矩形区域的坐标
            x = int(attributes['XCrop'])
            y = int(attributes['YCrop'])
            w = int(attributes['Width'])
            h = int(attributes['Height'])
            
            # 分割线位置（左半部分和右半部分的分界线）
            split_line_x = w // 2
            
            if (x < 0):x = 0
            if (y < 0):y = 0

            # 提取矩形区域
            roi = padded_image[y:y+h, x:x+w]

            # 初始化统计结果
            first_non_transparent = None
            last_non_transparent = None
            
            # 扫描分割线，找到第一个和最后一个非透明像素点
            for row in range(h):
                # 获取分割线上的像素点
                pixel = roi[row, split_line_x]
                
                # 检查 Alpha 通道是否非透明
                if pixel[3] != 0:  # Alpha 通道不为 0
                    if first_non_transparent is None:
                        first_non_transparent = (x + split_line_x, y + row)  # 全局坐标
                    last_non_transparent = (x + split_line_x, y + row)  # 全局坐标
            
            # 输出统计结果
            print(f"Spritesheet: {path}, 矩形区域 (x={x}, y={y}, w={w}, h={h}):")
            print(f"  第一个非透明像素点: {first_non_transparent}")
            print(f"  最后一个非透明像素点: {last_non_transparent}")
            print()

            if first_non_transparent is None:
                first_non_transparent = -999
                last_non_transparent = -999 + 60
            else:
                first_non_transparent = first_non_transparent[1]
                last_non_transparent = last_non_transparent[1]
            cutattributes = {
                'st': str(int(first_non_transparent - y)),
                'ed': str(int(last_non_transparent - y))
            }
            lua_table['AttributeDetail']["[" + str(spritesheet_id) + "]"]["[" + str(combination_id) + "]"] = dict(cutattributes)

            # 处理矩形区域：保留左半部分，右半部分填充透明
            roi[:, split_line_x:] = [0, 0, 0, 0]  # 右半部分设置为透明
            
            # 将处理后的 ROI 放回原图
            padded_image[y:y+h, x:x+w] = roi
        
        restored_image = crop_image(padded_image, image.shape[1], image.shape[0])
        # 保存处理后的图像
        output_path_ = 'output/' + path.replace('.png', '_' + cid + '_left.png')
        ensure_directory_exists(output_path_)
        cv2.imwrite(output_path_, restored_image)
        print(f"处理后的图像已保存为: {output_path_}")

        padded_image = pad_image(image, 200, 200)
        
        # 遍历属性组合
        for combination_key, combination_id in combinations.items():
            combination_dict = dict(combination_key)
            # 解析矩形属性
            attributes = {
                'XPivot': float(combination_dict.get('XPivot', 0)),
                'YPivot': float(combination_dict.get('YPivot', 0)),
                'XCrop': float(combination_dict.get('XCrop', 0)),
                'YCrop': float(combination_dict.get('YCrop', 0)),
                'Width': float(combination_dict.get('Width', 0)),
                'Height': float(combination_dict.get('Height', 0))
            }
            
            # 计算矩形区域的坐标
            x = int(attributes['XCrop'])
            y = int(attributes['YCrop'])
            w = int(attributes['Width'])
            h = int(attributes['Height'])
            # 分割线位置（左半部分和右半部分的分界线）
            split_line_x = w // 2

            if (x < 0):x = 0
            if (y < 0):y = 0
            
            # 提取矩形区域
            roi = padded_image[y:y+h, x:x+w]
            
            # 处理矩形区域：保留右半部分，左半部分填充透明
            roi[:, :split_line_x] = [0, 0, 0, 0]  # 左半部分设置为透明
            
            # 将处理后的 ROI 放回原图
            padded_image[y:y+h, x:x+w] = roi
        
        restored_image = crop_image(padded_image, image.shape[1], image.shape[0])
        
        # 保存处理后的图像
        output_path_ = 'output/' + path.replace('.png', '_' + cid + '_right.png')
        
        cv2.imwrite(output_path_, restored_image)
        print(f"处理后的图像已保存为: {output_path_}")

        
    # 将Lua表写入文件
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("local anm2_data = {\n")
        write_lua_table(f, lua_table, 1)
        f.write("}\n\nreturn anm2_data")

    copycontent = copy_root.find('Content')
    for spritesheet in copycontent.find('Spritesheets'):
        # 获取原始路径
        original_path = spritesheet.get('Path')
        if original_path:
            # 修改Path属性，使用新的路径前缀
            new_path = original_path.replace('.png', '_' + cid + '_left.png')
            spritesheet.set('Path', new_path)
            print(f"修改路径: {original_path} -> {new_path}")

    # 将修改后的XML树写入到新的文件
    copy_outputpath = 'output/' + file_path.replace('.anm2', '_left.anm2')
    copy_tree.write(copy_outputpath, encoding='utf-8', xml_declaration=True)
    print(f"修改后的文件已保存到: {copy_outputpath}")

    # 拷贝一份原始的XML树
    copy_tree = copy.deepcopy(tree)
    copy_root = copy_tree.getroot()
    copycontent = copy_root.find('Content')
    for spritesheet in copycontent.find('Spritesheets'):
        # 获取原始路径
        original_path = spritesheet.get('Path')
        if original_path:
            # 修改Path属性，使用新的路径前缀
            new_path = original_path.replace('.png', '_' + cid + '_right.png')
            spritesheet.set('Path', new_path)
            print(f"修改路径: {original_path} -> {new_path}")

    # 将修改后的XML树写入到新的文件
    copy_outputpath = 'output/' + file_path.replace('.anm2', '_right.anm2')
    copy_tree.write(copy_outputpath, encoding='utf-8', xml_declaration=True)
    print(f"修改后的文件已保存到: {copy_outputpath}")

def write_lua_table(f, table_data, indent_level):
    indent = '    ' * indent_level
    for key, value in table_data.items():
        if isinstance(value, dict):
            f.write(f"{indent}{key} = {{\n")
            write_lua_table(f, value, indent_level + 1)
            f.write(f"{indent}}},\n")
        elif isinstance(value, list):
            f.write(f"{indent}{key} = {{\n")
            for item in value:
                if isinstance(item, dict):
                    f.write(f"{indent}    {{\n")
                    write_lua_table(f, item, indent_level + 2)
                    f.write(f"{indent}    }},\n")
                else:
                    f.write(f"{indent}    {item},\n")
            f.write(f"{indent}}},\n")
        else:
            if isinstance(value, bool):
                # Lua 中的布尔值是小写的 true 和 false
                f.write(f"{indent}{key} = {'true' if value else 'false'},\n")
            elif isinstance(value, int):
                # 整数直接输出
                f.write(f"{indent}{key} = {value},\n")
            elif isinstance(value, str):
                # 字符串需要用双引号括起来
                try:
                    int(value)
                    f.write(f'{indent}{key} = {value},\n')
                except ValueError:
                    f.write(f'{indent}{key} = "{value}",\n')

# 调用函数并输出到.lua文件
#parse_anm2('monstro.anm2', 'monstro.lua')
#parse_anm2('the duke of flies.anm2', 'dukeofflies.lua')

# 获取当前目录
current_directory = os.getcwd()

# 遍历当前目录中的文件
for filename in os.listdir(current_directory):
    # 检查文件是否以 .anm2 结尾
    if filename.endswith('.anm2'):
        file_name_without_extension = os.path.splitext(filename)[0]
        new_filename = file_name_without_extension + '.lua'
        parse_anm2(filename,'output/' + new_filename,file_name_without_extension)