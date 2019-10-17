echo "-------1. 一键提交流程开启-------"
git status
git add .
echo "-------2. 添加到暂存区完毕-------"
read -p "提交信息:" commitinfo
git commit -m $commitinfo
echo "-------3. 添加到版本库完毕-------"
git push -u origin master
echo "-------4. 推送到github完毕-------"
git push -u gitee master
echo "-------5. 推送到gitee完毕-------"
