#!/bin/bash

# 输出 CSV 文件的标题
echo "index,Public Key,Mnemonic Phrase" > keys.csv

# 使用循环生成密钥
for i in {1..100}
do
    # 调用命令生成密钥并自动输入密码
    output=$(expect -c "
    spawn soundness-cli generate-key --name $i
    # 等待直到出现提示输入密码
    expect \"Enter password for secret key:\"
    send \"\r\"
    expect \"Confirm password:\"
    send \"\r\"
    # 等待命令输出完成
    expect \"✅ Generated new key pair '$i'\"
    # 捕获输出
    expect -re \".*\"
    set output \$expect_out(buffer)
    ")

    # 从输出中提取第 5 行（助记词）和第 11 行（公钥）
    mnemonic_phrase=$(echo "$output" | sed -n '6p' | sed 's/^ *//g')
    public_key=$(echo "$output" | sed -n '12p' | sed 's/^ *//g' | sed 's/^🔑 Public key: //')

    # 将提取到的助记词和公钥输出到 CSV 文件
    echo "$i,$public_key,$mnemonic_phrase" >> keys.csv
done

echo "Key generation complete! The keys are saved in keys.csv."
