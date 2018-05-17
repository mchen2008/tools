FILE_PATH="/home/user/local/bin/run-jupyter.pbs"

_grab_ip_old() {
  jobid=$1
  until cat /home/user/logs/jupyter-server.${jobid}.out 2>/dev/null | \
    grep -m 1 -oE "[0-9]+.[0-9]+.[0-9]+.[0-9]+:[0-9]{4}"; do sleep 1 ; done
}

_grab_ip() {
  jobid=$1
  port=$2
  hostname=$(qstat -f ${jobid} | grep -oP "exec_host = (\K[a-z0-9]+)")
  echo "http://${hostname}:${port}"
}

_submit_job() {
  port=$1
  jobid=$(qsub -q batch -v "PORT=$port" $FILE_PATH)
  echo $jobid
}

_submit_gpu_job() {
  port=$1
  jobid=$(qsub -q gpu -v "PORT=$port" $FILE_PATH)
  echo $jobid
}

jup() {
  port=$1
  if [[ -z "${port}" ]]; then
    port=8899
  fi
  jobid=$(_submit_job $port)
  echo "Launched Jupyter-Server to job: ${jobid}"
  jobid="${jobid%%.*}"
  echo -n "Waiting for ip address...  "
  sleep 5
  _grab_ip $jobid $port
}

jup-gpu() {
  port=$1
  if [[ -z "${port}" ]]; then
    port=8899
  fi
  jobid=$(_submit_gpu_job $port)
  echo "Launched Jupyter-Server to job: ${jobid}"
  jobid="${jobid%%.*}"
  echo -n "Waiting for ip address...  "
  sleep 5
  _grab_ip $jobid $port
}
