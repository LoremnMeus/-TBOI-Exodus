import xml.etree.ElementTree as ET

def infer_slot(shape, gridx, gridy):
    """
    根据 shape、gridx 和 gridy 推断门的 slot。
    """
    if shape == 1:  # shape=1 的情况
        if gridx == -1 and gridy == 3:  # 左门
            return 0
        elif gridx == 6 and gridy == -1:  # 上门
            return 1
        elif gridx == 13 and gridy == 3:  # 右门
            return 2
        elif gridx == 6 and gridy == 7:  # 下门
            return 3
    elif shape == 2:  # shape=2 的情况
        if gridx == -1 and gridy == 3:  # 左门
            return 0
        elif gridx == 13 and gridy == 3:  # 右门
            return 2
    elif shape == 3:  # shape=3 的情况
        if gridx == 6 and gridy == -1:  # 上门
            return 1
        elif gridx == 6 and gridy == 7:  # 下门
            return 3
    elif shape == 4:  # shape=4 的情况
        if gridx == -1 and gridy == 3:  # 左上门
            return 0
        elif gridx == -1 and gridy == 10:  # 左下门
            return 4
        elif gridx == 6 and gridy == -1:  # 上门
            return 1
        elif gridx == 6 and gridy == 14:  # 下门
            return 3
        elif gridx == 13 and gridy == 3:  # 右上门
            return 2
        elif gridx == 13 and gridy == 10:  # 右下门
            return 6
    elif shape == 5:  # shape=5 的情况
        if gridx == 6 and gridy == -1:  # 上门
            return 1
        elif gridx == 6 and gridy == 14:  # 下门
            return 3
    elif shape == 6:  # shape=6 的情况
        if gridx == -1 and gridy == 3:  # 左门
            return 0
        elif gridx == 6 and gridy == -1:  # 上门
            return 1
        elif gridx == 6 and gridy == 7:  # 下门
            return 3
        elif gridx == 19 and gridy == -1:  # 上中门
            return 5
        elif gridx == 19 and gridy == 7:  # 下中门
            return 7
        elif gridx == 26 and gridy == 3:  # 右门
            return 2
    elif shape == 7:  # shape=7 的情况
        if gridx == -1 and gridy == 3:  # 左门
            return 0
        elif gridx == 26 and gridy == 3:  # 右门
            return 2
    elif shape == 8:  # shape=8 的情况
        if gridx == -1 and gridy == 3:  # 左上门
            return 0
        elif gridx == -1 and gridy == 10:  # 左下门
            return 4
        elif gridx == 6 and gridy == -1:  # 上门
            return 1
        elif gridx == 6 and gridy == 14:  # 下门
            return 3
        elif gridx == 19 and gridy == -1:  # 上中门
            return 5
        elif gridx == 19 and gridy == 14:  # 下中门
            return 7
        elif gridx == 26 and gridy == 3:  # 右上门
            return 2
        elif gridx == 26 and gridy == 10:  # 右下门
            return 6
    elif shape == 9:  # shape=9 的情况
        if gridx == -1 and gridy == 10:  # 左下门
            return 4
        elif gridx == 6 and gridy == 6:  # 上门
            return 1
        elif gridx == 6 and gridy == 14:  # 下门
            return 3
        elif gridx == 12 and gridy == 3:  # 左上门
            return 0
        elif gridx == 19 and gridy == -1:  # 上中门
            return 5
        elif gridx == 19 and gridy == 14:  # 下中门
            return 7
        elif gridx == 26 and gridy == 3:  # 右上门
            return 2
        elif gridx == 26 and gridy == 10:  # 右下门
            return 6
    elif shape == 10:  # shape=10 的情况
        if gridx == -1 and gridy == 3:  # 左上门
            return 0
        elif gridx == -1 and gridy == 10:  # 左下门
            return 4
        elif gridx == 6 and gridy == -1:  # 上门
            return 1
        elif gridx == 6 and gridy == 14:  # 下门
            return 3
        elif gridx == 13 and gridy == 3:  # 右上门
            return 2
        elif gridx == 19 and gridy == 6:  # 上中门
            return 5
        elif gridx == 19 and gridy == 14:  # 下中门
            return 7
        elif gridx == 26 and gridy == 10:  # 右下门
            return 6
    elif shape == 11:  # shape=11 的情况
        if gridx == -1 and gridy == 3:  # 左门
            return 0
        elif gridx == 6 and gridy == -1:  # 上门
            return 1
        elif gridx == 6 and gridy == 7:  # 下门
            return 3
        elif gridx == 12 and gridy == 10:  # 左下门
            return 4
        elif gridx == 19 and gridy == -1:  # 上中门
            return 5
        elif gridx == 19 and gridy == 14:  # 下中门
            return 7
        elif gridx == 26 and gridy == 3:  # 右门
            return 2
        elif gridx == 26 and gridy == 10:  # 右下门
            return 6
    elif shape == 12:  # shape=12 的情况
        if gridx == -1 and gridy == 3:  # 左门
            return 0
        elif gridx == 6 and gridy == -1:  # 上门
            return 1
        elif gridx == 6 and gridy == 7:  # 下门
            return 3
        elif gridx == 19 and gridy == -1:  # 上中门
            return 5
        elif gridx == 19 and gridy == 7:  # 下中门
            return 7
        elif gridx == 26 and gridy == 3:  # 右门
            return 2
    return -1  # 默认值，表示未知 slot

