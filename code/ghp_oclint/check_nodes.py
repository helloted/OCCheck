import re
import os
import sys
sys.path.append("..")
from ghp_oclint.oc_node import AstNode, ASTNodeType

file_path = ''


def pick_nodes(the_file_path, clang_text):
    global file_path
    file_path = the_file_path
    interface_start = False
    implementation_start = False

    oc_nodes = []
    last_method_line = None
    for line in open(clang_text):
        line_text = line.strip('\n')

        if line_text.startswith('|-ObjCCategoryDecl'):
            interface_start = True

        # 全局变量
        # if not interface_start and line_text.startswith('|-VarDecl'):
        #     print(line_text)
        #     pattern = r'.*m:([0-9]*):([0-9]*), col:.*\> col:[0-9]* (.*) \'.*'
        #     m = re.match(pattern, line_text)
        #     if m is not None and len(m.groups()) == 3:
        #         node = convert_var_node(m.groups(), ASTNodeType.GlobalVariable)
        #         oc_nodes.append(node)

        if not interface_start:
            continue

        # 类名
        if line_text.startswith('|-ObjCImplementationDecl'):
            implementation_start = True
            pattern = r'.*\> line:(.*):[0-9]* (.*)'
            m = re.match(pattern, line_text)
            if m is not None and len(m.groups()) == 2:
                temp = list(m.groups())
                temp.insert(1,1)
                node = convert_node(temp, ASTNodeType.ClassName)
                oc_nodes.append(node)

        # 属性
        if interface_start and not implementation_start and line_text.startswith(
                '| |-ObjCPropertyDecl'):
            pattern = r'.*\<line:([0-9]*):([0-9]*), col:.*\> col:[0-9]* (.*) \'.*'
            m = re.match(pattern, line_text)
            if m is not None and len(m.groups()) == 3:
                node = convert_node(m.groups(), ASTNodeType.Property)
                oc_nodes.append(node)

        if not implementation_start:
            continue

        # Method方法名
        if '-ObjCMethodDecl' in line_text and 'line:' in line_text:
            pattern = r'.*\> line:([0-9]*):([0-9]*) \- (.*) \''
            m = re.match(pattern, line_text)
            if m is not None and len(m.groups()) == 3:
                node = convert_node(m.groups(), ASTNodeType.Method)
                last_method_line = node.line_num
                oc_nodes.append(node)

        # Method参数
        if line_text.startswith('| | |-ParmVarDecl'):
            pattern = r'.*\> col:([0-9]*) (.*) \''
            m = re.match(pattern, line_text)
            if m is not None and len(m.groups()) == 2:
                node = AstNode()
                node.type = ASTNodeType.Parameter
                node.line_num = last_method_line
                node.indent_size = m.groups()[0]
                node.content = m.groups()[1]
                oc_nodes.append(node)

        # 普通变量
        if line_text.startswith('| | |-VarDecl'):
            pattern = r'.*\<line:([0-9]*):([0-9]*), col:.*\> col:[0-9]* (.*) \'.*'
            m = re.match(pattern, line_text)
            if m is not None and len(m.groups()) == 3:
                node = convert_var_node(m.groups(), ASTNodeType.LocalVariable)
                oc_nodes.append(node)
    return oc_nodes

    # for node in oc_nodes:
    #     log = '{} {} {} {}'.format(node.line_num,node.indent_size, node.type, node.content)
    #     if node.ext_dic:
    #         log = log + str(node.ext_dic)
    #     print(log)


def convert_node(reslut, type):
    node = AstNode()
    node.type = type
    node.line_num = '{}:{}'.format(file_path, reslut[0])
    node.indent_size = reslut[1]
    node.content = reslut[2]
    return node

def convert_var_node(reslut, type):
    node = convert_node(reslut, type)
    content = reslut[2]  # used startBtn
    if content.startswith('used'):
        node.ext_dic['used'] = True
        node.content = content[5:]
    else:
        node.ext_dic['used'] = False
    return node

if __name__ == '__main__':
    pick_nodes('MYViewController.m', '../out.txt')
