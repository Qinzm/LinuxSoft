cat > /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 0        
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
###内存资源使用相关设定
net.core.wmem_default = 8388608 
net.core.rmem_default = 8388608 
net.core.rmem_max = 16777216 
net.core.wmem_max = 16777216 
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216     
net.ipv4.tcp_mem = 8388608 8388608 8388608
##应对DDOS攻击,TCP连接建立设置
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_synack_retries = 1 
net.ipv4.tcp_syn_retries = 1 
net.ipv4.tcp_max_syn_backlog = 262144
##应对timewait过高,TCP连接断开设置
net.ipv4.tcp_max_tw_buckets = 10000 
net.ipv4.tcp_tw_recycle = 1 
net.ipv4.tcp_tw_reuse = 1 
net.ipv4.tcp_timestamps = 0 
net.ipv4.tcp_fin_timeout = 5
net.ipv4.ip_local_port_range = 4000 65000
###TCP keepalived 连接保鲜设置
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 5
###其他TCP相关调节
net.core.somaxconn = 262144
net.core.netdev_max_backlog = 262144  
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
EOF

#注释
net.ipv4.ip_forward = 0 
#表示开启路由功能，0是关闭，1是开启
net.ipv4.conf.all.rp_filter=1      
#则是"告诉"kernel加强入站过滤（ingress filtering）和出站过滤（egress filtering）
net.ipv4.conf.default.rp_filter = 1 
#开启反向路径过滤
net.ipv4.conf.default.accept_source_route = 0
#处理无源路由的包
kernel.sysrq = 0
#控制系统调试内核的功能要求
kernel.core_uses_pid = 1
#用于调试多线程应用程序
kernel.msgmnb = 65536
#所有在消息队列中的消息总和的最大值(msgmnb=64k)
kernel.msgmax = 65536
#指定内核中消息队列中消息的最大值(msgmax=64k)
kernel.shmmax = 68719476736
#是核心参数中最重要的参数之一，用于定义单个共享内存段的最大值，64位linux系统：可取的最大值为物理内存值-1byte，
#建议值为多于物理内存的一半，一般取值大于SGA_MAX_SIZE即可，可以取物理内存-1byte。例如，如果为64GB物理内存，可取64*1024*1024*1024-1=68719476735
kernel.shmall = 4294967296
#该参数控制可以使用的共享内存的总页数。Linux共享内存页大小为4KB,共享内存段的大小都是共享内存页大小的整数倍。
#一个共享内存段的最大大小是 16G，那么需要共享内存页数是16GB/4KB=16777216KB /4KB=4194304（页），
#也就是64Bit系统下16GB物理内存，设置kernel.shmall = 4194304才符合要求(几乎是原来设置2097152的两倍)
