#!/usr/bin/env bash

source $HOME/dotfiles/.key.env.sh

IP_LIST_FILE="$HOME/.ssh/dev_ip_list.txt"

# ~/.ssh/config 에서 ip host 매핑정보를 추출한다.
ip_extract() {
	# 입력 파일 경로를 파라미터로 받습니다.
	input_file="$HOME/.ssh/config"

	# 입력 파일이 지정되지 않았을 경우 오류 메시지를 출력하고 종료합니다.
	if [ -z "$input_file" ]; then
			echo "Usage: $0 <input_file>"
			exit 1
	fi

	# 패턴 매칭을 위한 정규식
	host_pattern="^Host (.+)$"
	user_pattern="User ([0-9@.]+)@([^@]+)@([0-9.]+)"

	cat /dev/null > $IP_LIST_FILE

	# 출력 파일을 열고 결과를 작성합니다.
	while read line; do
			#echo "Read line: $line"  # 디버깅용 출력
			if [[ $line =~ $host_pattern ]]; then
					#echo "Matched host pattern: ${BASH_REMATCH[1]}"  # 디버깅용 출력
					host="${BASH_REMATCH[1]}"
					read -r line
					#echo "Read line: $line"  # 디버깅용 출력
					read -r line
					#echo "Read line: $line"  # 디버깅용 출력
					if [[ $line =~ $user_pattern ]]; then
							#echo "Matched user pattern: ${BASH_REMATCH[1]}, ${BASH_REMATCH[2]}"  # 디버깅용 출력
							username="${BASH_REMATCH[1]}"
							ip="${BASH_REMATCH[2]}"
							echo "${BASH_REMATCH[3]} $host" >> $IP_LIST_FILE
					else
							#echo "User pattern not matched: $line"  # 디버깅용 출력
							continue
					fi
			fi
	done < "$input_file"
}

# 함수 정의: getIPfromAlias
# 인수: $1 - 대상서버 이름
getIPfromAlias() {
    target_alias="$1"

    # CSV 파일에서 대상 alias에 해당하는 행을 찾아 IP를 출력
		# 
    ip_address=$(cat "$IP_LIST_FILE" | awk -F' ' -v alias="$target_alias" '$0 ~ alias {print $1}') 

    # 결과 출력
    if [ -n "$ip_address" ]; then
        echo "$ip_address"
    fi
}

if [ $# -eq 0 ]; then
  cat "$IP_LIST_FILE"
	echo ""
	echo "Usage: "
	echo "$ dev slack"
	echo "$ dev 10.40.50.60"
	echo "$ dev root slack"
	echo "$ dev root 10.40.50.60"
	exit -1
fi

# ip 리스트 추출
echo -e "IP 목록을 재작성합니다...\n"
ip_extract
cat $IP_LIST_FILE
echo -e "\n"

if [[ $1 =~ ^[0-9]+ ]]; then
	echo "Direct connect to dev-server: $1"
	echo "ssh ${AD_ID}@${ACCOUNT_DEV}@$1@${IP_GATE}"

	sshpass -p ${AD_PASS} ssh ${AD_ID}@${ACCOUNT_DEV}@$1@${IP_GATE}
elif [[ $1 = 'root' ]]; then
	if [[ $2 =~ ^[0-9]+ ]]; then
		echo "ssh ${AD_ID}@${ACCOUNT_ADMIN}@$2@${IP_GATE}"
		sshpass -p ${AD_PASS} ssh ${AD_ID}@${ACCOUNT_ADMIN}@$2@${IP_GATE}
	else 
		target_ip=$(getIPfromAlias "$2")
		echo "$2 -> $target_ip 로 접속합니다." 
    echo "ssh ${AD_ID}@${ACCOUNT_ADMIN}@$target_ip@${IP_GATE}"

    sshpass -p ${AD_PASS} ssh ${AD_ID}@${ACCOUNT_ADMIN}@$target_ip@${IP_GATE}
	fi

elif [[ $1 = 'sftp' ]]; then
	if [[ $2 =~ ^[0-9]+ ]]; then
		echo "sftp ${AD_ID}@${ACCOUNT_DEV}@$2@${IP_GATE}"
		sshpass -p ${AD_PASS} sftp ${AD_ID}@${ACCOUNT_DEV}@$2@${IP_GATE}
	else 
		target_ip=$(getIPfromAlias "$2")
		echo "$2 -> $target_ip 로 접속합니다." 
    echo "sftp ${AD_ID}@${ACCOUNT_DEV}@$target_ip@${IP_GATE}"

    sshpass -p ${AD_PASS} sftp ${AD_ID}@${ACCOUNT_DEV}@$target_ip@${IP_GATE}
	fi

else 
    echo "ssh $1"
    sshpass -p ${AD_PASS} ssh $1
fi

