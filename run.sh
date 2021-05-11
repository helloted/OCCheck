#!/usr/bin/env bash

if [ ! -d ".git" ]; then
  echo -e "\033[31m\033[01m\033[05mError:当前目录下没有.git文件夹，请在项目根目录下执行命令\033[0m"
  exit 8
fi

# occheck
curl -L https://raw.githubusercontent.com/helloted/OCCheck/main/ghp_occheck.zip -o ghp_occheck.zip
mkdir -p -m 777 .git/occheck
unzip -o ghp_occheck.zip -d .git/occheck
rm -f ghp_occheck.zip
mv occheck/occheck_path_list.txt ./

echo -e "\033[32m\033[01m\033[05m occheck success\033[0m"

#pre-commit
mkdir -p -m 777 .git/hooks
curl -L https://raw.githubusercontent.com/helloted/OCCheck/main/pre-commit-python3 -o pre-commit
mkdir -p -m 777 .git/hooks
mv pre-commit .git/hooks/
chmod +x  .git/hooks/pre-commit
echo -e "\033[32m\033[01m\033[05m pre-commit success\033[0m"

rm -f run.sh




