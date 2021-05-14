import os
import re
import time


def git_diff(check_path_list):
    git_diff_path = " ".join(check_path_list)
    git_temp_path = '.git/diff_git_temp'
    grep_str = '| grep -v -e \'^[+-]\' -e \'^index\''
    if os.path.exists(git_temp_path):
        os.remove(git_temp_path)

    command = 'git diff HEAD --cached -U0 -- {} --diff-filter=AM {} > {}'.format(
        git_diff_path, grep_str, git_temp_path)
    os.system(command)
    result_path = '.git/check.txt'
    if os.path.exists(result_path):
        os.remove(result_path)
    file_path = ''
    diff_index_list = []
    result_dic = {}
    start_pick_index = False
    for line in open(git_temp_path):
        line = line.strip('\n')
        if line.startswith(
                'diff --git'):  # 提取diff --git a/code/MYViewController.m b/code/MYViewController.m
            pattern = r'.*\ b/(.*)'
            m = re.match(pattern, line)
            last_file_path = file_path
            if m is not None and len(m.groups()) == 1:
                file_path = m.groups()[0]
                extension = os.path.splitext(file_path)[1]

                if len(last_file_path) and len(diff_index_list):
                    result_dic[last_file_path] = diff_index_list
                if extension == '.h' or extension == '.m':  # .h和.m文件才去提取参数
                    start_pick_index = True
                else:
                    start_pick_index = False
                diff_index_list = []

        if not start_pick_index:
            continue

        if line.startswith(
                '@@ -'):  # 提取 @@ -20,0 +21,2 @@ @interface MYViewController ()
            pattern = r'.* \+([0-9]*)(,|)(.*) @@'
            m = re.match(pattern, line)
            if m is not None and len(
                    m.groups()) == 3:
                diff = DiffRange()
                try:
                    diff.start_num = int(m.groups()[0])
                    length = m.groups()[2]
                    if len(length):
                        diff.end_num = diff.start_num + int(length)
                    else:
                        diff.end_num = diff.start_num + 1
                except Exception as e:
                    print(e)
                else:
                    diff_index_list.append(diff)

    if len(diff_index_list) > 0:
        result_dic[file_path] = diff_index_list
    return result_dic


def check(git_dit):
    total_start = time.time()
    files_count = 0
    pattern = r'.*.(h|m):([0-9]*):'

    log_list = []
    for file_path in git_dit.keys():
        files_count += 1
        time_start = time.time()
        ranges = git_dit[file_path]
        # print(file_path)
        # print(ranges)
        out_temp = '.git/ghp_temp_out'
        command = 'java -jar .git/occheck/occheck.jar --output {} --format text --config .git/occheck/config.xml {}'.format(
            out_temp,
            file_path)
        os.system(command)

        if os.path.exists(out_temp):
            # 整个文件的检测结果，看看是否在这次修改范围之内
            for line in open(out_temp):
                line = line.strip('\n')
                m = re.match(pattern, line)
                if m is not None and len(m.groups()) == 2:
                    line_num = m.groups()[1]
                    if len(line_num):
                        line_num = int(line_num)

                    for diff in ranges:
                        if diff.start_num <= line_num <= diff.end_num:
                            log_list.append(line)

        time_end = time.time()
        print(
            'Checked file: {}  Cost Time: {}s'.format(
                file_path,
                round(
                    time_end -
                    time_start,
                    3)))

    total_end = time.time()
    print(
        'Finished {} files, total Cost Time: {}s\n'.format(
            files_count,
            round(
                total_end -
                total_start,
                3)))
    if os.path.exists('error.log'):
        os.remove('error.log')
    if os.path.exists('log.log'):
        os.remove('log.log')
    return log_list


class DiffRange:
    def __init__(self):
        self.start_num = None
        self.end_num = None
