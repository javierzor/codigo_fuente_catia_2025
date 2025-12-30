
#!/bin/bash

echo "===== DEPLOY START ====="
date

cd /opt/l2j || exit 1

git pull origin main

echo "===== DEPLOY END ====="
