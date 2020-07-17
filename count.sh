#!/bin/bash
#
# 用法：
# ./count directory [min] [max]
# 输出给定目录文件下行数在min和max之间的文件路径名
# min和max是可选参数，默认输出所有文件路径名
# 

# 函数：将目录文件下的文件名保存在变量files
get_files () {
  files="`ls $1`"
}

# 函数：计算非目录文件的行数
count_lines () {
  f=$1  # $1表示函数的第一个参数
  #通过wc命令 和 sed命令 获得对应的行数
  #'s/^\([0-9]*\).*$/\1/' 通配符，让只生成数字
  # 2>/dev/null wc命令碰到目录文件会有错误信息，重定向它
  l=`wc -l $f 2>/dev/null | sed 's/^\([0-9]*\).*$/\1/'`
}

# 脚本只能支持下面两种形式的参数的调用
if [ $# -lt 1 -o $# -gt 3 ]
then
    echo "Usage: $0 directory"
    echo "Usage: $0 directory min max"
    exit 1
fi

# finder是两种功能的标志位
if [ $# -eq 1 ]
then
    finder=0
fi

if [ $# -eq 3 ]
then
    finder=1
fi

# 以换行符为分割字符
IFS=$'\012' # \012与\n都是换行符

# 初始化变量
l=0      # 非目录文件的行数
files=0  # 目录文件下的文件列表
result=0 # 存放目录文件的执行结果

# 获取目录文件下文件列表
get_files $1

# 遍历文件列表
for f in $files
do
    f=$1"/"$f # 组成相对路径
    # 对目录和非目录文件分别处理
    if [ -d $f ]
	# 目录文件	
    then  
	    # 对目录文件递归处理
        if [ $finder -eq 1 ] # 两种功能模式
        then
            result=`./count.sh $f $2 $3`
        else
            result=`./count.sh $f`
        fi
        
		# 遍历输出处理结果
        for i in $result
        do
            echo $i
        done
	# 非目录文件
    else
	    # 调用函数计算非目录文件的行数
        count_lines $f
        if [ $finder -eq 1 ] # 两种功能模式
		# 根据min，max限制输出的结果
        then
            if [ $l -ge $2 -a $l -le $3 ]
            then
                echo "$l : $f" # 行数 ：文件名
            fi
	    # 不限制输出的结果
        else
            echo "$l : $f"
        fi
    fi
done
