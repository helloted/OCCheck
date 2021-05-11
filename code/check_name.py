import re

def check_name(name):
    print(name)
    pattern = re.compile(r'^[a-z][a-zA-Z0-9]*$')
    if pattern.match(name):
        print('match')
    else:
        print('not match')


if __name__ == '__main__':
    check_name('myna_me')