FROM neilpang/acme.sh

# install aliyun-cli
# see:
# [1] https://www.alibabacloud.com/help/en/alibaba-cloud-cli/latest/run-alibaba-cloud-cli-in-a-docker-container
# [2] https://github.com/aliyun/aliyun-cli
RUN apk add --no-cache bash \
    && ln -s /bin/uname /usr/bin/uname \
    && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/aliyun/aliyun-cli/HEAD/install.sh)" \
    && mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

