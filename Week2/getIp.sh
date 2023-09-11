ip addr>temp.txt
cut -c 10-28 temp.txt>adr.txt
sed -n '10p' adr.txt
#reference to sed command https://linuxhandbook.com/display-specific-lines/
