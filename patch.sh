#!/usr/bin/env bash
# 提示使用者輸入開始日期 (格式 YYYY-MM-DD)
read -p "請輸入開始日期 (YYYY-MM-DD): " start_date
echo "開始日期是 $start_date!"

# 刪除舊的 xlsx
rm -f *.xlsx

uv run python main.py --product-names 'SUSE Linux Enterprise Server LTSS' --since "$start_date" --product-versions "12 SP5" --product-architectures x86_64 -o sles12sp5_patches.xlsx
echo $? && echo "已製作 sles12sp5_patches.xlsx!"

uv run python main.py --product-names 'SUSE Linux Enterprise Server LTSS' --since "$start_date" --product-versions "15 SP3" --product-architectures x86_64 -o sles15sp3_patches.xlsx
echo $? && echo "已製作 sles15sp3_patches.xlsx!"

uv run python main.py --product-names 'SUSE Linux Enterprise Server LTSS' --since "$start_date" --product-versions "15 SP4" --product-architectures x86_64 -o sles15sp4_patches.xlsx
echo $? && echo "已製作 sles15sp4_patches.xlsx!"

uv run python main.py --product-names 'SUSE Linux Enterprise Server LTSS' --since "$start_date" --product-versions "15 SP5" --product-architectures x86_64 -o sles15sp5_patches.xlsx
echo $? && echo "已製作 sles15sp5_patches.xlsx!"

uv run python main.py --product-names 'SUSE Linux Enterprise Server LTSS' --since "$start_date" --product-versions "15 SP6" --product-architectures x86_64 -o sles15sp6_patches.xlsx
echo $? && echo "已製作 sles15sp6_patches.xlsx!"

uv run python main.py --product-names 'SUSE Linux Enterprise Live Patching' --since "$start_date" --product-versions "15 SP7" --product-architectures x86_64 -o sles15sp7_patches.xlsx
echo $? && echo "已製作 sles15sp7_patches.xlsx!"
