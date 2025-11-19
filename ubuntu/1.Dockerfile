FROM ubuntu:22.10



VOLUME [ "/sys/fs/cgroup" ]
EXPOSE 22
ENTRYPOINT [ "/lib/systemd/systemd" ]
