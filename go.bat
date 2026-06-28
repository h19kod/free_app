@echo off
cd /d "e:\New folder (3)\project\free_app"
git add README.md
git commit -m "docs: rewrite README with full feature documentation"
git push origin main
echo DONE
pause
