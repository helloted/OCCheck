from enum import Enum, auto


class AutoName(Enum):
    def _generate_next_value_(name, start, count, last_values):
        return name


class ASTNodeType(AutoName):
    ClassName = auto(),
    Property = auto(),
    Method = auto(),
    Function = auto(),
    Parameter = auto(),
    LocalVariable = auto(),
    GlobalVariable = auto(),
    Macro = auto(),


class AstNode:
    def __init__(self):
        self.line_num = None
        self.content = None
        self.type = None
        self.indent_size = None
        self.ext_dic = {}
