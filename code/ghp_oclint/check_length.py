

def check_length_file(file_path):
    brace_count = 0
    index = 0
    method_count = 0
    logs = []
    for line in open(file_path):
        index += 1
        if line.startswith('//'):  # 注释掉的代码
            continue

        line = line.strip()
        line = line.strip('\n')

        if len(line) > 120:
            line_num = file_path + ':{}'.format(index)
            msg = line_num + ' 行长度为{}, 不应该超过{}'.format(len(line),120)
            logs.append(msg)

        # 计算方法内行数
        start_count = line.count('{')
        if brace_count == 0 and start_count > 0:  # 开始计数
            method_count = index
        end_count = line.count('}')
        brace_count += start_count
        brace_count -= end_count
        if brace_count == 0 and end_count != 0 and method_count:
            total_count = index - method_count  # 这一次方括号内的总行数
            if total_count > 80:
                line_num = file_path + ':{}'.format(method_count)
                msg = line_num + ' 函数体行数为{}, 不应该超过{}'.format(total_count,80)
                logs.append(msg)
    return logs


if __name__ == '__main__':
    check_length_file('../GCDAsyncUdpSocket.m')
