+++
date = '{{ .Date }}'
draft = true
title = '{{ replace .File.ContentBaseName "-" " " | title }}'
# 英文 slug，用于生成不带中文的 URL（如 docker-kubernetes-core-concepts），留空则回退为文件名
slug = ''
description = ''
categories = []
tags = []
+++