def xml_to_lua(xml_file, lua_file):
    # 解析XML文件
    tree = ET.parse(xml_file)
    root = tree.getroot()

    # 创建Lua文件
    with open(lua_file, 'w', encoding='utf-8') as f:
        f.write('return {\n')
        f.write('\tMETADATA=nil,\n')
        
        # 遍历每个房间
        for room in root.findall('room'):
            # 写入房间基本信息
            f.write(f'\t{{TYPE={room.get("type")}, VARIANT={room.get("variant")}, SUBTYPE={room.get("subtype")}, NAME="{room.get("name")}", '
                   f'DIFFICULTY={room.get("difficulty")}, WEIGHT={round(float(room.get("weight")), 6)}, '
                   f'WIDTH={room.get("width")}, HEIGHT={room.get("height")}, SHAPE={room.get("shape")}, METADATA=nil,\n')
            
            # 处理门
            for door in room.findall('door'):
                gridx = int(door.get("x"))
                gridy = int(door.get("y"))
                shape = int(room.get("shape"))
                slot = infer_slot(shape, gridx, gridy)  # 推断 slot
                f.write(f'\t\t{{ISDOOR=true, GRIDX={gridx}, GRIDY={gridy}, '
                       f'SLOT={slot}, EXISTS={str(door.get("exists")).lower()}}},\n')
            
            # 处理生成点
            for spawn in room.findall('spawn'):
                entity = spawn.find('entity')
                f.write(f'\t\t{{ISDOOR=false, GRIDX={int(spawn.get("x"))}, GRIDY={int(spawn.get("y"))},\n')
                f.write(f'\t\t\t{{TYPE={int(entity.get("type"))}, VARIANT={int(entity.get("variant"))}, '
                       f'SUBTYPE={int(entity.get("subtype"))}, WEIGHT={round(float(entity.get("weight")), 6)}, METADATA=nil}},\n')
                f.write('\t\t},\n')
            
            f.write('\t},\n')
        
        f.write('}\n')

# 使用示例
xml_to_lua('EdenFall_room_.xml', 'EdenFall_room_.lua')
#xml_to_lua('Mixture_room.xml', 'Mixture_room.lua')
xml_to_lua('Eden_room.xml', 'Eden_room.lua')
#xml_to_lua('Nether_room.xml', 'Nether_room.lua')
#xml_to_lua('base_room1.xml', 'base_room1.lua')
#xml_to_lua('base_room2.xml', 'base_room2.lua')