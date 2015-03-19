@dir = "/usr/local/service/KaraokeSearch/"
@dir_log = "/usr/local/var/log/unicorn/"

worker_processes 1 # CPUのコア数に揃える
working_directory @dir

timeout 300
listen 80

pid "/tmp/pids/unicorn.pid" #pidを保存するファイル

# unicornは標準出力には何も吐かないのでログ出力を忘れずに
stderr_path "#{@dir_log}unicorn.stderr.log"
stdout_path "#{@dir_log}unicorn.stdout.log"
