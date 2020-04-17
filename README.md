# PopupTube

**PopupTube** is a pop-up video streaming solution.
Similar to a [pop-up retail store][popup-store], it is meant to be
temporarily deployed and then torn down.
The idea is to be able to concurrently watch a movie with your friends,
without everyone having to install specialized plugins or software.

## Summary

The operation of PopupTube can be summarized as:

- [Docker][docker] is used to launch a temporary
  [RTMP-enabled][nginx-rtmp] [nginx][nginx] web-server.
- [ffmpeg][ffmpeg] is used to send the streamed content to the web-server.
- Visitors can watch the content via either the web-player included
  with PopupTube, or using an external application like [VLC][vlc].

To run PopupTube, you will need a computer that can handle encoding the
content faster than it is consumed, and has enough juice left to also
serve it to visitors.
Plus, an internet connection that can handle the generated upstream
traffic to the visitors.
Being enrolled in a university is not mandatory, but it should
come handy in this case.

PopupTube uses json files for configuration.
The configuration files are used to "render" various template files
and produce the required html, application configurations and scripts.
The templates are written using the [Jinja][jinja] templating language
and rendered via [j2cli][j2cli].
[GNU Make][make] is used for automation. After the initial setup,
launching PopupTube only requires editing a couple of json files and
running make.

[docker]: https://docs.docker.com/get-docker/
[ffmpeg]: https://ffmpeg.org/
[j2cli]: https://github.com/m000/j2cli
[jinja]: https://jinja.palletsprojects.com/
[make]: https://www.gnu.org/software/make/
[nginx]: https://nginx.org/
[nginx-rtmp]: https://github.com/arut/nginx-rtmp-module/
[vlc]: https://www.videolan.org/vlc/

## Initial setup

### Docker image
Before begining, you'll need to [setup Docker][docker] and make sure
it works (not covered here).
Then, you'll need to fetch the [rtmp-hls docker image][dhub-img].
The source for the image is [available on github][github-img].

```bash
docker pull alqutami/rtmp-hls
```

[ffmpeg-dl]: https://johnvansickle.com/ffmpeg/
[dhub-img]: https://hub.docker.com/r/alqutami/rtmp-hls
[github-img]: https://github.com/TareqAlqutami/rtmp-hls-server

### HTTPs certificate
We will use a [Let's Encrypt][letsencrypt] certificate issued for
a dynamic DNS host. You can register a dynamic DNS host name e.g.
on [Duck DNS][duckdns]. You can use `ddupdate` to automatically
update the DNS name with your current IP address (not covered here).

Then, you create a certificate following these steps:

* Install `certbot` and run it in standalone mode:
  ```bash
  apt-get install certbot
  sudo certbot certonly --standalone
  ```
* Then copy the generated certificates to the local `certs` directory:
  ```bash
  sudo rsync -avLPh --chown=$(id -un):$(id -gn) /etc/letsencrypt/live/mydomain.duckdns.org/ ./nginx/certs/
  ```
* Finally generate [DH parameters][dh] (takes a while):
  ```bash
  openssl dhparam -out certs/dhparams.pem 4096
  ```

[letsencrypt]: https://letsencrypt.org/
[duckdns]: https://www.duckdns.org/
[dh]: https://security.stackexchange.com/questions/94390/whats-the-purpose-of-dh-parameters
[popup-store]: https://en.wikipedia.org/wiki/Pop-up_retail

### ffmpeg
Ubuntu typically ships with an outdated version of [ffmpeg][ffmpeg].
For this, it is recommended to download a recent
[static ffmpeg build][ffmpeg-dl] and extract `ffmpeg` and `ffprobe`
in the `bin` directory.

```bash
tar -Jxvf ffmpeg*-static.tar.xz -C ./bin --strip-components=1 --wildcards '*/ffmpeg' '*/ffprobe'
rm -f ffmpeg*-static.tar.xz
```

If you already have another ffmpeg version that you'd like to use,
just create appropriate symbolic links to `ffmpeg` and `ffprobe`
inside the `bin` directory.

### j2cli
It is recommended to setup [j2cli][j2cli] in a python virtual
environment.

```bash
virtualenv -p python3 pyenv
. ./pyenv/bin/activate
pip install -r requirements.txt
```





[ffmpeg-dl]: https://johnvansickle.com/ffmpeg/

## Additional resources
* https://github.com/arut/nginx-rtmp-module/wiki/Directives
* https://www.isrv.pw/html5-live-streaming-with-mpeg-dash
* https://docs.peer5.com/guides/setting-up-hls-live-streaming-server-using-nginx/
* https://www.bento4.com/developers/dash/subtitles/
* https://github.com/arut/nginx-rtmp-module/wiki/Directives#hls_sync

