# acme-bot

一个运行于 Docker 容器中的，基于 acme.sh 的 SSL 证书自动更新和部署机器人。

## 为什么需要 acme-bot？

[acme.sh](https://github.com/acmesh-official/acme.sh) 是一个非常优秀的 ACME 协议客户端，它支持多种 DNS API 和多种 Web 服务器，可以自动申请和更新 SSL 证书。但是，acme.sh 虽然提供了官方的 Docker 镜像，但是此镜像并不能做到基于配置信息自动更新证书和部署证书。

acme-bot 是一个基于 acme.sh 官方 Docker 镜像的二次封装，它可以做到通过环境变量配置 acme.sh，告诉 acme.sh 你的域名和 DNS API 的信息，acme-bot 会自动申请和更新证书，并且可以自动部署证书到你指定的服务中。因此它特别适合运行在 Docker 容器中，作为一个独立的证书管理机器人。

## 如何使用 acme-bot？

acme-bot 的使用非常简单，只需要几个环境变量即可。下面是一个使用 acme-bot 的例子：

```bash
docker run -d \
  --name acme-bot \
  -e EMAIL="hello@example.com" \
  -e DOMAINS="dns_ali:example.com" \
  -e Ali_Key="your_ali_key" \
  -e Ali_Secret="your_ali_secret" \
  -v $PWD/acme:/acme.sh \
  joyqi/acme-bot
```

你也可以使用 ghcr.io 镜像 `ghcr.io/joyqi/acme-bot`。

我同样提供了一个 [docker-compose.yml](./docker-compose.yml) 文件，你可以直接使用 `docker-compose up -d` 来启动 acme-bot。当然，你需要修改 `docker-compose.yml` 文件中的环境变量。

## 环境变量

acme-bot 支持以下环境变量：

- `EMAIL`:（必须）你的邮箱地址，用于注册 acme.sh 账号。
- `DOMAINS`: （必须）你的域名和 DNS API 的信息，格式为 `dns_api:domain1,domain2,...[/deploy_hook]`。其中 `dns_api` 是你的 DNS API 的名称，具体支持的列表请参考 [acme.sh 的文档](https://github.com/acmesh-official/acme.sh/wiki/dnsapi)。`domain1,domain2,...` 是你的域名列表，用逗号分隔。`/deploy_hook` 是可选的，用于指定证书在发布/更新后的部署方法，具体支持的列表请参考 [acme.sh 的文档](https://github.com/acmesh-official/acme.sh/wiki/deployhooks)。
- `CA`: （可选）acme.sh 的 ACME 服务器，默认为 zerossl，你可以指定其它的 ACME 服务器，具体支持的列表请参考 [acme.sh 的文档](https://github.com/acmesh-official/acme.sh/wiki/Server)。
- `NOTIFY`: （可选）通知方式 `notify-hook`，你可以指定各种通知方式，具体支持的列表请参考 [acme.sh 的文档](https://github.com/acmesh-official/acme.sh/wiki/notify)。多个 `notify-hook` 用逗号分隔。

⚠️注意：以上配置信息中的 `dns_api`、`deploy_hook` 和 `notify-hook` 指定后都需要配置对应的环境变量，具体的环境变量请参考 [acme.sh 的文档](https://github.com/acmesh-official/acme.sh/wiki)。