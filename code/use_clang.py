import os
import time
from ghp_oclint.check_nodes import pick_nodes
from ghp_oclint.check_length import check_length_file


os.system('xcrun -k')
file_list = ['GCDAsyncUdpSocket.m','MYViewController.m']
# file_list.extend(file_list)
# file_list.extend(file_list)
# file_list.extend(file_list)
# file_list.extend(file_list)

total_start = time.time()
index = 0
for file_path in file_list:
    index += 1
    out_path = 'clang_temp_{}'.format(index)
    time_start = time.time()
    clang_command = 'xcrun -sdk iphonesimulator clang -fmodules -fsyntax-only -fobjc-arc -Xclang -ast-dump {} ' \
              '-fno-diagnostics-color > {}'.format(file_path,out_path)
    os.system(clang_command)
    nodes = pick_nodes(file_path, out_path)
    os.remove(out_path)
    print(nodes)
    length_logs = check_length_file(file_path)
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
    'Finished {} files, total Cost Time: {}s'.format(
        len(file_list),
        round(
            total_end -
            total_start,
            3)))