#!/bin/bash

REPOS_DIR=~/bitbucket

for repo in `ls ${REPOS_DIR}/`; do
  cd ${REPOS_DIR}/${repo}
  echo -n `date +"[%Y-%m-%d %H:%M:%S]"` "${repo}: " >> ${REPOS_DIR}/../update_repos.txt
  git pull --rebase -q
    if [ $? -eq 0 ]; then
      echo OK >> ${REPOS_DIR}/../update_repos.txt
    else
      echo FAILED >> ${REPOS_DIR}/../update_repos.txt
    fi
  cd ..
done
