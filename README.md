# gravity

Giraffe
gray

game index and markdown page

## 拓展接口

参考文章[给 Markdown 添加视频支持](https://blog.kaciras.com/article/18/add-video-support-to-markdown)。
在不创建指令的方式中，模仿GitLab Flavored Markdown。添加语法
1. `![audio: title](http://xxx)`
2. `![video: title](http://xxx)`
3. `![gif: title](http://xxx)`
4. `![button: title](http://xxx)`

## meta字段配置

html文件中配置meta字段markdown-root，具体如下。
```html
<meta name="markdown-root" content="page">
<meta name="markdown-url-root" content="/">
<meta name="markdown-img-root" content="/">
```

没有配置时，默认为“/”。

markdown-root用于配置markdown文件的根地址。配置为“page”后，markdown文件的访问路径为`http://xxx.com/page/yyy.md`

软件启动后，会访问"$markdown-root/index.md"文件。

markdown-url-root用于配置markdown中非http或https开头的链接的处理方式。具体查看下文。

markdown-img-root用于配置markdown中非http或https开头的图片链接的处理方式。具体查看下文。

## URL地址处理规则

对网络地址/相对路径/绝对路径，这3种情况进行区分。

### 对于markdown文件中的URL链接的处理。

#### URL地址以“http://”或者“https://”开头

- 作为普通链接处理，用户点击后，在新标签页打开。

#### URL地址以“.md”或者“.markdown”结尾

1. 不以“/”开头，将URL地址以当前的markdown文件计算相对路径，在当前页面重新加载URL。
2. 以“/”开头，将URL地址处理为“$markdown-root$URL”，在当前页面重新加载URL。

#### URL地址不以“.md”或者“.markdown”结尾

1. 不以“/”开头，将URL地址以当前的markdown文件计算相对路径，在新标签页打开。
2. 以“/”开头，将URL地址处理为“$markdown-url-root$URL”，在新标签页打开。

### 图片地址

其他拓展类型，也按下面规则处理。

#### URL地址以“http://”或者“https://”开头

- 作为普通链接处理。

#### 不以“/”开头

- 将URL地址以当前的markdown文件计算相对路径。

#### 以“/”开头

- 将URL地址处理为“$markdown-img-root$URL”

## 其他命令

1. 命令行编译Web：
   flutter build web --release --base-href=/gravity/

2. 修改hosts文件  
   windows上hosts文件路径为
   C:\Windows\System32\drivers\etc\hosts  
   刷新本地dns数据  
   ipconfig /flushdns